import sqlite3
import requests
import time

DB = "trotanalyser.db"
HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json"
}

BATCH_SIZE = 5000
SLEEP_SECONDS = 0.15


def ensure_log_table(conn):
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS sync_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_name TEXT,
        started_at TEXT,
        finished_at TEXT,
        rows_imported INTEGER,
        status TEXT,
        error_message TEXT
    )
    """)
    conn.commit()


def fetch_races_batch(conn, offset, limit):
    cur = conn.cursor()
    cur.execute("""
    SELECT id, date_course, reunion, course
    FROM races
    ORDER BY id
    LIMIT ? OFFSET ?
    """, (limit, offset))
    return cur.fetchall()


def race_already_imported(conn, race_id):
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM runners WHERE race_id = ? LIMIT 1", (race_id,))
    return cur.fetchone() is not None


def safe_get_participants(payload):
    if isinstance(payload, dict):
        participants = payload.get("participants")
        if isinstance(participants, list):
            return participants
    return []


def get_or_create_horse(cur, horse_name, sexe):
    cur.execute(
        "INSERT OR IGNORE INTO horses(nom, sexe) VALUES (?, ?)",
        (horse_name, sexe)
    )
    cur.execute("SELECT id FROM horses WHERE nom = ?", (horse_name,))
    row = cur.fetchone()
    return row[0] if row else None


def get_or_create_driver(cur, driver_name):
    if not driver_name:
        return None
    cur.execute("INSERT OR IGNORE INTO drivers(nom) VALUES (?)", (driver_name,))
    cur.execute("SELECT id FROM drivers WHERE nom = ?", (driver_name,))
    row = cur.fetchone()
    return row[0] if row else None


def get_or_create_trainer(cur, trainer_name):
    if not trainer_name:
        return None
    cur.execute("INSERT OR IGNORE INTO trainers(nom) VALUES (?)", (trainer_name,))
    cur.execute("SELECT id FROM trainers WHERE nom = ?", (trainer_name,))
    row = cur.fetchone()
    return row[0] if row else None


def import_race(conn, race_id, date_course, reunion, course):
    if race_already_imported(conn, race_id):
        return "SKIP_ALREADY", 0

    date_api = (date_course or "").replace("/", "").replace("-", "")
    reunion = reunion or ""
    course = course or ""

    if not date_api or not reunion.startswith("R") or not course.startswith("C"):
        return "SKIP_BAD_RACE_KEYS", 0

    url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/programme/{date_api}/{reunion}/{course}/participants"

    try:
        resp = requests.get(url, headers=HEADERS, timeout=20)
    except Exception:
        return "ERROR_HTTP", 0

    if resp.status_code != 200:
        return f"SKIP_HTTP_{resp.status_code}", 0

    try:
        data = resp.json()
    except Exception:
        return "ERROR_JSON", 0

    participants = safe_get_participants(data)
    if not participants:
        return "SKIP_NO_PARTICIPANTS", 0

    cur = conn.cursor()
    inserted = 0

    for p in participants:
        horse = p.get("nom")
        if not horse:
            continue

        num = p.get("numPmu")
        age = p.get("age")
        sexe = p.get("sexe")
        driver = p.get("driver")
        trainer = p.get("entraineur")
        musique = p.get("musique")
        ferrure = p.get("ferrure") or p.get("ferrureLibelle") or p.get("indicateurFerrure")

        horse_id = get_or_create_horse(cur, horse, sexe)
        driver_id = get_or_create_driver(cur, driver)
        trainer_id = get_or_create_trainer(cur, trainer)

        if horse_id is None:
            continue

        cur.execute("""
        INSERT OR IGNORE INTO runners(
            race_id,
            horse_id,
            driver_id,
            trainer_id,
            num_pmu,
            age,
            musique,
            ferrure
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            race_id,
            horse_id,
            driver_id,
            trainer_id,
            num,
            age,
            musique,
            ferrure
        ))

        if cur.rowcount:
            inserted += 1

    conn.commit()

    if inserted == 0:
        return "SKIP_ZERO_INSERT", 0

    return "OK", inserted


def main():
    conn = sqlite3.connect(DB)
    ensure_log_table(conn)

    total_inserted = 0
    total_ok = 0
    total_skip = 0
    total_error = 0
    offset = 0

    while True:
        races = fetch_races_batch(conn, offset, BATCH_SIZE)
        if not races:
            break

        print(f"LOT offset={offset} taille={len(races)}")

        for race_id, date_course, reunion, course in races:
            status, inserted = import_race(conn, race_id, date_course, reunion, course)

            if status == "OK":
                total_ok += 1
                total_inserted += inserted
                print(f"OK race {race_id} -> {inserted} partants")
            elif status.startswith("SKIP"):
                total_skip += 1
                print(f"{status} race {race_id}")
            else:
                total_error += 1
                print(f"{status} race {race_id}")

            time.sleep(SLEEP_SECONDS)

        offset += BATCH_SIZE

    print("IMPORT TERMINE")
    print("COURSES OK =", total_ok)
    print("COURSES SKIP =", total_skip)
    print("COURSES ERROR =", total_error)
    print("RUNNERS INSERTES =", total_inserted)

    conn.close()


if __name__ == "__main__":
    main()

import sqlite3
import requests
from concurrent.futures import ThreadPoolExecutor

DB = "trotanalyser.db"

conn = sqlite3.connect(DB)
cur = conn.cursor()

cur.execute("SELECT id, date_course, reunion, course FROM races")
races = cur.fetchall()

conn.close()

HEADERS = {"User-Agent": "Mozilla/5.0"}

def process(row):
    race_id, date_course, reunion, course = row

    if not date_course or not reunion or not course:
        return

    date_api = str(date_course).replace("/", "").replace("-", "")
    url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/programme/{date_api}/{reunion}/{course}/participants"

    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
        if resp.status_code != 200:
            return

        data = resp.json()
        participants = data.get("participants")

        if not participants:
            return

        conn = sqlite3.connect(DB)
        cur = conn.cursor()

        for p in participants:
            horse = p.get("nom")
            if not horse:
                continue

            driver = p.get("driver")
            trainer = p.get("entraineur")

            cur.execute("INSERT OR IGNORE INTO horses(nom) VALUES (?)", (horse,))
            cur.execute("SELECT id FROM horses WHERE nom = ?", (horse,))
            horse_id = cur.fetchone()[0]

            if driver:
                cur.execute("INSERT OR IGNORE INTO drivers(nom) VALUES (?)", (driver,))
                cur.execute("SELECT id FROM drivers WHERE nom = ?", (driver,))
                row_driver = cur.fetchone()
                driver_id = row_driver[0] if row_driver else None
            else:
                driver_id = None

            if trainer:
                cur.execute("INSERT OR IGNORE INTO trainers(nom) VALUES (?)", (trainer,))
                cur.execute("SELECT id FROM trainers WHERE nom = ?", (trainer,))
                row_trainer = cur.fetchone()
                trainer_id = row_trainer[0] if row_trainer else None
            else:
                trainer_id = None

            cur.execute("""
                INSERT OR IGNORE INTO runners(
                    race_id,
                    horse_id,
                    driver_id,
                    trainer_id,
                    num_pmu,
                    age,
                    musique
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                race_id,
                horse_id,
                driver_id,
                trainer_id,
                p.get("numPmu"),
                p.get("age"),
                p.get("musique")
            ))

        conn.commit()
        conn.close()

        print("OK", race_id)

    except Exception:
        return

with ThreadPoolExecutor(max_workers=12) as exe:
    list(exe.map(process, races))

print("IMPORT TERMINE")

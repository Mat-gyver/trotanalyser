import requests
import sqlite3
import sys

DB = "trotanalyser.db"
API = "https://open-pmu-api.vercel.app/api/arrivees"

def main(date):
    conn = sqlite3.connect(DB)
    cur = conn.cursor()

    r = requests.get(API, params={"date": date}, timeout=60)
    r.raise_for_status()
    data = r.json()

    if isinstance(data, dict) and "message" in data:
        races = data["message"]
    else:
        races = data

    inserted = 0

    for race in races:
        if not isinstance(race, dict):
            continue

        rc = str(race.get("r/c", ""))
        reunion = None
        course = None

        if "C" in rc:
            parts = rc.split("C", 1)
            reunion = parts[0]
            course = "C" + parts[1]

        cur.execute("""
        INSERT INTO historical_races
        (date_course, hippo, reunion, course, prix, discipline, distance, montant, nb_partants, non_partants, arrivee, details)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        """, (
            race.get("date"),
            race.get("lieu"),
            reunion,
            course,
            race.get("prix"),
            race.get("type"),
            race.get("distance"),
            str(race.get("montant")),
            race.get("partants"),
            str(race.get("non_partants")),
            str(race.get("arrivee")),
            race.get("details")
        ))

        inserted += 1

    conn.commit()
    conn.close()

    print(f"{inserted} courses importées pour {date}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 open_pmu/import_open_pmu_history.py JJ/MM/AAAA")
        sys.exit(1)
    main(sys.argv[1])

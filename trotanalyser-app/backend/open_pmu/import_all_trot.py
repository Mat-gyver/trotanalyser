import requests
import sqlite3
import sys
from datetime import datetime, timedelta

DB = "trotanalyser.db"

def daterange(start, end):
    start = datetime.strptime(start, "%d/%m/%Y")
    end = datetime.strptime(end, "%d/%m/%Y")
    d = start
    while d <= end:
        yield d.strftime("%d%m%Y"), d.strftime("%d/%m/%Y")
        d += timedelta(days=1)

def ensure_table(conn):
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS historical_races(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_course TEXT,
        hippo TEXT,
        reunion TEXT,
        course TEXT,
        discipline TEXT,
        specialite TEXT,
        libelle TEXT
    )
    """)
    conn.commit()

def is_trot(course):
    discipline = (course.get("discipline") or "").upper()
    specialite = (course.get("specialite") or "").upper()
    return ("TROT" in discipline) or ("TROT" in specialite)

def import_day(conn, day_api, day_fr):
    url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/programme/{day_api}"
    r = requests.get(url, timeout=30)

    if r.status_code != 200:
        return 0

    data = r.json()
    cur = conn.cursor()
    total = 0

    for reunion in data["programme"]["reunions"]:
        hippo_data = reunion.get("hippodrome", {})
        if isinstance(hippo_data, dict):
            hippo = hippo_data.get("libelleCourt") or hippo_data.get("libelleLong") or ""
        else:
            hippo = str(hippo_data or "")

        num_reu = reunion.get("numOfficiel", 0)

        for course in reunion.get("courses", []):
            if not is_trot(course):
                continue

            num_course = course.get("numOrdre", 0)
            discipline = course.get("discipline") or ""
            specialite = course.get("specialite") or ""
            libelle = course.get("libelle") or ""

            cur.execute("""
            INSERT INTO historical_races(
                date_course, hippo, reunion, course, discipline, specialite, libelle
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                day_fr,
                hippo,
                f"R{num_reu}",
                f"C{num_course}",
                discipline,
                specialite,
                libelle
            ))

            total += 1

    conn.commit()
    return total

def main(start, end):
    conn = sqlite3.connect(DB)
    ensure_table(conn)

    total = 0

    for day_api, day_fr in daterange(start, end):
        n = import_day(conn, day_api, day_fr)
        total += n
        print(day_fr, "->", n, "courses trot")

    print("TOTAL =", total)
    conn.close()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("usage: python3 import_all_trot.py JJ/MM/AAAA JJ/MM/AAAA")
        sys.exit()

    main(sys.argv[1], sys.argv[2])

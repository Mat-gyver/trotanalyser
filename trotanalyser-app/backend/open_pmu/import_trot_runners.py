import json
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
    CREATE TABLE IF NOT EXISTS historical_runners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_course TEXT,
        hippo TEXT,
        reunion TEXT,
        course TEXT,
        num_pmu INTEGER,
        cheval TEXT,
        age INTEGER,
        sexe TEXT,
        driver TEXT,
        entraineur TEXT,
        musique TEXT,
        ferrure TEXT,
        place_arrivee INTEGER,
        raw_json TEXT
    )
    """)
    cur.execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS idx_runners_unique
    ON historical_runners(date_course, hippo, reunion, course, num_pmu, cheval)
    """)
    conn.commit()


def is_trot(course):
    discipline = (course.get("discipline") or "").upper()
    specialite = (course.get("specialite") or "").upper()
    return ("TROT" in discipline) or ("TROT" in specialite)


def walk(obj):
    if isinstance(obj, dict):
        yield obj
        for v in obj.values():
            yield from walk(v)
    elif isinstance(obj, list):
        yield obj
        for item in obj:
            yield from walk(item)


def pick_name(value):
    if isinstance(value, dict):
        return (
            value.get("nom")
            or value.get("name")
            or value.get("libelle")
            or value.get("libelleCourt")
            or value.get("libelleLong")
        )
    return value


def to_int(value):
    try:
        if value is None or value == "":
            return None
        return int(value)
    except Exception:
        return None


def score_participant_dict(d):
    if not isinstance(d, dict):
        return 0
    score = 0
    for key in ["nom", "numPmu", "age", "sexe", "driver", "entraineur", "musique", "ferrure"]:
        if key in d:
            score += 2
    for key in ["cheval", "jockey", "proprietaire", "dernieresPerformances"]:
        if key in d:
            score += 1
    return score


def find_participants(data):
    best = []
    best_score = -1

    for node in walk(data):
        if isinstance(node, list) and node and all(isinstance(x, dict) for x in node):
            scores = [score_participant_dict(x) for x in node]
            avg_score = sum(scores) / len(scores)
            max_score = max(scores)
            total_score = avg_score + max_score + min(len(node), 30) / 10.0

            if max_score >= 4 and total_score > best_score:
                best = node
                best_score = total_score

    return best


def find_arrival_order(data):
    for node in walk(data):
        if isinstance(node, dict):
            val = node.get("ordreArrivee")
            if isinstance(val, list) and val:
                return val
    return None


def get_place(arrival_order, num_pmu):
    if not arrival_order or num_pmu is None:
        return None
    try:
        return arrival_order.index(num_pmu) + 1
    except ValueError:
        return None


def import_day(conn, day_api, day_fr):
    programme_url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/programme/{day_api}"
    r = requests.get(programme_url, timeout=30)
    if r.status_code != 200:
        return 0

    data = r.json()
    total = 0
    cur = conn.cursor()

    for reunion in data["programme"]["reunions"]:
        hippo = reunion["hippodrome"]["libelleCourt"]
        R = reunion["numOfficiel"]

        for course in reunion["courses"]:
            if not is_trot(course):
                continue

            C = course["numOrdre"]
            course_url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/course/{day_api}/R{R}/C{C}"
            cr = requests.get(course_url, timeout=30)
            if cr.status_code != 200:
                continue

            course_data = cr.json()
            participants = find_participants(course_data)
            arrival_order = find_arrival_order(course_data)

            for p in participants:
                num = to_int(p.get("numPmu") or p.get("numero") or p.get("numCheval"))
                cheval = (
                    p.get("nom")
                    or pick_name(p.get("cheval"))
                    or p.get("nomCheval")
                )
                age = to_int(p.get("age"))
                sexe = p.get("sexe")
                driver = pick_name(p.get("driver") or p.get("jockey"))
                entraineur = pick_name(p.get("entraineur") or p.get("trainer"))
                musique = p.get("musique") or p.get("musiqueRecente")
                ferrure = (
                    p.get("ferrure")
                    or p.get("indicateurFerrure")
                    or p.get("ferrureLibelle")
                )
                place = get_place(arrival_order, num)

                if not cheval and num is None:
                    continue

                cur.execute("""
                INSERT OR IGNORE INTO historical_runners
                (date_course, hippo, reunion, course, num_pmu, cheval, age, sexe, driver, entraineur, musique, ferrure, place_arrivee, raw_json)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    day_fr,
                    hippo,
                    f"R{R}",
                    f"C{C}",
                    num,
                    cheval,
                    age,
                    sexe,
                    driver,
                    entraineur,
                    musique,
                    ferrure,
                    place,
                    json.dumps(p, ensure_ascii=False)
                ))

                if cur.rowcount:
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
        print(day_fr, "->", n, "partants")

    print("TOTAL RUNNERS =", total)
    conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("usage: python3 import_trot_runners.py JJ/MM/AAAA JJ/MM/AAAA")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])

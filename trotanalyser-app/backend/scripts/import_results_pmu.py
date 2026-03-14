import sys
from pathlib import Path

# Permet d'importer les modules du dossier backend
BASE_DIR = Path(__file__).resolve().parents[1]
if str(BASE_DIR) not in sys.path:
    sys.path.append(str(BASE_DIR))

from context import extract_hippodrome_label
from pmu_client import get_arrivee_definitive, get_programme_by_date, iter_last_days
from stats_db import init_db, insert_race_result


def safe_int(value, default=None):
    try:
        if value is None or value == "":
            return default
        return int(float(value))
    except Exception:
        return default


def format_sql_date(day_str: str) -> str:
    # "15032026" -> "2026-03-15"
    return f"{day_str[4:8]}-{day_str[2:4]}-{day_str[0:2]}"


def extract_arrival_participants(result_data: dict) -> list:
    return (
        result_data.get("participants")
        or result_data.get("partants")
        or result_data.get("arrivee")
        or []
    )


def extract_position(participant: dict):
    return (
        safe_int(participant.get("rang"))
        or safe_int(participant.get("place"))
        or safe_int(participant.get("position"))
        or safe_int(participant.get("ordreArrivee"))
    )


def import_one_day(day_str: str) -> dict:
    inserted = 0
    scanned_races = 0
    errors = 0

    try:
        programme_data = get_programme_by_date(day_str)
    except Exception:
        return {
            "date": day_str,
            "inserted": 0,
            "scannedRaces": 0,
            "errors": 1,
        }

    reunions = programme_data.get("reunions", [])

    for reunion_data in reunions:
        reunion_code = f"R{reunion_data.get('numOfficiel')}"
        hippodrome = extract_hippodrome_label(reunion_data.get("hippodrome"))

        for course_data in reunion_data.get("courses", []):
            course_code = f"C{course_data.get('numOrdre')}"
            distance = safe_int(course_data.get("distance"))
            scanned_races += 1

            try:
                result_data = get_arrivee_definitive(day_str, reunion_code, course_code)
            except Exception:
                errors += 1
                continue

            participants = extract_arrival_participants(result_data)

            if not participants:
                continue

            for p in participants:
                position = extract_position(p)

                driver = p.get("driver") or p.get("jockey")
                entraineur = p.get("entraineur") or p.get("trainer")

                try:
                    insert_race_result(
                        race_date=format_sql_date(day_str),
                        reunion=reunion_code,
                        course=course_code,
                        hippodrome=hippodrome,
                        distance=distance,
                        cheval=p.get("nom"),
                        numero=safe_int(p.get("numPmu")),
                        driver=driver,
                        entraineur=entraineur,
                        position=position,
                        allocation=None,
                    )
                    inserted += 1
                except Exception:
                    errors += 1

    return {
        "date": day_str,
        "inserted": inserted,
        "scannedRaces": scanned_races,
        "errors": errors,
    }


def import_last_days(days: int = 7) -> dict:
    init_db()

    total_inserted = 0
    total_races = 0
    total_errors = 0
    details = []

    for day_str in iter_last_days(days):
        result = import_one_day(day_str)
        details.append(result)
        total_inserted += result["inserted"]
        total_races += result["scannedRaces"]
        total_errors += result["errors"]

    return {
        "days": days,
        "totalInserted": total_inserted,
        "totalScannedRaces": total_races,
        "totalErrors": total_errors,
        "details": details,
    }


def main():
    result = import_last_days(365)
    print(result)


if __name__ == "__main__":
    main()

import sys
from pathlib import Path

# permet d'importer les modules du dossier backend
BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(BASE_DIR))

from pmu_client import pmu, iter_last_days
from stats_db import init_db, insert_race_result
from context import extract_hippodrome_label


def safe_int(value, default=None):
    try:
        if value is None or value == "":
            return default
        return int(float(value))
    except Exception:
        return default


def import_one_day(day_str):
    inserted = 0

    try:
        data = pmu(day_str)
    except Exception:
        return 0

    programme = data.get("programme", {})
    reunions = programme.get("reunions", [])

    for reunion_data in reunions:
        reunion_code = f"R{reunion_data.get('numOfficiel')}"
        hippodrome = extract_hippodrome_label(reunion_data.get("hippodrome"))

        for course_data in reunion_data.get("courses", []):
            course_code = f"C{course_data.get('numOrdre')}"
            distance = course_data.get("distance")

            # tentative de récupération des résultats
            try:
                result_data = pmu(f"{day_str}/{reunion_code}/{course_code}/arrivee-definitive")
            except Exception:
                continue

            participants = (
                result_data.get("participants")
                or result_data.get("partants")
                or []
            )

            for p in participants:
                position = (
                    p.get("rang")
                    or p.get("place")
                    or p.get("position")
                    or p.get("ordreArrivee")
                )

                driver = p.get("driver") or p.get("jockey")
                entraineur = p.get("entraineur") or p.get("trainer")

                insert_race_result(
                    race_date=f"{day_str[4:8]}-{day_str[2:4]}-{day_str[0:2]}",
                    reunion=reunion_code,
                    course=course_code,
                    hippodrome=hippodrome,
                    distance=safe_int(distance),
                    cheval=p.get("nom"),
                    numero=safe_int(p.get("numPmu")),
                    driver=driver,
                    entraineur=entraineur,
                    position=safe_int(position),
                    allocation=None,
                )
                inserted += 1

    return inserted


def main():
    init_db()

    total = 0
    for day_str in iter_last_days(365):
        count = import_one_day(day_str)
        total += count
        print(f"{day_str}: {count} lignes importées")

    print(f"\nImport terminé : {total} lignes")


if __name__ == "__main__":
    main()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pmu_client import today, get_programme_today, get_participants
from context import extract_course_context, find_reunion_and_course, extract_hippodrome_label
from scoring import base_score_musique, regularite_index, indice_forme_trot
from badges import badges_turf
from synthesis import build_course_synthesis
from stats_db import init_db
from stats_engine import (
    get_driver_stats_12m,
    get_trainer_stats_12m,
    get_driver_stats_30d,
    get_trainer_stats_30d,
)
from scripts.import_results_pmu import import_last_days

app = FastAPI()

init_db()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/api/admin/import-results")
def import_results(days: int = 7):
    return import_last_days(days)


@app.get("/api/programme/today")
def programme_today():
    programme_data = get_programme_today()
    reunions = []

    for reunion_data in programme_data.get("reunions", []):
        reunion_code = f"R{reunion_data.get('numOfficiel')}"
        hippodrome = extract_hippodrome_label(reunion_data.get("hippodrome"))

        courses = []
        for course_data in reunion_data.get("courses", []):
            courses.append(
                {
                    "valueMax": 0,
                    "reunion": reunion_code,
                    "course": f"C{course_data.get('numOrdre')}",
                    "titre": f"{reunion_code} C{course_data.get('numOrdre')} - {course_data.get('libelle', '')}",
                    "distance": course_data.get("distance"),
                    "partants": course_data.get("nombreDeclaresPartants"),
                }
            )

        reunions.append(
            {
                "reunion": reunion_code,
                "hippodrome": hippodrome,
                "courses": courses,
            }
        )

    return {
        "date": today(),
        "reunions": reunions,
    }


@app.get("/api/course/{reunion}/{course}")
def course(reunion: str, course: str):
    day_str = today()

    participants_data = get_participants(day_str, reunion, course)

    programme_data = get_programme_today()
    reunion_data, course_data = find_reunion_and_course(programme_data, reunion, course)

    context = extract_course_context(
        participants_data=participants_data,
        reunion_data=reunion_data,
        course_data=course_data,
    )

    participants = participants_data.get("participants", [])
    chevaux = []

    for p in participants:
        driver_stats_12m = get_driver_stats_12m(p.get("driver"))
        trainer_stats_12m = get_trainer_stats_12m(p.get("entraineur"))
        driver_stats_30d = get_driver_stats_30d(p.get("driver"))
        trainer_stats_30d = get_trainer_stats_30d(p.get("entraineur"))

        cheval = {
            "numero": p.get("numPmu"),
            "nom": p.get("nom"),
            "driver": p.get("driver"),
            "entraineur": p.get("entraineur"),
            "musique": p.get("musique"),
            "ferrure": p.get("ferrure") or p.get("deferre") or "NR",
            "corde": p.get("placeCorde"),
            "age": p.get("age"),
            "gains": p.get("gains"),
            "sexe": p.get("sexe"),
            "driverStats12m": driver_stats_12m,
            "trainerStats12m": trainer_stats_12m,
            "driverStats30d": driver_stats_30d,
            "trainerStats30d": trainer_stats_30d,
            "driverIndex12m": driver_stats_12m["index12m"],
            "trainerIndex12m": trainer_stats_12m["index12m"],
            "driverForm30j": driver_stats_30d["index30d"],
            "trainerForm30j": trainer_stats_30d["index30d"],
        }

        cheval["scoreIA"] = base_score_musique(cheval.get("musique"))
        cheval["regulariteIndex"] = regularite_index(cheval.get("musique"))
        cheval["indiceFormeTrot"] = indice_forme_trot(cheval, context.get("distance"))

        # intégration légère de la forme récente
        cheval["scoreIA"] = round(
            cheval["scoreIA"]
            + (cheval["driverForm30j"] * 0.15)
            + (cheval["trainerForm30j"] * 0.12),
            2,
        )

        chevaux.append(chevaux := cheval)

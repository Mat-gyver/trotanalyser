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
    get_stable_heat_30d,
    get_driver_distance_stats_12m,
    get_trainer_distance_stats_12m,
    get_driver_track_stats_12m,
    get_trainer_track_stats_12m,
    get_driver_start_stats_12m,
    get_trainer_start_stats_12m,
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


def extract_start_type(course_data, participants_data):
    txt = " ".join(
        [
            str(course_data.get("libelle", "") or ""),
            str(course_data.get("categorieParticularite", "") or ""),
            str(course_data.get("typeDepart", "") or ""),
            str(course_data.get("modeDepart", "") or ""),
            str(participants_data.get("typeDepart", "") or ""),
            str(participants_data.get("modeDepart", "") or ""),
        ]
    ).upper()

    if "AUTO" in txt or "AUTOSTART" in txt:
        return "autostart"

    if "VOLTE" in txt or "VOLTÉ" in txt:
        return "volte"

    return "unknown"


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

    start_type = extract_start_type(course_data or {}, participants_data or {})

    participants = participants_data.get("participants", [])
    chevaux = []

    for p in participants:
        driver_stats_12m = get_driver_stats_12m(p.get("driver"))
        trainer_stats_12m = get_trainer_stats_12m(p.get("entraineur"))
        driver_stats_30d = get_driver_stats_30d(p.get("driver"))
        trainer_stats_30d = get_trainer_stats_30d(p.get("entraineur"))
        stable_heat_30d = get_stable_heat_30d(p.get("entraineur"))
        driver_distance_stats = get_driver_distance_stats_12m(
            p.get("driver"),
            context.get("distance"),
        )
        trainer_distance_stats = get_trainer_distance_stats_12m(
            p.get("entraineur"),
            context.get("distance"),
        )
        driver_track_stats = get_driver_track_stats_12m(
            p.get("driver"),
            context.get("hippodrome"),
        )
        trainer_track_stats = get_trainer_track_stats_12m(
            p.get("entraineur"),
            context.get("hippodrome"),
        )
        driver_start_stats = get_driver_start_stats_12m(
            p.get("driver"),
            start_type,
        )
        trainer_start_stats = get_trainer_start_stats_12m(
            p.get("entraineur"),
            start_type,
        )

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
            "stableHeat30d": stable_heat_30d,
            "driverDistanceStats12m": driver_distance_stats,
            "trainerDistanceStats12m": trainer_distance_stats,
            "driverTrackStats12m": driver_track_stats,
            "trainerTrackStats12m": trainer_track_stats,
            "driverStartStats12m": driver_start_stats,
            "trainerStartStats12m": trainer_start_stats,
            "driverIndex12m": driver_stats_12m["index12m"],
            "trainerIndex12m": trainer_stats_12m["index12m"],
            "driverForm30j": driver_stats_30d["index30d"],
            "trainerForm30j": trainer_stats_30d["index30d"],
            "stableHeatIndex30j": stable_heat_30d["index30d"],
            "stableHeatLabel30j": stable_heat_30d["label"],
            "driverDistanceIndex": driver_distance_stats["indexDistance"],
            "trainerDistanceIndex": trainer_distance_stats["indexDistance"],
            "driverTrackIndex": driver_track_stats["indexTrack"],
            "trainerTrackIndex": trainer_track_stats["indexTrack"],
            "driverStartIndex": driver_start_stats["indexStart"],
            "trainerStartIndex": trainer_start_stats["indexStart"],
            "distanceBucket": driver_distance_stats["distanceBucket"],
            "startType": start_type,
        }

        cheval["scoreIA"] = base_score_musique(cheval.get("musique"))
        cheval["regulariteIndex"] = regularite_index(cheval.get("musique"))
        cheval["indiceFormeTrot"] = indice_forme_trot(cheval, context.get("distance"))

        cheval["scoreIA"] = round(
            cheval["scoreIA"]
            + (cheval["driverForm30j"] * 0.15)
            + (cheval["trainerForm30j"] * 0.12)
            + (cheval["stableHeatIndex30j"] * 0.10)
            + (cheval["driverDistanceIndex"] * 0.10)
            + (cheval["trainerDistanceIndex"] * 0.08)
            + (cheval["driverTrackIndex"] * 0.10)
            + (cheval["trainerTrackIndex"] * 0.08)
            + (cheval["driverStartIndex"] * 0.10)
            + (cheval["trainerStartIndex"] * 0.08),
            2,
        )

        chevaux.append(cheval)

    chevaux = sorted(
        chevaux,
        key=lambda x: (
            x.get("scoreIA", 0),
            x.get("indiceFormeTrot", 0),
            x.get("driverForm30j", 0),
            x.get("trainerForm30j", 0),
            x.get("stableHeatIndex30j", 0),
            x.get("driverDistanceIndex", 0),
            x.get("trainerDistanceIndex", 0),
            x.get("driverTrackIndex", 0),
            x.get("trainerTrackIndex", 0),
            x.get("driverStartIndex", 0),
            x.get("trainerStartIndex", 0),
            x.get("driverIndex12m", 0),
            x.get("trainerIndex12m", 0),
        ),
        reverse=True,
    )

    for i, cheval in enumerate(chevaux):
        cheval["rankIA"] = i + 1
        cheval["badges"] = badges_turf(cheval)

    return {
        "reunion": reunion,
        "course": course,
        "hippodrome": context.get("hippodrome"),
        "distance": context.get("distance"),
        "meteo": context.get("meteo"),
        "temperature": context.get("temperature"),
        "vent": context.get("vent"),
        "souplesse": context.get("souplesse"),
        "startType": start_type,
        "partants": len(chevaux),
        "participants": chevaux,
        "synthesis": build_course_synthesis(chevaux),
    }


@app.get("/api/stats/driver/{name}")
def stats_driver(
    name: str,
    distance: int | None = None,
    hippodrome: str | None = None,
    start_type: str | None = None,
):
    payload = {
        "stats12m": get_driver_stats_12m(name),
        "stats30d": get_driver_stats_30d(name),
    }

    if distance is not None:
        payload["distanceStats12m"] = get_driver_distance_stats_12m(name, distance)

    if hippodrome is not None:
        payload["trackStats12m"] = get_driver_track_stats_12m(name, hippodrome)

    if start_type is not None:
        payload["startStats12m"] = get_driver_start_stats_12m(name, start_type)

    return payload


@app.get("/api/stats/trainer/{name}")
def stats_trainer(
    name: str,
    distance: int | None = None,
    hippodrome: str | None = None,
    start_type: str | None = None,
):
    payload = {
        "stats12m": get_trainer_stats_12m(name),
        "stats30d": get_trainer_stats_30d(name),
        "stableHeat30d": get_stable_heat_30d(name),
    }

    if distance is not None:
        payload["distanceStats12m"] = get_trainer_distance_stats_12m(name, distance)

    if hippodrome is not None:
        payload["trackStats12m"] = get_trainer_track_stats_12m(name, hippodrome)

    if start_type is not None:
        payload["startStats12m"] = get_trainer_start_stats_12m(name, start_type)

    return payload

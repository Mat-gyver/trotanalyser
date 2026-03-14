from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pmu_client import pmu, today, get_programme_today
from context import extract_course_context, find_reunion_and_course
from scoring import base_score_musique, regularite_index, indice_forme_trot
from badges import badges_turf
from synthesis import build_course_synthesis

app = FastAPI()

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


@app.get("/api/course/{reunion}/{course}")
def course(reunion: str, course: str):

    d = today()
    r = reunion.replace("R", "")
    c = course.replace("C", "")

    participants_data = pmu(f"{d}/R{r}/C{c}/participants")

    programme = get_programme_today()
    reunion_data, course_data = find_reunion_and_course(programme, reunion, course)

    context = extract_course_context(participants_data, reunion_data, course_data)

    participants = participants_data.get("participants", [])

    chevaux = []

    for p in participants:

        cheval = {
            "numero": p.get("numPmu"),
            "nom": p.get("nom"),
            "driver": p.get("driver"),
            "entraineur": p.get("entraineur"),
            "musique": p.get("musique"),
            "ferrure": p.get("ferrure"),
        }

        cheval["scoreIA"] = base_score_musique(cheval["musique"])
        cheval["regulariteIndex"] = regularite_index(cheval["musique"])
        cheval["indiceFormeTrot"] = indice_forme_trot(cheval, context["distance"])

        chevaux.append(cheval)

    chevaux = sorted(chevaux, key=lambda x: x["scoreIA"], reverse=True)

    for i, cheval in enumerate(chevaux):

        cheval["rankIA"] = i + 1
        cheval["badges"] = badges_turf(cheval)

    return {
        "reunion": reunion,
        "course": course,
        "hippodrome": context["hippodrome"],
        "distance": context["distance"],
        "participants": chevaux,
        "synthesis": build_course_synthesis(chevaux),
    }

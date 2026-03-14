from datetime import datetime
import requests

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


PMU_BASE = "https://offline.turfinfo.api.pmu.fr/rest/client/7/programme"


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --------------------------------------------------
# OUTILS
# --------------------------------------------------


def today():
    return datetime.now().strftime("%d%m%Y")


def pmu(path):
    url = f"{PMU_BASE}/{path}"
    headers = {"User-Agent": "Mozilla/5.0"}

    response = requests.get(url, headers=headers, timeout=15)
    response.raise_for_status()

    return response.json()


# --------------------------------------------------
# SCORE FORME
# --------------------------------------------------


def score(musique):

    if not musique:
        return 0

    total = 0

    for char in str(musique)[:8]:

        if char == "1":
            total += 10
        elif char == "2":
            total += 8
        elif char == "3":
            total += 6
        elif char == "4":
            total += 4
        elif char == "5":
            total += 2
        elif char.lower() == "d":
            total -= 5

    return max(0, total)


# --------------------------------------------------
# NOUVEL INDICE REGULARITE
# --------------------------------------------------


def regularite_index(musique):

    if not musique:
        return 0

    bonnes = 0
    fautes = 0

    for char in str(musique)[:8]:

        if char in ["1", "2", "3", "4", "5"]:
            bonnes += 1

        if char.lower() in ["d", "a"]:
            fautes += 1

    score = bonnes - fautes

    if score >= 4:
        return 8

    if score >= 2:
        return 5

    if score >= 0:
        return 2

    return 0


# --------------------------------------------------
# INDICES DRIVER / TRAINER
# --------------------------------------------------


def driver_index(driver):

    if not driver:
        return 0

    d = str(driver).upper()

    elite = [
        "RAFFIN",
        "ABRIVARD",
        "BAZIRE",
        "THOMAIN",
        "NIVARD",
        "GOOP",
        "ROCHARD",
        "LAGADEUC",
        "PLOQUIN",
    ]

    solide = ["MOTTIER", "DUBOIS", "COLLETTE", "LEBOURGEOIS", "MARTENS"]

    if any(x in d for x in elite):
        return 8

    if any(x in d for x in solide):
        return 4

    return 1


def trainer_index(entraineur):

    if not entraineur:
        return 0

    e = str(entraineur).upper()

    elite = ["BAZIRE", "ABRIVARD", "MARMION", "DUVALDESTIN", "ALLAIRE"]

    if any(x in e for x in elite):
        return 8

    return 2


# --------------------------------------------------
# RETARD DE GAINS
# --------------------------------------------------


def retard_gains_index(age, gains, score_ia):

    try:
        age_n = int(age)
    except:
        age_n = 0

    try:
        g = float(str(gains).replace(" ", "").replace(",", "."))
    except:
        g = 0

    if age_n <= 0:
        return 0

    ratio = g / max(age_n, 1)

    if score_ia >= 20 and ratio < 20000:
        return 8

    if score_ia >= 12 and ratio < 30000:
        return 5

    if score_ia >= 6 and ratio < 45000:
        return 2

    return 0


# --------------------------------------------------
# PROBABILITES IA
# --------------------------------------------------


def probabilite_from_score(score_ia, total_score):

    if total_score <= 0:
        return 1

    return max(1, round((score_ia / total_score) * 100))


def confiance_from_score(score_ia):

    if score_ia >= 30:
        return 85

    if score_ia >= 20:
        return 72

    if score_ia >= 12:
        return 60

    if score_ia >= 6:
        return 48

    return 35


# --------------------------------------------------
# BADGES
# --------------------------------------------------


def badges_turf(cheval):

    badges = []

    if cheval.get("rankIA") == 1:
        badges.append("TOP IA")

    if cheval.get("value", 0) > 5:
        badges.append("VALUE BET")

    return badges


# --------------------------------------------------
# INDICE PARI
# --------------------------------------------------


def indice_pari(cheval):

    score = cheval.get("scoreIA", 0)
    regularite = cheval.get("regulariteIndex", 0)
    driver = cheval.get("driverIndex", 0)
    trainer = cheval.get("trainerIndex", 0)
    retard = cheval.get("retardGains", 0)
    value = cheval.get("value", 0)
    confiance = cheval.get("confianceIA", 0)

    note = (
        score * 0.30
        + regularite * 0.20
        + driver * 0.10
        + trainer * 0.10
        + retard * 0.10
        + value * 0.15
        + confiance * 0.05
    )

    if note >= 30:
        return 5

    if note >= 24:
        return 4

    if note >= 18:
        return 3

    if note >= 12:
        return 2

    return 1


# --------------------------------------------------
# API
# --------------------------------------------------


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/api/course/{reunion}/{course}")
def course(reunion: str, course: str):

    d = today()

    r = reunion.replace("R", "")
    c = course.replace("C", "")

    data = pmu(f"{d}/R{r}/C{c}/participants")

    participants = data.get("participants", [])

    chevaux = []

    for p in participants:

        musique = p.get("musique", "")

        score_ia = score(musique)

        chevaux.append(
            {
                "numero": p.get("numPmu"),
                "nom": p.get("nom"),
                "driver": p.get("driver"),
                "entraineur": p.get("entraineur"),
                "musique": musique,
                "age": p.get("age"),
                "gains": p.get("gains"),
                "scoreIA": score_ia,
                "cotePMU": (
                    (p.get("dernierRapportDirect") or {}).get("rapport")
                    if isinstance(p.get("dernierRapportDirect"), dict)
                    else p.get("dernierRapportDirect")
                ),
            }
        )

    total_score = sum(x["scoreIA"] for x in chevaux)

    for cheval in chevaux:

        prob = probabilite_from_score(cheval["scoreIA"], total_score)

        cote_ia = round(100 / prob, 2) if prob > 0 else 100

        cote_pmu = cheval.get("cotePMU") or 0

        try:
            cote_pmu = float(cote_pmu)
        except:
            cote_pmu = 0

        prob_pmu = round(100 / cote_pmu, 2) if cote_pmu > 0 else 0

        value = round(prob - prob_pmu, 2)

        confiance = confiance_from_score(cheval["scoreIA"])

        retard = retard_gains_index(
            cheval.get("age"),
            cheval.get("gains"),
            cheval["scoreIA"],
        )

        cheval["probabiliteIA"] = prob
        cheval["probabilitePMU"] = prob_pmu
        cheval["coteIA"] = cote_ia
        cheval["value"] = value
        cheval["confianceIA"] = confiance

        cheval["driverIndex"] = driver_index(cheval.get("driver"))
        cheval["trainerIndex"] = trainer_index(cheval.get("entraineur"))

        cheval["retardGains"] = retard
        cheval["regulariteIndex"] = regularite_index(cheval.get("musique"))

    chevaux = sorted(chevaux, key=lambda x: x["scoreIA"], reverse=True)

    for i, cheval in enumerate(chevaux):

        cheval["rankIA"] = i + 1

        cheval["badges"] = badges_turf(cheval)

        cheval["indicePari"] = indice_pari(cheval)

    return {
        "reunion": reunion,
        "course": course,
        "participants": chevaux,
    }

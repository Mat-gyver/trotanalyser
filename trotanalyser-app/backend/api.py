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


def today():
    return datetime.now().strftime("%d%m%Y")


def pmu(path):
    url = f"{PMU_BASE}/{path}"
    headers = {"User-Agent": "Mozilla/5.0"}
    r = requests.get(url, headers=headers, timeout=15)
    r.raise_for_status()
    return r.json()


def score(m):
    if not m:
        return 0
    s = 0
    for c in m[:8]:
        if c == "1":
            s += 10
        elif c == "2":
            s += 8
        elif c == "3":
            s += 6
        elif c == "4":
            s += 4
        elif c == "5":
            s += 2
        elif c.lower() == "d":
            s -= 5
    return max(0, s)


def analyse_forme(musique):
    if not musique:
        return "forme récente peu lisible"

    s = score(musique)

    if s >= 30:
        return "musique récente très solide avec plusieurs performances de premier plan"
    if s >= 20:
        return "forme récente favorable avec une vraie compétitivité"
    if s >= 10:
        return "forme récente correcte mais sans marge importante"
    if s >= 5:
        return "forme récente assez moyenne dans l'ensemble"
    return "forme récente décevante avec peu de garanties"


def analyse_ferrure(ferrure):
    f = (ferrure or "").upper().strip()

    if f in ["D4", "DP"]:
        return "ferrure attractive pour cet engagement"
    if f in ["DA", "PA", "PLAQUE", "P"]:
        return "ferrure intermédiaire à surveiller"
    if not f:
        return "ferrure non renseignée"
    return "ferrure sans avantage évident"


def analyse_driver(driver):
    if not driver:
        return "driver non renseigné"

    top_drivers = [
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

    d = driver.upper()

    if any(nom in d for nom in top_drivers):
        return "driver de tout premier plan dans cette catégorie"
    return "driver correct dans ce lot"


def analyse_entraineur(entraineur):
    if not entraineur:
        return "entraîneur non renseigné"

    top_trainers = [
        "BAZIRE",
        "ABRIVARD",
        "MARMION",
        "DUVALDESTIN",
        "ALLAIRE",
        "THOMAIN",
        "HENRY",
    ]

    e = entraineur.upper()

    if any(nom in e for nom in top_trainers):
        return "entraînement redoutable sur ce type d'épreuve"
    return "entraînement classique"


def analyse_piste_meteo(distance=None, hippodrome=None):
    try:
        d = int(distance) if distance else 0
    except Exception:
        d = 0

    h = (hippodrome or "").upper()

    notes = []

    if d >= 2850:
        notes.append("profil plutôt tenu pour les longues distances")
    elif d >= 2100:
        notes.append("profil cohérent sur distance intermédiaire")
    elif d > 0:
        notes.append("profil à juger sur un parcours de vitesse")
    else:
        notes.append("distance à confirmer")

    if any(x in h for x in ["VINCENNES", "ENGHIEN", "CAGNES", "CABOURG", "GRAIGNES"]):
        notes.append(f"repères hippodrome à surveiller sur {hippodrome}")
    else:
        notes.append("repères hippodrome encore limités")

    return ". ".join(notes)


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


def driver_index(driver):
    if not driver:
        return 0
    d = driver.upper()
    elite = ["RAFFIN", "ABRIVARD", "BAZIRE", "THOMAIN", "NIVARD", "GOOP", "ROCHARD", "LAGADEUC", "PLOQUIN"]
    solide = ["MOTTIER", "DUBOIS", "COLLETTE", "LEBOURGEOIS", "MARTENS", "JAMARD", "DERIEUX"]
    if any(x in d for x in elite):
        return 8
    if any(x in d for x in solide):
        return 4
    return 1


def trainer_index(entraineur):
    if not entraineur:
        return 0
    e = entraineur.upper()
    elite = ["BAZIRE", "ABRIVARD", "MARMION", "DUVALDESTIN", "ALLAIRE", "THOMAIN", "HENRY", "ROUBAUD"]
    solide = ["DERIEUX", "LE VEXIER", "ALEXANDRE", "GUELPA", "GRIFT"]
    if any(x in e for x in elite):
        return 8
    if any(x in e for x in solide):
        return 4
    return 1


def retard_gains_index(age, gains, score_ia):
    try:
        age_n = int(age)
    except Exception:
        age_n = 0
    try:
        g = float(str(gains).replace(" ", "").replace(",", "."))
    except Exception:
        g = 0.0

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


def build_data_turf_pro(driver, entraineur, age, gains, score_ia):
    d_idx = driver_index(driver)
    e_idx = trainer_index(entraineur)
    r_idx = retard_gains_index(age, gains, score_ia)

    notes = []

    if d_idx >= 8:
        notes.append("driver très confirmé")
    elif d_idx >= 4:
        notes.append("driver fiable")
    else:
        notes.append("driver assez neutre")

    if e_idx >= 8:
        notes.append("entraînement redoutable")
    elif e_idx >= 4:
        notes.append("entraînement solide")
    else:
        notes.append("entraînement standard")

    if r_idx >= 8:
        notes.append("profil très intéressant au regard des gains")
    elif r_idx >= 5:
        notes.append("possible retard de gains")
    elif r_idx >= 2:
        notes.append("profil correct au niveau des gains")
    else:
        notes.append("pas d'avantage net sur les gains")

    return ". ".join(notes).capitalize() + "."


def fragile_favori(cote_pmu, score_ia, confiance_ia):
    try:
        c = float(cote_pmu)
    except Exception:
        c = 999.0
    return c <= 5 and score_ia <= 12 and confiance_ia <= 60


def tocard_ia(cote_pmu, score_ia, value, retard_gains):
    try:
        c = float(cote_pmu)
    except Exception:
        c = 0.0
    return c >= 15 and score_ia >= 10 and (value > 1 or retard_gains >= 5)


def outsider_interessant(cote_pmu, score_ia, value, confiance_ia):
    try:
        c = float(cote_pmu)
    except Exception:
        c = 0.0
    return c >= 8 and score_ia >= 12 and value > 0 and confiance_ia >= 48


def badges_turf(c):
    badges = []
    if c.get("rankIA") == 1:
        badges.append("TOP IA")
    if c.get("value", 0) > 0.4:
        badges.append("VALUE BET")
    if fragile_favori(c.get("cotePMU"), c.get("scoreIA", 0), c.get("confianceIA", 0)):
        badges.append("FAVORI FRAGILE")
    if tocard_ia(c.get("cotePMU"), c.get("scoreIA", 0), c.get("value", 0), c.get("retardGains", 0)):
        badges.append("TOCARD IA")
    if outsider_interessant(c.get("cotePMU"), c.get("scoreIA", 0), c.get("value", 0), c.get("confianceIA", 0)):
        badges.append("OUTSIDER INTÉRESSANT")
    return badges


def build_analyse_ia(
    musique,
    ferrure,
    driver,
    entraineur,
    score_ia,
    probabilite_ia,
    value,
    distance=None,
    hippodrome=None,
):
    tendances = []

    tendances.append(analyse_forme(musique).capitalize())
    tendances.append(analyse_driver(driver).capitalize())
    tendances.append(analyse_entraineur(entraineur).capitalize())
    tendances.append(analyse_ferrure(ferrure).capitalize())

    if probabilite_ia >= 20:
        tendances.append("Profil prioritaire pour les toutes premières places")
    elif probabilite_ia >= 12:
        tendances.append("Chance régulière pour les places")
    else:
        tendances.append("Doit surtout rassurer avant d'inspirer une pleine confiance")

    if value >= 3:
        tendances.append("Le modèle IA détecte une vraie value par rapport au PMU")
    elif value > 0:
        tendances.append("L'écart IA/PMU reste légèrement favorable")
    else:
        tendances.append("Pas de value évidente face au marché PMU")

    tendances.append(analyse_piste_meteo(distance, hippodrome).capitalize())

    return ". ".join(tendances) + "."


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/api/programme/today")
def programme():
    d = today()

    try:
        data = pmu(d)
    except Exception as e:
        return {"error": "pmu_fetch_failed", "detail": str(e)}

    programme_data = data.get("programme", {})
    reunions_data = programme_data.get("reunions", [])

    reunions = []

    for r in reunions_data:
        courses = []

        for c in r.get("courses", []):
            courses.append(
                {
                    "valueMax": 0,
                    "reunion": f"R{r.get('numOfficiel')}",
                    "course": f"C{c.get('numOrdre')}",
                    "titre": f"R{r.get('numOfficiel')} C{c.get('numOrdre')} - {c.get('libelle', '')}",
                    "distance": c.get("distance"),
                    "partants": c.get("nombreDeclaresPartants"),
                }
            )

        hippodrome = r.get("hippodrome") or {}

        reunions.append(
            {
                "reunion": f"R{r.get('numOfficiel')}",
                "hippodrome": hippodrome.get("libelleCourt", ""),
                "courses": courses,
            }
        )

    return {"date": d, "reunions": reunions}


@app.get("/api/course/{reunion}/{course}")
def course(reunion: str, course: str):
    d = today()

    r = reunion.replace("R", "")
    c = course.replace("C", "")

    try:
        data = pmu(f"{d}/R{r}/C{c}/participants")
    except Exception as e:
        return {"error": "pmu_fetch_failed", "detail": str(e)}

    participants = data.get("participants", [])
    chevaux = []

    for p in participants:
        musique = p.get("musique", "")

        chevaux.append(
            {
                "numero": p.get("numPmu"),
                "nom": p.get("nom"),
                "driver": p.get("driver"),
                "entraineur": p.get("entraineur"),
                "ferrure": p.get("ferrure") or p.get("deferre") or p.get("chaussure") or "NR",
                "musique": musique,
                "corde": p.get("placeCorde"),
                "age": p.get("age"),
                "gains": p.get("gains"),
                "sexe": p.get("sexe"),
                "scoreIA": score(musique),
                "cotePMU": (
                    (p.get("dernierRapportDirect") or {}).get("rapport")
                    if isinstance(p.get("dernierRapportDirect"), dict)
                    else p.get("dernierRapportDirect")
                ),
                "analyseIA": "",
            }
        )

    total_score = sum(c.get("scoreIA", 0) for c in chevaux)

    for cheval in chevaux:
        prob = probabilite_from_score(cheval.get("scoreIA", 0), total_score)
        cote_ia = round(100 / prob, 2) if prob > 0 else 100.0

        cote_pmu = cheval.get("cotePMU") or 0
        try:
            cote_pmu = float(cote_pmu)
        except Exception:
            cote_pmu = 0.0

        value = round(cote_pmu - cote_ia, 2)
        confiance = confiance_from_score(cheval.get("scoreIA", 0))
        retard_gains = retard_gains_index(
            cheval.get("age"),
            cheval.get("gains"),
            cheval.get("scoreIA", 0),
        )

        cheval["probabiliteIA"] = prob
        cheval["coteIA"] = cote_ia
        cheval["value"] = value
        cheval["confianceIA"] = confiance
        cheval["driverIndex"] = driver_index(cheval.get("driver"))
        cheval["trainerIndex"] = trainer_index(cheval.get("entraineur"))
        cheval["retardGains"] = retard_gains
        cheval["dataTurfPro"] = build_data_turf_pro(
            cheval.get("driver"),
            cheval.get("entraineur"),
            cheval.get("age"),
            cheval.get("gains"),
            cheval.get("scoreIA", 0),
        )
        cheval["analyseIA"] = build_analyse_ia(
            cheval.get("musique"),
            cheval.get("ferrure"),
            cheval.get("driver"),
            cheval.get("entraineur"),
            cheval.get("scoreIA", 0),
            prob,
            value,
            data.get("distance"),
            (data.get("hippodrome") or {}).get("libelleCourt", data.get("hippodrome")),
        )

    chevaux = sorted(chevaux, key=lambda x: x.get("scoreIA", 0), reverse=True)

    for i, cheval in enumerate(chevaux):
        cheval["rankIA"] = i + 1

    for cheval in chevaux:
        cheval["badges"] = badges_turf(cheval)

    return {
        "reunion": reunion,
        "course": course,
        "participants": chevaux,
    }

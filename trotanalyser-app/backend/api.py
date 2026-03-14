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

    try:
        return response.json()
    except Exception:
        raise ValueError(f"Réponse PMU non JSON pour {url}")


def safe_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(str(value).replace(" ", "").replace(",", "."))
    except Exception:
        return default


def safe_int(value, default=0):
    try:
        if value is None:
            return default
        return int(value)
    except Exception:
        return default


def upper_text(value):
    return str(value or "").upper().strip()


# --------------------------------------------------
# EXTRACTION CONTEXTE COURSE
# --------------------------------------------------


def extract_hippodrome_label(data):
    hippodrome = data.get("hippodrome") or {}

    if isinstance(hippodrome, dict):
        return (
            hippodrome.get("libelleCourt")
            or hippodrome.get("libelleLong")
            or hippodrome.get("libelle")
            or ""
        )

    return str(hippodrome or "")


def extract_course_context(data):
    hippodrome_label = extract_hippodrome_label(data)

    meteo = (
        data.get("meteo")
        or data.get("meteoLibelle")
        or data.get("weather")
        or None
    )

    temperature = (
        data.get("temperature")
        or data.get("temperatureC")
        or data.get("temp")
        or None
    )

    vent = (
        data.get("vent")
        or data.get("ventKmH")
        or data.get("wind")
        or None
    )

    souplesse = (
        data.get("souplesse")
        or data.get("etatPiste")
        or data.get("going")
        or None
    )

    return {
        "hippodrome": hippodrome_label,
        "meteo": meteo,
        "temperature": temperature,
        "vent": vent,
        "souplesse": souplesse,
    }


# --------------------------------------------------
# NIVEAU DE COURSE
# --------------------------------------------------


def niveau_course_index(hippodrome=None, distance=None, partants=None):
    note = 0

    h = upper_text(hippodrome)
    d = safe_int(distance, 0)
    p = safe_int(partants, 0)

    if any(x in h for x in ["VINCENNES", "ENGHIEN", "CAGNES"]):
        note += 4
    elif any(x in h for x in ["CABOURG", "GRAIGNES", "LAVAL", "CAEN"]):
        note += 2
    else:
        note += 1

    if d >= 2850:
        note += 2
    elif d >= 2100:
        note += 1

    if p >= 16:
        note += 2
    elif p >= 12:
        note += 1

    return min(note, 10)


# --------------------------------------------------
# SCORES ET INDICES
# --------------------------------------------------


def base_score_musique(musique):
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

    reg_score = bonnes - fautes

    if reg_score >= 4:
        return 8
    if reg_score >= 2:
        return 5
    if reg_score >= 0:
        return 2

    return 0


def course_level_adjustment(niveau_course, base_score):
    """
    Corrige légèrement la musique selon le niveau du lot.
    Lot relevé + bonne musique = bonus.
    Lot faible + musique flatteuse = légère décote.
    """
    niveau = safe_int(niveau_course, 0)
    base = safe_int(base_score, 0)

    if niveau >= 7 and base >= 12:
        return 3
    if niveau >= 5 and base >= 10:
        return 2
    if niveau <= 2 and base >= 20:
        return -2
    if niveau <= 3 and base >= 12:
        return -1

    return 0


def extract_vent_strength(vent):
    if vent is None:
        return 0

    if isinstance(vent, (int, float)):
        return safe_int(vent, 0)

    txt = upper_text(vent)

    if "FORT" in txt or "STRONG" in txt:
        return 25
    if "MOD" in txt:
        return 15
    if "FAIBLE" in txt or "LOW" in txt:
        return 8

    return safe_int(vent, 0)


def meteo_fit_index(ferrure=None, distance=None, vent=None, souplesse=None):
    """
    Petit ajustement prudent.
    On ne veut pas inventer une science exacte, seulement intégrer
    le contexte météo/piste dans l’analyse cheval.
    """
    score = 0

    f = upper_text(ferrure)
    d = safe_int(distance, 0)
    v = extract_vent_strength(vent)
    s = upper_text(souplesse)

    # Longue distance + vent fort = contexte plus exigeant
    if d >= 2700 and v >= 20:
        score -= 1

    # Souplesse / piste plus profonde
    if any(x in s for x in ["SOUPLE", "LOURD", "COLLANT", "HEAVY"]):
        if f in ["D4", "DP"]:
            score += 1
        elif f == "NR":
            score -= 1

    # Piste rapide / bon terrain
    if any(x in s for x in ["BON", "RAPIDE", "GOOD", "FAST"]):
        if f in ["DA", "D4", "DP"]:
            score += 1

    return max(-2, min(score, 2))


def compute_score_ia(
    musique=None,
    niveau_course=0,
    ferrure=None,
    distance=None,
    vent=None,
    souplesse=None,
):
    base = base_score_musique(musique)
    level_adj = course_level_adjustment(niveau_course, base)
    meteo_adj = meteo_fit_index(
        ferrure=ferrure,
        distance=distance,
        vent=vent,
        souplesse=souplesse,
    )

    final_score = max(0, base + level_adj + meteo_adj)

    return {
        "baseScoreIA": base,
        "courseLevelAdj": level_adj,
        "meteoFitIndex": meteo_adj,
        "scoreIA": final_score,
    }


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

    d = upper_text(driver)
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
    solide = [
        "MOTTIER",
        "DUBOIS",
        "COLLETTE",
        "LEBOURGEOIS",
        "MARTENS",
        "JAMARD",
        "DERIEUX",
    ]

    if any(x in d for x in elite):
        return 8
    if any(x in d for x in solide):
        return 4
    return 1


def trainer_index(entraineur):
    if not entraineur:
        return 0

    e = upper_text(entraineur)
    elite = [
        "BAZIRE",
        "ABRIVARD",
        "MARMION",
        "DUVALDESTIN",
        "ALLAIRE",
        "THOMAIN",
        "HENRY",
        "ROUBAUD",
    ]
    solide = ["DERIEUX", "LE VEXIER", "ALEXANDRE", "GUELPA", "GRIFT"]

    if any(x in e for x in elite):
        return 8
    if any(x in e for x in solide):
        return 4
    return 1


def retard_gains_index(age, gains, score_ia):
    age_n = safe_int(age, 0)
    g = safe_float(gains, 0.0)

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


def market_bias_index(cote_pmu, probabilite_ia, probabilite_pmu):
    """
    Corrige le biais marché PMU.
    Négatif : favori trop joué.
    Positif : outsider potentiellement sous-coté.
    """
    cote = safe_float(cote_pmu, 0.0)
    pia = safe_float(probabilite_ia, 0.0)
    ppmu = safe_float(probabilite_pmu, 0.0)

    if cote <= 3 and pia + 3 < ppmu:
        return -4

    if cote <= 5 and pia < ppmu:
        return -2

    if cote >= 15 and pia >= ppmu + 8:
        return 4

    if cote >= 10 and pia >= ppmu + 5:
        return 2

    return 0


# --------------------------------------------------
# ANALYSES TEXTE
# --------------------------------------------------


def analyse_forme(musique):
    if not musique:
        return "forme récente peu lisible"

    s = base_score_musique(musique)

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
    f = upper_text(ferrure)

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

    d = upper_text(driver)

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

    e = upper_text(entraineur)

    if any(nom in e for nom in top_trainers):
        return "entraînement redoutable sur ce type d'épreuve"
    return "entraînement classique"


def analyse_piste_meteo(distance=None, hippodrome=None, meteo=None, vent=None, souplesse=None):
    d = safe_int(distance, 0)
    h = upper_text(hippodrome)
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

    if souplesse:
        notes.append(f"état de piste indiqué : {souplesse}")

    if meteo:
        notes.append(f"météo signalée : {meteo}")

    if vent:
        notes.append(f"vent signalé : {vent}")

    return ". ".join(notes)


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


# --------------------------------------------------
# BADGES ET INDICES PARI
# --------------------------------------------------


def fragile_favori(cote_pmu, score_ia, confiance_ia):
    c = safe_float(cote_pmu, 999.0)
    return c <= 5 and score_ia <= 12 and confiance_ia <= 60


def tocard_ia(cote_pmu, score_ia, value, retard_gains):
    c = safe_float(cote_pmu, 0.0)
    return c >= 15 and score_ia >= 10 and (value > 5 or retard_gains >= 5)


def outsider_interessant(cote_pmu, score_ia, value, confiance_ia):
    c = safe_float(cote_pmu, 0.0)
    return c >= 8 and score_ia >= 12 and value > 0 and confiance_ia >= 48


def faux_favori_pmu(cheval):
    cote = safe_float(cheval.get("cotePMU"), 999.0)
    score_ia = cheval.get("scoreIA", 0)
    confiance = cheval.get("confianceIA", 0)
    regularite = cheval.get("regulariteIndex", 0)
    market_bias = cheval.get("marketBiasIndex", 0)

    if market_bias <= -4:
        return True

    if cote <= 4 and score_ia < 15:
        return True

    if cote <= 3 and regularite < 3:
        return True

    if cote <= 3 and confiance < 60:
        return True

    return False


def badges_turf(cheval):
    badges = []

    if cheval.get("rankIA") == 1:
        badges.append("TOP IA")

    if cheval.get("value", 0) > 5:
        badges.append("VALUE BET")

    if faux_favori_pmu(cheval):
        badges.append("FAVORI SURCOTÉ")

    if fragile_favori(
        cheval.get("cotePMU"),
        cheval.get("scoreIA", 0),
        cheval.get("confianceIA", 0),
    ):
        badges.append("FAVORI FRAGILE")

    if tocard_ia(
        cheval.get("cotePMU"),
        cheval.get("scoreIA", 0),
        cheval.get("value", 0),
        cheval.get("retardGains", 0),
    ):
        badges.append("TOCARD IA")

    if outsider_interessant(
        cheval.get("cotePMU"),
        cheval.get("scoreIA", 0),
        cheval.get("value", 0),
        cheval.get("confianceIA", 0),
    ):
        badges.append("OUTSIDER INTÉRESSANT")

    return badges


def indice_pari(cheval):
    score_ia = cheval.get("scoreIA", 0)
    regularite = cheval.get("regulariteIndex", 0)
    driver = cheval.get("driverIndex", 0)
    trainer = cheval.get("trainerIndex", 0)
    retard = cheval.get("retardGains", 0)
    value = cheval.get("value", 0)
    confiance = cheval.get("confianceIA", 0)
    market_bias = cheval.get("marketBiasIndex", 0)

    note = (
        score_ia * 0.28
        + regularite * 0.18
        + driver * 0.10
        + trainer * 0.10
        + retard * 0.10
        + value * 0.12
        + confiance * 0.05
        + market_bias * 1.5
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
    meteo=None,
    vent=None,
    souplesse=None,
    niveau_course=None,
    market_bias=None,
    meteo_fit=None,
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

    if value >= 10:
        tendances.append("Le modèle IA détecte une très forte value par rapport au PMU")
    elif value >= 5:
        tendances.append("Le modèle IA détecte une value intéressante face au PMU")
    elif value > 0:
        tendances.append("L'écart IA/PMU reste légèrement favorable")
    else:
        tendances.append("Pas de value évidente face au marché PMU")

    if safe_int(niveau_course, 0) >= 7:
        tendances.append("Le lot du jour paraît relevé, ce qui renforce la sélectivité de la course")

    if safe_int(market_bias, 0) <= -2:
        tendances.append("Le marché PMU semble survaloriser ce profil")
    elif safe_int(market_bias, 0) >= 2:
        tendances.append("Le marché PMU semble sous-évaluer ce profil")

    if safe_int(meteo_fit, 0) >= 1:
        tendances.append("Le contexte météo-piste paraît plutôt favorable à ce cheval")
    elif safe_int(meteo_fit, 0) <= -1:
        tendances.append("Le contexte météo-piste ajoute un doute supplémentaire")

    tendances.append(
        analyse_piste_meteo(
            distance=distance,
            hippodrome=hippodrome,
            meteo=meteo,
            vent=vent,
            souplesse=souplesse,
        ).capitalize()
    )

    return ". ".join(tendances) + "."


# --------------------------------------------------
# SYNTHESE COURSE
# --------------------------------------------------


def build_course_synthesis(chevaux):
    top_performance = sorted(
        chevaux,
        key=lambda x: (
            x.get("rankIA", 999),
            -x.get("scoreIA", 0),
            -x.get("confianceIA", 0),
        ),
    )[:3]

    top_value = sorted(
        chevaux,
        key=lambda x: x.get("value", 0),
        reverse=True,
    )[:3]

    faux_favoris = [
        cheval for cheval in chevaux
        if "FAVORI SURCOTÉ" in (cheval.get("badges") or [])
    ]

    outsiders_value = [
        cheval for cheval in chevaux
        if "OUTSIDER INTÉRESSANT" in (cheval.get("badges") or [])
    ]

    def short_item(cheval):
        return {
            "numero": cheval.get("numero"),
            "nom": cheval.get("nom"),
            "rankIA": cheval.get("rankIA"),
            "scoreIA": cheval.get("scoreIA"),
            "probabiliteIA": cheval.get("probabiliteIA"),
            "probabilitePMU": cheval.get("probabilitePMU"),
            "cotePMU": cheval.get("cotePMU"),
            "value": cheval.get("value"),
            "indicePari": cheval.get("indicePari"),
            "badges": cheval.get("badges", []),
        }

    return {
        "topPerformance": [short_item(c) for c in top_performance],
        "topValue": [short_item(c) for c in top_value],
        "fauxFavoris": [short_item(c) for c in faux_favoris],
        "outsidersValue": [short_item(c) for c in outsiders_value],
    }


# --------------------------------------------------
# ROUTES API
# --------------------------------------------------


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

    for reunion_data in reunions_data:
        courses = []

        for course_data in reunion_data.get("courses", []):
            courses.append(
                {
                    "valueMax": 0,
                    "reunion": f"R{reunion_data.get('numOfficiel')}",
                    "course": f"C{course_data.get('numOrdre')}",
                    "titre": f"R{reunion_data.get('numOfficiel')} C{course_data.get('numOrdre')} - {course_data.get('libelle', '')}",
                    "distance": course_data.get("distance"),
                    "partants": course_data.get("nombreDeclaresPartants"),
                }
            )

        hippodrome = reunion_data.get("hippodrome") or {}

        reunions.append(
            {
                "reunion": f"R{reunion_data.get('numOfficiel')}",
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

    context = extract_course_context(data)
    participants = data.get("participants", [])
    niveau_course = niveau_course_index(
        hippodrome=context["hippodrome"],
        distance=data.get("distance"),
        partants=len(participants),
    )

    chevaux = []

    for participant in participants:
        musique = participant.get("musique", "")
        ferrure = (
            participant.get("ferrure")
            or participant.get("deferre")
            or participant.get("chaussure")
            or "NR"
        )

        score_bundle = compute_score_ia(
            musique=musique,
            niveau_course=niveau_course,
            ferrure=ferrure,
            distance=data.get("distance"),
            vent=context["vent"],
            souplesse=context["souplesse"],
        )

        chevaux.append(
            {
                "numero": participant.get("numPmu"),
                "nom": participant.get("nom"),
                "driver": participant.get("driver"),
                "entraineur": participant.get("entraineur"),
                "ferrure": ferrure,
                "musique": musique,
                "corde": participant.get("placeCorde"),
                "age": participant.get("age"),
                "gains": participant.get("gains"),
                "sexe": participant.get("sexe"),
                "baseScoreIA": score_bundle["baseScoreIA"],
                "courseLevelAdj": score_bundle["courseLevelAdj"],
                "meteoFitIndex": score_bundle["meteoFitIndex"],
                "scoreIA": score_bundle["scoreIA"],
                "cotePMU": (
                    (participant.get("dernierRapportDirect") or {}).get("rapport")
                    if isinstance(participant.get("dernierRapportDirect"), dict)
                    else participant.get("dernierRapportDirect")
                ),
                "analyseIA": "",
            }
        )

    total_score = sum(cheval.get("scoreIA", 0) for cheval in chevaux)

    for cheval in chevaux:
        prob = probabilite_from_score(cheval.get("scoreIA", 0), total_score)
        cote_ia = round(100 / prob, 2) if prob > 0 else 100.0

        cote_pmu = safe_float(cheval.get("cotePMU"), 0.0)
        probabilite_pmu = round(100 / cote_pmu, 2) if cote_pmu > 0 else 0.0
        value = round(prob - probabilite_pmu, 2)

        confiance = confiance_from_score(cheval.get("scoreIA", 0))
        retard_gains = retard_gains_index(
            cheval.get("age"),
            cheval.get("gains"),
            cheval.get("scoreIA", 0),
        )

        market_bias = market_bias_index(
            cheval.get("cotePMU"),
            prob,
            probabilite_pmu,
        )

        cheval["probabiliteIA"] = prob
        cheval["probabilitePMU"] = probabilite_pmu
        cheval["coteIA"] = cote_ia
        cheval["value"] = value
        cheval["confianceIA"] = confiance
        cheval["driverIndex"] = driver_index(cheval.get("driver"))
        cheval["trainerIndex"] = trainer_index(cheval.get("entraineur"))
        cheval["retardGains"] = retard_gains
        cheval["regulariteIndex"] = regularite_index(cheval.get("musique"))
        cheval["marketBiasIndex"] = market_bias
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
            distance=data.get("distance"),
            hippodrome=context["hippodrome"],
            meteo=context["meteo"],
            vent=context["vent"],
            souplesse=context["souplesse"],
            niveau_course=niveau_course,
            market_bias=market_bias,
            meteo_fit=cheval.get("meteoFitIndex"),
        )

    chevaux = sorted(
        chevaux,
        key=lambda x: (
            x.get("scoreIA", 0),
            x.get("confianceIA", 0),
            x.get("value", 0),
        ),
        reverse=True,
    )

    for i, cheval in enumerate(chevaux):
        cheval["rankIA"] = i + 1

    for cheval in chevaux:
        cheval["badges"] = badges_turf(cheval)
        cheval["indicePari"] = indice_pari(cheval)

    return {
        "reunion": reunion,
        "course": course,
        "hippodrome": context["hippodrome"],
        "distance": data.get("distance"),
        "partants": len(chevaux),
        "meteo": context["meteo"],
        "temperature": context["temperature"],
        "vent": context["vent"],
        "souplesse": context["souplesse"],
        "niveauCourse": niveau_course,
        "participants": chevaux,
        "synthesis": build_course_synthesis(chevaux),
    }

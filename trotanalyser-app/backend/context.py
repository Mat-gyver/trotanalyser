from utils import safe_int, upper_text


def extract_hippodrome_label(value):

    if isinstance(value, dict):
        return (
            value.get("libelleCourt")
            or value.get("libelleLong")
            or value.get("libelle")
            or ""
        )

    return str(value or "").strip()


def find_reunion_and_course(programme_data, reunion, course):

    reunion_target = reunion.replace("R", "")
    course_target = course.replace("C", "")

    for reunion_data in programme_data.get("reunions", []):

        if str(reunion_data.get("numOfficiel")) != reunion_target:
            continue

        for course_data in reunion_data.get("courses", []):

            if str(course_data.get("numOrdre")) == course_target:
                return reunion_data, course_data

        return reunion_data, None

    return None, None


def extract_course_context(participants_data, reunion_data=None, course_data=None):

    reunion_data = reunion_data or {}
    course_data = course_data or {}

    hippodrome = (
        extract_hippodrome_label(reunion_data.get("hippodrome"))
        or extract_hippodrome_label(course_data.get("hippodrome"))
        or extract_hippodrome_label(participants_data.get("hippodrome"))
    )

    distance = (
        course_data.get("distance")
        or participants_data.get("distance")
        or None
    )

    return {
        "hippodrome": hippodrome,
        "distance": distance,
        "meteo": participants_data.get("meteo"),
        "temperature": participants_data.get("temperature"),
        "vent": participants_data.get("vent"),
        "souplesse": participants_data.get("souplesse"),
    }


def niveau_course_index(hippodrome=None, distance=None, partants=None):

    note = 0

    h = upper_text(hippodrome)
    d = safe_int(distance)
    p = safe_int(partants)

    if "VINCENNES" in h:
        note += 4
    elif "ENGHIEN" in h:
        note += 3
    else:
        note += 1

    if d >= 2700:
        note += 2
    elif d >= 2100:
        note += 1

    if p >= 16:
        note += 2
    elif p >= 12:
        note += 1

    return min(note, 10)

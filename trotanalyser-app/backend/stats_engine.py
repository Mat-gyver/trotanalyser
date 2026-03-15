from datetime import datetime, timedelta

from stats_db import get_results_since


def normalize_name(value):
    return str(value or "").strip().upper()


def date_days_ago(days):
    return (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")


def distance_bucket(distance):
    try:
        d = int(distance or 0)
    except Exception:
        d = 0

    if d == 0:
        return "unknown"
    if d < 2200:
        return "sprint"
    if d < 2700:
        return "intermediaire"
    return "tenue"


def compute_entity_stats(results, field_name, entity_name):
    entity = normalize_name(entity_name)

    filtered = [
        r for r in results
        if normalize_name(r.get(field_name)) == entity
    ]

    total = len(filtered)

    if total == 0:
        return {
            "name": entity_name,
            "courses": 0,
            "wins": 0,
            "places": 0,
            "winRate": 0.0,
            "placeRate": 0.0,
            "index": 0.0,
        }

    wins = sum(1 for r in filtered if r.get("position") == 1)
    places = sum(1 for r in filtered if r.get("position") in [1, 2, 3])

    win_rate = round((wins / total) * 100, 2)
    place_rate = round((places / total) * 100, 2)
    index_value = round((win_rate * 0.6) + (place_rate * 0.4), 2)

    return {
        "name": entity_name,
        "courses": total,
        "wins": wins,
        "places": places,
        "winRate": win_rate,
        "placeRate": place_rate,
        "index": index_value,
    }


def compute_entity_distance_stats(results, field_name, entity_name, target_distance):
    entity = normalize_name(entity_name)
    bucket = distance_bucket(target_distance)

    filtered = [
        r for r in results
        if normalize_name(r.get(field_name)) == entity
        and distance_bucket(r.get("distance")) == bucket
    ]

    total = len(filtered)

    if total == 0:
        return {
            "name": entity_name,
            "distanceBucket": bucket,
            "courses": 0,
            "wins": 0,
            "places": 0,
            "winRate": 0.0,
            "placeRate": 0.0,
            "indexDistance": 0.0,
        }

    wins = sum(1 for r in filtered if r.get("position") == 1)
    places = sum(1 for r in filtered if r.get("position") in [1, 2, 3])

    win_rate = round((wins / total) * 100, 2)
    place_rate = round((places / total) * 100, 2)
    index_distance = round((win_rate * 0.6) + (place_rate * 0.4), 2)

    return {
        "name": entity_name,
        "distanceBucket": bucket,
        "courses": total,
        "wins": wins,
        "places": places,
        "winRate": win_rate,
        "placeRate": place_rate,
        "indexDistance": index_distance,
    }


def compute_entity_track_stats(results, field_name, entity_name, hippodrome):
    entity = normalize_name(entity_name)
    track = normalize_name(hippodrome)

    filtered = [
        r for r in results
        if normalize_name(r.get(field_name)) == entity
        and normalize_name(r.get("hippodrome")) == track
    ]

    total = len(filtered)

    if total == 0:
        return {
            "name": entity_name,
            "hippodrome": hippodrome,
            "courses": 0,
            "wins": 0,
            "places": 0,
            "winRate": 0.0,
            "placeRate": 0.0,
            "indexTrack": 0.0,
        }

    wins = sum(1 for r in filtered if r.get("position") == 1)
    places = sum(1 for r in filtered if r.get("position") in [1, 2, 3])

    win_rate = round((wins / total) * 100, 2)
    place_rate = round((places / total) * 100, 2)
    index_track = round((win_rate * 0.6) + (place_rate * 0.4), 2)

    return {
        "name": entity_name,
        "hippodrome": hippodrome,
        "courses": total,
        "wins": wins,
        "places": places,
        "winRate": win_rate,
        "placeRate": place_rate,
        "indexTrack": index_track,
    }


def get_driver_stats_12m(driver_name):
    results = get_results_since(date_days_ago(365))
    stats = compute_entity_stats(results, "driver", driver_name)

    return {
        "name": stats["name"],
        "courses": stats["courses"],
        "wins": stats["wins"],
        "places": stats["places"],
        "winRate": stats["winRate"],
        "placeRate": stats["placeRate"],
        "index12m": stats["index"],
    }


def get_trainer_stats_12m(trainer_name):
    results = get_results_since(date_days_ago(365))
    stats = compute_entity_stats(results, "entraineur", trainer_name)

    return {
        "name": stats["name"],
        "courses": stats["courses"],
        "wins": stats["wins"],
        "places": stats["places"],
        "winRate": stats["winRate"],
        "placeRate": stats["placeRate"],
        "index12m": stats["index"],
    }


def get_driver_stats_30d(driver_name):
    results = get_results_since(date_days_ago(30))
    stats = compute_entity_stats(results, "driver", driver_name)

    return {
        "name": stats["name"],
        "courses": stats["courses"],
        "wins": stats["wins"],
        "places": stats["places"],
        "winRate": stats["winRate"],
        "placeRate": stats["placeRate"],
        "index30d": stats["index"],
    }


def get_trainer_stats_30d(trainer_name):
    results = get_results_since(date_days_ago(30))
    stats = compute_entity_stats(results, "entraineur", trainer_name)

    return {
        "name": stats["name"],
        "courses": stats["courses"],
        "wins": stats["wins"],
        "places": stats["places"],
        "winRate": stats["winRate"],
        "placeRate": stats["placeRate"],
        "index30d": stats["index"],
    }


def get_stable_heat_30d(trainer_name):
    stats = get_trainer_stats_30d(trainer_name)
    index30d = stats["index30d"]
    courses = stats["courses"]

    if courses < 3:
        label = "Peu couru"
    elif index30d >= 35:
        label = "Écurie brûlante"
    elif index30d >= 25:
        label = "Écurie en forme"
    elif index30d >= 15:
        label = "Écurie correcte"
    else:
        label = "Écurie froide"

    return {
        "name": trainer_name,
        "courses30d": courses,
        "index30d": index30d,
        "label": label,
    }


def get_driver_distance_stats_12m(driver_name, distance):
    results = get_results_since(date_days_ago(365))
    return compute_entity_distance_stats(results, "driver", driver_name, distance)


def get_trainer_distance_stats_12m(trainer_name, distance):
    results = get_results_since(date_days_ago(365))
    return compute_entity_distance_stats(results, "entraineur", trainer_name, distance)


def get_driver_track_stats_12m(driver_name, hippodrome):
    results = get_results_since(date_days_ago(365))
    return compute_entity_track_stats(results, "driver", driver_name, hippodrome)


def get_trainer_track_stats_12m(trainer_name, hippodrome):
    results = get_results_since(date_days_ago(365))
    return compute_entity_track_stats(results, "entraineur", trainer_name, hippodrome)

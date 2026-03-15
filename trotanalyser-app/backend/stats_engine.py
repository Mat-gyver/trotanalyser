from datetime import datetime, timedelta

from stats_db import get_results_since


def normalize_name(value):
    return str(value or "").strip().upper()


def date_days_ago(days):
    return (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")


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

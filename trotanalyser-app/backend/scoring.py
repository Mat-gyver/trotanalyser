from utils import safe_int, upper_text


def base_score_musique(musique):

    if not musique:
        return 0

    score = 0

    for c in str(musique)[:8]:

        if c == "1":
            score += 10
        elif c == "2":
            score += 8
        elif c == "3":
            score += 6
        elif c == "4":
            score += 4
        elif c == "5":
            score += 2
        elif c.lower() == "d":
            score -= 5

    return max(score, 0)


def regularite_index(musique):

    if not musique:
        return 0

    bonnes = 0
    fautes = 0

    for c in str(musique)[:8]:

        if c in ["1", "2", "3", "4", "5"]:
            bonnes += 1

        if c.lower() in ["d", "a"]:
            fautes += 1

    return max(bonnes - fautes, 0)


def indice_forme_trot(cheval, distance=None):

    musique = cheval.get("musique")
    ferrure = upper_text(cheval.get("ferrure"))

    score = base_score_musique(musique)

    if ferrure in ["D4", "DP"]:
        score += 5

    if distance and safe_int(distance) >= 2700:
        score += 2

    return score

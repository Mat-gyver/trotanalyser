def badges_turf(cheval):

    badges = []

    if cheval.get("rankIA") == 1:
        badges.append("TOP IA")

    if cheval.get("value", 0) > 5:
        badges.append("VALUE BET")

    return badges

def build_course_synthesis(chevaux):

    top = sorted(
        chevaux,
        key=lambda x: x.get("scoreIA", 0),
        reverse=True
    )[:3]

    return {
        "topPerformance": top
    }

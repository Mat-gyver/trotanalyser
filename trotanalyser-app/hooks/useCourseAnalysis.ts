import { useMemo } from "react"

export function useCourseAnalysis(data: any) {

  const sortedParticipants = useMemo(() => {
    if (!data?.participants) return []
    return [...data.participants].sort(
      (a, b) => (b.scoreIA || 0) - (a.scoreIA || 0)
    )
  }, [data])


  const paceAnalysis = useMemo(() => {

    const leaders = sortedParticipants.filter(p =>
      String(p.analyseIA || "").toLowerCase().includes("tête")
    )

    const finishers = sortedParticipants.filter(p =>
      String(p.analyseIA || "").toLowerCase().includes("fin")
    )

    let train = "NORMAL"

    if (leaders.length >= 3) train = "RAPIDE"
    if (leaders.length <= 1) train = "LENT"

    return {
    train,
      leaders,
      finishers
    }

  }, [sortedParticipants])


  const valueBets = useMemo(() => {

    return sortedParticipants.filter(p => {

      const probIA = p.probabiliteIA || 0
      const cote = p.cotePMU || 0

      if (!cote) return false

      const probPMU = 100 / cote
      const value = probIA - probPMU

      return value > 8

    })

  }, [sortedParticipants])


  const enrichedSortedParticipants = useMemo(() => {

    return sortedParticipants.map(p => {

      const probIA = p.probabiliteIA || 0
      const cote = p.cotePMU || 0
      const retard = p.retardGains || 0

      const probPMU = cote ? 100 / cote : 0
      const value = probIA - probPMU

      const favoriFragile =
        cote <= 3 &&
        (p.scoreIA || 0) < 15 &&
        (p.driverIndex || 0) < 5

      const grosTocard =
        probIA >= 10 &&
        cote >= 20 &&
        retard >= 5

      return {
        ...p,
        valueSignal: value,
        favoriFragile,
        grosTocard
      }

    })

  }, [sortedParticipants])


    const top3IA = useMemo(() => {
    return enrichedSortedParticipants.slice(0, 3)
  }, [enrichedSortedParticipants])

  const topValue = useMemo(() => {
    return valueBets[0] || null
  }, [valueBets])

  return {
    sortedParticipants: enrichedSortedParticipants,
    top3IA,
    valueBets,
    paceAnalysis,
    topValue
  }
}
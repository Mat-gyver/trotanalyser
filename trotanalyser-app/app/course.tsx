import { useEffect, useState } from "react"
import { View, Text, FlatList, StyleSheet } from "react-native"
import { useLocalSearchParams } from "expo-router"
import { API_BASE } from "../constants/courseApiBase"

export default function CourseScreen() {

  const { reunion, course } = useLocalSearchParams()

  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {

    const load = async () => {
      try {

        const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`)
        const json = await res.json()

        setData(json)

      } catch (e) {
        console.log("API error", e)
      } finally {
        setLoading(false)
      }
    }

    load()

  }, [])

  if (loading) {
    return (
      <View style={styles.center}>
        <Text>Chargement...</Text>
      </View>
    )
  }

  if (!data) {
    return (
      <View style={styles.center}>
        <Text>Aucune donnée</Text>
      </View>
    )
  }

  const renderStars = (n) => {
    return "⭐".repeat(n || 0)
  }

  const renderItem = ({ item }) => {

    return (
      <View style={styles.card}>

        <View style={styles.header}>

          <Text style={styles.numero}>
            {item.numero}
          </Text>

          <Text style={styles.nom}>
            {item.nom}
          </Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Driver</Text>
          <Text>{item.driver}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Entraîneur</Text>
          <Text>{item.entraineur}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Musique</Text>
          <Text>{item.musique}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Score IA</Text>
          <Text>{item.scoreIA}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Probabilité IA</Text>
          <Text>{item.probabiliteIA}%</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Cote PMU</Text>
          <Text>{item.cotePMU}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Value</Text>
          <Text>{item.value}</Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Indice pari</Text>
          <Text style={styles.stars}>
            {renderStars(item.indicePari)}
          </Text>

        </View>

        <View style={styles.row}>

          <Text style={styles.label}>Badges</Text>

          <Text>
            {(item.badges || []).join(" • ")}
          </Text>

        </View>

        <Text style={styles.analyse}>
          {item.analyseIA}
        </Text>

      </View>
    )
  }

  return (

    <View style={styles.container}>

      <Text style={styles.title}>
        {data.hippodrome} — {data.reunion} {data.course}
      </Text>

      <FlatList
        data={data.participants}
        keyExtractor={(item) => item.numero.toString()}
        renderItem={renderItem}
      />

    </View>

  )

}

const styles = StyleSheet.create({

  container: {
    flex: 1,
    padding: 12,
    backgroundColor: "#0b1c2c"
  },

  title: {
    color: "white",
    fontSize: 20,
    marginBottom: 10
  },

  card: {
    backgroundColor: "#11283f",
    padding: 12,
    borderRadius: 10,
    marginBottom: 10
  },

  header: {
    flexDirection: "row",
    marginBottom: 6
  },

  numero: {
    color: "#00e1ff",
    fontWeight: "bold",
    marginRight: 8
  },

  nom: {
    color: "white",
    fontWeight: "bold"
  },

  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 2
  },

  label: {
    color: "#8fb3d9"
  },

  stars: {
    color: "#ffd700",
    fontSize: 16
  },

  analyse: {
    marginTop: 6,
    color: "#c7d8ea",
    fontSize: 12
  },

  center: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center"
  }

})

import { useEffect, useState } from "react";
import {
  ActivityIndicator,
  FlatList,
  Pressable,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { useRouter } from "expo-router";

import { API_BASE } from "../../constants/courseApiBase";

export default function Index() {
  const router = useRouter();

  const [loading, setLoading] = useState(true);
  const [reunions, setReunions] = useState<any[]>([]);

  useEffect(() => {
    fetchProgramme();
  }, []);

  async function fetchProgramme() {
    try {
      const res = await fetch(`${API_BASE}/api/programme/today`);
      const json = await res.json();

      setReunions(json.reunions || []);
    } catch (e) {
      console.log("Erreur chargement programme", e);
    } finally {
      setLoading(false);
    }
  }

  function renderCourse({ item }: any) {
    const values: number[] = [];

    item.participants?.forEach((p: any) => {
      const value = Number(p?.value || 0);
      values.push(value);
    });

    const valueMax = values.length ? Math.max(...values) : 0;

    return (
      <Pressable
        style={styles.card}
        onPress={() =>
          router.push(`/course?reunion=${item.reunion}&course=${item.course}`)
        }
      >
        <View style={styles.row}>
          <Text style={styles.title}>{item.titre}</Text>
          <Text style={styles.partants}>{item.partants} partants</Text>
        </View>

        <View style={styles.metaRow}>
          <Text style={styles.meta}>{item.distance} m</Text>

          <Text
            style={[
              styles.value,
              valueMax > 5 ? styles.valueStrong : styles.valueNormal,
            ]}
          >
            Value max : {valueMax.toFixed(1)}
          </Text>
        </View>
      </Pressable>
    );
  }

  function renderReunion({ item }: any) {
    return (
      <View style={styles.reunionBlock}>
        <Text style={styles.reunionTitle}>
          {item.reunion} - {item.hippodrome}
        </Text>

        <FlatList
          data={item.courses}
          keyExtractor={(item) => item.course}
          renderItem={renderCourse}
        />
      </View>
    );
  }

  if (loading) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color="#00E0FF" />
      </View>
    );
  }

  return (
    <FlatList
      data={reunions}
      keyExtractor={(item) => item.reunion}
      renderItem={renderReunion}
    />
  );
}

const styles = StyleSheet.create({
  loader: {
    flex: 1,
    justifyContent: "center",
  },

  reunionBlock: {
    padding: 14,
  },

  reunionTitle: {
    fontSize: 18,
    fontWeight: "700",
    marginBottom: 8,
  },

  card: {
    backgroundColor: "#0E1B2A",
    borderRadius: 10,
    padding: 14,
    marginBottom: 10,
  },

  row: {
    flexDirection: "row",
    justifyContent: "space-between",
  },

  title: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "600",
  },

  partants: {
    color: "#9FB2C8",
  },

  metaRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 6,
  },

  meta: {
    color: "#9FB2C8",
  },

  value: {
    fontWeight: "600",
  },

  valueStrong: {
    color: "#00E676",
  },

  valueNormal: {
    color: "#9FB2C8",
  },
});

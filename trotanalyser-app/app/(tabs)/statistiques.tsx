import { SafeAreaView, StyleSheet, Text, View } from "react-native";

export default function StatistiquesScreen() {
      return (
            <SafeAreaView style={styles.container}>
                  <View style={styles.card}>
                        <Text style={styles.title}>Statistiques IA</Text>

                        <Text style={styles.line}>Paris analysés : 124</Text>
                        <Text style={styles.line}>Value bets détectés : 37</Text>
                        <Text style={styles.line}>Taux de réussite : 29%</Text>
                        <Text style={styles.line}>Gains simulés : 301€</Text>
                  </View>
            </SafeAreaView>
      );
}

const styles = StyleSheet.create({
      container: {
            flex: 1,
            backgroundColor: "#04101a",
            padding: 16,
      },
      card: {
            backgroundColor: "#0b1c2b",
            borderRadius: 18,
            padding: 18,
            borderWidth: 1,
            borderColor: "#1f3d5a",
            marginTop: 16,
      },
      title: {
            color: "#ffffff",
            fontSize: 24,
            fontWeight: "800",
            marginBottom: 16,
      },
      line: {
            color: "#c8deec",
            fontSize: 16,
            marginBottom: 10,
      },
});
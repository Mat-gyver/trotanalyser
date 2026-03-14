import { SafeAreaView, StyleSheet, Text, View } from "react-native";

export default function ModalScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>TrotAnalyser</Text>
        <Text style={styles.text}>Écran modal désactivé.</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#04101a",
    justifyContent: "center",
    alignItems: "center",
    padding: 24,
  },
  card: {
    width: "100%",
    maxWidth: 420,
    backgroundColor: "#0b1c2b",
    borderRadius: 20,
    padding: 24,
    borderWidth: 1,
    borderColor: "#1f3d5a",
  },
  title: {
    color: "#ffffff",
    fontSize: 24,
    fontWeight: "800",
    marginBottom: 10,
  },
  text: {
    color: "#b9d6ea",
    fontSize: 15,
    lineHeight: 22,
  },
});

import { Tabs } from "expo-router";
import { Ionicons } from "@expo/vector-icons";

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerStyle: { backgroundColor: "#07131f" },
        headerTintColor: "#ffffff",
        headerTitleStyle: { fontWeight: "700" },
        tabBarStyle: {
          backgroundColor: "#07131f",
          borderTopColor: "#163247",
        },
        tabBarActiveTintColor: "#5ec8ff",
        tabBarInactiveTintColor: "#7f9db1",
        sceneStyle: {
          backgroundColor: "#04101a",
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Réunions",
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="list" size={size} color={color} />
          ),
        }}
      />

      <Tabs.Screen
        name="statistiques"
        options={{
          title: "Statistiques",
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="stats-chart" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}

import Constants from "expo-constants";

const getApiBase = () => {
  const debuggerHost = Constants.expoConfig?.hostUri;

  if (debuggerHost) {
    const host = debuggerHost.split(":").shift();
    return `http://${host}:8000`;
  }

  return "http://localhost:8000";
};

export const API_BASE = getApiBase();

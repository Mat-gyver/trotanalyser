import React from "react";
import { View } from "react-native";

type Props = {
  children?: React.ReactNode;
};

export default function CourseHorseInlineCard({ children }: Props) {
  return <View>{children}</View>;
}

import React, { memo } from "react";
import { View } from "react-native";

type Props = {
  children?: React.ReactNode;
};

function CourseHorseInlineCard({ children }: Props) {
  return (
    <View
      style={{
        marginBottom: 8,
        padding: 10,
        borderRadius: 10,
        backgroundColor: "rgba(255,255,255,0.03)",
      }}
    >
      {children}
    </View>
  );
}

export default memo(CourseHorseInlineCard);

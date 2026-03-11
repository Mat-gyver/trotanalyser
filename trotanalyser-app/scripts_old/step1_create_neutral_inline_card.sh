#!/bin/bash
set -e

mkdir -p components/course

cat > components/course/CourseHorseInlineCard.tsx <<'TSX'
import React from "react";
import { View } from "react-native";

type Props = {
  children?: React.ReactNode;
};

export default function CourseHorseInlineCard({ children }: Props) {
  return <View>{children}</View>;
}
TSX

echo "CourseHorseInlineCard.tsx créé"
npx tsc --noEmit --pretty false

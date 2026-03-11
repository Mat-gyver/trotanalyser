#!/bin/bash
set -e

FILE="components/course/CourseHorseInlineCard.tsx"
BACKUP="backups/CourseHorseInlineCard_before_restore_wrapper_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

cat > "$FILE" <<'TSX'
import React from "react";
import { View } from "react-native";

type Props = {
  children?: React.ReactNode;
};

export default function CourseHorseInlineCard({ children }: Props) {
  return <View>{children}</View>;
}
TSX

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false

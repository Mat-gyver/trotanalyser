#!/bin/bash
set -e

FILE="components/course/CourseHorseInlineCard.tsx"
BACKUP="backups/CourseHorseInlineCard_before_wrapper_fix_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP" 2>/dev/null || true
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
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false

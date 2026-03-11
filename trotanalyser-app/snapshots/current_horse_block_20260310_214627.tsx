      
{sortedParticipants.map((c) => (
         <CourseHorseInlineCard key={String(c.numero)}> 
          <View style={[styles.cardHeader,{alignItems:"center"}]}>
            <View style={styles.nameWrap}>
              {renderCasaque(c)}
              <Text style={styles.lineStats}>
                {c.numero} - {c.nom}   SCORE IA {scoreBar(c.scoreIA)} {c.scoreIA ?? "-"}   IA {iaProbBar(c.probabiliteIA, c.cotePMU)} {c.probabiliteIA ?? 0}%   PMU {pmuBar(c.cotePMU)} {Math.round(impliedProbPmu(c.cotePMU))}%
              </Text>
            </View>

            

            <View style={styles.rankPill}>
              <Text style={styles.rankText}>#{c.rankIA || "-"}</Text>
            </View>
          </View>

          <View style={styles.badgesRow}>
            {(c.badges || []).slice(0, 3).map((badge, index) => (
              <View
                key={`${c.numero}-${badge}-${index}`}
                style={[
                  styles.badge,
                  badge === "VALUE BET" && styles.badgeValue,
                  badge === "TOP IA" && styles.badgeTop,
                  badge === "FAVORI FRAGILE" && styles.badgeFragile,
                  badge === "VALUE FORTE"
                ? styles.badgeValueStrong
                : badge === "VALUE"
                ? styles.badgeValue
                : badge === "SURCOTÉ"
                ? styles.badgeSurcote
                : badge === "TOCARD IA" && styles.badgeTocard,
                  badge === "OUTSIDER INTÉRESSANT" && styles.badgeOutsider,
                ]}
              >
                <Text style={styles.badgeText}>{badge}</Text>
              </View>
            ))}
          </View>

          <View style={styles.cardBody}>
            <View style={styles.cardLeft}>
              <Text style={styles.lineCompact}>
                {c.driver || "NR"}{" "}
                <Text style={[styles.noteInline, { color: noteColor(c.driverIndex) }]}>
                  ({c.driverIndex ?? 0}/10)
                </Text>
                {" / "}
                {c.entraineur || "NR"}{" "}
                <Text style={[styles.noteInline, { color: noteColor(c.trainerIndex) }]}>
                  ({c.trainerIndex ?? 0}/10)
                </Text>
                {" • "}
                {shortFerrure(c.ferrure)}
                {" • Cote PMU ≈ "}
                {c.cotePMU ?? "-"}
              </Text>

              <Text style={styles.lineCompact}>{c.musique || "-"}</Text>

              <Text style={styles.analysis}>{shortAnalyse(c.analyseIA)}</Text>
            </View>

            <View style={styles.cardRight}>
              
              <Text style={styles.name}>
                
              </Text>

              <Text style={styles.scoreMeta}>
                 Value{" "}
                <Text
                  style={[
                    styles.valueText,
                    (c.value || 0) > 3
                      ? styles.valueStrong
                      : (c.value || 0) > 0
                      ? styles.valuePositive
                      : styles.valueNegative,
                  ]}
                >
                  {c.value ?? "-"}
                </Text>{" "}
                </Text>

              <Text style={styles.microStats}>
                G{c.retardGains ?? 0}
              </Text>
<View style={styles.inlineRow}>
                <Text
                  style={[
                    styles.levelBadge,
                    (c.probabiliteIA || 0) >= 20
                      ? styles.levelFavori
                      : (c.probabiliteIA || 0) >= 10
                      ? styles.levelChance
                      : styles.levelOutsider,
                  ]}
                >
                  {(c.probabiliteIA || 0) >= 20
                    ? "🟢 Favori"
                    : (c.probabiliteIA || 0) >= 10
                    ? "🟡 Chance"
                    : "🔴 Outsider"}
                </Text>

                <Text style={styles.pariIndex}>Indice Pari : {pariStars(c)}</Text>
              </View>

              <View style={styles.alertRow}>
                {alertTags(c).map((tag, index) => (
                  <View key={`${c.numero}-alert-${index}`} style={styles.alertPill}>
                    <Text style={styles.alertText}>{tag}</Text>
                  </View>
                ))}
              </View>
            </View>
          </View>
        </CourseHorseInlineCard>

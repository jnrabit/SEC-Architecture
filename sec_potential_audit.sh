#!/bin/bash
echo "📊 SEC-POTENZIAL-ANALYSE: SKALIERUNGS-KURVE 📊"
echo "------------------------------------------------"

sizes=("100M" "200M" "500M" "1000M")

for size in "${sizes[@]}"; do
    echo -n "Prüfe Dichte für $size... "
    
    # Temporäre Daten im RAM erzeugen
    head -c "$size" /dev/urandom > /tmp/scale_test.dat
    
    START=$(date +%s%N)
    # Parallel-Vektor (8 Threads) nutzen
    for i in {1..8}; do
        (head -c $(echo "$size" | sed 's/M//')M /tmp/scale_test.dat | openssl enc -aes-256-cbc -k "seed1812" -pbkdf2 > /dev/null) &
    done
    wait
    END=$(date +%s%N)
    
    DIFF=$(echo "scale=3; ($END - $START)/1000000000" | bc)
    # Berechne MB pro Sekunde (Durchsatz)
    MB=$(echo "$size" | sed 's/M//')
    SPEED=$(echo "scale=2; $MB / $DIFF" | bc)
    
    echo "Zeit: ${DIFF}s | Durchsatz: ${SPEED} MB/s"
    rm /tmp/scale_test.dat
done
echo "------------------------------------------------"

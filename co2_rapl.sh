#!/bin/bash

export LC_NUMERIC=C

CO2_FACTOR=0.06  # kg CO2/kWh France
SAMPLE_INTERVAL=1

get_energy() {
    sudo cat /sys/class/powercap/intel-rapl:0/energy_uj
}

watts_to_co2_ug_per_sec() {
    WATTS=$1
    CO2=$(awk "BEGIN {printf \"%.4f\", $WATTS * $CO2_FACTOR * 1000000 / 3600}")
    echo "$CO2"
}

PREV=$(get_energy)
while true; do
    sleep $SAMPLE_INTERVAL
    NOW=$(get_energy)
    DELTA_UJ=$((NOW - PREV))
    PREV=$NOW
    W=$(awk "BEGIN {printf \"%.4f\", $DELTA_UJ / 1000000 / $SAMPLE_INTERVAL}")
    CO2=$(watts_to_co2_ug_per_sec $W)
    printf "⚡ Consommation CPU : %.4f W | 🌍 CO2 estimé : %.4f µg/s\n" $W $CO2
done

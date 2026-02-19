#!/bin/bash

# Facteur CO2 France (kg CO2 / kWh)
CO2_FACTOR=0.06
SAMPLE_INTERVAL=5  # secondes

# Fonction pour formater les nombres pour printf
format_number() {
    # 3 décimales max et 0 devant le point si nécessaire
    echo "$1" | awk '{val=sprintf("%.3f",$1); if(val<1 && val>-1) printf "0%s\n",substr(val,2); else print val}'
}

# Lecture consommation CPU via powercap
get_cpu_power() {
    if [ -r /sys/class/powercap/intel-rapl:0/energy_uj ]; then
        local start=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
        sleep 1
        local end=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
        local power_w=$(echo "scale=6; ($end - $start) / 1000000" | bc)
        echo "$power_w"
    else
        echo "2"  # valeur par défaut fictive
    fi
}

# Lecture consommation DRAM via powercap (si disponible)
get_dram_power() {
    if [ -r /sys/class/powercap/intel-rapl:0:0/energy_uj ]; then
        local start=$(cat /sys/class/powercap/intel-rapl:0:0/energy_uj)
        sleep 1
        local end=$(cat /sys/class/powercap/intel-rapl:0:0/energy_uj)
        local power_w=$(echo "scale=6; ($end - $start) / 1000000" | bc)
        echo "$power_w"
    else
        echo "0"  # DRAM non mesurable
    fi
}

# Lecture consommation disque (approximation)
get_disk_power() {
    # Exemple : valeur fixe ou estimation simple
    echo "2"
}

# Conversion watts -> µg CO2/s
watts_to_co2_ug_per_sec() {
    WATTS=$1
    KWH=$(echo "scale=8; $WATTS / 1000" | bc)
    CO2_KG=$(echo "scale=8; $KWH * $CO2_FACTOR" | bc)
    CO2_UG_S=$(echo "scale=8; $CO2_KG * 1000000 / 3600" | bc)
    echo "$CO2_UG_S"
}

while true; do
    CPU_W=$(get_cpu_power)
    DRAM_W=$(get_dram_power)
    DISK_W=$(get_disk_power)

    TOTAL_W=$(echo "$CPU_W + $DRAM_W + $DISK_W" | bc)

    CPU_CO2=$(watts_to_co2_ug_per_sec $CPU_W)
    DRAM_CO2=$(watts_to_co2_ug_per_sec $DRAM_W)
    DISK_CO2=$(watts_to_co2_ug_per_sec $DISK_W)
    TOTAL_CO2=$(watts_to_co2_ug_per_sec $TOTAL_W)

    # Formattage pour printf
    CPU_W=$(format_number $CPU_W)
    DRAM_W=$(format_number $DRAM_W)
    DISK_W=$(format_number $DISK_W)
    TOTAL_W=$(format_number $TOTAL_W)

    CPU_CO2=$(format_number $CPU_CO2)
    DRAM_CO2=$(format_number $DRAM_CO2)
    DISK_CO2=$(format_number $DISK_CO2)
    TOTAL_CO2=$(format_number $TOTAL_CO2)

    printf "⚡ CPU: %s W | DRAM: %s W | Disque: %s W | Total: %s W\n" \
        "$CPU_W" "$DRAM_W" "$DISK_W" "$TOTAL_W"
    printf "🌍 CO2 CPU: %s µg/s | DRAM: %s µg/s | Disque: %s µg/s | Total: %s µg/s\n\n" \
        "$CPU_CO2" "$DRAM_CO2" "$DISK_CO2" "$TOTAL_CO2"

    sleep $SAMPLE_INTERVAL
done

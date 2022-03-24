#!/bin/bash

# Script que suma estadísticas al output de docker stats
# ya que no cuenta la cantidad total de ram o cpu del sistema

# Obtiene la cantidad total de ram, asume que el sistema tiene el manos 1 GB (1024*1024)
HOST_MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2/1024/1024}')


# Obtenemos la salida del comando de docker stat, se muestra al final
# Sin modificar la variable special IFS, la salida del comando docker stats
# No va a tener nuevas líneas, con lo cual da fallo al procesar cada línea con awk

IFS=;
DOCKER_STATS_CMD=`docker stats --no-stream --format "table {{.MemPerc}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Name}}"`

SUM_RAM=`echo $DOCKER_STATS_CMD | tail -n +2 | sed "s/%//g" | awk '{s+=$1} END {print s}'`
SUM_CPU=`echo $DOCKER_STATS_CMD | tail -n +2 | sed "s/%//g" | awk '{s+=$2} END {print s}'`
SUM_RAM_QUANTITY=`LC_NUMERIC=C printf %.2f $(echo "$SUM_RAM*$HOST_MEM_TOTAL*0.01" | bc)`

# Mostramos el contenido

echo $DOCKER_STATS_CMD
echo -e "${SUM_RAM}%\t\t\t${SUM_CPU}%\t\t${SUM_RAM_QUANTITY}GiB / ${HOST_MEM_TOTAL}GiB\tTOTAL"

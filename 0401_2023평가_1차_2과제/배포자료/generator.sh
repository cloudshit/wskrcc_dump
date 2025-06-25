#!/bin/bash

NAMES=("kim" "kim" "kim" "lee" "lee" "park")
CITYS=("seoul" "seoul" "gyeonggi")
name_idx=0
city_idx=0
LOG_PATH="/var/log/mykinesis"

if [[ ! -d /var/log/mykinesis ]]; then
  mkdir -p $LOG_PATH
fi

while true; do
  for i in {0..9}; do
    dt=$(date +%T)
    r1=$(head -1 /dev/urandom | od -N1 | awk '{print $2}')
    let "name_idx = r1 % ${#NAMES[@]}"
    name=${NAMES[${name_idx}]}

    r2=$(head -1 /dev/urandom | od -N1 | awk '{print $2}')
    let "city_idx = r2 % ${#CITYS[@]}"
    city=${CITYS[${city_idx}]}

    echo {\"date\": \"${dt}\", \"name\": \"${name}\", \"city\": \"${city}\"} >> ${LOG_PATH}/user.log
  done

  sleep 1
done

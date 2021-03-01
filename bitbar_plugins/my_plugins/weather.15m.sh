#!/bin/bash

# read from config
source /Users/qianhaoyu/Desktop/utils/bitbar_plugins/configs/weather.config

MENUFONT="size=12 font=UbuntuMono-Bold"
COLORS=("#297722" "#ffde33" "#ff9933" "#cc0033" "#660099" "#7e0023")

# parameters

WEATHER_FUTURE_LENGTH=3
shopt -s nocasematch # ignore case for string comparison

WEATHER_DATA=$(curl -s "http://api.weatherapi.com/v1/forecast.json?key=${WEATHER_TOKEN}&q=${WEATHER_CITY}&days=${WEATHER_FUTURE_LENGTH}&aqi=yes&alerts=yes")
WEATHER_FUTURE=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.forecast.forecastday')

WEATHER_RES_REALTIME_INFO=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.condition.text')
WEATHER_RES_REALTIME_TEMPERATURE=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.temp_c')
AQI_DATA=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.air_quality.pm2_5')
ALERTS=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.alerts.alert')


# Function round(precision, number)
round() {
    n=$(printf "%.${1}g" "$2")
    if [ "$n" != "${n#*e}" ]
    then
        f="${n##*e-}"
        test "$n" = "$f" && f= || f=$(( ${f#0}+$1-1 ))
        printf "%0.${f}f" "$n"
    else
        printf "%s" "$n"
    fi
}
AQI_RES=$(round 2 ${AQI_DATA})
AQI_RES=$(expr $AQI_DATA)
AQI_RES=${AQI_RES%.*}

function aqi_colorize {
  if [ "$1" -le 12 ]; then
    echo "${COLORS[0]}"
  elif [ "$1" -le 35 ]; then
    echo "${COLORS[1]}"
  elif [ "$1" -le 55 ]; then
    echo "${COLORS[2]}"
  elif [ "$1" -le 150 ]; then
    echo "${COLORS[3]}"
  elif [ "$1" -le 250 ]; then
    echo "${COLORS[4]}"
  else
    echo "${COLORS[5]}"
  fi
}

function weather_sym {

  if [ "$1" ==  "Sunny" ]; then
    echo "☀️"
  elif [ "$1" ==  "Clear" ]; then
    echo "🌙"
  elif [ "$1" == "Partly cloudy" ] || [ "$1" == "Cloudy" ]; then
    echo "☁️"
  elif ( "$1" == *"thunder"* ); then
    echo "⚡️"
  elif [ "$1" == *"mist"* ] || [ "$1" == *"fog"* ]; then
    echo "💨"
  elif ([ "$1" == *"rain"* ] || [ "$1" == *"drizzle"* ]) && [ "$1" != *"heavy"* ] ; then
    echo "🌦"
  elif ([ "$1" == *"rain"* ] || [ "$1" == *"drizzle"* ]) && [ "$1" == *"heavy"* ] ; then
    echo "🌧"
  elif [ "$1" == *"snow"* ] || [ "$1" == *"sleet"* ] ; then
    echo "❄️"
  else
    echo "$1"
  fi
}

COLOR="$(aqi_colorize ${AQI_RES})"

# remote the unnecessary quotes
WEATHER_RES_REALTIME_INFO="${WEATHER_RES_REALTIME_INFO#\"}"
WEATHER_RES_REALTIME_INFO="${WEATHER_RES_REALTIME_INFO%\"}"
WEATHER_RES_REALTIME_INFO_SYM=$(weather_sym "${WEATHER_RES_REALTIME_INFO}") # use quotes to prevent info loss

echo "🌡️${WEATHER_RES_REALTIME_INFO_SYM} ${WEATHER_RES_REALTIME_TEMPERATURE}℃ 😷${AQI_RES} | color=${COLOR} ${MENUFONT}"
echo "---"
echo "Today: 🌡️${WEATHER_RES_REALTIME_INFO} ${WEATHER_RES_REALTIME_TEMPERATURE}℃ 😷${AQI_RES}"
for(( i=0;i<WEATHER_FUTURE_LENGTH;i++)) do
  WEATHER_FUTURE_N=$(echo "${WEATHER_FUTURE}" | /usr/local/bin/jq ".[${i}]")
  # echo "${WEATHER_FUTURE_N}"
  WEATHER_FUTURE_N_DATE=$(echo "${WEATHER_FUTURE_N}" | /usr/local/bin/jq '.date')
  WEATHER_FUTURE_N_WEATHER=$(echo "${WEATHER_FUTURE_N}" | /usr/local/bin/jq '.day.condition.text')
  WEATHER_FUTURE_N_TEMPERATURE=$(echo "${WEATHER_FUTURE_N}" | /usr/local/bin/jq '.day.avgtemp_c')


  # remote the unnecessary quotes
  WEATHER_FUTURE_N_DATE="${WEATHER_FUTURE_N_DATE#\"}"
  WEATHER_FUTURE_N_DATE="${WEATHER_FUTURE_N_DATE%\"}"
  WEATHER_FUTURE_N_DATE="${WEATHER_FUTURE_N_DATE:5}"
  WEATHER_FUTURE_N_WEATHER="${WEATHER_FUTURE_N_WEATHER#\"}"
  WEATHER_FUTURE_N_WEATHER="${WEATHER_FUTURE_N_WEATHER%\"}"
  echo "${WEATHER_FUTURE_N_DATE} ${WEATHER_FUTURE_N_WEATHER}（${WEATHER_FUTURE_N_TEMPERATURE}℃）";
done;

# alerts

for(( i=0;i<${#ALERTS[@]};i++)) do
  ALERT=$(echo "${ALERTS}" | /usr/local/bin/jq ".[${i}]")
  MESSAGE=$(echo "${ALERT}" | /usr/local/bin/jq '.headline')
  MESSAGE="${MESSAGE#\"}"
  MESSAGE="${MESSAGE%\"}"
  echo "Alerts: ${MESSAGE}"
done;

# echo "AQI Detail... | href=${AQI_DETAIL_URL}"
echo "yxq大傻芝"
echo "Refresh... | refresh=true"

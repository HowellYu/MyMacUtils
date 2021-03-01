#!/bin/bash
#
# <bitbar.title>weather</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Chongyu Yuan</bitbar.author>
# <bitbar.author.github>nnnggel</bitbar.author.github>
# <bitbar.desc>real-time Chinese weather info(includes aqi), required jq(https://aqicn.org/api/) and aqi token(https://aqicn.org/api/)(</bitbar.desc>
# <bitbar.image>https://s2.ax1x.com/2019/04/01/As7pVO.jpg</bitbar.image>
# <bitbar.dependencies>bash,jq</bitbar.dependencies>
# <bitbar.abouturl>http://www.yuanchongyu.com</bitbar.abouturl>

MENUFONT="size=12 font=UbuntuMono-Bold"
COLORS=("#297722" "#ffde33" "#ff9933" "#cc0033" "#660099" "#7e0023")

# where to get the token -> https://www.juhe.cn/docs/api/id/73
WEATHER_TOKEN="670ed82cd4434825a3f45432210103"
WEATHER_CITY="Chicago" #eg. 上海
WEATHER_FUTURE_LENGTH=3

# WEATHER_DATA=$(curl -s "http://api.weatherapi.com/v1/current.json?key=${WEATHER_TOKEN}&q=${WEATHER_CITY}&aqi=yes")
WEATHER_DATA=$(curl -s "http://api.weatherapi.com/v1/forecast.json?key=${WEATHER_TOKEN}&q=${WEATHER_CITY}&days=${WEATHER_FUTURE_LENGTH}&aqi=yes")
WEATHER_FUTURE=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.forecast.forecastday')
# DELETE ME, TEST DATA
# WEATHER_DATA="{\"reason\":\"查询成功!\",\"result\":{\"city\":\"上海\",\"realtime\":{\"temperature\":\"15\",\"humidity\":\"25\",\"info\":\"晴\",\"wid\":\"00\",\"direct\":\"北风\",\"power\":\"0级\",\"aqi\":\"55\"},\"future\":[{\"date\":\"2019-04-01\",\"temperature\":\"9\\/17℃\",\"weather\":\"晴转多云\",\"wid\":{\"day\":\"00\",\"night\":\"01\"},\"direct\":\"南风\"},{\"date\":\"2019-04-02\",\"temperature\":\"11\\/16℃\",\"weather\":\"阴转多云\",\"wid\":{\"day\":\"02\",\"night\":\"01\"},\"direct\":\"东南风转东风\"},{\"date\":\"2019-04-03\",\"temperature\":\"11\\/17℃\",\"weather\":\"阴\",\"wid\":{\"day\":\"02\",\"night\":\"02\"},\"direct\":\"东风转东南风\"},{\"date\":\"2019-04-04\",\"temperature\":\"13\\/15℃\",\"weather\":\"小雨\",\"wid\":{\"day\":\"07\",\"night\":\"07\"},\"direct\":\"东南风转南风\"},{\"date\":\"2019-04-05\",\"temperature\":\"13\\/19℃\",\"weather\":\"多云\",\"wid\":{\"day\":\"01\",\"night\":\"01\"},\"direct\":\"西北风转南风\"}]},\"error_code\":0}"

# WEATHER_RES_REALTIME=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.result.realtime')
WEATHER_RES_REALTIME_INFO=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.condition.text')
WEATHER_RES_REALTIME_TEMPERATURE=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.temp_c')
AQI_DATA=$(echo "${WEATHER_DATA}" | /usr/local/bin/jq '.current.air_quality.pm2_5')

# DELETE ME, TEST DATA
# AQI_DATA="{\"status\":\"ok\",\"data\":{\"aqi\":824,\"idx\":1437,\"attributions\":[{\"url\":\"http://www.semc.gov.cn/\",\"name\":\"Shanghai Environment Monitoring Center(上海市环境监测中心)\"},{\"url\":\"http://106.37.208.233:20035/emcpublish/\",\"name\":\"China National Urban air quality real-time publishing platform (全国城市空气质量实时发布平台)\"},{\"url\":\"https://china.usembassy-china.org.cn/embassy-consulates/shanghai/air-quality-monitor-stateair/\",\"name\":\"U.S. Consulate Shanghai Air Quality Monitor\"},{\"url\":\"https://waqi.info/\",\"name\":\"World Air Quality Index Project\"}],\"city\":{\"geo\":[31.2047372,121.4489017],\"name\":\"Shanghai (上海)\",\"url\":\"https://aqicn.org/city/shanghai\"},\"dominentpol\":\"pm25\",\"iaqi\":{\"co\":{\"v\":6.4},\"h\":{\"v\":20.4},\"no2\":{\"v\":20.2},\"o3\":{\"v\":67.5},\"p\":{\"v\":1019.2},\"pm10\":{\"v\":57},\"pm25\":{\"v\":824},\"so2\":{\"v\":4.6},\"t\":{\"v\":17.5},\"w\":{\"v\":0.3}},\"time\":{\"s\":\"2019-04-01 17:00:00\",\"tz\":\"+08:00\",\"v\":1554138000},\"debug\":{\"sync\":\"2019-04-01T18:49:19+09:00\"}}}"

# how to install jq -> https://stedolan.github.io/jq/download/
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
  if [ "$1" -le 50 ]; then
    echo "${COLORS[0]}"
  elif [ "$1" -le 100 ]; then
    echo "${COLORS[1]}"
  elif [ "$1" -le 150 ]; then
    echo "${COLORS[2]}"
  elif [ "$1" -le 200 ]; then
    echo "${COLORS[3]}"
  elif [ "$1" -le 300 ]; then
    echo "${COLORS[4]}"
  else
    echo "${COLORS[5]}"
  fi
}

shopt -s nocasematch

function weather_sym {
  if [ "$1" ==  "Sunny" ]; then
    echo "☀️"
  elif [ "$1" ==  "Clear" ]; then
    echo "🌙"
  elif [ "$1" == "Partly cloudy" ] || [ "$1" == "Cloudy" ]; then
    echo "☁️"
  elif ( "$1" =~ *"thunder"* ); then
    echo "⚡️"
  elif [ "$1" =~ *"mist"* ] || [ "$1" =~ *"fog"* ]; then
    echo "💨"
  elif ([ "$1" =~ *"rain"* ] || [ "$1" =~ *"drizzle"* ]) && [ "$1" != *"heavy"* ] ; then
    echo "🌦"
  elif ([ "$1" =~ *"rain"* ] || [ "$1" =~ *"drizzle"* ]) && [ "$1" =~ *"heavy"* ] ; then
    echo "🌧"
  elif [ "$1" =~ *"snow"* ] || [ "$1" =~ *"sleet"* ] ; then
    echo "❄️"
  else
    echo "$1"
  fi
}



# function weather_sym {
#   if [ "$1" ==  "Sunny"]; then
#     echo "☀️"
#   if [ "$1" ==  "Clear"]; then
#     echo "🌙"
#   elif [ "$1" == "Partly cloudy" ] || [ "$1" == "Cloudy" ]; then
#     echo "☁️"
#   elif [ "$1" == "Mist" ] || [ "$1" == "Fog" ] || [ "$1" == *"mist"* ] || [ "$1" == *"fog"* ]; then
#     echo "💨"
#   elif [ "$1" == *"clear"* ]; then
#     echo "☀️"
#   elif [ "$1" == *"clear"* ]; then
#     echo "☀️"
#   else
#     echo "$1"
#   fi
# }

COLOR="$(aqi_colorize ${AQI_RES})"

# remote the unnecessary quotes
WEATHER_RES_REALTIME_INFO="${WEATHER_RES_REALTIME_INFO#\"}"
WEATHER_RES_REALTIME_INFO="${WEATHER_RES_REALTIME_INFO%\"}"
WEATHER_RES_REALTIME_INFO_SYM="$(weather_sym ${WEATHER_RES_REALTIME_INFO})"

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
  WEATHER_FUTURE_N_WEATHER="${WEATHER_FUTURE_N_WEATHER#\"}"
  WEATHER_FUTURE_N_WEATHER="${WEATHER_FUTURE_N_WEATHER%\"}"
  echo "${WEATHER_FUTURE_N_DATE} ${WEATHER_FUTURE_N_WEATHER}（${WEATHER_FUTURE_N_TEMPERATURE}℃）";
done;
# echo "AQI Detail... | href=${AQI_DETAIL_URL}"
echo "yxq大傻芝"
echo "Refresh... | refresh=true"

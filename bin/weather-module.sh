#!/usr/bin/env bash

set -u

# Configure sua cidade aqui. Ex: "Curitiba" ou "Rio de Janeiro"
CITY="Canoas"
# Código do país (ISO 3166-1 alpha-2). Ex: "BR"
COUNTRY_CODE="BR"

declare -A WEATHER_TEXT=(
  [0]="Céu limpo"
  [1]="Poucas nuvens"
  [2]="Parcialmente nublado"
  [3]="Nublado"
  [45]="Neblina"
  [48]="Neblina com gelo"
  [51]="Garoa fraca"
  [53]="Garoa moderada"
  [55]="Garoa intensa"
  [56]="Garoa congelante fraca"
  [57]="Garoa congelante intensa"
  [61]="Chuva fraca"
  [63]="Chuva moderada"
  [65]="Chuva forte"
  [66]="Chuva congelante fraca"
  [67]="Chuva congelante forte"
  [71]="Neve fraca"
  [73]="Neve moderada"
  [75]="Neve forte"
  [77]="Grãos de neve"
  [80]="Pancadas fracas"
  [81]="Pancadas moderadas"
  [82]="Pancadas fortes"
  [85]="Pancadas de neve fracas"
  [86]="Pancadas de neve fortes"
  [95]="Trovoadas"
  [96]="Trovoadas com granizo fraco"
  [99]="Trovoadas com granizo forte"
)

declare -A ICONS=(
  [0]=""
  [1]="󰖕"
  [2]="󰖕"
  [3]=""
  [45]=""
  [48]=""
  [51]=""
  [53]=""
  [55]=""
  [56]=""
  [57]=""
  [61]=""
  [63]=""
  [65]=""
  [66]=""
  [67]=""
  [71]=""
  [73]=""
  [75]=""
  [77]=""
  [80]=""
  [81]=""
  [82]=""
  [85]=""
  [86]=""
  [95]=""
  [96]=""
  [99]=""
)

sanitize_error() {
  local value=${1:-}
  value=${value//</}
  value=${value//>/}
  printf '%s' "$value"
}

print_error() {
  local title=$1
  local error=$2
  local safe_error
  safe_error=$(sanitize_error "$error")

  jq -cn --arg title "$title" --arg err "$safe_error" '{
    text: "",
    tooltip: ($title + "\n" + $err),
    class: "weather"
  }'
}

urlencode() {
  jq -rn --arg v "$1" '$v|@uri'
}

build_geocode_url() {
  local city=$1
  local country_code=$2
  local city_name city_query country_query

  city_name=${city%%,*}
  city_name=${city_name#"${city_name%%[![:space:]]*}"}
  city_name=${city_name%"${city_name##*[![:space:]]}"}

  city_query=$(urlencode "$city_name")
  country_query=$(urlencode "$country_code")

  printf '%s' "https://geocoding-api.open-meteo.com/v1/search?name=${city_query}&count=1&language=pt&format=json&country_code=${country_query}"
}

build_forecast_url() {
  local lat=$1
  local lon=$2
  printf '%s' "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true&daily=temperature_2m_min,temperature_2m_max,weathercode&timezone=auto"
}

fetch_with_retries() {
  local url=$1
  local attempts=${2:-3}
  local attempt output wait

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if output=$(curl -fsSL --connect-timeout 10 --max-time 15 -H "User-Agent: curl/8.0" -H "Accept: application/json" "$url" 2>&1); then
      printf '%s' "$output"
      return 0
    fi
    wait=$(awk "BEGIN { print 0.4 * ${attempt} }")
    sleep "$wait"
  done

  printf '%s' "${output:-Falha ao buscar dados}" >&2
  return 1
}

main() {
  local geocode_url geocode forecast_url forecast
  local city_name country admin1 lat lon
  local code daily_code desc icon temp min_temp max_temp temp_display
  local location_label tooltip_text

  if [[ -z "$CITY" ]]; then
    print_error "Erro inesperado:" "Defina CITY para busca via Open-Meteo"
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    print_error "Erro inesperado:" "Dependência ausente: jq"
    return 0
  fi

  geocode_url=$(build_geocode_url "$CITY" "$COUNTRY_CODE")
  if ! geocode=$(fetch_with_retries "$geocode_url"); then
    print_error "Erro de conexão:" "$geocode"
    return 0
  fi

  if ! lat=$(jq -er '.results[0].latitude' <<<"$geocode" 2>/dev/null); then
    print_error "Erro inesperado:" "Cidade não encontrada"
    return 0
  fi

  lon=$(jq -r '.results[0].longitude' <<<"$geocode")
  city_name=$(jq -r --arg fallback "$CITY" '.results[0].name // $fallback' <<<"$geocode")
  country=$(jq -r '.results[0].country // ""' <<<"$geocode")
  admin1=$(jq -r '.results[0].admin1 // ""' <<<"$geocode")

  forecast_url=$(build_forecast_url "$lat" "$lon")
  if ! forecast=$(fetch_with_retries "$forecast_url"); then
    print_error "Erro de conexão:" "$forecast"
    return 0
  fi

  temp=$(jq -r '.current_weather.temperature // empty' <<<"$forecast")
  if [[ -n "$temp" ]]; then
    temp_display=$(jq -nr --argjson t "$temp" '$t|floor')
  else
    temp_display=""
  fi

  code=$(jq -r '.current_weather.weathercode // ""' <<<"$forecast")
  min_temp=$(jq -r '.daily.temperature_2m_min[0] // ""' <<<"$forecast")
  max_temp=$(jq -r '.daily.temperature_2m_max[0] // ""' <<<"$forecast")
  daily_code=$(jq -r '.daily.weathercode[0] // ""' <<<"$forecast")

  desc=${WEATHER_TEXT[$code]:-${WEATHER_TEXT[$daily_code]:-Tempo instável}}
  icon=${ICONS[$code]:-}

  location_label=$(jq -nr --arg city "$city_name" --arg admin1 "$admin1" --arg country "$country" '[ $city, $admin1, $country ] | map(select(length > 0)) | join(", ")')
  tooltip_text="<b>📍 ${location_label}</b>"
  tooltip_text+=$'\n'"${desc}"
  tooltip_text+=$'\n'" ${min_temp}°C  /   ${max_temp}°C"

  jq -cn --arg icon "$icon" --arg temp "$temp_display" --arg tooltip "$tooltip_text" '{
    text: ($icon + " " + $temp + "°C"),
    tooltip: $tooltip,
    class: "weather"
  }'
}

main "$@"

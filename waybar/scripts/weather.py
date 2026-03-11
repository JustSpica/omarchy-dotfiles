#!/usr/bin/env python3
import json
import math
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request

# Configure sua cidade aqui. Ex: "Curitiba" ou "Rio de Janeiro"
CITY = "Canoas"
# Código do país (ISO 3166-1 alpha-2). Ex: "BR"
COUNTRY_CODE = "BR"

REQUEST_HEADERS = {
    "User-Agent": "curl/8.0",
    "Accept": "application/json",
}

WEATHER_TEXT = {
    "0": "Céu limpo",
    "1": "Poucas nuvens",
    "2": "Parcialmente nublado",
    "3": "Nublado",
    "45": "Neblina",
    "48": "Neblina com gelo",
    "51": "Garoa fraca",
    "53": "Garoa moderada",
    "55": "Garoa intensa",
    "56": "Garoa congelante fraca",
    "57": "Garoa congelante intensa",
    "61": "Chuva fraca",
    "63": "Chuva moderada",
    "65": "Chuva forte",
    "66": "Chuva congelante fraca",
    "67": "Chuva congelante forte",
    "71": "Neve fraca",
    "73": "Neve moderada",
    "75": "Neve forte",
    "77": "Grãos de neve",
    "80": "Pancadas fracas",
    "81": "Pancadas moderadas",
    "82": "Pancadas fortes",
    "85": "Pancadas de neve fracas",
    "86": "Pancadas de neve fortes",
    "95": "Trovoadas",
    "96": "Trovoadas com granizo fraco",
    "99": "Trovoadas com granizo forte",
}

ICONS = {
    "0": "",
    "1": "󰖕",
    "2": "󰖕",
    "3": "",
    "45": "",
    "48": "",
    "51": "",
    "53": "",
    "55": "",
    "56": "",
    "57": "",
    "61": "",
    "63": "",
    "65": "",
    "66": "",
    "67": "",
    "71": "",
    "73": "",
    "75": "",
    "77": "",
    "80": "",
    "81": "",
    "82": "",
    "85": "",
    "86": "",
    "95": "",
    "96": "",
    "99": "",
}


def sanitize_error(value):
    return str(value).replace("<", "").replace(">", "")


def print_error(title, error):
    safe_error = sanitize_error(error)
    print(json.dumps({
        "text": "",
        "tooltip": f"{title}\n{safe_error}",
        "class": "weather"
    }))


def build_geocode_url(city, country_code):
    city_name = city.split(",")[0].strip()
    city_query = urllib.parse.quote(city_name)
    country_query = urllib.parse.quote(country_code) if country_code else ""
    return (
        "https://geocoding-api.open-meteo.com/v1/search"
        f"?name={city_query}&count=1&language=pt&format=json"
        f"&country_code={country_query}"
    )


def build_forecast_url(lat, lon):
    return (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        "&current_weather=true"
        "&daily=temperature_2m_min,temperature_2m_max,weathercode"
        "&timezone=auto"
    )


def fetch_json(url, context):
    request = urllib.request.Request(url, headers=REQUEST_HEADERS)
    with urllib.request.urlopen(request, timeout=15, context=context) as response:
        return json.loads(response.read().decode("utf-8"))


def fetch_with_retries(url, context, attempts=3):
    last_error = None
    for attempt in range(attempts):
        try:
            return fetch_json(url, context)
        except (urllib.error.URLError, ssl.SSLError, TimeoutError) as e:
            last_error = e
            time.sleep(0.4 * (attempt + 1))
    if last_error is not None:
        raise last_error
    raise RuntimeError("Falha ao buscar dados")


def get_location(city, country_code, context):
    geocode_url = build_geocode_url(city, country_code)
    data = fetch_with_retries(geocode_url, context)
    results = data.get("results") or []
    if not results:
        raise RuntimeError("Cidade não encontrada")
    location = results[0]
    return {
        "lat": location["latitude"],
        "lon": location["longitude"],
        "city_name": location.get("name", city),
        "country": location.get("country", ""),
        "admin1": location.get("admin1", ""),
    }


def get_forecast(lat, lon, context):
    forecast_url = build_forecast_url(lat, lon)
    forecast = fetch_with_retries(forecast_url, context)
    current = forecast.get("current_weather") or {}
    daily = forecast.get("daily") or {}
    return current, daily


def format_tooltip(location_label, desc, min_temp, max_temp):
    tooltip_text = f"<b>📍 {location_label}</b>\n"
    tooltip_text += f"{desc}\n"
    tooltip_text += f" {min_temp}°C  /   {max_temp}°C"
    return tooltip_text


def format_output(icon, temp, tooltip_text):
    return {
        "text": f"{icon} {temp}°C",
        "tooltip": tooltip_text,
        "class": "weather"
    }

def main():
    try:
        # Codifica o nome da cidade para URL (Open-Meteo Geocoding)
        if not CITY:
            raise RuntimeError("Defina CITY para busca via Open-Meteo")

        context = ssl.create_default_context()
        location = get_location(CITY, COUNTRY_CODE, context)
        current, daily = get_forecast(location["lat"], location["lon"], context)

        temp = current.get("temperature")
        temp_display = math.floor(temp) if temp is not None else ""
        code = str(current.get("weathercode", ""))
        min_temp = (daily.get("temperature_2m_min") or [""])[0]
        max_temp = (daily.get("temperature_2m_max") or [""])[0]
        daily_code = str((daily.get("weathercode") or [""])[0])

        desc = WEATHER_TEXT.get(code) or WEATHER_TEXT.get(daily_code, "Tempo instável")
        icon = ICONS.get(code, "")

        location_parts = [
            part for part in [location["city_name"], location["admin1"], location["country"]]
            if part
        ]
        location_label = ", ".join(location_parts)

        tooltip_text = format_tooltip(location_label, desc, min_temp, max_temp)
        print(json.dumps(format_output(icon, temp_display, tooltip_text)))

    except (urllib.error.URLError, ssl.SSLError, TimeoutError) as e:
        print_error("Erro de conexão:", e)
    except Exception as e:
        print_error("Erro inesperado:", e)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import json
import urllib.request
import urllib.parse

CITY = "Canoas,RS"

def main():
    try:
        city_query = urllib.parse.quote(CITY) if CITY else ""
        url = f"https://wttr.in/{city_query}?format=j1&lang=pt"
        
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())

        current = data['current_condition'][0]
        
        try:
            desc = current['lang_pt'][0]['value']
        except Exception as e:
            safe_error = str(e).replace("<", "").replace(">", "")
            print(json.dumps({
                "text": "", 
                "tooltip": f"Erro de conexão:\n{safe_error}",
                "class": "weather"
            }))

        today = data['weather'][0]
        min_temp = today['mintempC']
        max_temp = today['maxtempC']
        
        city_name = data['nearest_area'][0]['areaName'][0]['value']
        
        temp = current['temp_C']
        code = current['weatherCode'] 

        icons = {
            "113": "",  # Sunny
            "116": "󰖕",  # PartlyCloudy
            "119": "",  # Cloudy
            "122": "",  # VeryCloudy
            "143": "", # Fog
            "176": "",  # LightRain
            "200": "",  # ThunderyShowers
            "266": "",  # LightRain
            "308": "",  # HeavyRain
            "395": ""   # Snow
        }
        
        icon = icons.get(code, "")
        
        tooltip_text = f"<b>📍 {city_name}</b>\n"
        tooltip_text += f"{desc.capitalize()}\n"
        tooltip_text += f" {min_temp}°C  /   {max_temp}°C\n"
        tooltip_text += f"Sensação: {current['FeelsLikeC']}°C"

        print(json.dumps({
            "text": f"{icon} {temp}°C",
            "tooltip": tooltip_text,
            "class": "weather"
        }))

    except Exception as e:
        print(json.dumps({"text": "Err", "tooltip": str(e)}))

if __name__ == "__main__":
    main()

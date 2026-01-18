#!/usr/bin/env python3
import sys
import subprocess
import json
import re

FILLED = "▮"
EMPTY = "▯"
BAR_LENGTH = 10

MIN_K = 4000
MAX_K = 6000
STEP = 200

def get_progress_bar(percent):
    filled_len = int(round(percent * BAR_LENGTH / 100))
    
    filled_len = max(0, min(filled_len, BAR_LENGTH))
    empty_len = BAR_LENGTH - filled_len
    return (FILLED * filled_len) + (EMPTY * empty_len)

def get_current_k():
    try:
        output = subprocess.check_output(["hyprctl", "hyprsunset", "temperature"], text=True, stderr=subprocess.DEVNULL).strip()

        match = re.search(r'\d+', output)
        if match:
            return int(match.group(0))
        return MAX_K 
    except:
        return MAX_K

def change_temperature(direction):
    current = get_current_k()
    
    if direction == "up":
        new_k = current - STEP
    else:
        new_k = current + STEP
    
    new_k = max(MIN_K, min(new_k, MAX_K))
    
    subprocess.run(["hyprctl", "hyprsunset", "temperature", str(new_k)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    print(json.dumps({}))

def get_volume():
    try:
        vol_output = subprocess.check_output(["pamixer", "--get-volume"], text=True).strip()
        percent = int(vol_output)
        
        mute_output = subprocess.check_output(["pamixer", "--get-mute"], text=True).strip()
        is_muted = mute_output == "true"

        bar = get_progress_bar(percent)

        if is_muted or percent == 0:
            icon = ""
        else:
            icon = ""
                
        return {
            "text": f"<span color='#f9e2af'>{icon} {bar}</span>",
            "tooltip": f"Volume: {percent}% {'(Silenciado)' if is_muted else ''}"
        }
    except:
        return {"text": "", "tooltip": ""}

def get_temperature():
    current_k = get_current_k()

    is_active = current_k < MAX_K

    if is_active:
        range_k = MAX_K - MIN_K
        diff = MAX_K - current_k
        percent = int((diff / range_k) * 100)

        bar = get_progress_bar(percent)
        text_state = f"{current_k}K"
    else:
        bar = get_progress_bar(0)
        text_state = "Off"

    return {
        "text": f"<span color='#f38ba8'> {bar}</span>",
        "tooltip": f"Night Light: {text_state} (Hyprsunset)",
        "class": "active" if is_active else "inactive"
    }

def main():
    if len(sys.argv) < 2: return
    mode = sys.argv[1]

    if mode == "volume":
        print(json.dumps(get_volume()))
    elif mode == "temperature":
        print(json.dumps(get_temperature()))
    elif mode == "temperature_up":
        change_temperature("up")
    elif mode == "temperature_down":
        change_temperature("down")

if __name__ == "__main__":
    main()

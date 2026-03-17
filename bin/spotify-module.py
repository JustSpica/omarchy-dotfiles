#!/usr/bin/env python3
import json
import subprocess
import sys

def format_time(microseconds):
    seconds = int(microseconds / 1000000)
    minutes = seconds // 60
    seconds = seconds % 60
    return f"{minutes}:{seconds:02}"

def create_progress_bar(current, total, length=15):
    if total == 0:
        return "━" * length
    
    percent = current / total
    filled_length = int(length * percent)
    
    filled_length = min(filled_length, length)
    
    bar = "━" * filled_length + "" + "━" * (length - filled_length)
    return bar

def main():
    try:
        status = subprocess.check_output(
            ["playerctl", "-p", "spotify", "status"], 
            text=True, stderr=subprocess.DEVNULL
        ).strip()

        if status == "Playing":
            metadata_cmd = ["playerctl", "-p", "spotify", "metadata", "--format", 
                          "{{artist}}::{{title}}::{{mpris:length}}::{{position}}"]
            
            meta_str = subprocess.check_output(metadata_cmd, text=True).strip()
            artist, title, length_str, position_str = meta_str.split("::")

            length_micro = int(length_str) if length_str else 0
            position_micro = int(position_str) if position_str else 0
            
            time_now = format_time(position_micro)
            time_total = format_time(length_micro)
            progress_bar = create_progress_bar(position_micro, length_micro)
            
            track_text = f"{artist} - {title}"
            if len(track_text) > 35:
                track_text = track_text[:32] + "..."
            
            track_text = track_text.replace("&", "&amp;")
            escaped_artist = artist.replace("&", "&amp;")
            escaped_title = title.replace("&", "&amp;")

            tooltip_lines = [
                f"{escaped_artist} - {escaped_title}",
                f"<span color='#a6adc8'>{time_now}  {progress_bar}  {time_total}</span>"
            ]

            print(json.dumps({
                "text": f"<span color='#1db954'>[   {track_text} ]</span>",
                "class": "playing",
                "tooltip": "\n".join(tooltip_lines)
            }))
            
        else:
            raise Exception("Paused")

    except Exception:
        print(json.dumps({
            "text": "<span color='#e5c07b'>[   404 - Not Found ]</span>",
            "class": "stopped",
            "tooltip": "Spotify desconectado ou pausado."
        }))

if __name__ == "__main__":
    main()

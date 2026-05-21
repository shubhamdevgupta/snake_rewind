#!/usr/bin/env python3
"""Generates minimal retro WAV files."""
import math
import struct
import wave
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "audio"
SAMPLE_RATE = 22050


def write_tone(path: Path, freq: float, duration: float, volume: float = 0.35) -> None:
    n = int(SAMPLE_RATE * duration)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        for i in range(n):
            t = i / SAMPLE_RATE
            env = 1.0 - (i / n)
            s = volume * env * math.sin(2 * math.pi * freq * t)
            wf.writeframes(struct.pack("<h", int(s * 32767)))


def write_game_over(path: Path) -> None:
    n = int(SAMPLE_RATE * 0.6)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        for i in range(n):
            t = i / SAMPLE_RATE
            freq = 440 - (t * 300)
            env = 1.0 - (i / n)
            s = 0.3 * env * math.sin(2 * math.pi * freq * t)
            wf.writeframes(struct.pack("<h", int(s * 32767)))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    write_tone(OUT / "click.wav", 880, 0.04)
    write_tone(OUT / "eat.wav", 1200, 0.08)
    write_game_over(OUT / "game_over.wav")
    write_tone(OUT / "bg.wav", 220, 1.2, volume=0.08)
    print(f"Wrote sounds to {OUT}")


if __name__ == "__main__":
    main()

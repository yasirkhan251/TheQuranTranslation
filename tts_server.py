#!/usr/bin/env python3
"""Local neural text-to-speech endpoint for Noor Quran Companion.

Install with: python -m pip install -r requirements-tts.txt
Run with:     python tts_server.py
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs
import asyncio
import io
import os

import edge_tts

HOST = "127.0.0.1"
PORT = 8000
VOICES = {
    "en": "en-US-AriaNeural",
    "ur": "ur-PK-UzmaNeural",
}

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path != "/api/tts":
            self.send_error(404, "Not found")
            return
        params = parse_qs(parsed.query)
        language = params.get("tl", ["en"])[0].lower().split("-")[0]
        text = params.get("q", [""])[0].strip()
        if language not in VOICES:
            self.send_error(400, "Language must be en or ur")
            return
        if not text:
            self.send_error(400, "Text is required")
            return
        if len(text) > 1500:
            self.send_error(413, "Please request a shorter verse")
            return
        try:
            audio = asyncio.run(self.generate(text, VOICES[language]))
        except Exception as exc:
            print("TTS generation failed:", repr(exc), flush=True)
            self.send_error(502, "Voice provider failed. Check internet and voice availability.")
            return
        self.send_response(200)
        self.send_header("Content-Type", "audio/mpeg")
        self.send_header("Content-Length", str(len(audio)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(audio)

    async def generate(self, text, voice):
        stream = edge_tts.Communicate(text, voice)
        output = bytearray()
        async for chunk in stream.stream():
            if chunk["type"] == "audio":
                output.extend(chunk["data"])
        if not output:
            raise RuntimeError("Voice provider returned no audio")
        return bytes(output)

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)

if __name__ == "__main__":
    print(f"Noor TTS server listening on http://{HOST}:{PORT}", flush=True)
    print("Voices: English en-US-AriaNeural | Urdu ur-PK-UzmaNeural", flush=True)
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()

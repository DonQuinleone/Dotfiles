#!/usr/bin/env python3

import argparse
import os
import signal
import subprocess
import sys
import threading
from collections import deque
from queue import Queue

import numpy

SAMPLE_RATE = 16000
FRAME_MS = 30
FRAME_SAMPLES = SAMPLE_RATE * FRAME_MS // 1000
FRAME_BYTES = FRAME_SAMPLES * 2
BYTES_PER_MS = SAMPLE_RATE * 2 / 1000

SILENCE_FLUSH_MS = 1200
MIN_SPEECH_MS = 400
MIN_SEGMENT_MS = 5000
MAX_SEGMENT_MS = 24000

CALIBRATION_FRAMES = 10
SPEECH_MARGIN = 3.0
MIN_SPEECH_RMS = 90.0
FLOOR_DECAY = 0.95
FULL_SCALE = 32768.0

RECORD_COMMAND = [
    "pw-record",
    "--rate", str(SAMPLE_RATE),
    "--channels", "1",
    "--format", "s16",
    "--raw",
    "-",
]


def samples_of(raw):
    return numpy.frombuffer(
        bytes(raw), dtype=numpy.int16).astype(numpy.float32)


def frame_rms(frame):
    samples = samples_of(frame)
    return float(numpy.sqrt(numpy.mean(samples * samples)))


def to_float(buffer):
    return samples_of(buffer) / FULL_SCALE


# The model loads inside the worker so that capture starts at
# once: the load overlaps with the first thing being said.
class Transcriber:
    def __init__(self, model, threads, language):
        self.model_name = model
        self.threads = threads
        self.language = language
        self.queue = Queue()
        self.parts = []
        self.worker = threading.Thread(target=self._run)
        self.worker.start()

    def submit(self, audio):
        self.queue.put(audio)

    def finish(self):
        self.queue.put(None)
        self.worker.join()
        return " ".join(part for part in self.parts if part)

    def _run(self):
        from faster_whisper import WhisperModel

        model = WhisperModel(
            self.model_name,
            device="cpu",
            compute_type="int8",
            cpu_threads=self.threads,
        )
        while True:
            audio = self.queue.get()
            if audio is None:
                return
            self.parts.append(self._transcribe(model, audio))

    def _transcribe(self, model, audio):
        segments, _ = model.transcribe(
            audio,
            language=self.language,
            beam_size=1,
            condition_on_previous_text=False,
            initial_prompt=self.parts[-1] if self.parts else None,
        )
        return "".join(part.text for part in segments).strip()


class Segmenter:
    def __init__(self):
        self.buffer = bytearray()
        self.speech_ms = 0
        self.silence_ms = 0
        self.floor = None
        self.calibration = deque(maxlen=CALIBRATION_FRAMES)

    def add(self, frame):
        self.buffer += frame
        level = frame_rms(frame)
        if self.floor is None:
            self.calibration.append(level)
            if len(self.calibration) == CALIBRATION_FRAMES:
                self.floor = sum(self.calibration) / \
                    CALIBRATION_FRAMES
            self.silence_ms += FRAME_MS
            return
        if level >= self._threshold():
            self.speech_ms += FRAME_MS
            self.silence_ms = 0
            return
        self.silence_ms += FRAME_MS
        self.floor = FLOOR_DECAY * self.floor + \
            (1 - FLOOR_DECAY) * level

    def _threshold(self):
        return max(MIN_SPEECH_RMS, self.floor * SPEECH_MARGIN)

    def duration_ms(self):
        return len(self.buffer) / BYTES_PER_MS

    def ready(self):
        if self.speech_ms < MIN_SPEECH_MS:
            return False
        if self.duration_ms() >= MAX_SEGMENT_MS:
            return True
        return (self.silence_ms >= SILENCE_FLUSH_MS
                and self.duration_ms() >= MIN_SEGMENT_MS)

    def has_speech(self):
        return self.speech_ms >= MIN_SPEECH_MS

    def take(self):
        audio = to_float(self.buffer)
        self.buffer = bytearray()
        self.speech_ms = 0
        self.silence_ms = 0
        return audio


def emit(text, command):
    if not text:
        return
    subprocess.run(command, input=text.encode(), check=False)


def parse_arguments():
    parser = argparse.ArgumentParser(prog="dictate-engine")
    parser.add_argument("--model", default=os.environ.get(
        "DICTATE_MODEL", "small.en"))
    parser.add_argument("--threads", type=int, default=int(
        os.environ.get("DICTATE_THREADS", "6")))
    parser.add_argument("--language", default=os.environ.get(
        "DICTATE_LANGUAGE", "en"))
    return parser.parse_args()


def output_command():
    configured = os.environ.get("DICTATE_OUTPUT")
    if configured:
        return configured.split()
    return ["wtype", "-"]


def record_command():
    configured = os.environ.get("DICTATE_RECORD")
    if configured:
        return configured.split()
    return RECORD_COMMAND


def main():
    options = parse_arguments()
    recorder = subprocess.Popen(
        record_command(), stdout=subprocess.PIPE)

    def halt(_signal, _frame):
        recorder.terminate()

    signal.signal(signal.SIGTERM, halt)
    signal.signal(signal.SIGINT, halt)

    transcriber = Transcriber(
        options.model, options.threads, options.language)
    segmenter = Segmenter()

    while True:
        frame = recorder.stdout.read(FRAME_BYTES)
        if len(frame) < FRAME_BYTES:
            break
        segmenter.add(frame)
        if segmenter.ready():
            transcriber.submit(segmenter.take())

    if segmenter.has_speech():
        transcriber.submit(segmenter.take())
    emit(transcriber.finish().strip(), output_command())
    return 0


if __name__ == "__main__":
    sys.exit(main())

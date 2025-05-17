import subprocess

command = [
    "f5-tts_infer-cli",
    "--model", "F5TTS_v1_Base",
    "--ref_audio", "sample1.wav",
    "--ref_text", "The quick brown fox jumps over the lazy dog. Today is a beautiful day to learn something new. Please record this sentence clearly and at a natural pace.",
    "--gen_text", "My name is varun ananthakrishnan and im a gay femboy twink.",
    "--output_file", "output_f5tts.wav"
]

try:
    subprocess.run(command, check=True)
    print("TTS generation completed successfully.")
except subprocess.CalledProcessError as e:
    print("An error occurred while running the command:", e)

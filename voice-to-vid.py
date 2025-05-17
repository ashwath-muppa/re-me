import subprocess

image_path = "arthur.png"
audio_path = "tests/output_f5tts.wav"
result_dir = "results"

command = [
    "python", "inference.py",
    "--driven_audio", audio_path,
    "--source_image", image_path,
    "--result_dir", result_dir
]

subprocess.run(command, check=True)
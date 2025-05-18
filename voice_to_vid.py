import subprocess

def run_voice_to_video(image_path="volvo.png", audio_path="fin.wav", result_dir="DONE"):
    command = [
        "python", "inference.py",
        "--driven_audio", audio_path,
        "--source_image", image_path,
        "--result_dir", result_dir
    ]
    subprocess.run(command, check=True)

# Example usage:
# run_voice_to_video()
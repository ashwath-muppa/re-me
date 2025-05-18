import subprocess

def run_f5_tts_infer(
    model="F5TTS_v1_Base",
    ref_audio="audios/2025-May.wav",
    ref_text="The quick brown fox jumps over the lazy dog. Today is a beautiful day to learn something new. Please record this sentence clearly and at a natural pace.",
    gen_text="hi",
    output_file="tmp_output.wav"
):
    command = [
        "f5-tts_infer-cli",
        "--model", model,
        "--ref_audio", ref_audio,
        "--ref_text", ref_text,
        "--gen_text", gen_text,
        "--output_file", output_file
    ]
    try:
        print("Running TTS generation...")
        subprocess.run(command, check=True)
        print("TTS generation completed successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print("An error occurred while running the command:", e)
        return False

# Remove or comment out this block to avoid running on import
# if __name__ == "__main__":
#       run_f5_tts_infer()

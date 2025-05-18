import whisper
import os

def transcribe_audio(audio_file_path, model_size="base"):
    """
    Transcribe audio file using OpenAI's Whisper model

    Parameters:
    - audio_file_path: Path to the audio file
    - model_size: Whisper model size (tiny, base, small, medium, large)

    Returns:
    - Transcribed text as a string, or None if an error occurs
    """
    if not os.path.exists(audio_file_path):
        print(f"Error: File {audio_file_path} not found")
        return None

    print(f"Loading Whisper {model_size} model...")
    model = whisper.load_model(model_size)

    print(f"Transcribing {audio_file_path}...")
    result = model.transcribe(audio_file_path)

    return result.get("text", "")

# Driver for testing the function directly
if __name__ == "__main__":
    # Replace this path with your actual test audio file
    test_audio = "C:/Users/arnav/Downloads/FallenHillsDr2(1).m4a"
    test_model = "base"

    print("Running test transcription with demo values...")
    transcription = transcribe_audio(test_audio, test_model)

    if transcription:
        print("Transcription result:\n")
        print(transcription)
    else:
        print("Transcription failed.")
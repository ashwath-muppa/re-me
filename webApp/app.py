from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from textresponse import get_response
import os
import speech_recognition as sr
import io
from pydub import AudioSegment
from voice_to_voice import run_f5_tts_infer
import uuid
from voice_to_vid import run_voice_to_video 

from flask_session import Session

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# Configure server-side session
app.config['SESSION_TYPE'] = 'filesystem'  # You can also use 'redis', 'memcached', etc.
app.config['SESSION_FILE_DIR'] = '/Users/ashwathreddymuppa/time-face/session_files'  # Ensure this directory exists
app.config['SESSION_PERMANENT'] = False
app.config['SESSION_USE_SIGNER'] = True
app.config['SESSION_KEY_PREFIX'] = 'myapp_'

# Initialize the session
Session(app)

JOURNALS_DIR = "/Users/ashwathreddymuppa/time-face/journals"
AUDIO_DIR = "/Users/ashwathreddymuppa/time-face/audios"
IMAGE_DIR = "/Users/ashwathreddymuppa/time-face/images"

def read_journal_entries():
    """Read all journal entries from the journal directory."""
    journal_entries = {}
    for filename in os.listdir(JOURNALS_DIR):
        if filename.endswith('.txt'):
            year, month = filename.replace('.txt', '').split('-')
            file_path = os.path.join(JOURNALS_DIR, filename)
            with open(file_path, 'r') as file:
                entries = file.read().strip().split('---\n')
                journal_entries[(month, year)] = entries
    return journal_entries

@app.route('/')
@app.route('/journal', methods=['GET', 'POST'])
def journal():
    months = []
    journal_entries = {}  # Ensure journal_entries is initialized
    existing_audios = {}
    existing_images = {}

    # Ensure the journals directory exists
    if not os.path.exists(JOURNALS_DIR):
        os.makedirs(JOURNALS_DIR, exist_ok=True)
        return render_template('journal.html', months=months, journal_entries=journal_entries, existing_audios=existing_audios, existing_images=existing_images, now=datetime.now())

    # List all .txt files in the journals directory
    journal_files = [f for f in os.listdir(JOURNALS_DIR) if f.endswith('.txt')]

    for filename in journal_files:
        file_path = os.path.join(JOURNALS_DIR, filename)
        year_str, month_name = filename.replace('.txt', '').split('-')

        month_year_key = (month_name, year_str)

        if month_year_key not in months:
            months.append(month_year_key)
            journal_entries[month_year_key] = []

        # Check if the audio file exists for this month and year
        audio_filename = f"{year_str}-{month_name}.wav"
        existing_audios[month_year_key] = os.path.exists(os.path.join(AUDIO_DIR, audio_filename))

        # Check if the image file exists for this month and year
        image_filename = f"{year_str}-{month_name}.png"
        existing_images[month_year_key] = os.path.exists(os.path.join(IMAGE_DIR, image_filename))

        try:
            with open(file_path, 'r') as f:
                content = f.read()

            entry_blocks = content.strip().split('---\n')
            for block in entry_blocks:
                if not block.strip():
                    continue

                lines = block.strip().split('\n')
                entry_date = None
                entry_content_lines = []

                for line in lines:
                    if line.startswith('Date: '):
                        entry_date = line.replace('Date: ', '').strip()
                    else:
                        entry_content_lines.append(line)

                entry_content = '\n'.join(entry_content_lines).strip()

                if entry_date and entry_content:
                    journal_entries[month_year_key].append({
                        'content': entry_content,
                        'date': entry_date
                    })
                elif entry_date:
                    journal_entries[month_year_key].append({
                        'content': '',
                        'date': entry_date
                    })

        except Exception as e:
            print(f"Error reading or parsing file {filename}: {e}")

    return render_template('journal.html', months=months, journal_entries=journal_entries, existing_audios=existing_audios, existing_images=existing_images, now=datetime.now())

@app.route('/add_month', methods=['POST'])
def add_month():
    month_name = request.form.get('month_name')
    year = request.form.get('year')

    # Read existing journal entries to get the list of existing months/years
    journal_entries = read_journal_entries()
    existing_months = list(journal_entries.keys()) # Get the list of (month, year) tuples

    # Check if the new month/year combination already exists
    if month_name and year and (month_name, year) not in existing_months:
        # Create a new text file for the month and year
        # Assuming get_journal_file_path is defined elsewhere and works correctly
        # If not, you'll need to define it or construct the path here
        file_path = os.path.join(JOURNALS_DIR, f"{year}-{month_name}.txt")

        if not os.path.exists(file_path):
            try:
                with open(file_path, 'w') as file:
                    file.write("")  # Create an empty file
            except Exception as e:
                print(f"Error creating journal file {file_path}: {e}")
                # Optionally, return an error message to the user

    # Redirect back to the journal page to display the updated list
    return redirect(url_for('journal'))

def get_journal_file_path(year, month):
    """Construct the file path for a journal entry based on year and month."""
    return os.path.join(JOURNALS_DIR, f"{year}-{month}.txt")

@app.route('/add_entry/<month>/<year>', methods=['POST'])
def add_entry(month, year):
    journal_entries = read_journal_entries()  # Load journal entries here
    entry_content = request.form.get('entry_content')
    entry_date = request.form.get('entry_date')
    audio_file = request.files.get('audio_file')  # Get the uploaded audio file
    month_year_key = (month, year)

    if month_year_key in journal_entries and entry_content and entry_date:
        # Format date as YYYY-MM for month grouping
        formatted_month = f"{year}-{month}"

        journal_entries[month_year_key].append({
            'content': entry_content,
            'date': entry_date
        })

        # Save each entry directly into the text file for the month and year
        journal_filename = get_journal_file_path(year, month)

        # Append the entry to the journal file
        with open(journal_filename, "a") as f:
            f.write(f"Date: {entry_date}\n")
            f.write(f"{entry_content}\n")
            f.write("---\n")

        # Save the audio file in a separate audios directory if it exists
        if audio_file:
            audio_dir = "/Users/ashwathreddymuppa/time-face/audios"
            os.makedirs(audio_dir, exist_ok=True)
            audio_filename = os.path.join(audio_dir, f"{entry_date}.wav")
            audio_file.save(audio_filename)

        # Redirect back to the journal page
        return redirect(url_for('journal'))

    return "Failed to save journal entry. Please ensure all fields are filled correctly."
    return redirect(url_for('journal'))

@app.route('/chat', methods=['GET', 'POST'])
def chat():
    print(session.get('response_mode'))
    if 'chat_history' not in session:
        session['chat_history'] = []

    # Ensure journal_entries is defined
    journal_entries = read_journal_entries()  # Load journal entries from the function

    # Define months based on the journal entries
    months = list(journal_entries.keys())

    selected_month = session.get('selected_month')
    chat_message = None

    if request.method == 'POST':
        new_selected_month = request.form.get('selected_month')
        audio_file = request.files.get('audio_file')

        if new_selected_month and (new_selected_month != selected_month):
            session['chat_history'] = []
            session['selected_month'] = new_selected_month
            selected_month = new_selected_month
            if not request.form.get('chat_message') and not audio_file:
                 session.modified = True
                 pass

        # Process audio file if present
        if audio_file and selected_month:
            r = sr.Recognizer()
            try:
                # Use pydub to load the audio file
                audio_segment = AudioSegment.from_file(audio_file)

                # Convert to a format speech_recognition likes (e.g., 16-bit PCM WAV)
                wav_file = io.BytesIO()
                audio_segment.export(wav_file, format="wav")
                wav_file.seek(0) # Rewind the BytesIO object to the beginning

                audio_data = sr.AudioFile(wav_file)
                with audio_data as source:
                    audio = r.record(source)

                transcribed_text = r.recognize_google(audio)
                chat_message = transcribed_text

                session['chat_history'].append({
                    'type': 'user',
                    'content': chat_message,
                    'timestamp': datetime.now().strftime("%H:%M")
                })

            except sr.UnknownValueError:
                chat_message = None
                if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                     session['chat_history'].append({
                        'type': 'bot',
                        'content': "❌ Could not understand audio",
                        'timestamp': datetime.now().strftime("%H:%M")
                    })
                     session.modified = True
                     return jsonify({'chat_history': session.get('chat_history', [])})
                else:
                    pass

            except sr.RequestError as e:
                chat_message = None
                error_msg = f"❌ Speech recognition service error: {e}"
                print(error_msg)
                if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                     session['chat_history'].append({
                        'type': 'bot',
                        'content': error_msg,
                        'timestamp': datetime.now().strftime("%H:%M")
                    })
                     session.modified = True
                     return jsonify({'chat_history': session.get('chat_history', [])})
                else:
                    pass

            except Exception as e:
                 chat_message = None
                 error_msg = f"❌ An error occurred processing audio: {str(e)}"
                 print(error_msg)
                 if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                     session['chat_history'].append({
                        'type': 'bot',
                        'content': error_msg,
                        'timestamp': datetime.now().strftime("%H:%M")
                    })
                     session.modified = True
                     return jsonify({'chat_history': session.get('chat_history', [])})
                 else:
                    pass

        if chat_message is None:
             chat_message = request.form.get('chat_message')

        if chat_message and selected_month:
            if not audio_file:
                 session['chat_history'].append({
                    'type': 'user',
                    'content': chat_message,
                    'timestamp': datetime.now().strftime("%H:%M")
                })

            try:
                month_name, year = selected_month.split()
                journal_month = f"{month_name} {year}"

                bot_response = get_response(chat_message, journal_month)

                if session.get('response_mode') == 'voice':
                    ref_audio_path = f"/Users/ashwathreddymuppa/time-face/audios/{year}-{month_name}.wav"
                    audio_id = str(uuid.uuid4())
                    generated_audio_dir = "/Users/ashwathreddymuppa/time-face/static/generated_audio"
                    os.makedirs(generated_audio_dir, exist_ok=True)
                    output_file = f"{generated_audio_dir}/{audio_id}.wav"
                    tts_success = run_f5_tts_infer(
                        ref_audio=ref_audio_path,
                        gen_text=bot_response,
                        output_file=output_file
                    )
                    if tts_success:
                        # Speed up the audio by 10x using pydub
                        audio_url = f"/static/generated_audio/{audio_id}.wav"
                        session['chat_history'].append({
                            'type': 'bot_audio',
                            'audio_url': audio_url,
                            'timestamp': datetime.now().strftime("%H:%M")
                        })
                    else:
                        session['chat_history'].append({
                            'type': 'bot',
                            'content': "❌ Voice generation failed.",
                            'timestamp': datetime.now().strftime("%H:%M")
                        })
                elif session.get('response_mode') == 'video':
                    # Use the hardcoded video URL, ensuring it's accessible via /static
                    # Make sure the video file is located in your static/DONE directory
                    video_url = "/static/generated_audio/vo.mp4"
                    
                    session['chat_history'].append({
                        'type': 'bot_video',
                        'video_url': video_url,
                        'timestamp': datetime.now().strftime("%H:%M")
                    })
                else:
                    session['chat_history'].append({
                        'type': 'bot',
                        'content': bot_response,
                        'timestamp': datetime.now().strftime("%H:%M")
                    })
            except ValueError:
                 session['chat_history'].append({
                    'type': 'bot',
                    'content': "❌ Please select a valid month first",
                    'timestamp': datetime.now().strftime("%H:%M")
                })
            except Exception as e:
                 session['chat_history'].append({
                    'type': 'bot',
                    'content': f"❌ An error occurred: {str(e)}",
                    'timestamp': datetime.now().strftime("%H:%M")
                })

            session.modified = True

            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({'chat_history': session.get('chat_history', [])})

        elif request.headers.get('X-Requested-With') == 'XMLHttpRequest':
             return jsonify({'chat_history': session.get('chat_history', [])})

    return render_template('chat.html',
                         months=months,
                         selected_month=selected_month,
                         chat_history=session.get('chat_history', []))

@app.route('/view_entry/<month>/<year>/<int:index>')
def view_entry(month, year, index):
    journal_entries = read_journal_entries()  # Load journal entries here to make them accessible in this function

    month_year_key = (month, year)

    if month_year_key not in journal_entries or index >= len(journal_entries[month_year_key]):
        return redirect(url_for('journal'))

    entry = journal_entries[month_year_key][index]
    return render_template('view_entry.html', entry=entry, month=month, year=year)

@app.route('/settings', methods=['GET', 'POST'])
def settings():
    if request.method == 'POST':
        # Save the selected response mode to the session
        session['response_mode'] = request.form.get('response_mode')
        return redirect(url_for('settings'))  # Redirect back to settings page after saving

    # Retrieve the current mode from the session
    current_mode = session.get('response_mode', 'text')  # Default to 'text' if not set
    return render_template('settings.html', current_mode=current_mode)

@app.route('/upload_audio/<month>/<year>', methods=['POST'])
def upload_audio(month, year):
    audio_file = request.files.get('audio_file')
    audio_uploaded = False
    chat_history = session.get('chat_history', [])
    if audio_file:
        audio_dir = "/Users/ashwathreddymuppa/time-face/audios"
        os.makedirs(audio_dir, exist_ok=True)
        audio_filename = os.path.join(audio_dir, f"{year}-{month}.wav")
        
        if os.path.exists(audio_filename):
            audio_uploaded = True
            return jsonify({
                'chat_history': chat_history,
                'audio_uploaded': audio_uploaded,
                'message': 'Audio already exists'
            }), 409

        audio_file.save(audio_filename)
        audio_uploaded = True
        return jsonify({
            'chat_history': chat_history,
            'audio_uploaded': audio_uploaded,
            'message': 'Audio uploaded successfully'
        }), 200

    return jsonify({
        'chat_history': chat_history,
        'audio_uploaded': audio_uploaded,
        'message': 'No audio file uploaded'
    }), 400

@app.route('/upload_image/<month>/<year>', methods=['POST'])
def upload_image(month, year):
    image_file = request.files.get('image_file')
    image_uploaded = False
    chat_history = session.get('chat_history', [])
    if image_file:
        image_dir = "/Users/ashwathreddymuppa/time-face/images"
        os.makedirs(image_dir, exist_ok=True)
        image_filename = os.path.join(image_dir, f"{year}-{month}.png")
        
        # Check if the image file already exists
        if os.path.exists(image_filename):
            image_uploaded = True
            return jsonify({
                'chat_history': chat_history,
                'image_uploaded': image_uploaded,
                'message': 'Image already exists'
            }), 409  # HTTP 409 Conflict

        image_file.save(image_filename)
        image_uploaded = True
        return jsonify({
            'chat_history': chat_history,
            'image_uploaded': image_uploaded,
            'message': 'Image uploaded successfully'
        }), 200

    return jsonify({
        'chat_history': chat_history,
        'image_uploaded': image_uploaded,
        'message': 'No image file uploaded'
    }), 400

JOURNALS_DIR = '/Users/ashwathreddymuppa/time-face/journals'

def add_journal_entry(year, month, entry_content, entry_date):
    """Add a new journal entry to the specified year and month file."""
    file_path = get_journal_file_path(year, month)
    with open(file_path, 'a') as file:
        file.write(f"Date: {entry_date}\n{entry_content}\n---\n")

if __name__ == '__main__':
    app.run(debug=True)



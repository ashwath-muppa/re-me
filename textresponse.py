import os
import re
import google.generativeai as genai

# Load API key
with open("apikey.txt", "r") as f:
    api_key = f.read().strip()

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-1.5-flash")

# Update the journal pattern to match new format
journal_pattern = re.compile(r"Date: (.+)\n(.*?)(?=---)", re.DOTALL)

def get_response(user_input, journal_month):
    try:
        # Convert "Month Year" to "YYYY-Month" format
        month_name, year = journal_month.split()
        search_month = f"{year}-{month_name}"
        
        filename = f"/Users/ashwathreddymuppa/time-face/journals/{search_month}.txt"
        
        # Ensure the directory exists
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        # Create the file if it doesn't exist
        if not os.path.exists(filename):
            with open(filename, "w") as f:
                f.write("")  # Create an empty file
        
        with open(filename, "r") as f:
            content = f.read()
            
        matches = journal_pattern.findall(content)
        if not matches:
            return "❌ No journals found for this month. Try selecting another or writing a new entry."
            
        journal_text = "\n\n".join([f"{date}\n{text}" for date, text in matches])

        system_prompt = f"""
I am a person who wrote the following journal(s) in {journal_month}. I need you to pretend to be me from that time.
You are no longer Google Gemini but rather me from the past. Only respond as I would, and do not overdo anything
or overuse words. Respond accurately and match the style, capitalization, and tone of how I wrote the journals.
Don't be overly long unless asked to. Be brief, emotionally accurate, and authentic.

These are the journal entries:
{journal_text}
"""
        chat = model.start_chat()
        response = chat.send_message(system_prompt + f"\n\nCurrent self: {user_input}\nPast self:")
        return response.text.strip()
        
    except Exception as e:
        return f"❌ Error processing your request: {str(e)}"

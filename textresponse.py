import os
import re
import google.generativeai as genai

# Load API key
with open("apikey.txt", "r") as f:
    api_key = f.read().strip()

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-1.5-flash")

# Load journal entries
with open("journals.txt", "r", encoding="utf-8") as f:
    raw_text = f.read()

# Match: Journal N (YYYY-MM-DD)
journal_pattern = re.compile(r"(Journal \d+)\s+\((\d{4}-\d{2})-\d{2}\)\s+(.*?)(?=Journal \d+ \(|\Z)", re.DOTALL)
journals = journal_pattern.findall(raw_text)

# Build dictionary: month -> list of (title, text)
journals_by_month = {}
for title, month, text in journals:
    if month not in journals_by_month:
        journals_by_month[month] = []
    journals_by_month[month].append((title, text.strip()))

def get_response(user_input, journal_month):
    if journal_month not in journals_by_month or not journals_by_month[journal_month]:
        return "❌ No journals found for this month. Try selecting another or writing a new entry."

    selected_entries = journals_by_month[journal_month]
    journal_text = "\n\n".join([f"{title}\n{text}" for title, text in selected_entries])

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

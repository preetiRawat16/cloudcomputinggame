from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import os

app = Flask(__name__)
CORS(app)  # Allows all origins; adjust for specific domains if needed

# Use absolute path to avoid DB issues in Docker/Render
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'leaderboard.db')

# Initialize the database and table
def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            score INTEGER NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

init_db()

@app.route('/')
def home():
    return "Leaderboard API with SQLite is running."

@app.route('/submit', methods=['POST'])
def submit_score():
    data = request.get_json()
    name = data.get('name', '').strip()
    score = data.get('score')

    if name and isinstance(score, int) and 0 <= score <= 100000:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('INSERT INTO scores (name, score) VALUES (?, ?)', (name, score))
        conn.commit()
        conn.close()
        print(f"Saved: {name} - {score}")
        return jsonify({'message': 'Score saved'}), 200
    else:
        return jsonify({'error': 'Invalid input'}), 400

@app.route('/leaderboard', methods=['GET'])
def get_leaderboard():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('SELECT name, score FROM scores ORDER BY score DESC LIMIT 10')
    results = cursor.fetchall()
    conn.close()

    leaderboard = [{'name': name, 'score': score} for name, score in results]
    return jsonify(leaderboard)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)
DB_NAME = 'leaderboard.db'

# Create DB table if it doesn't exist
def init_db():
    conn = sqlite3.connect(DB_NAME)
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
    name = data.get('name')
    score = data.get('score')

    if name and isinstance(score, int):
        conn = sqlite3.connect(DB_NAME)
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
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('SELECT name, score FROM scores ORDER BY score DESC')
    results = cursor.fetchall()
    conn.close()

    leaderboard = [{'name': name, 'score': score} for name, score in results]
    return jsonify(leaderboard)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

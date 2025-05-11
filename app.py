from flask import Flask, request, jsonify
from operator import itemgetter

app = Flask(__name__)

# In-memory leaderboard (resets on every restart)
leaderboard = []

@app.route('/')
def home():
    return "Leaderboard API is running."

@app.route('/submit', methods=['POST'])
def submit_score():
    data = request.get_json()
    name = data.get('name')
    score = data.get('score')
    
    if name and isinstance(score, int):
        leaderboard.append({'name': name, 'score': score})
        print(f"Received score: {name} - {score}")
        return jsonify({'message': 'Score received', 'name': name, 'score': score}), 200
    else:
        return jsonify({'error': 'Invalid input'}), 400

@app.route('/leaderboard', methods=['GET'])
def get_leaderboard():
    leaderboard.sort(key=lambda x: x['score'], reverse=True)  # Sort descending
    return jsonify(leaderboard)

if __name__ == '__main__':
    app.run(debug=True)

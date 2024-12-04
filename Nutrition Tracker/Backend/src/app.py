from flask import Flask, request, jsonify
from firebase_manager import FirebaseManager
from nutrition_manager import NutritionManager
from datetime import datetime

app = Flask(__name__)
firebase = FirebaseManager()
nutrition = NutritionManager(firebase.db)


@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})


@app.route('/create_user', methods=['POST'])
def create_user():
    data = request.json
    result = firebase.create_user(
        data['email'],
        data['password'],
        {
            'name': data.get('name'),
            'age': data.get('age'),
            'weight': data.get('weight'),
            'height': data.get('height'),
            'goalWeight': data.get('goalWeight')
        }
    )
    return jsonify(result)


@app.route('/daily_progress/<user_id>/<date>', methods=['GET', 'POST'])
def handle_daily_progress(user_id, date):
    if request.method == 'POST':
        data = request.json
        result = nutrition.update_daily_progress(user_id, date, data)
        return jsonify(result)
    else:
        result = nutrition.get_daily_progress(user_id, date)
        return jsonify(result or {'status': 'error', 'message': 'No data found'})


if __name__ == '__main__':
    app.run(debug=True)

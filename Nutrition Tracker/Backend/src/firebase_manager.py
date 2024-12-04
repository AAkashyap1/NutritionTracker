from firebase_admin import credentials, firestore, auth
import firebase_admin
from datetime import datetime, timedelta
from typing import Dict, Any, Optional


class FirebaseManager:
    def __init__(self, config_path: str):
        cred = credentials.Certificate(config_path)
        try:
            firebase_admin.initialize_app(cred)
        except ValueError:
            pass
        self.db = firestore.client()

    async def create_user(self, email: str, password: str, user_data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            user = auth.create_user(
                email=email,
                password=password
            )

            user_ref = self.db.collection('users').document(user.uid)
            user_ref.set({
                **user_data,
                'created_at': firestore.SERVER_TIMESTAMP
            })

            return {'status': 'success', 'user_id': user.uid}
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

    async def get_daily_progress(self, user_id: str) -> Optional[Dict[str, Any]]:
        try:
            today = datetime.now().strftime('%Y-%m-%d')
            doc = self.db.collection('users').document(user_id)\
                .collection('daily_progress').document(today).get()

            if doc.exists:
                return doc.to_dict()
            return None
        except Exception as e:
            print(f"Error getting daily progress: {str(e)}")
            return None

    async def update_daily_progress(self, user_id: str, progress_data: Dict[str, Any]) -> bool:
        try:
            today = datetime.now().strftime('%Y-%m-%d')
            doc_ref = self.db.collection('users').document(user_id)\
                .collection('daily_progress').document(today)

            doc = doc_ref.get()
            if doc.exists:
                existing_progress = doc.to_dict()
            else:
                existing_progress = {
                    'calories': 0,
                    'protein': 0,
                    'carbs': 0,
                    'fats': 0,
                    'fiber': 0,
                    'water': 0
                }

            updated_progress = {
                'calories': existing_progress.get('calories', 0) + progress_data.get('calories', 0),
                'protein': existing_progress.get('protein', 0) + progress_data.get('protein', 0),
                'carbs': existing_progress.get('carbs', 0) + progress_data.get('carbs', 0),
                'fats': existing_progress.get('fats', 0) + progress_data.get('fats', 0),
                'fiber': existing_progress.get('fiber', 0) + progress_data.get('fiber', 0),
                'water': existing_progress.get('water', 0) + progress_data.get('water', 0)
            }

            doc_ref.set(updated_progress)
            return True
        except Exception as e:
            print(f"Error updating daily progress: {str(e)}")
            return False

    async def reset_daily_progress(self) -> None:
        """Reset all users' daily progress (to be called at midnight)."""
        try:
            users = self.db.collection('users').stream()
            today = datetime.now().strftime('%Y-%m-%d')

            for user in users:
                self.db.collection('users').document(user.id)\
                    .collection('daily_progress').document(today)\
                    .set({
                        'calories': 0,
                        'protein': 0,
                        'carbs': 0,
                        'fats': 0,
                        'fiber': 0,
                        'water': 0
                    })
        except Exception as e:
            print(f"Error resetting daily progress: {str(e)}")

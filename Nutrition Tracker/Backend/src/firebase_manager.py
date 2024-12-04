from firebase_admin import credentials, firestore, auth, initialize_app
from fastapi import HTTPException
from typing import Dict, Any, Optional
from datetime import datetime
import asyncio


class FirebaseManager:
    def __init__(self, config_path: str):
        try:
            try:
                self.app = initialize_app(credentials.Certificate(config_path))
            except ValueError:
                pass

            self.db = firestore.client()
            print("Firebase initialized successfully")
        except Exception as e:
            print(f"Firebase initialization error: {str(e)}")
            raise

    async def create_user_profile(self, user_id: str, profile_data: dict) -> dict:
        try:
            print(
                f"Attempting to create user profile with data: {profile_data}")

            doc_ref = self.db.collection('users').document(user_id)
            doc_ref.set(profile_data)

            doc = doc_ref.get()
            if not doc.exists:
                raise Exception("Failed to verify document creation")

            print(f"Successfully created user profile for {user_id}")
            return profile_data

        except Exception as e:
            print(f"Detailed Firestore Error: {str(e)}")
            raise HTTPException(
                status_code=400,
                detail=f"Failed to create user profile: {str(e)}"
            )

    async def sign_in_user(self, email: str, password: str) -> dict:
        try:
            user = auth.get_user_by_email(email)
            doc = self.db.collection('users').document(user.uid).get()
            if not doc.exists:
                raise HTTPException(
                    status_code=404, detail="User profile not found")
            return doc.to_dict()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def get_user(self, user_id: str) -> dict:
        try:
            doc = self.db.collection('users').document(user_id).get()
            if not doc.exists:
                raise HTTPException(status_code=404, detail="User not found")
            return doc.to_dict()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

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

import cv2
import numpy as np
import pytesseract
from PIL import Image
import io
import re
from typing import Dict, Optional
from ..models.schemas import NutritionData


class NutritionLabelProcessor:
    def __init__(self):
        self.nutrient_patterns = {
            'calories': [
                r'calories[\s]+(\d+)',
                r'energy[:\s]+(\d+)',
                r'cal[\s.]+(\d+)'
            ],
            'protein': [
                r'protein[\s]+(\d{1,3})g',
                r'protein[\s]+(\d{1,3})\s*g',
                r'protein[\s]+(\d{1,3})'
            ],
            'carbs': [
                r'total carbohydrate[\s]+(\d{1,3})g',
                r'carbohydrate[\s]+(\d{1,3})g',
                r'total carbohydrate[\s]+(\d{1,3})',
                r'carbohydrate[\s]+(\d{1,3})'
            ],
            'fats': [
                r'total fat[\s]+(\d{1,3})g',
                r'fat[\s]+(\d{1,3})g',
                r'total fat[\s]+(\d{1,3})',
                r'fat[\s]+(\d{1,3})'
            ],
            'fiber': [
                r'dietary fiber[\s]+(\d{1,3})g',
                r'fiber[\s]+(\d{1,3})g',
                r'dietary fiber[\s]+(\d{1,3})',
                r'fiber[\s]+(\d{1,3})'
            ]
        }

    def preprocess_image(self, image_data: bytes) -> np.ndarray:
        """Preprocess image for better OCR results."""
        try:
            nparr = np.frombuffer(image_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

            gray = cv2.convertScaleAbs(gray, alpha=1.5, beta=0)

            thresh = cv2.adaptiveThreshold(
                gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                cv2.THRESH_BINARY, 11, 2
            )

            denoised = cv2.fastNlMeansDenoising(thresh)

            bordered = cv2.copyMakeBorder(
                denoised, 10, 10, 10, 10,
                cv2.BORDER_CONSTANT, value=255
            )

            return bordered

        except Exception as e:
            print(f"Error in preprocessing image: {str(e)}")
            raise

    def extract_value(self, text: str, nutrient: str) -> Optional[float]:
        """Extract nutrient value using multiple regex patterns."""
        try:
            text = text.lower().strip()
            patterns = self.nutrient_patterns.get(nutrient.lower(), [])

            for pattern in patterns:
                match = re.search(pattern, text)
                if match:
                    value_str = match.group(1)
                    value_str = ''.join(
                        c for c in value_str if c.isdigit() or c == '.')
                    try:
                        return float(value_str)
                    except ValueError:
                        continue

            return None

        except Exception as e:
            print(f"Error extracting {nutrient}: {str(e)}")
            return None

    def process_image(self, image_data: bytes) -> NutritionData:
        """Process nutrition label image and extract nutrition information."""
        try:
            processed_img = self.preprocess_image(image_data)

            custom_config = r'--oem 3 --psm 6'

            text = pytesseract.image_to_string(
                processed_img, config=custom_config)

            lines = text.split('\n')
            full_text = ' '.join(lines)

            nutrition_values = {}
            for nutrient in ['calories', 'protein', 'carbs', 'fats', 'fiber']:
                value = None
                for line in lines:
                    value = self.extract_value(line, nutrient)
                    if value is not None:
                        break

                if value is None:
                    value = self.extract_value(full_text, nutrient)

                nutrition_values[nutrient] = value if value is not None else 0.0

            print(f"Extracted values: {nutrition_values}")

            return NutritionData(**nutrition_values)

        except Exception as e:
            print(f"Error processing image: {str(e)}")
            return NutritionData(
                calories=0.0,
                protein=0.0,
                carbs=0.0,
                fats=0.0,
                fiber=0.0
            )

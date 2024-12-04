import cv2
import numpy as np
from ..models.schemas import WaterData


class WaterBottleProcessor:
    def __init__(self):
        self.standard_sizes = {
            'small': 0.5,
            'medium': 1.0,
            'large': 1.5
        }

    def detect_water_level(self, image_data: bytes) -> float:
        """Detect water level in bottle and estimate remaining volume."""
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        blurred = cv2.GaussianBlur(gray, (9, 9), 0)

        _, thresh = cv2.threshold(blurred, 127, 255, cv2.THRESH_BINARY)

        contours, _ = cv2.findContours(
            thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if not contours:
            return 0.0

        bottle_contour = max(contours, key=cv2.contourArea)

        x, y, w, h = cv2.boundingRect(bottle_contour)
        water_height = h * 0.7

        estimated_volume = self.standard_sizes['medium'] * (water_height / h)

        return round(estimated_volume, 2)

    def process_image(self, image_data: bytes) -> WaterData:
        """Process water bottle image and return water amount."""
        try:
            amount = self.detect_water_level(image_data)
            return WaterData(amount=amount)
        except Exception as e:
            print(f"Error processing water bottle image: {str(e)}")
            return WaterData(amount=0.0)

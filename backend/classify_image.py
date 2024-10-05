import os
# Tắt tất cả các log của TensorFlow (bao gồm cả tiến trình training và dự đoán)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

import sys
import tensorflow as tf
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image

# Load model đã huấn luyện
model = load_model('vgg16_model.h5', compile=False)

# Danh sách ánh xạ từ class_idx tới loại vải
fabric_classes = ['Cotton', 'Silk', 'Denim', 'Polyester', 'Linen', 'Wool', 'Nylon']  # Thay bằng các loại vải tương ứng với mô hình của bạn

def classify_image(image_path):
    try:
        # Mở ảnh và chuyển đổi sang RGB
        img = Image.open(image_path).convert('RGB')
        img = img.resize((224, 224))  # Điều chỉnh kích thước ảnh cho phù hợp với mô hình VGG16
        
        # Chuẩn hóa ảnh
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # Dự đoán loại vải
        predictions = model.predict(img_array)

        # Kiểm tra xem dự đoán có hợp lệ không
        if predictions is None or len(predictions) == 0:
            return None, None
        
        class_idx = np.argmax(predictions)
        confidence = predictions[0][class_idx]

        # Kiểm tra confidence, nếu quá thấp thì trả về không nhận diện được
        if confidence < 0.5:  # Ngưỡng confidence là 50%
            return None, None
        return fabric_classes[class_idx], confidence  # Trả về loại vải và độ tin cậy
    except Exception as e:
        print(f"Error during image classification: {e}")
        return None, None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Vui lòng cung cấp đường dẫn ảnh.")
        sys.exit(1)

    image_path = sys.argv[1]  # Đường dẫn ảnh được truyền từ Node.js
    fabric_type, confidence = classify_image(image_path)

    # Nếu không phân loại được, trả về thông báo lỗi
    if fabric_type is None:
        print('Không nhận diện được')
    else:
        # In ra loại vải và độ tin cậy
        print(f'{fabric_type},{confidence}')

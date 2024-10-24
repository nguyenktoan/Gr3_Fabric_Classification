import os
# Tắt tất cả các log của TensorFlow (bao gồm cả tiến trình training và dự đoán)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

import sys
import tensorflow as tf
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image

# Load model đã huấn luyện
model = load_model('base_line_resnet50.h5', compile=False)

# Danh sách ánh xạ từ class_idx tới loại vải (theo yêu cầu mới)
fabric_classes = ['Cotton', 'Denim', 'Nylon', 'Polyester', 'Silk', 'Wool']

def classify_image(image_path):
    try:
        # Mở ảnh và kiểm tra lỗi nếu không mở được
        try:
            img = Image.open(image_path).convert('RGB')
        except Exception:
            return None, None
        
        img = img.resize((224, 224))  # Điều chỉnh kích thước ảnh cho phù hợp với mô hình

        # Chuẩn hóa ảnh
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # Dự đoán loại vải
        predictions = model.predict(img_array, verbose=0)  # Tắt thông báo progress

        # Kiểm tra xem dự đoán có hợp lệ không
        if predictions is None or len(predictions) == 0:
            return None, None
        
        class_idx = np.argmax(predictions)
        confidence = predictions[0][class_idx]

        # Kiểm tra confidence, nếu quá thấp thì trả về không nhận diện được
        if confidence < 0.5:  # Ngưỡng confidence là 50%
            return None, None

        # Trả về loại vải và độ tin cậy
        return fabric_classes[class_idx], confidence

    except Exception:
        return None, None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)  # Không in ra thông báo lỗi, chỉ thoát nếu không có đường dẫn ảnh

    image_path = sys.argv[1]  # Đường dẫn ảnh được truyền từ Node.js
    fabric_type, confidence = classify_image(image_path)  # Lưu kết quả vào biến

    # Nếu không phân loại được, không trả về thông báo nào
    if fabric_type is None:
        sys.exit(1)  # Thoát mà không làm gì thêm

    # Nếu có kết quả, in ra kết quả
    print(f'{fabric_type},{confidence}')  # Chỉ in ra kết quả cuối cùng

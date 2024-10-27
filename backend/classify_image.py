import os
import joblib
import numpy as np
from keras.preprocessing import image
from keras.applications.resnet50 import ResNet50, preprocess_input
from sklearn.preprocessing import Normalizer
from keras.models import load_model
import sys

# Tắt tất cả các log của TensorFlow (bao gồm cả tiến trình training và dự đoán)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

# Danh sách ánh xạ từ class_idx tới loại vải
fabric_classes = ['Cotton', 'Denim', 'Nylon', 'Polyester', 'Silk', 'Wool']

class FabricClassificationPipeline:
    def __init__(self, mlp_model_path, resnet_model_path):
        # Đường dẫn đến mô hình
        self.mlp_model_path = mlp_model_path

        # Tải mô hình ResNet50 từ đường dẫn đã cho
        self.resnet_model = load_model(resnet_model_path, compile=False)
        # print("ResNet50 model loaded successfully from", resnet_model_path)

        # Tải mô hình MLP đã huấn luyện
        self.mlp_model = joblib.load(self.mlp_model_path)
        # print("MLP model loaded successfully.")

        # Khởi tạo normalizer
        self.normalizer = Normalizer()

    def load_and_preprocess_image(self, image_path):
        # Kiểm tra xem file có tồn tại không
        if not os.path.exists(image_path):
            print(f"File not found: {image_path}")
            raise FileNotFoundError(f"File not found: {image_path}")

        # Tải và xử lý ảnh
        img = image.load_img(image_path, target_size=(224, 224))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = preprocess_input(img_array)
        return img_array

    def extract_features(self, img_array):
        # Trích xuất đặc trưng từ ResNet50
        features = self.resnet_model.predict(img_array)
        return features.reshape(1, -1)

    def normalize_features(self, features):
        # Chuẩn hóa đặc trưng
        return self.normalizer.fit_transform(features)

    def classify_image(self, image_path):
        # 1. Xử lý ảnh
        img_array = self.load_and_preprocess_image(image_path)

        # 2. Trích xuất đặc trưng
        features = self.extract_features(img_array)

        # 3. Chuẩn hóa đặc trưng
        normalized_features = self.normalize_features(features)

        # 4. Dự đoán với MLP model
        try:
            predictions = self.mlp_model.predict(normalized_features)
            confidence_scores = self.mlp_model.predict_proba(normalized_features)

            class_idx = predictions[0]
            confidence = confidence_scores[0][class_idx]

            # Nếu độ tin cậy dưới 50%, trả về không xác định
            if confidence < 0.5:
                return None, None

            # Trả về kết quả dự đoán loại vải và độ tin cậy
            return fabric_classes[class_idx], confidence

        except Exception as e:
            print(f"Prediction error: {e}")
            return None, None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)  # Không in ra thông báo lỗi, chỉ thoát nếu không có đường dẫn ảnh

    image_path = sys.argv[1]  # Đường dẫn ảnh được truyền từ Node.js
    mlp_model_path = 'MLP_model_full_train.pkl'  # Đường dẫn tới mô hình MLP
    resnet_model_path = 'resnet50_feature_extractor.h5'  # Đường dẫn tới mô hình ResNet50

    # Tạo đối tượng pipeline
    pipeline = FabricClassificationPipeline(mlp_model_path, resnet_model_path)

    # Phân loại hình ảnh
    fabric_type, confidence = pipeline.classify_image(image_path)

    # Nếu không phân loại được, không trả về thông báo nào
    if fabric_type is None:
        sys.exit(1)  # Thoát mà không làm gì thêm

    # Nếu có kết quả, in ra kết quả
    print(f'{fabric_type},{confidence}')  # Chỉ in ra kết quả cuối cùng
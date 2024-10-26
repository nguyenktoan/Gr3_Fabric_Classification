import os
import joblib
import numpy as np
from keras.preprocessing import image
from keras.applications.resnet50 import ResNet50, preprocess_input
from sklearn.preprocessing import Normalizer
import time
from keras.models import load_model
import sys

# Tắt tất cả các log của TensorFlow (bao gồm cả tiến trình training và dự đoán)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

class FabricClassificationPipeline:
    def __init__(self, mlp_model_path, resnet_model_path):
        # Đường dẫn đến mô hình
        self.mlp_model_path = mlp_model_path

        # Tải mô hình ResNet50 từ đường dẫn đã cho
        self.resnet_model = load_model(resnet_model_path, compile=False)
        print("ResNet50 model loaded successfully from", resnet_model_path)

        # Tải mô hình MLP đã huấn luyện
        self.mlp_model = joblib.load(self.mlp_model_path)
        print("MLP model loaded successfully.")

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

    def predict_with_mlp(self, normalized_features):
        # Dự đoán với MLP model
        try:
            predictions = self.mlp_model.predict(normalized_features)
            confidence_scores = self.mlp_model.predict_proba(normalized_features)

            label_mapping = {0: 'Cotton', 1: 'Denim', 2: 'Nylon', 3: 'Polyester', 4: 'Silk', 5: 'Wool'}
            predicted_label = label_mapping.get(predictions[0], "Unknown")
            predicted_confidence = confidence_scores[0][predictions[0]] * 100

            if predicted_confidence < 50:
                predicted_label, predicted_confidence = "Unclassified", 0.0

            # In kết quả theo định dạng yêu cầu
            print(f"{predicted_label},{predicted_confidence:.2f}")
            return predicted_label, predicted_confidence
        except Exception as e:
            print(f"Prediction error: {e}")
            return None, None

    def run_pipeline(self, image_path):
        # Pipeline chính để xử lý và dự đoán ảnh
        start_time = time.time()

        # 1. Xử lý ảnh
        img_array = self.load_and_preprocess_image(image_path)

        # 2. Trích xuất đặc trưng
        features = self.extract_features(img_array)

        # 3. Chuẩn hóa đặc trưng
        normalized_features = self.normalize_features(features)

        # 4. Dự đoán nhãn
        predicted_label, predicted_confidence = self.predict_with_mlp(normalized_features)


        return predicted_label, predicted_confidence

# Đường dẫn đến mô hình MLP và ResNet50 đã lưu
mlp_model_path = 'MLP_model_full_train.pkl'  # Đường dẫn tới mô hình MLP
resnet_model_path = 'resnet50_feature_extractor.h5'  # Đường dẫn tới mô hình ResNet50

# Tạo đối tượng pipeline
pipeline = FabricClassificationPipeline(mlp_model_path, resnet_model_path)

# Lấy đường dẫn ảnh từ tham số command line
image_path = sys.argv[1]

# Chạy pipeline với ảnh đã tải lên
predicted_label, predicted_confidence = pipeline.run_pipeline(image_path)

# In kết quả theo định dạng yêu cầu
if predicted_label is not None and predicted_confidence is not None:
    print(f"{predicted_label},{predicted_confidence:.2f}")
else:
    print("Error during prediction.")

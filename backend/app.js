const express = require('express');
const multer = require('multer');
const { spawn } = require('child_process');
const path = require('path');
const mongoose = require('mongoose');  // Thêm mongoose để kết nối MongoDB
const app = express();
const port = 3000;

// Kết nối tới MongoDB
mongoose.connect('mongodb://localhost:27017/fabricDB')
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((err) => {
    console.error('Error connecting to MongoDB', err);
  });

// Định nghĩa schema và model cho loại vải
const fabricSchema = new mongoose.Schema({
  type: String,           // Loại vải
  confidence: Number,      // Độ tin cậy của mô hình
  imageUrl: String,        // Đường dẫn tới hình ảnh
  processedInfo: String,   // Hướng dẫn xử lý vải
  timestamp: {             // Thời gian phân loại
    type: Date,
    default: Date.now
  }
});

const Fabric = mongoose.model('Fabric', fabricSchema);

// Cấu hình multer để lưu file upload vào thư mục "uploads"
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, './uploads');  // Lưu ảnh vào thư mục 'uploads'
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));  // Đặt tên file theo timestamp
  }
});
const upload = multer({ storage: storage });

// Phục vụ các file tĩnh từ thư mục "uploads"
app.use('/uploads', express.static('uploads'));

// Thêm thông tin xử lý vải dựa trên loại vải
const getProcessedInfo = (fabricType) => {
  const processedInfoMap = {
    'Cotton': 'Wash in cold water, avoid high temperature drying.',
    'Silk': 'Dry clean only.',
    'Wool': 'Hand wash with cold water, lay flat to dry.',
    // Thêm các loại vải và hướng dẫn xử lý tương ứng khác
  };

  return processedInfoMap[fabricType] || 'No specific care instructions available.';
};

// Route POST để upload ảnh và phân loại
app.post('/upload', upload.single('image'), (req, res) => {
  const file = req.file;

  if (!file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const imagePath = path.join(__dirname, file.path);  // Đường dẫn đầy đủ tới ảnh

  // Gọi Python script để phân loại hình ảnh
  const pythonProcess = spawn('python3', ['classify_image.py', imagePath]);

  let responseSent = false;

  // Biểu thức chính quy để tìm kiếm kết quả đúng
  const resultPattern = /^[a-zA-Z]+,[0-9.]+$/;

  pythonProcess.stdout.on('data', async (data) => {
    if (!responseSent) {
      const output = data.toString().trim();

      // Kiểm tra kết quả có đúng định dạng không
      if (resultPattern.test(output)) {
        const [fabricType, confidence] = output.split(',');

        // Lấy hướng dẫn xử lý vải từ loại vải đã phân loại
        const processedInfo = getProcessedInfo(fabricType.trim());

        // Lưu kết quả vào MongoDB
        const newFabric = new Fabric({
          type: fabricType.trim(),
          confidence: parseFloat(confidence),
          imageUrl: `http://localhost:3000/uploads/${file.filename}`,  // Đường dẫn đầy đủ tới file ảnh đã upload
          processedInfo: processedInfo            // Thêm hướng dẫn xử lý vải
        });

        try {
          await newFabric.save();  // Lưu vào MongoDB
          res.status(200).json({
            message: 'File uploaded and classified successfully',
            result: {
              class: fabricType.trim(),
              confidence: parseFloat(confidence),
              imageUrl: `http://localhost:3000/uploads/${file.filename}`,  // Đường dẫn đầy đủ tới file ảnh đã upload
              processedInfo: processedInfo            // Trả về hướng dẫn xử lý vải
            }
          });
        } catch (err) {
          console.error('Error saving to MongoDB', err);
          res.status(500).json({ error: 'Error saving classification to database' });
        }

        responseSent = true;
      }
    }
  });

  pythonProcess.stderr.on('data', (data) => {
    console.error(`Python error: ${data}`);
    if (!responseSent) {
      res.status(500).json({ error: 'Error during classification' });
      responseSent = true;
    }
  });

  pythonProcess.on('close', (code) => {
    if (!responseSent) {
      res.status(500).json({ error: 'No response from Python script' });
    }
  });
});

// Chạy server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});

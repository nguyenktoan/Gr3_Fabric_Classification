const express = require('express');
const multer = require('multer');
const { spawn } = require('child_process');
const path = require('path');
const { Pool } = require('pg');  // Thêm thư viện PostgreSQL
const app = express();
const port = 3000;

// Cấu hình PostgreSQL
const pool = new Pool({
    user: 'postgres.dwxyindbkbapffajbdug', // Thay bằng tên người dùng PostgreSQL của bạn
    host: 'aws-0-ap-southeast-1.pooler.supabase.com', // Hoặc địa chỉ của máy chủ PostgreSQL của bạn
    database: 'postgres', // Tên cơ sở dữ liệu của bạn
    password: 'HuaTuanVi168@', // Mật khẩu của bạn
    port: 5432, // Cổng của PostgreSQL, mặc định là 5432
});

// Ánh xạ từ tên loại vải sang ID
const fabricTypeToId = {
    'Cotton': '1',
    'Denim': '2',
    'Nylon': '3',
    'Polyester': '4',
    'Silk': '5',
    'Wool': '6'
};

// Hàm để viết hoa chữ cái đầu của loại vải
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
}

// Cấu hình multer để lưu file upload vào thư mục "uploads"
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './uploads');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Phục vụ các file tĩnh từ thư mục "uploads"
app.use('/uploads', express.static('uploads'));

// **URL công khai từ Ngrok**
// **URL công khai từ Ngrok**
const ngrokBaseUrl = 'https://d6b5-2401-d800-bf1-3fe7-8d92-e1f4-617-5d5a'; // Thay bằng URL công khai từ Ngrok

// **API Upload ảnh**
app.post('/uploadImage', upload.single('image'), (req, res) => {
    const file = req.file;

    if (!file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }

    // Sử dụng URL từ ngrok cho hình ảnh
    const imageUrl = `${ngrokBaseUrl}/uploads/${file.filename}`;
    res.status(200).json({ message: 'Image uploaded successfully', imageUrl });
});


// **API Phân loại ảnh bằng Python**
app.post('/classifyImage', upload.single('image'), async (req, res) => {
    const file = req.file;

    if (!file) {
        return res.status(400).json({ error: 'No file uploaded for classification' });
    }

    const imagePath = path.join(__dirname, file.path);
    const imageUrl = `${ngrokBaseUrl}/uploads/${file.filename}`; // Sử dụng URL từ ngrok cho phân loại

    const pythonProcess = spawn('python3', ['classify_image.py', imagePath]);

    let dataBuffer = '';

    pythonProcess.stdout.on('data', (data) => {
        dataBuffer += data.toString();
    });

    pythonProcess.stdout.on('end', async () => {
        const output = dataBuffer.trim();

        const resultPattern = /^[a-zA-Z]+,[0-9.]+$/;
        if (resultPattern.test(output)) {
            const [fabricType, confidence] = output.split(',');
            const cleanedFabricType = capitalizeFirstLetter(fabricType.trim());
            const parsedConfidence = parseFloat(confidence);

            try {
                const fabricInfoQuery = `
                   SELECT id, fabric_name, description, care_instructions 
                   FROM FabricTypes 
                   WHERE fabric_name = $1
                `;
                const fabricResult = await pool.query(fabricInfoQuery, [cleanedFabricType]);

                if (fabricResult.rows.length === 0) {
                    return res.status(404).json({ error: 'Fabric type not found in database' });
                }

                const fabricInfo = fabricResult.rows[0];
                const fabricId = fabricInfo.id;  // Lưu id từ bảng FabricTypes
                const fabricName = fabricInfo.fabric_name; // Lưu tên loại vải

                const classificationResult = {
                    fabric_id: fabricId,  // Lưu fabric_id
                    name_fabric: fabricName,  // Lưu tên loại vải
                    imageUrl: imageUrl,  // Đảm bảo sử dụng URL từ ngrok
                    confidence: parsedConfidence,
                    description: fabricInfo.description || "Mô tả không có sẵn",
                    careInstructions: fabricInfo.care_instructions || "Hướng dẫn không có sẵn",
                    timestamp: new Date().toISOString()
                };

                const insertClassification = `
                    INSERT INTO ClassificationResults (fabric_id, name_fabric, upload_time, classification_result, image_url)
                    VALUES ($1, $2, $3, $4, $5)
                `;
                await pool.query(insertClassification, [classificationResult.fabric_id, classificationResult.name_fabric, classificationResult.timestamp, parsedConfidence, imageUrl]);

                return res.status(200).json({
                    message: 'Image classified successfully',
                    result: classificationResult
                });
            } catch (err) {
                return res.status(500).json({ error: 'Error processing the request', details: err.message });
            }
        } else {
            return res.status(500).json({ error: 'Invalid result format from Python' });
        }
    });

    pythonProcess.stderr.on('data', (data) => {
        return res.status(500).json({ error: 'Error during classification', details: data.toString() });
    });
});


// **API Lấy dữ liệu lịch sử phân loại vải**
app.get('/getFabricHistory', async (req, res) => {
    try {
        const query = 'SELECT * FROM ClassificationResults';
        const result = await pool.query(query);

        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching classification history:', err.message);
        res.status(500).json({ error: 'Error fetching classification history', details: err.message });
    }
});

// **API Xóa lịch sử phân loại vải**
app.delete('/deleteFabricHistory/:id', async (req, res) => {
    const id = req.params.id;

    try {
        const query = 'DELETE FROM ClassificationResults WHERE id = $1';
        await pool.query(query, [id]);

        res.status(200).send({ message: 'Xóa thành công' });
    } catch (error) {
        res.status(500).send({ message: 'Xóa thất bại', error });
    }
});

// Chạy server
app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});

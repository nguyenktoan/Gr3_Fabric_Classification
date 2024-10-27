const express = require('express');
const multer = require('multer');
const { spawn } = require('child_process');
const path = require('path');
const { Pool } = require('pg');
const app = express();
const port = 3000;

// Cấu hình PostgreSQL
const pool = new Pool({
    user: 'postgres.dwxyindbkbapffajbdug',
    host: 'aws-0-ap-southeast-1.pooler.supabase.com',
    database: 'postgres',
    password: 'HuaTuanVi168@',
    port: 6543,
});

// Hàm để viết hoa chữ cái đầu của loại vải
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
}

// Cấu hình multer để lưu file upload vào thư mục "uploads"
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        console.log('Bắt đầu upload file'); // Log khi bắt đầu upload
        cb(null, './uploads');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        console.log('Tạo tên file duy nhất cho upload: ' + uniqueSuffix); // Log tạo tên file
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Phục vụ các file tĩnh từ thư mục "uploads"
app.use('/uploads', express.static('uploads'));

// URL công khai từ Ngrok
const ngrokBaseUrl = 'http://localhost:3000';

// **API Upload ảnh**
app.post('/uploadImage', upload.single('image'), (req, res) => {
    console.log('Upload image API called');

    const file = req.file;

    if (!file) {
        console.log('Không có file nào được upload');
        return res.status(400).json({ error: 'No file uploaded' });
    }

    const imageUrl = `${ngrokBaseUrl}/uploads/${file.filename}`;
    console.log(`Image uploaded successfully: ${imageUrl}`);

    res.status(200).json({ message: 'Image uploaded successfully', imageUrl });
});

// **API Phân loại ảnh bằng Python**
app.post('/classifyImage', upload.single('image'), async (req, res) => {
    console.log('Classify image API called'); // Bắt đầu phân loại ảnh

    const file = req.file;

    if (!file) {
        console.log('Không có file nào được upload để phân loại');
        return res.status(400).json({ error: 'No file uploaded for classification' });
    }

    const imagePath = path.join(__dirname, file.path);
    const imageUrl = `${ngrokBaseUrl}/uploads/${file.filename}`;

    console.log(`Image path: ${imagePath}`);
    console.log('Starting Python process for image classification');

    // Khởi chạy tiến trình Python để phân loại ảnh
    const pythonProcess = spawn('python3', ['classify_image.py', imagePath]);

    let dataBuffer = '';

    // Lắng nghe dữ liệu từ Python process
    pythonProcess.stdout.on('data', (data) => {
        console.log(`Python process output: ${data.toString()}`); // Log tất cả output của Python
        dataBuffer += data.toString();
    });

    // Khi Python process hoàn tất
    pythonProcess.stdout.on('end', async () => {
        console.log('Python process finished');
        const output = dataBuffer.trim();
        console.log(`Output from Python: ${output}`);

        // Tách kết quả thành từng dòng
        const lines = output.split('\n');

        // Tìm dòng chứa kết quả hợp lệ (loại_vải,confidence)
        const resultPattern = /^[a-zA-Z]+,[0-9.]+$/;
        const validResult = lines.find(line => resultPattern.test(line.trim()));

        // Nếu kết quả hợp lệ, xử lý và lưu vào database
        if (validResult) {
            const [fabricType, confidence] = validResult.split(',');
            const cleanedFabricType = capitalizeFirstLetter(fabricType.trim());
            const parsedConfidence = parseFloat(confidence);

            console.log(`Parsed result: Fabric Type - ${cleanedFabricType}, Confidence - ${parsedConfidence}`);

            try {
                console.log(`Fetching fabric info from database for: ${cleanedFabricType}`);
                const fabricInfoQuery = `
                   SELECT id, fabric_name, description, care_instructions 
                   FROM FabricTypes 
                   WHERE fabric_name = $1
                `;
                const fabricResult = await pool.query(fabricInfoQuery, [cleanedFabricType]);

                if (fabricResult.rows.length === 0) {
                    console.log('Fabric type not found in database');
                    return res.status(404).json({ error: 'Fabric type not found in database' });
                }

                const fabricInfo = fabricResult.rows[0];
                console.log(`Fabric info: ${JSON.stringify(fabricInfo)}`);

                const classificationResult = {
                    fabric_id: fabricInfo.id,
                    name_fabric: fabricInfo.fabric_name,
                    imageUrl: imageUrl,
                    description: fabricInfo.description || "Mô tả không có sẵn",
                    careInstructions: fabricInfo.care_instructions || "Hướng dẫn không có sẵn",
                    confidence: parsedConfidence,  // Đảm bảo confidence có mặt ở đây
                    timestamp: new Date().toISOString()
                    
                };

                console.log(`Final classification result: ${JSON.stringify(classificationResult)}`);
                
                const insertClassification = `
                    INSERT INTO ClassificationResults (fabric_id, name_fabric, upload_time, classification_result, image_url)
                    VALUES ($1, $2, $3, $4, $5)
                `;
                console.log('Inserting classification result into database');
                await pool.query(insertClassification, [classificationResult.fabric_id, classificationResult.name_fabric, classificationResult.timestamp, parsedConfidence, imageUrl]);

                console.log('Inserted classification result into database');
                return res.status(200).json({
                    message: 'Image classified successfully',
                    result: classificationResult  // Trả về kết quả bao gồm confidence
                });
            } catch (err) {
                console.error('Error processing request:', err.message);
                return res.status(500).json({ error: 'Error processing the request', details: err.message });
            }
        } else {
            console.log('No valid result format found from Python output');
            return res.status(500).json({ error: 'Invalid result format from Python' });
        }
    });

    // Log lỗi từ tiến trình Python
    pythonProcess.stderr.on('data', (data) => {
        console.error(`Error from Python process: ${data.toString()}`);
        return res.status(500).json({ error: 'Error during classification', details: data.toString() });
    });

    // Log khi tiến trình Python kết thúc bất thường
    pythonProcess.on('close', (code) => {
        console.log(`Python process exited with code ${code}`);
    });
});

// Chạy server
app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});

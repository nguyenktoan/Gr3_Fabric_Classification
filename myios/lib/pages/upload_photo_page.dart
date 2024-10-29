import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'second_page.dart';

class UploadPhotoPage extends StatefulWidget {
  @override
  _UploadPhotoPageState createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  late AnimationController _controller; // Khai báo controller
  late Animation<double> _animation; // Khai báo animation cho lắc lư

  @override
  void initState() {
    super.initState();

    // Tạo AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Lặp lại hiệu ứng

    // Tạo tween cho lắc lư
    _animation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Navigate to the second page after image selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondPage(imagePath: image.path),
        ),
      );
    }
  }

  // Function hiển thị hướng dẫn
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Instructions for use',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Step 1: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Go to our app and press "Upload your photo". Select and upload a clear photo of the fabric.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Step 2: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Click "Classify your photo", our AI system will automatically process and analyze the fabric photo.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Step 3: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'See results. You can review the results in history.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF79B142),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng controller khi không cần thiết
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF79B142),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Phần nội dung chính của trang
          Positioned(
            top: 70, // Đẩy robot lên phía trên
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF79B142), // Màu nền trùng với nút upload
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.cloud_upload,
                    size: 200, // Thay đổi kích thước icon nếu cần
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage, // Mở trình chọn ảnh khi nhấn nút
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF79B142),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    'UPLOAD YOUR PHOTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40), // Khoảng trống trước robot
              ],
            ),
          ),
          // Robot GIF ở dưới cùng
          Positioned(
            bottom: 0, // Đặt robot ở dưới cùng màn hình
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showInstructions, // Hiển thị hướng dẫn khi nhấn vào robot
              child: Image.asset(
                'assets/robot2.gif', // Đảm bảo bạn đã thêm hình ảnh robot vào assets
                width: MediaQuery.of(context).size.width, // Chiều rộng bằng với chiều rộng màn hình
                height: MediaQuery.of(context).size.height * 0.25, // Chiều cao chiếm 25% chiều cao màn hình
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Robot PNG với hiệu ứng lắc lư
          Positioned(
            bottom: 30,
            left: 130,
            right: 2,
            child: GestureDetector(
              onTap: _showInstructions, // Hiển thị hướng dẫn khi nhấn vào robot
              child: AnimatedBuilder(
                animation: _controller,
                child: Image.asset(
                  'assets/robot2.png', // Hình ảnh robot 2D
                  width: MediaQuery.of(context).size.width * 0.5, // Chiều rộng bằng với chiều rộng màn hình
                  height: MediaQuery.of(context).size.height * 0.2, // Chiều cao chiếm 25% chiều cao màn hình
                  fit: BoxFit.cover,
                ),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 3.14159 / 180, // Quay nhẹ
                    child: child,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'third_page.dart';
import 'loading_page.dart'; // Import trang loading mới

class SecondPage extends StatefulWidget {
  final String imagePath;

  SecondPage({required this.imagePath});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with SingleTickerProviderStateMixin {
  String? _currentImagePath;
  late AnimationController _controller; // Khai báo controller
  late Animation<double> _rotationAnimation; // Khai báo animation

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath; // Khởi tạo với hình ảnh ban đầu

    // Tạo AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Lặp lại hiệu ứng

    // Tạo tween cho xoay vòng
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Function hiển thị hướng dẫn
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hướng dẫn sử dụng',
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
                  'Bước 1: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Vào ứng dụng của chúng tôi và nhấp vào "Tải ảnh lên". Chọn và tải lên một hình ảnh rõ nét của loại vải.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Bước 2: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nhấp vào "Phân loại ảnh của bạn", hệ thống AI của chúng tôi sẽ tự động xử lý và phân tích hình ảnh vải.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Bước 3: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Xem kết quả. Bạn có thể "Chụp lại" bài kiểm tra nếu bạn muốn ^^',
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
                'Đóng',
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

  // Hàm phân loại hình ảnh và chuyển sang trang kết quả
  Future<void> _classifyImage() async {
    // Chuyển sang trang loading
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage()), // Chuyển tới trang loading
    );

    String url = 'http://localhost:3000/classifyImage'; // Địa chỉ API Ngrok

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', _currentImagePath!));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseData.body);

        // Đóng trang loading trước khi chuyển trang
        Navigator.popUntil(context, (route) => route.isFirst); // Đóng trang loading

        // Chuyển tới ThirdPage với kết quả phân loại
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThirdPage(
              imagePath: _currentImagePath!,
              result: jsonResponse['result'], // Gửi kết quả
            ),
          ),
        );
      } else {
        print('Failed to upload image with status: ${response.statusCode}');
        Navigator.popUntil(context, (route) => route.isFirst); // Đóng trang loading nếu có lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to classify image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      Navigator.popUntil(context, (route) => route.isFirst); // Đóng trang loading nếu có lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
            'Classify',
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
          // Nội dung chính của trang
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100), // Tăng khoảng cách phía trên
                    if (_currentImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_currentImagePath!),
                          width: double.infinity,
                          height: 250, // Điều chỉnh kích thước ảnh
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Quay lại trang trước
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'BACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _classifyImage(); // Gọi hàm phân loại
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF79B142),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'CLASSIFY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40), // Khoảng trống trước robot
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showInstructions, // Hiển thị hướng dẫn khi nhấn vào robot
              child: Image.asset(
                'assets/robot2.gif', // Hình ảnh robot GIF
                width: MediaQuery.of(context).size.width, // Chiều rộng bằng với chiều rộng màn hình
                height: MediaQuery.of(context).size.height * 0.25, // Chiều cao chiếm 25% chiều cao màn hình
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                    angle: _rotationAnimation.value, // Xoay nhẹ
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
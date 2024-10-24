import 'package:flutter/material.dart';
import 'package:myios/splash_screen.dart';
import 'pages/upload_photo_page.dart'; // Import trang UploadPhotoPage
import 'pages/fourth_page.dart'; // Import trang FourthPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Chuyển đến trang SplashScreen trước
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Để theo dõi trang hiện tại

  final List<Widget> _pages = [
    UploadPhotoPage(), // Trang tải ảnh
    FourthPage(results: []), // Trang lịch sử
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Cập nhật chỉ số của trang hiện tại
    });

    // Nếu nhấn vào UploadPhotoPage, có thể reset trạng thái nếu cần
    if (index == 0) {
      // Có thể thêm logic để reset hoặc làm mới UploadPhotoPage nếu cần
      // Nếu UploadPhotoPage có stateful logic, có thể muốn thêm phương thức để reset.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Hiển thị trang dựa trên chỉ số
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // Hàm khi nhấn vào item
      ),
    );
  }
}

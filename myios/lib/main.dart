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
  final int initialIndex;

  MainPage({this.initialIndex = 0});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Nhận giá trị initialIndex để hiển thị trang mong muốn
  }

  final List<Widget> _pages = [
    UploadPhotoPage(), // Trang tải ảnh
    FourthPage(results: []), // Trang lịch sử
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Cập nhật chỉ số của trang hiện tại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Hiển thị trang hiện tại dựa trên chỉ số
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
        selectedItemColor: _currentIndex == 1 ? Colors.white :Colors.blue,
        backgroundColor: _currentIndex == 1 ? Color(0xFF79B142) : Colors.white, // Nền xanh lá khi ở trang "History"
        onTap: _onItemTapped, // Khi nhấn vào một mục trong thanh điều hướng
      ),
    );
  }
}


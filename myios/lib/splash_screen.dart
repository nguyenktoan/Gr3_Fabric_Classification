import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Tạo AnimationController để điều khiển cả hiệu ứng quay và độ mờ
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Tổng thời gian cho animation
      vsync: this,
    );

    // Tạo animation cho hiệu ứng độ mờ
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Bắt đầu animation quay và độ mờ
    _controller.forward();

    // Chờ 3 giây và điều hướng đến MainPage
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(), // Trang chính
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng controller khi không cần thiết
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8BC34A), // Màu nền xanh
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              child: Image.asset(
                'assets/logo.png', // Thêm logo của bạn ở đây
                width: 250,
                height: 250,
              ),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * 3.14159, // Quay 360 độ
                  child: child,
                );
              },
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'Frabica',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

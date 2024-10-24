import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(0xFF79B142), // Màu nền xanh lá
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị ảnh động
            Container(
              height: 250,
              width: 250,
              child: Image.asset('assets/loading.gif'), // Đường dẫn tới ảnh động
            ),
            SizedBox(height: 20),
            Text(
              'Classifying..',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

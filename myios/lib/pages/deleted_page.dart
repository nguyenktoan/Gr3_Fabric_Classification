import 'package:flutter/material.dart';

class DeletedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),

        ),
        centerTitle: true,
        backgroundColor: Color(0xFF79B142), // Màu nền xanh lá
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị ảnh động
            Container(
              height: 150,
              width: 150,
              child: Image.asset('assets/deleted.gif'), // Đường dẫn tới ảnh động
            ),
            SizedBox(height: 20),
            Text(
              'Completely deleted!',
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

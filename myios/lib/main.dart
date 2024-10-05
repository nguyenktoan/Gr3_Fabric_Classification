import 'package:flutter/material.dart';
import 'pages/upload_photo_page.dart'; // Import trang UploadPhotoPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: UploadPhotoPage(
          classifiedResults: [], // Truyền danh sách rỗng ban đầu
        ),
      ),
    );
  }
}

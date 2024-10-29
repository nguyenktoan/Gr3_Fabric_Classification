import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'upload_photo_page.dart'; // Import trang UploadPhotoPage
import 'fourth_page.dart'; // Import trang FourthPage
import '../main.dart'; // Import MainPage để điều hướng

class ThirdPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  ThirdPage({required this.imagePath, required this.result});

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // Điều hướng về MainPage với trang tương ứng
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(initialIndex: index), // Điều hướng về MainPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var result = widget.result;
    var timestamp = result['timestamp'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Classified Result'),
        backgroundColor: Color(0xFF79B142), // Màu nền xanh lá
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildResultPage(result, widget.imagePath, timestamp),
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        backgroundColor: Color(0xFF79B142),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildResultPage(Map<String, dynamic> result, String imagePath, String? timestamp) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'RESULT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Type: ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFF03488E), Color(0xFFFF0072), Color(0xFF021D81), Color(0xFFFF0072)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    '${result['name_fabric'] ?? 'No type available'}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Classified at: ${_formatTimestamp(timestamp)}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            if (result['description'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${result['description']}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (result['careInstructions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Care Instructions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${result['careInstructions']}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Quay lại trang UploadPhotoPage khi nhấn "RETAKE"
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(initialIndex: 0), // Quay lại trang Home
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF79B142),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'RETAKE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp != null && timestamp.isNotEmpty) {
      try {
        DateTime dateTime = DateTime.parse(timestamp);
        DateTime vietnamTime = dateTime.toLocal();
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(vietnamTime);
      } catch (e) {
        print('Error parsing date: $e');
        return 'Invalid date';
      }
    }
    return 'No time available';
  }
}

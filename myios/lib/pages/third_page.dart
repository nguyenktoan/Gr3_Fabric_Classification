import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../main.dart';
import 'fourth_page.dart';
import 'upload_photo_page.dart'; // Đảm bảo import UploadPhotoPage

class ThirdPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  ThirdPage({required this.imagePath, required this.result});

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  int _selectedIndex = 0;

  // Hàm để chuyển trang
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), // Trở về UploadPhotoPage
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FourthPage(results: [])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var result = widget.result;
    var timestamp = result['timestamp'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Classified Result'),
        backgroundColor: Color(0xFF79B142),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(widget.imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'RESULT',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Type: ${result['name_fabric'] ?? 'No type available'}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Text(
                'Classified at: ${_formatTimestamp(timestamp)}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              if (result['description'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${result['description']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              SizedBox(height: 10),
              if (result['careInstructions'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Care Instructions:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${result['careInstructions']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()), // Quay về UploadPhotoPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF79B142),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    'RETAKE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  // Hàm format lại confidence thành phần trăm
  String _formatConfidence(dynamic confidence) {
    if (confidence != null && confidence is double) {
      return '${(confidence * 100).toStringAsFixed(2)}%';  // Nhân với 100 để ra phần trăm và định dạng 2 số sau dấu phẩy
    }
    return 'No confidence available';
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp != null && timestamp.isNotEmpty) {
      try {
        String cleanedTimestamp = timestamp.replaceAll('Z', '');
        final DateTime dateTime = DateTime.parse(cleanedTimestamp).toLocal();
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
        return 'Ngày không hợp lệ';
      }
    }
    return 'Không có thời gian';
  }
}

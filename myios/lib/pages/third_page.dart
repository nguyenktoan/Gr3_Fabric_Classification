import 'package:flutter/material.dart';
import 'dart:io'; // For using the image file
import 'fourth_page.dart'; // Import FourthPage

class ThirdPage extends StatelessWidget {
  final String imagePath;
  final List<Map<String, String>> classifiedResults; // Danh sách các kết quả phân loại

  ThirdPage({required this.imagePath, required this.classifiedResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ngăn không tự động thêm nút mũi tên
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
            children: [
              // Display the uploaded image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(15), // Rounded corners
                child: Image.file(
                  File(imagePath),
                  width: double.infinity, // Horizontal full width
                  height: 200, // Set a standard height
                  fit: BoxFit.cover, // Ensure the image covers the space
                ),
              ),
              SizedBox(height: 20),

              // Result title - căn giữa
              Center(
                child: Text(
                  'RESULT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Fabric Type
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Căn trái
                children: [
                  Text(
                    'Fabric Type:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(width: 10), // Khoảng cách giữa tiêu đề và giá trị
                  Text(
                    'Cotton',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal, // Không in đậm
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Recycling Recommendations
              Text(
                'Recycling Recommendations:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Thụt vào một chút
                child: Text(
                  '• Recycling Option: Can be recycled into new fabric or other products.\n'
                      '• Pre-Sorting Needed: No pre-sorting required; suitable for general textile recycling programs.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              // Care Instructions
              Text(
                'Care Instructions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Thụt vào một chút
                child: Text(
                  '• Wash in cold water to preserve fabric integrity.\n'
                      '• Avoid high-temperature drying to prevent shrinkage.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              // Additional Notes
              Text(
                'Additional Notes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Thụt vào một chút
                child: Text(
                  '• Cotton is a biodegradable fabric, making it a good choice for sustainable fashion.\n'
                      '• Consider donating or repurposing worn cotton items before recycling.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              // Retake and View History buttons
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back to the first page and clear all previous pages
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Kích thước đồng bộ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Bo góc
                        ),
                      ),
                      child: Text(
                        'Retake',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Đồng bộ với kích thước chữ của nút classify
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FourthPage(
                              results: classifiedResults,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Kích thước đồng bộ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Bo góc
                        ),
                      ),
                      child: Text(
                        'View History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Đồng bộ với kích thước chữ của nút classify
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

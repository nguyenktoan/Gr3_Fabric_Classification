import 'package:flutter/material.dart';
import '../components/delete_button.dart'; // Sử dụng DeleteButton component
import 'deleted_page.dart'; // Import trang DeletedPage

class ResultPage extends StatelessWidget {
  final Map<String, String> result;

  ResultPage({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh giả định vải
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: Image.asset(
                  'assets/fabric_image_placeholder.png', // Thay thế bằng ảnh thực tế
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Kết quả
            Text(
              'RESULT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            // Loại vải
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Fabric Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: result['fabricType'] ?? 'N/A'),
                ],
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Khuyến nghị tái chế
            Text(
              'Recycling Recommendations:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              '• Recycling Option: Can be recycled into new fabric or other products.\n• Pre-Sorting Needed: No pre-sorting required; suitable for general textile recycling programs.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16.0),

            // Hướng dẫn chăm sóc
            Text(
              'Care Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              result['care'] ?? 'N/A',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16.0),

            // Ghi chú bổ sung
            Text(
              'Additional Notes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              '• Cotton is a biodegradable fabric, making it a good choice for sustainable fashion.\n• Consider donating or repurposing worn cotton items before recycling.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 32.0),

            // Nút Delete - Sử dụng DeleteButton component
            DeleteButton(
              onPressed: () {
                // Hiện thị trang DeletedPage tạm thời
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletedPage()),
                );

                // Quay lại trang lịch sử sau 3 giây
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.popUntil(context, (route) => route.isFirst); // Quay lại trang FourthPage
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

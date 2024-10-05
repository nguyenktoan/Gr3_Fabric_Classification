import 'package:flutter/material.dart';

class FourthPage extends StatelessWidget {
  final List<Map<String, String>> results; // Danh sách lưu trữ các kết quả phân loại

  FourthPage({required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classified Results'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true, // Bật nút back tự động
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: results.isNotEmpty
            ? ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Card(
              child: ListTile(
                title: Text('Fabric: ${result['fabricType']}'),
                subtitle: Text('Recycling: ${result['recycling']}'),
                trailing: Text('Care: ${result['care']}'),
              ),
            );
          },
        )
            : Center(
          child: Text('No results yet'),
        ),
      ),
    );
  }
}

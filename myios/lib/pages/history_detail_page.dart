import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> historyItem;
  final Function onDelete;

  HistoryDetailPage({required this.historyItem, required this.onDelete});

  // Function to format the timestamp
  String _formatTimestamp(String? timestamp) {
    if (timestamp != null && timestamp.isNotEmpty) {
      try {
        DateTime dateTime = DateTime.parse(timestamp).toLocal(); // Convert to local (Vietnam time)
        return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime); // Custom format
      } catch (e) {
        print('Error parsing date: $e');
        return 'Invalid date';
      }
    }
    return 'No time available';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = historyItem['image_url']?.toString() ?? '';
    final String fabricType = historyItem['name_fabric']?.toString() ?? 'Unknown';
    final double confidence = historyItem['classification_result'] != null
        ? double.tryParse(historyItem['classification_result'].toString()) ?? 0.0
        : 0.0;
    final String timestamp = _formatTimestamp(historyItem['upload_time']?.toString()); // Use formatted timestamp
    final String description = historyItem['description']?.toString() ?? 'No description available';
    final String careInstruction = historyItem['care_instructions']?.toString() ?? 'No care instructions available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Fabric Details'),
        backgroundColor: Color(0xFF79B142),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Fabric Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF79B142)),
                    ),
                    SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFF03488E), Color(0xFFFF0072), Color(0xFF021D81), Color(0xFFFF0072)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        fabricType,
                        style: TextStyle(
                          fontSize: 24, // Increased font size for visibility
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Set color, but it will be replaced by the gradient
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Classified At',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF79B142)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      timestamp, // Formatted timestamp
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Accuracy',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${confidence.toStringAsFixed(5)}%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Divider(height: 32, color: Colors.grey),
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF79B142)),
              ),
              SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(description, style: TextStyle(fontSize: 16)),
              ),
              Divider(height: 32, color: Colors.grey),
              Text(
                'Care Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF79B142)),
              ),
              SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(careInstruction, style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Confirm Deletion'),
                          content: Text('Are you sure you want to delete this history item?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      onDelete();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'DELETE',
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
      ),
    );
  }
}

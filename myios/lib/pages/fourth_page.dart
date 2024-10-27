import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'upload_photo_page.dart'; // Import UploadPhotoPage

class FourthPage extends StatefulWidget {
  final List<Map<String, String>> results; // List of classification results from MainPage

  FourthPage({required this.results}); // Initialize results list

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  List<dynamic> _history = []; // List of classification history
  dynamic _recentlyDeleted; // Store recently deleted history
  String searchQuery = ''; // Variable to store search keyword
  int _selectedIndex = 1; // Current tab index
  bool _isUndoVisible = false; // Status to show undo button
  int _undoDuration = 3; // Undo time (seconds)
  int _undoIndex = -1; // Store the position of the item being undone

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Call function to fetch classification history from API
  }

  // Function to fetch history data from server
  Future<void> _fetchHistory() async {
    String url = 'http://localhost:3000/getFabricHistory'; // API address to fetch history from Ngrok

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _history = json.decode(response.body); // Update history data

          // Sort by timestamp if available
          _history.sort((a, b) {
            String? aTimestamp = a['upload_time'];
            String? bTimestamp = b['upload_time'];

            if (aTimestamp == null || bTimestamp == null) {
              return 0; // Do not sort if timestamp is missing
            }

            try {
              DateTime aDateTime = DateTime.parse(aTimestamp);
              DateTime bDateTime = DateTime.parse(bTimestamp);
              return bDateTime.compareTo(aDateTime); // Sort in descending order of time
            } catch (e) {
              print('Error parsing date: $e');
              return 0; // If error, do not change order
            }
          });
        });
      } else {
        print('Failed to fetch history with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to format the timestamp received from the server
  String _formatTimestamp(String? timestamp) {
    if (timestamp != null && timestamp.isNotEmpty) {
      try {
        final DateTime dateTime = DateTime.parse(timestamp).toLocal(); // Convert to local time
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format the date
      } catch (e) {
        print('Error parsing date: $e');
        return 'Invalid date';
      }
    }
    return 'No time available';
  }

  // Function to delete history item both in frontend and backend
  Future<void> _deleteHistoryItem(int index) async {
    final item = _history[index];
    final id = item['id']?.toString(); // Ensure ID is a string

    if (id == null || id.isEmpty) {
      print('Invalid ID');
      return;
    }

    // Store the recently deleted item
    setState(() {
      _recentlyDeleted = _history[index]; // Store the item for restoration
      _undoIndex = index; // Store position
      _isUndoVisible = true; // Show undo button
    });

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have deleted the history, press the undo icon to undo after $_undoDuration seconds'),
      ),
    );

    // Countdown timer
    await Future.delayed(Duration(seconds: _undoDuration));

    // If the undo button was not pressed, delete the item permanently
    if (_isUndoVisible) {
      String url = 'http://localhost:3000/deleteFabricHistory/$id'; // API address to delete history from Ngrok
      await http.delete(Uri.parse(url));

      // Remove item from frontend
      setState(() {
        _history.removeAt(_undoIndex); // Remove item from frontend
        _isUndoVisible = false; // Hide undo button
      });

      // Show snackbar to inform successful deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('History deleted successfully!'),
        ),
      );
    }
  }

  // Function to undo deletion
  void _undoDelete() {
    setState(() {
      // Keep the position and just replace the undo icon with the delete icon
      _isUndoVisible = false; // Hide undo button
      _recentlyDeleted = null; // Reset variable
      _undoIndex = -1; // Reset position
    });

    // Show snackbar to inform successful undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Undo successful!'),
      ),
    );
  }

  // Function to filter history by search keyword
  List<dynamic> _getFilteredResults() {
    if (searchQuery.isEmpty) {
      return _history;
    }
    return _history.where((item) {
      final type = item['name_fabric']?.toString() ?? '';
      final timestamp = item['upload_time']?.toString() ?? '';
      return type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          timestamp.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = _getFilteredResults(); // Get filtered list by search keyword

    return Scaffold(
      appBar: AppBar(
        title: Text('Fabric Classification History'),
        backgroundColor: Color(0xFF79B142), // Green background color
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search keyword
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter fabric type or date (e.g., 2024-10-23)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // History list
          Expanded(
            child: filteredResults.isEmpty
                ? Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                final String imageUrl = item['image_url']?.toString() ?? '';
                final String type = item['name_fabric']?.toString() ?? 'Not determined';
                final double confidence = item['classification_result'] != null
                    ? double.tryParse(item['classification_result'].toString()) ?? 0.0
                    : 0.0;
                final String timestamp = item['upload_time']?.toString() ?? '';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Display uploaded image
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 80, color: Colors.grey);
                            },
                          )
                        else
                          Icon(Icons.broken_image, size: 80, color: Colors.grey),

                        SizedBox(width: 16),

                        // Display information next to the image
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Classification date: ${_formatTimestamp(timestamp)}',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Fabric type: $type',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Confidence: ${confidence.toStringAsFixed(2)}%',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),

                              // Delete or undo button
                              Align(
                                alignment: Alignment.centerRight,
                                child: _isUndoVisible && _undoIndex == index
                                    ? IconButton(
                                  icon: Icon(Icons.undo, color: Colors.green),
                                  onPressed: _undoDelete,
                                )
                                    : IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteHistoryItem(index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

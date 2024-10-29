import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'upload_photo_page.dart';
import 'history_detail_page.dart';

class FourthPage extends StatefulWidget {
  final List<Map<String, String>> results;

  FourthPage({required this.results});

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  List<dynamic> _history = [];
  dynamic _lastDeletedItem;
  String searchQuery = '';
  bool _showUndo = false;
  int _undoTime = 3;
  int _undoIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/getFabricHistory'));
      if (response.statusCode == 200) {
        setState(() => _history = (json.decode(response.body)..sort(_compareByTime)));
      } else {
        print('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  int _compareByTime(a, b) {
    try {
      return DateTime.parse(b['upload_time']).compareTo(DateTime.parse(a['upload_time']));
    } catch (e) {
      print('Date parsing error: $e');
      return 0;
    }
  }

  String _formatTime(String? time) {
    return time != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(time).toLocal())
        : 'No time available';
  }

  Future<void> _deleteHistoryItem(int index) async {
    final item = _history[index];
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) return print('Invalid ID');

    setState(() {
      _lastDeletedItem = item;
      _undoIndex = index;
      _showUndo = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('History item deleted, undo within $_undoTime seconds')),
    );

    await Future.delayed(Duration(seconds: _undoTime));
    if (_showUndo) {
      await http.delete(Uri.parse('http://localhost:3000/deleteFabricHistory/$id'));
      setState(() {
        _history.removeAt(_undoIndex);
        _showUndo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('History deleted successfully!')));
    }
  }

  void _undoDelete() {
    setState(() {
      _showUndo = false;
      _lastDeletedItem = null;
      _undoIndex = -1;
      // Thêm lại mục đã xóa vào danh sách nếu cần thiết
      if (_lastDeletedItem != null && _undoIndex != -1) {
        _history.insert(_undoIndex, _lastDeletedItem);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Undo successful!')));
  }

  List<dynamic> _getFilteredResults() {
    return searchQuery.isEmpty
        ? _history
        : _history.where((item) {
      final type = item['name_fabric']?.toString() ?? '';
      final time = item['upload_time']?.toString() ?? '';
      return type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          time.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = _getFilteredResults();
    return Scaffold(
      appBar: AppBar(
        title: Text('Fabric Classification History'),
        backgroundColor: Color(0xFF79B142),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() {
                    value == 'Sort by time' ? _history.sort(_compareByTime) : _history.sort((a, b) {
                      return (a['name_fabric'] ?? '').toLowerCase().compareTo((b['name_fabric'] ?? '').toLowerCase());
                    });
                  }),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Sort by time', child: Text('Sort by time')),
                    PopupMenuItem(value: 'Sort by name', child: Text('Sort by name')),
                  ],
                  icon: Icon(Icons.sort, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredResults.isEmpty
                ? Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                final imageUrl = item['image_url'] ?? '';
                final fabricType = item['name_fabric'] ?? 'Unspecified';
                final confidence = item['classification_result'] != null
                    ? double.tryParse(item['classification_result'].toString()) ?? 0.0
                    : 0.0;
                final time = item['upload_time'] ?? '';

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryDetailPage(
                      historyItem: item,
                      onDelete: () => _deleteHistoryItem(index),
                    )),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              if (imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 40, // Giảm kích thước ảnh xuống 40x40
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                )
                              else
                                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Classification Date: ${_formatTime(time)}',
                                      style: TextStyle(fontSize: 14, color: Color(0XFF2C6975)),
                                      overflow: TextOverflow.visible,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Fabric Type: $fabricType',
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Confidence: ${confidence.toStringAsFixed(5)}%',
                                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 30,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _showUndo && _undoIndex == index
                                  ? IconButton(
                                icon: Icon(Icons.undo, color: Colors.green),
                                onPressed: _undoDelete,
                              )
                                  : IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteHistoryItem(index),
                              ),
                            ),
                          ),
                        ],
                      ),
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

import 'package:flutter/material.dart';
import 'package:bus_track_app/core/api/dio_client.dart';

class ChildStatusScreen extends StatefulWidget {
  final int studentId;
  final int? plannedTripId;
  final String studentName;

  const ChildStatusScreen({
    super.key,
    required this.studentId,
    this.plannedTripId,
    required this.studentName,
  });

  @override
  State<ChildStatusScreen> createState() => _ChildStatusScreenState();
}

class _ChildStatusScreenState extends State<ChildStatusScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/parent/child-status/${widget.studentId}');
      if (response.statusCode == 200) {
        setState(() {
          _data = response.data;
          _loading = false;
          _lastUpdated = DateTime.now();
        });
      } else {
        setState(() {
          _error = 'Failed to load status';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _data?['status'] ?? 'unknown';
    final busLocation = _data?['bus_location'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStatus,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchStatus,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: status == 'boarded'
                                      ? Colors.green[100]
                                      : status == 'dropped_off'
                                          ? Colors.grey[300]
                                          : Colors.orange[100],
                                  child: Icon(
                                    status == 'boarded'
                                        ? Icons.directions_bus
                                        : status == 'dropped_off'
                                            ? Icons.home
                                            : Icons.schedule,
                                    color: status == 'boarded'
                                        ? Colors.green
                                        : status == 'dropped_off'
                                            ? Colors.grey
                                            : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status: $status',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (busLocation != null)
                                        Text(
                                          'Lat: ${busLocation['lat']}\nLng: ${busLocation['lng']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      if (_lastUpdated != null)
                                        Text(
                                          'Last updated: ${_formatTime(_lastUpdated!)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Map Placeholder (or bus location visual)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: busLocation != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 60,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Bus is at:\n${busLocation['lat']}, ${busLocation['lng']}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      'Bus not active',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
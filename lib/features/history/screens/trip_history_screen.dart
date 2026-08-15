import 'package:flutter/material.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'package:bus_track_app/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<dynamic> _trips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final dio = DioClient().dio;
      dynamic response;
      if (user.roleId == 3) {
        // Driver
        response = await dio.get('/driver/trip-history');
      } else if (user.roleId == 4 || user.roleId == 5) {
        // Parent – for simplicity, we'll fetch history for the first child (or we can let user choose)
        // For now, we'll get all children and fetch history for each, or we can add a drop-down.
        // Let's fetch all children first.
        final childrenRes = await dio.get('/parent/children');
        final children = childrenRes.data;
        if (children.isNotEmpty) {
          // Use the first child's ID – we can improve this later
          final childId = children[0]['id'];
          response = await dio.get('/parent/child-history/$childId');
        } else {
          setState(() {
            _trips = [];
            _loading = false;
          });
          return;
        }
      } else {
        setState(() {
          _error = 'Unauthorized';
          _loading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        setState(() {
          _trips = response.data;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Failed to load history';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No trip history found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          final isDriver = context.read<AuthProvider>().user?.roleId == 3;
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_bus,
                                        color: Colors.blue[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trip['route_name'] ?? 'Trip',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          trip['status'] ?? 'Completed',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.grey[700],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Date: ${trip['date'] ?? trip['planned_date'] ?? 'N/A'}'),
                                  if (isDriver)
                                    Text('Students: ${trip['student_count'] ?? 0}'),
                                  if (!isDriver)
                                    Text('Status: ${trip['status']}'),
                                  if (trip['started_at'] != null && trip['ended_at'] != null)
                                    Text(
                                      '${trip['started_at']} → ${trip['ended_at']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
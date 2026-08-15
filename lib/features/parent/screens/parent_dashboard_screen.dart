import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'package:bus_track_app/features/auth/providers/auth_provider.dart';
import 'package:bus_track_app/features/parent/screens/child_status_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  List<dynamic> _children = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchChildren(showLoading: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchChildren({bool showLoading = true}) async {
    if (_loading && showLoading) return;

    if (showLoading) {
      setState(() => _loading = true);
    }

    try {
      final dio = DioClient().dio;
      final response = await dio.get('/parent/children');
      if (response.statusCode == 200) {
        setState(() {
          _children = response.data;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Failed to load children';
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
        title: const Text('My Children'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No children found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _fetchChildren(showLoading: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _children.length,
                        itemBuilder: (context, index) {
                          final child = _children[index];
                          final status = child['status'] ?? 'unknown';
                          final plannedTripId = child['planned_trip_id'];

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
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
                              title: Text(
                                child['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text('Status: $status'),
                              trailing: Chip(
                                label: Text(
                                  status == 'boarded'
                                      ? 'On Bus'
                                      : status == 'dropped_off'
                                          ? 'Dropped Off'
                                          : 'Scheduled',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: status == 'boarded'
                                    ? Colors.green
                                    : status == 'dropped_off'
                                        ? Colors.grey
                                        : Colors.orange,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildStatusScreen(
                                      studentId: child['id'],
                                      plannedTripId: plannedTripId,
                                      studentName: child['name'] ?? 'Child',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
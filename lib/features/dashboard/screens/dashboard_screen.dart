import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'package:bus_track_app/features/auth/providers/auth_provider.dart';
import 'package:bus_track_app/features/trip/screens/trip_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _trips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/planned-trips/on-route');
      if (response.statusCode == 200) {
        setState(() {
          _trips = response.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load trips';
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
        title: const Text('Driver Dashboard'),
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
              : _trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_bus, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No active trips',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchTrips,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: const Icon(Icons.directions_bus, color: Colors.blue),
                              ),
                              title: Text(
                                trip['route_name'] ?? 'Trip',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Bus: ${trip['bus_plate'] ?? 'N/A'}'),
                                  Text('Started: ${trip['started_at'] ?? 'Not started'}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  trip['started_at'] != null ? 'Active' : 'Scheduled',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: trip['started_at'] != null
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripDetailScreen(
                                      plannedTripId: trip['id'],
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
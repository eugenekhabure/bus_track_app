import 'package:flutter/material.dart';
import 'package:bus_track_app/core/api/dio_client.dart';

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
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/planned-trips/all'); // This endpoint returns all trips
      if (response.statusCode == 200) {
        setState(() {
          _trips = response.data;
          _loading = false;
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
                            'No trips found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _trips.length,
                      itemBuilder: (context, index) {
                        final trip = _trips[index];
                        final status = trip['status'] ?? 'scheduled';
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: status == 'completed'
                                  ? Colors.grey[300]
                                  : status == 'active'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                              child: Icon(
                                status == 'completed'
                                    ? Icons.check
                                    : status == 'active'
                                        ? Icons.directions_bus
                                        : Icons.schedule,
                                color: status == 'completed'
                                    ? Colors.grey
                                    : status == 'active'
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                            title: Text(trip['route_name'] ?? 'Trip'),
                            subtitle: Text('${trip['planned_date'] ?? ''} - ${trip['driver_name'] ?? 'N/A'}'),
                            trailing: Chip(
                              label: Text(
                                status,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: status == 'completed'
                                  ? Colors.grey
                                  : status == 'active'
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'package:bus_track_app/core/services/location_service.dart';

class TripDetailScreen extends StatefulWidget {
  final int plannedTripId;
  const TripDetailScreen({super.key, required this.plannedTripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  List<dynamic> _students = [];
  Map<String, dynamic>? _tripData;
  bool _loading = true;
  bool _loadingAction = false;
  String? _error;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  Future<void> _fetchTripData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = DioClient().dio;

      final tripResponse = await dio.get('/planned-trips/${widget.plannedTripId}');
      if (tripResponse.statusCode == 200) {
        setState(() {
          _tripData = tripResponse.data;
        });
      } else {
        setState(() {
          _error = 'Failed to load trip details';
          _loading = false;
        });
        return;
      }

      final studentResponse = await dio.get(
        '/planned-trips/get-all-students-on-trip/${widget.plannedTripId}',
      );
      if (studentResponse.statusCode == 200) {
        setState(() {
          _students = studentResponse.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load students';
          _loading = false;
        });
      }

      final bool isStarted = _tripData?['started_at'] != null && _tripData?['ended_at'] == null;
      if (isStarted) {
        _locationService.startTracking(widget.plannedTripId);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _startStopTrip(String action) async {
    setState(() => _loadingAction = true);
    try {
      final dio = DioClient().dio;
      final response = await dio.post(
        '/planned-trips/start-stop',
        data: {
          'planned_trip_id': widget.plannedTripId,
          'action': action,
        },
      );
      if (response.statusCode == 200) {
        if (action == 'start') {
          _locationService.startTracking(widget.plannedTripId);
        } else {
          _locationService.stopTracking();
        }
        await _fetchTripData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip ${action == 'start' ? 'started' : 'stopped'} successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${action} trip')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  Future<void> _updateStudentStatus(int studentTripId, String action) async {
    setState(() => _loadingAction = true);
    try {
      final dio = DioClient().dio;
      final endpoint = action == 'pick-up' ? '/planned-trips/pick-up' : '/planned-trips/drop-off';
      final response = await dio.post(endpoint, data: {'student_trip_id': studentTripId});
      if (response.statusCode == 200) {
        await _fetchTripData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student ${action == 'pick-up' ? 'picked up' : 'dropped off'} successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to $action student')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isStarted = _tripData?['started_at'] != null && _tripData?['ended_at'] == null;
    final bool isEnded = _tripData?['ended_at'] != null;

    // Group students by status
    final Map<String, List<dynamic>> grouped = {};
    for (var s in _students) {
      final status = s['status'] ?? 'scheduled';
      if (!grouped.containsKey(status)) grouped[status] = [];
      grouped[status]!.add(s);
    }

    final statusOrder = ['scheduled', 'boarded', 'dropped_off'];
    final statusLabels = {
      'scheduled': 'To Pick Up',
      'boarded': 'On Board',
      'dropped_off': 'Dropped Off',
    };
    final statusColors = {
      'scheduled': Colors.orange,
      'boarded': Colors.green,
      'dropped_off': Colors.grey,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isEnded)
            IconButton(
              icon: Icon(isStarted ? Icons.stop : Icons.play_arrow),
              onPressed: _loadingAction
                  ? null
                  : () {
                      _startStopTrip(isStarted ? 'stop' : 'start');
                    },
              tooltip: isStarted ? 'Stop Trip' : 'Start Trip',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    // Trip status summary
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${isEnded ? 'Completed' : isStarted ? 'Active' : 'Scheduled'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isStarted && !isEnded)
                            Chip(
                              label: const Text('LIVE', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          if (isStarted && !isEnded)
                            Text(
                              _locationService.isTracking ? '📍 Tracking' : '📍 No GPS',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    // Students list grouped by status
                    Expanded(
                      child: _students.isEmpty
                          ? const Center(child: Text('No students assigned'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: statusOrder.length,
                              itemBuilder: (context, statusIndex) {
                                final statusKey = statusOrder[statusIndex];
                                final list = grouped[statusKey] ?? [];
                                if (list.isEmpty) return const SizedBox.shrink();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 20,
                                            color: statusColors[statusKey],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            statusLabels[statusKey] ?? statusKey,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${list.length}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...list.map((student) {
                                      final status = student['status'] ?? 'scheduled';
                                      return Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          title: Text(student['student_name'] ?? 'Unknown'),
                                          subtitle: Text('Status: $status'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (status == 'scheduled')
                                                ElevatedButton(
                                                  onPressed: isStarted && !isEnded
                                                      ? () => _updateStudentStatus(
                                                          student['student_trip_id'], 'pick-up')
                                                      : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text('Pick Up'),
                                                ),
                                              if (status == 'boarded')
                                                ElevatedButton(
                                                  onPressed: isStarted && !isEnded
                                                      ? () => _updateStudentStatus(
                                                          student['student_trip_id'], 'drop-off')
                                                      : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.orange,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text('Drop Off'),
                                                ),
                                              if (status == 'dropped_off')
                                                const Chip(
                                                  label: Text('Done'),
                                                  backgroundColor: Colors.grey,
                                                  labelStyle: TextStyle(color: Colors.white),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
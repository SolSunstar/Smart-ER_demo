import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/demo_trip.dart';
import '../widgets/impact_strip.dart';
import '../widgets/route_map.dart';

/// Log your own bike, transit or walking trip with a simple timer.
class TrackRideScreen extends StatefulWidget {
  final TravelMode initialMode;
  const TrackRideScreen({super.key, this.initialMode = TravelMode.bike});

  @override
  State<TrackRideScreen> createState() => _TrackRideScreenState();
}

class _TrackRideScreenState extends State<TrackRideScreen> {
  late TravelMode _mode = widget.initialMode;
  Timer? _ticker;
  int _seconds = 0;

  bool get _running => _ticker != null;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _seconds = 0;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    setState(() => _ticker = null);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip logged'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${modeInfo[_mode]!.label} trip, ${_format(_seconds)}'),
              const SizedBox(height: 12),
              ImpactStrip(mode: _mode),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  String _format(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track my own trip')),
      body: Column(
        children: [
          Expanded(child: RouteMap(mode: _mode)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<TravelMode>(
                    segments: [
                      for (final m in [
                        TravelMode.bike,
                        TravelMode.transit,
                        TravelMode.walk
                      ])
                        ButtonSegment(
                          value: m,
                          label: Text(modeInfo[m]!.label),
                          icon: Icon(modeInfo[m]!.icon),
                        ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: _running
                        ? null
                        : (s) => setState(() => _mode = s.first),
                  ),
                  const SizedBox(height: 12),
                  Text(_format(_seconds),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ImpactStrip(mode: _mode, showYearly: false),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _running ? _stop : _start,
                    icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                    label: Text(_running ? 'Stop and log trip' : 'Start trip'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

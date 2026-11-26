import 'package:material_ui/material_ui.dart';

import '../services/proximity_service.dart';
import '../theme.dart';

/// The main status panel on the driver and rider views: shows whether the
/// two phones are searching for, connected to, or have lost each other.
class HandshakeCard extends StatelessWidget {
  final ProximityStatus status;
  final String partnerName;
  final String? note; // e.g. "Alex hasn't arrived yet"
  final VoidCallback? onEndRide;
  final VoidCallback? onReconnect;

  const HandshakeCard({
    super.key,
    required this.status,
    required this.partnerName,
    this.note,
    this.onEndRide,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, subtitle) = switch (status) {
      ProximityStatus.searching => (
          AppColors.bluetooth,
          Icons.bluetooth_searching,
          'Looking for $partnerName',
          'Keep Bluetooth on. Your phones connect automatically when '
              "you're close.",
        ),
      ProximityStatus.connected => (
          AppColors.green,
          Icons.bluetooth_connected,
          'Connected to $partnerName',
          'Ride verified. Stay connected until drop-off.',
        ),
      ProximityStatus.lost => (
          AppColors.emergency,
          Icons.bluetooth_disabled,
          'Connection lost',
          'Move closer or check that Bluetooth is on.',
        ),
    };

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (status == ProximityStatus.searching)
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: AppColors.bluetooth),
                        ),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(icon, color: color, size: 30),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BLUETOOTH HANDSHAKE',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.8,
                              color: color,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (note != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange[800], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(note!,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ],
            if (status == ProximityStatus.lost && onReconnect != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onReconnect,
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Try to reconnect'),
              ),
            ],
            if (status == ProximityStatus.connected && onEndRide != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onEndRide,
                  icon: const Icon(Icons.flag),
                  label: const Text('End ride'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

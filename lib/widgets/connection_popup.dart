import 'package:material_ui/material_ui.dart';

import '../theme.dart';

String _first(String name) => name.split(' ').first;
String _initials(String name) =>
    name.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join();

/// Pop-up shown when the driver's and passenger's phones connect.
Future<void> showConnectedPopup(
  BuildContext context, {
  required String partnerName,
  required bool isRider,
}) {
  final partnerRole = isRider ? 'driver' : 'passenger';

  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LinkedPhones(partner: _initials(partnerName), connected: true),
            const SizedBox(height: 16),
            const Text('Handshake complete',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("You're connected to $partnerName, your $partnerRole.",
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const _CheckRow(
                Icons.verified, AppColors.green, 'Trip verified and logged'),
            const _CheckRow(Icons.bluetooth_connected, AppColors.bluetooth,
                'Stay connected until drop-off'),
            const _CheckRow(Icons.eco, AppColors.green,
                  'Your cost and CO₂ savings are being tracked'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start ride'),
            ),
          ],
        ),
      ),
    ),
  );
}

enum LostAction { reconnect, message, ignore }

/// Pop-up shown when the connection drops during a ride.
Future<LostAction?> showConnectionLostPopup(
  BuildContext context, {
  required String partnerName,
  required bool isRider,
}) {
  final first = _first(partnerName);

  return showDialog<LostAction>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _LinkedPhones(
                  partner: _initials(partnerName), connected: false),
            ),
            const SizedBox(height: 16),
            const Text('Connection lost',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              "Your phone can't find $first's phone anymore. You may have "
              'moved apart, or Bluetooth was turned off.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, LostAction.reconnect),
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Try to reconnect'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, LostAction.message),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text('Message $first'),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            const Text(
              'Ride went fine and a phone just died?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, LostAction.ignore),
              icon: const Icon(Icons.check),
              label: const Text('Ignore and complete ride'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Two phones joined by a Bluetooth link (green) or a broken one (red).
class _LinkedPhones extends StatelessWidget {
  final String partner;
  final bool connected;
  const _LinkedPhones({required this.partner, required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.green : AppColors.emergency;

    Widget phone(String label) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(Icons.smartphone, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        phone('You'),
        SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                Expanded(child: Divider(color: color, thickness: 2)),
                Icon(
                  connected ? Icons.bluetooth_connected : Icons.link_off,
                  color: connected ? AppColors.bluetooth : AppColors.emergency,
                ),
                Expanded(child: Divider(color: color, thickness: 2)),
              ],
            ),
          ),
        ),
        phone(partner),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _CheckRow(this.icon, this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

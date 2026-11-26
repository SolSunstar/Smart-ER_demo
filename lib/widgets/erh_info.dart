import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Bottom sheet explaining Emergency Ride Home. Opened from the small
/// info buttons.
Future<void> showErhInfo(BuildContext context) {
  Widget step(IconData icon, String title, String body) => ListTile(
        dense: true,
        leading: Icon(icon, color: AppColors.emergency),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(body),
      );

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Emergency Ride Home',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            step(Icons.bluetooth_searching, 'Connect with your driver',
                'Your phones connect over Bluetooth when you meet.'),
            step(Icons.timer_outlined, 'Driver late or cancelled?',
                'Check in with them, or request an emergency ride.'),
            step(Icons.local_taxi, 'Get home',
                'A taxi or rideshare is arranged for you.'),
            const ListTile(
              dense: true,
              leading: Icon(Icons.local_hospital, color: AppColors.emergency),
              title: Text('Medical or police emergency? Call 911 first.'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Noticeable Emergency Ride Home section for the rider view.
/// When [urgent] is true (driver late, cancelled or disconnected) it shows
/// a button to request the ride.
class ErhRiderCard extends StatelessWidget {
  final bool urgent;
  final VoidCallback onRequest;

  const ErhRiderCard(
      {super.key, required this.urgent, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.emergency.withValues(alpha: urgent ? 0.12 : 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.emergency, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: AppColors.emergency),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emergency Ride Home',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.emergencyDark)),
                      Text(
                        urgent
                            ? "Driver not here? You can request a ride home now."
                            : "You're covered if your driver doesn't show or has to cancel.",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'About Emergency Ride Home',
                  icon: const Icon(Icons.info_outline,
                      color: AppColors.emergency),
                  onPressed: () => showErhInfo(context),
                ),
              ],
            ),
            if (urgent)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emergency),
                  onPressed: onRequest,
                  icon: const Icon(Icons.local_taxi),
                  label: const Text('Request emergency ride'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Asks the rider to confirm, then opens the confirmation screen.
Future<void> requestEmergencyRide(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.local_taxi, color: AppColors.emergency, size: 40),
      title: const Text('Emergency Ride Home'),
      content: const Text(
        'If your driver is not picking you up, you can request an '
        'emergency ride home.\n\nFor police or medical emergencies, dial 911.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.emergency,
            minimumSize: const Size(0, 40),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Request ride'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyRideRequestedScreen()),
    );
  }
}

/// Confirmation shown after the rider requests an emergency ride.
class EmergencyRideRequestedScreen extends StatelessWidget {
  const EmergencyRideRequestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Ride'),
        backgroundColor: AppColors.emergency,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_taxi, size: 90, color: AppColors.emergency),
            const SizedBox(height: 20),
            const Text(
              'EMERGENCY RIDE REQUESTED',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'A driver is on the way. Estimated arrival: 8 min.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Back to Trip Search'),
            ),
          ],
        ),
      ),
    );
  }
}

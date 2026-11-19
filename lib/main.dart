import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartERApp());
}

class SmartERApp extends StatelessWidget {
  const SmartERApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart-ER Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select your role',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            RadioListTile<String>(
              title: const Text('Driver'),
              value: 'Driver',
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Rider'),
              value: 'Rider',
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Text(
            selectedRole == null
            ? 'No role selected'
            : 'Selected role: $selectedRole',
            ),

            const SizedBox(height: 30),

            ElevatedButton(
            onPressed: selectedRole == null
            ? null
            : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingScreen(
                  role: selectedRole!,
                ),
              ),
            );
            },
            child: const Text('Start Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class WaitingScreen extends StatefulWidget {
  final String role;

  const WaitingScreen({
    super.key,
    required this.role,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  bool handshakeComplete = false;
  Timer? riderWaitTimer;
  bool emergencyRideAvailable = false;

  Timer? activeRideTimer;
  bool rideEmergencyAvailable = false;

  @override
  void initState() {
    super.initState();

    if (widget.role == 'Rider') {
      riderWaitTimer = Timer(
        const Duration(seconds: 5), // Rider wait timer if driver no-show
        () {
          if (mounted && !handshakeComplete) {
            setState(() {
              emergencyRideAvailable = true;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    riderWaitTimer?.cancel();
    activeRideTimer?.cancel();
    super.dispose();
  }

  void startActiveRideTimer() {
    if (widget.role == 'Rider') {
      activeRideTimer = Timer(
        const Duration(seconds: 5), // Timer for ER-button's appearance when in the vehicle
        () {
          if (mounted && handshakeComplete) {
            setState(() {
              rideEmergencyAvailable = true;
            });
          }
        },
      );
    }
  }

  void showEmergencyRideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Ride'),
          content: const Text(
            'If your driver is NOT picking you up you may request a valid emergency ride.\n\n'
            'For Police or Medical Emergencies, please dial 911.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EmergencyRideRequestedScreen(),
                  ),
                );
              },
              child: const Text('Request Emergency Ride'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart-ER Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.role} Mode',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            if (!handshakeComplete) ...[
              const CircularProgressIndicator(),

              const SizedBox(height: 30),

              Text(
                widget.role == 'Driver'
                    ? 'Waiting for rider...'
                    : 'Searching for driver...',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  riderWaitTimer?.cancel();

                  setState(() {
                    handshakeComplete = true;
                    emergencyRideAvailable = false;
                  });

                  startActiveRideTimer();
                },
                child: const Text('Simulate Handshake'),
              ),

              if (emergencyRideAvailable) ...[
                const SizedBox(height: 30),

                SizedBox(
                  width: 280,
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      showEmergencyRideDialog();
                    },
                    child: const Text(
                      'EMERGENCY RIDE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            if (handshakeComplete) ...[
              const Icon(
                Icons.check_circle,
                size: 70,
              ),

              const SizedBox(height: 20),

              const Text(
                'Handshake Confirmed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Commute is now active.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton:
        handshakeComplete &&
              widget.role == 'Rider' &&
              rideEmergencyAvailable
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () {
                showEmergencyRideDialog();
              },
              child: const Text(
                'ER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,    
    );
  }
}

class EmergencyRideRequestedScreen extends StatelessWidget {
  const EmergencyRideRequestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart-ER Demo'),
      ),
      body: const Center(
        child: Text(
          'EMERGENCY RIDE REQUESTED',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
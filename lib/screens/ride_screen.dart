import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/demo_trip.dart';
import '../services/chat.dart';
import '../services/proximity_service.dart';
import '../theme.dart';
import '../widgets/connection_popup.dart';
import '../widgets/erh_info.dart';
import '../widgets/handshake_card.dart';
import '../widgets/impact_strip.dart';
import '../widgets/route_map.dart';
import 'chat_screen.dart';
import 'emergency_ride_screen.dart';

/// Driver or rider view of one carpool ride. The Bluetooth handshake is the
/// main panel; the map, messaging, Emergency Ride Home and impact sit
/// around it.
class RideScreen extends StatefulWidget {
  final String role; // 'Driver' or 'Rider'
  const RideScreen({super.key, required this.role});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final _proximity = SimulatedProximityService();
  final _chat = ChatThread();
  StreamSubscription<ProximityEvent>? _sub;

  ProximityStatus _status = ProximityStatus.searching;
  Timer? _replyTimer;
  bool _late = false; // driver hasn't shown up on time (rider only)
  bool _cancelled = false; // driver cancelled (rider only)
  bool _chatOpen = false;

  bool get isRider => widget.role == 'Rider';
  String get partnerName => isRider ? 'Alex M.' : 'Jordan K.';
  String get partnerFirst => partnerName.split(' ').first;

  @override
  void initState() {
    super.initState();
    _sub = _proximity.events.listen(_onProximityEvent);
    _proximity.start();
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _sub?.cancel();
    _proximity.stop();
    _chat.dispose();
    super.dispose();
  }

  // ---------- Bluetooth handshake ----------

  Future<void> _onProximityEvent(ProximityEvent event) async {
    if (!mounted) return;
    final previous = _status;
    setState(() => _status = event.status);

    switch (event.status) {
      case ProximityStatus.searching:
        break;

      case ProximityStatus.connected:
            setState(() => _late = false);
        await showConnectedPopup(context,
            partnerName: partnerName, isRider: isRider);

      case ProximityStatus.lost:
        if (previous != ProximityStatus.connected) return;
        final action = await showConnectionLostPopup(context,
            partnerName: partnerName, isRider: isRider);
        if (!mounted) return;
        switch (action) {
          case LostAction.reconnect:
            _proximity.simulateSearching();
          case LostAction.message:
            _openChat();
          case LostAction.ignore:
            // The ride went fine; a phone just died. Treat it as complete.
            _endRide();
          case null:
            break;
        }
    }
  }

  // ---------- Messaging ----------

  Future<void> _openChat() async {
    _chatOpen = true;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          thread: _chat,
          partnerName: partnerName,
          quickReplies: isRider
              ? const ["I'm at the pickup spot", 'Where are you?', 'Running late']
              : const ["I'm here", '5 min away', 'Running late'],
        ),
      ),
    );
    _chatOpen = false;
  }

  /// A message arrives from the other person. Shows an alert directing the
  /// user to the text line (unless they're already in it).
  Future<void> _receiveMessage(String text) async {
    _chat.send(text, mine: false, from: partnerName);
    if (_chatOpen) return;

    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.mark_chat_unread,
            color: AppColors.green, size: 36),
        title: Text('New message from $partnerFirst'),
        content: Text('"$text"', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open messages'),
          ),
        ],
      ),
    );
    if (open == true && mounted) _openChat();
  }

  // ---------- Rider actions ----------

  void _checkIn() {
    _chat.send("Hi $partnerFirst, I'm at the pickup spot. Are you close?",
        mine: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in sent to $partnerFirst')),
    );
    // Demo: the driver replies a few seconds later.
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _receiveMessage('Sorry! Stuck in traffic, about 5 min away.');
    });
  }

  Future<void> _driverCancelled() async {
    // A cancelled driver also "hasn't arrived", so the late message and
    // the Emergency Ride Home option appear on the rider page.
    setState(() {
      _cancelled = true;
      _late = true;
    });
    _chat.send('Sorry, I have to cancel. Family emergency.',
        mine: false, from: partnerName);

    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cancel, color: AppColors.emergency, size: 40),
        title: Text('$partnerFirst cancelled the ride'),
        content: Text('$partnerFirst sent you a message about it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('OK'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open messages'),
          ),
        ],
      ),
    );
    if (open == true && mounted) _openChat();
  }

  // ---------- Driver actions ----------

  Future<void> _emergencyCancel() async {
    const reasons = ['Vehicle problem', 'Personal emergency', 'Other'];
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Emergency cancel'),
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
                '$partnerFirst will be told right away and offered an '
                'Emergency Ride Home. Why are you cancelling?'),
          ),
          for (final r in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, r),
              child: Text(r, style: const TextStyle(fontSize: 16)),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep the ride',
                style: TextStyle(color: AppColors.green, fontSize: 16)),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.green, size: 40),
        title: const Text('Ride cancelled'),
        content: Text(
            '$partnerFirst has been notified and offered an Emergency Ride Home.'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  // ---------- Both ----------

  Future<void> _endRide() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.flag, color: AppColors.green, size: 40),
        title: const Text('Ride complete'),
        content: const SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nice work! Compared with driving alone, this trip:'),
              SizedBox(height: 12),
              ImpactStrip(mode: TravelMode.carpool),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final connected = _status == ProximityStatus.connected;
    // Emergency Ride Home only shows alongside the "hasn't arrived" message.
    final driverMissing = isRider && _late && !connected;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRider ? 'Rider view' : 'Driver view'),
        actions: [
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _openChat,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          RouteMap(
            mode: TravelMode.carpool,
            height: 180,
            // Rider sees the driver's car approaching; driver sees the
            // passenger waiting at the pickup spot.
            partner: connected
                ? null
                : (isRider ? DemoTrip.driverApproaching : DemoTrip.origin),
            partnerIcon: isRider ? Icons.directions_car : Icons.person,
          ),
          const SizedBox(height: 4),

          HandshakeCard(
            status: _status,
            partnerName: partnerName,
            note: driverMissing
                ? (_cancelled
                    ? "$partnerFirst hasn't arrived yet and has cancelled the "
                        'ride. You can use Emergency Ride Home.'
                    : "$partnerFirst hasn't arrived yet. Check in, or use "
                        'Emergency Ride Home.')
                : null,
            onReconnect: _proximity.simulateSearching,
            onEndRide: _endRide,
          ),

          // Main actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openChat,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text('Message $partnerFirst'),
                  ),
                ),
                const SizedBox(width: 8),
                if (isRider)
                  Expanded(
                    child: driverMissing
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: _checkIn,
                            icon: const Icon(Icons.how_to_reg),
                            label: const Text('Check in'),
                          )
                        : OutlinedButton.icon(
                            onPressed: connected ? null : _checkIn,
                            icon: const Icon(Icons.how_to_reg),
                            label: const Text('Check in'),
                          ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.emergency,
                        side: const BorderSide(color: AppColors.emergency),
                      ),
                      onPressed: _emergencyCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Emergency cancel'),
                    ),
                  ),
              ],
            ),
          ),

          // Compact Emergency Ride Home option, same size as the buttons above
          if (driverMissing)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emergency,
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () => requestEmergencyRide(context),
                      icon: const Icon(Icons.local_taxi),
                      label: const Text('Emergency ride home'),
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
            ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text('This ride vs. driving alone',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ImpactStrip(mode: TravelMode.carpool),
          ),

          _DemoControls(
            children: [
              _demoButton('Simulate connection',
                  connected ? null : () => _proximity.simulateConnect(
                      partnerName: partnerName)),
              _demoButton('Simulate disconnect',
                  connected ? _proximity.simulateLoss : null),
              _demoButton(
                isRider ? 'Driver sends message' : 'Passenger sends message',
                () => _receiveMessage(isRider
                    ? "I'm at the pickup spot, blue Honda Civic."
                    : "I'm by the front entrance."),
              ),
              if (isRider)
                _demoButton('Driver is late',
                    _late || connected ? null : () => setState(() => _late = true)),
              if (isRider)
                _demoButton('Driver cancels',
                    _cancelled ? null : _driverCancelled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _demoButton(String label, VoidCallback? onPressed) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 12),
        ),
        onPressed: onPressed,
        child: Text(label),
      );
}

/// Buttons that fake events, for demoing on one device.
class _DemoControls extends StatelessWidget {
  final List<Widget> children;
  const _DemoControls({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text('Demo controls',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }
}

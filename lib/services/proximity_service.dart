import 'dart:async';

/// What the app needs to know about the driver <-> passenger link.
enum ProximityStatus { searching, connected, lost }

class ProximityEvent {
  final ProximityStatus status;
  final String? partnerName;
  final int? signalStrength; // RSSI in dBm, when a real radio provides it

  const ProximityEvent(this.status, {this.partnerName, this.signalStrength});
}

/// The screens only talk to this interface, so the simulated version used
/// for the demo can later be swapped for a real Bluetooth one without
/// changing any UI code.
abstract class ProximityService {
  Stream<ProximityEvent> get events;
  Future<void> start();
  Future<void> stop();
}

/// Demo implementation: no radio needed, so it runs on an emulator,
/// on the web, or on a single phone. Buttons in the UI call
/// [simulateConnect] and [simulateLoss].
class SimulatedProximityService implements ProximityService {
  final _controller = StreamController<ProximityEvent>.broadcast();

  @override
  Stream<ProximityEvent> get events => _controller.stream;

  @override
  Future<void> start() async {
    _controller.add(const ProximityEvent(ProximityStatus.searching));
  }

  void simulateConnect({String partnerName = 'Alex M.'}) {
    _controller.add(ProximityEvent(
      ProximityStatus.connected,
      partnerName: partnerName,
      signalStrength: -58,
    ));
  }

  void simulateSearching() {
    _controller.add(const ProximityEvent(ProximityStatus.searching));
  }

  void simulateLoss() {
    _controller.add(const ProximityEvent(ProximityStatus.lost));
  }

  @override
  Future<void> stop() async {
    await _controller.close();
  }
}

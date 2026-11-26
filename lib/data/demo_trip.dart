import 'package:material_ui/material_ui.dart';
import 'package:latlong2/latlong.dart';

/// The demo route: Yorkdale Shopping Centre to 4700 Keele St (York University).
class DemoTrip {
  static const originName = 'Yorkdale Shopping Centre';
  static const destinationName = '4700 Keele St, North York, ON';

  static final origin = LatLng(43.7254, -79.4522);
  static final destination = LatLng(43.7738, -79.5014);

  /// Rough path: Hwy 401 west to Keele St, then north to York University
  /// (not turn-by-turn accurate).
  static final route = <LatLng>[
    origin,
    LatLng(43.7232, -79.4600),
    LatLng(43.7250, -79.4830),
    LatLng(43.7480, -79.4875),
    LatLng(43.7700, -79.4915),
    LatLng(43.7740, -79.4950),
    destination,
  ];

  /// Where the driver is shown while still on the way to pick up.
  static final driverApproaching = LatLng(43.7190, -79.4500);
}

enum TravelMode { carpool, transit, bike, walk }

class ModeInfo {
  final String label;
  final IconData icon;
  final Color color;
  final int minutes; // one-way trip time
  final double cost; // one-way cost in dollars
  final double co2Kg; // one-way CO2 per person

  const ModeInfo(
      this.label, this.icon, this.color, this.minutes, this.cost, this.co2Kg);
}

/// Demo estimates for this ~9 km trip. Driving alone is the baseline that
/// every option is compared against.
const driveAlone =
    ModeInfo('Drive alone', Icons.directions_car, Colors.grey, 16, 9.50, 1.9);

const modeInfo = <TravelMode, ModeInfo>{
  TravelMode.carpool: ModeInfo(
      'Carpool', Icons.people, Color(0xFF1E88E5), 20, 4.75, 0.95),
  TravelMode.transit: ModeInfo(
      'Transit', Icons.directions_bus, Color(0xFF8E24AA), 32, 3.35, 0.45),
  TravelMode.bike:
      ModeInfo('Bike', Icons.pedal_bike, Color(0xFF2E7D32), 30, 0, 0),
  TravelMode.walk:
      ModeInfo('Walk', Icons.directions_walk, Color(0xFFE65100), 95, 0, 0),
};

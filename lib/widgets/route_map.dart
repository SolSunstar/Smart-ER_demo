import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/demo_trip.dart';
import '../theme.dart';

/// OpenStreetMap view of the demo route, coloured by travel mode.
/// Optionally shows where the other person (driver/passenger) is.
class RouteMap extends StatelessWidget {
  /// Turned off in widget tests, which can't download map tiles.
  static bool tilesEnabled = true;

  final TravelMode mode;
  final double? height;
  final LatLng? partner;
  final IconData partnerIcon;

  const RouteMap({
    super.key,
    required this.mode,
    this.height,
    this.partner,
    this.partnerIcon = Icons.directions_car,
  });

  @override
  Widget build(BuildContext context) {
    final info = modeInfo[mode]!;

    final map = FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(DemoTrip.route),
          padding: const EdgeInsets.fromLTRB(40, 70, 40, 30),
        ),
      ),
      children: [
        if (tilesEnabled)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smart_er_demo',
          ),
        PolylineLayer(
          polylines: [
            Polyline(points: DemoTrip.route, color: info.color, strokeWidth: 5),
          ],
        ),
        MarkerLayer(
          markers: [
            _pin(DemoTrip.origin, Icons.place, AppColors.green),
            _pin(DemoTrip.destination, Icons.flag, AppColors.emergency),
            if (partner != null) _partnerMarker(partner!),
          ],
        ),
        RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );

    return height == null ? map : SizedBox(height: height, child: map);
  }

  Marker _pin(LatLng point, IconData icon, Color color) => Marker(
        point: point,
        width: 36,
        height: 36,
        alignment: Alignment.topCenter,
        child: Icon(icon, color: color, size: 36),
      );

  Marker _partnerMarker(LatLng point) => Marker(
        point: point,
        width: 34,
        height: 34,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bluetooth,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(partnerIcon, color: Colors.white, size: 18),
        ),
      );
}

import 'package:material_ui/material_ui.dart';

import '../data/demo_trip.dart';
import '../theme.dart';
import '../widgets/erh_info.dart';
import '../widgets/impact_strip.dart';
import '../widgets/route_map.dart';
import 'ride_screen.dart';
import 'track_ride_screen.dart';

/// Start screen: route map with travel-mode chips, a small impact summary,
/// and three actions.
class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key});

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  TravelMode _mode = TravelMode.carpool;

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Search'),
        actions: [
          // Small Emergency Ride Home info button
          IconButton(
            tooltip: 'About Emergency Ride Home',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showErhInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map with travel-mode chips on top
          Expanded(
            child: Stack(
              children: [
                RouteMap(mode: _mode),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final m in TravelMode.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _ModeChip(
                              mode: m,
                              selected: _mode == m,
                              onTap: () => setState(() => _mode = m),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // From / To, each on its own full-width line
                  const _AddressRow(
                    icon: Icons.place,
                    color: AppColors.green,
                    label: 'From',
                    address: DemoTrip.originName,
                  ),
                  const SizedBox(height: 4),
                  const _AddressRow(
                    icon: Icons.flag,
                    color: AppColors.emergency,
                    label: 'To',
                    address: DemoTrip.destinationName,
                  ),
                  const SizedBox(height: 6),
                  ImpactStrip(mode: _mode, showYearly: false),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              _open(const RideScreen(role: 'Rider')),
                          icon: const Icon(Icons.search),
                          label: const Text('Find a ride'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 46)),
                          onPressed: () =>
                              _open(const RideScreen(role: 'Driver')),
                          icon: const Icon(Icons.add),
                          label: const Text('Post a ride'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _open(TrackRideScreen(
                      initialMode: _mode == TravelMode.carpool
                          ? TravelMode.bike
                          : _mode,
                    )),
                    icon: const Icon(Icons.timeline),
                    label: const Text('Track my own trip'),
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

class _ModeChip extends StatelessWidget {
  final TravelMode mode;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = modeInfo[mode]!;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(info.icon,
          size: 18, color: selected ? Colors.white : info.color),
      label: Text(info.label),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      selected: selected,
      selectedColor: info.color,
      backgroundColor: Colors.white,
      onSelected: (_) => onTap(),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../data/demo_trip.dart';
import '../theme.dart';

/// Compact comparison against driving alone: extra time (or time saved),
/// money saved and CO2 saved, plus what that adds up to over a year.
class ImpactStrip extends StatelessWidget {
  final TravelMode mode;
  final bool showYearly;

  const ImpactStrip({super.key, required this.mode, this.showYearly = true});

  @override
  Widget build(BuildContext context) {
    final info = modeInfo[mode]!;
    final extraMin = info.minutes - driveAlone.minutes;
    final costSaved = driveAlone.cost - info.cost;
    final co2Saved = driveAlone.co2Kg - info.co2Kg;

    // Round trip, about 230 work days a year
    const tripsPerYear = 2 * 230;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Item(
                icon: Icons.schedule,
                value: extraMin <= 0 ? '${-extraMin} min' : '+$extraMin min',
                label: extraMin <= 0 ? 'faster' : 'extra time',
                good: extraMin <= 5,
              ),
              _Item(
                icon: Icons.savings_outlined,
                value: '\$${costSaved.toStringAsFixed(2)}',
                label: 'saved',
                good: true,
              ),
              _Item(
                icon: Icons.eco_outlined,
                value: '${co2Saved.toStringAsFixed(1)} kg',
                label: 'CO₂ saved',
                good: true,
              ),
            ],
          ),
          if (showYearly) ...[
            const SizedBox(height: 4),
            Text(
              '5 days a week: about \$${(costSaved * tripsPerYear).round()} '
              'and ${(co2Saved * tripsPerYear).round()} kg CO₂ saved a year '
              'vs. driving alone.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool good;

  const _Item(
      {required this.icon,
      required this.value,
      required this.label,
      required this.good});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 18, color: good ? AppColors.green : Colors.orange[800]),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

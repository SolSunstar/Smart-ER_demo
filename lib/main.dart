import 'package:material_ui/material_ui.dart';

import 'screens/trip_search_screen.dart';
import 'theme.dart';

void main() {
  runApp(const SmartERApp());
}

class SmartERApp extends StatelessWidget {
  const SmartERApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-ER',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Lets packages that still use the old built-in Material library
      // (like flutter_map) work alongside material_ui.
      builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
      home: const TripSearchScreen(),
    );
  }
}

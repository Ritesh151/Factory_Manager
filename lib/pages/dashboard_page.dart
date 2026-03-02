import 'package:flutter/material.dart';

import '../features/dashboard/presentation/screens/dashboard_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // reuse existing screen with updated UI
    return const DashboardScreen();
  }
}

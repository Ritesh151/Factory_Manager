import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../shared/widgets/sidebar_navigation.dart';
import '../../shared/widgets/top_bar.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNavigation(
            currentPath: GoRouterState.of(context).matchedLocation,
            onNavigate: (path) => context.go(path),
          ),
          Expanded(
            child: Column(
              children: [
                const TopBar(title: AppConstants.appName),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

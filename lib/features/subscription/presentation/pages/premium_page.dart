import 'package:flutter/material.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Premium',
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Premium subscription options will appear here.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

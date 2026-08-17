import 'package:flutter/material.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({
    required this.categoryId,
    super.key,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Education',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Education content for "$categoryId" will appear here.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

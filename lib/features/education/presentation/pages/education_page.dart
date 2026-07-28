import 'package:flutter/material.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Полезное',
      body: AppEmptyState(
        title: 'Скоро здесь будет интересно',
        message: 'Материалы о категории «$categoryId» уже готовятся.',
      ),
    );
  }
}

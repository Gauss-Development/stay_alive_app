import 'package:flutter/material.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Категории',
      body: AppEmptyState(
        title: 'Пока пусто',
        message: 'Здесь появятся полезные категории продуктов.',
      ),
    );
  }
}

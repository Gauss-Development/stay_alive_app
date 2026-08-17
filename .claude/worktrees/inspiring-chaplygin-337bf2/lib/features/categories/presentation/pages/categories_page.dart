import 'package:flutter/material.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Categories',
      body: Center(
        child: Text('Category definitions will appear here.'),
      ),
    );
  }
}

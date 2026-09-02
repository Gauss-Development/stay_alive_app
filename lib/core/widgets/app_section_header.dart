import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';

/// Section title row with an optional trailing counter/action.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleLarge,
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

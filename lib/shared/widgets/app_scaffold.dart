import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_icon_button.dart';

/// Simple screen scaffold with the soft «Росток» header row.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: <Widget>[
                    if (context.canPop())
                      AppIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => context.pop(),
                      )
                    else
                      const SizedBox(width: 44),
                    Expanded(
                      child: Center(
                        child: Text(title!, style: context.text.titleLarge),
                      ),
                    ),
                    if (actions == null || actions!.isEmpty)
                      const SizedBox(width: 44)
                    else
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  ],
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

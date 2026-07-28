import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_primitives.dart';

/// Dev entry point (`/rostok`) linking to the five Росток screens so they can
/// be previewed without touching the existing app's navigation. Remove once the
/// redesign is wired into the real routes.
class RostokGalleryPage extends StatelessWidget {
  const RostokGalleryPage({super.key});

  static const List<(String, String, String)> _entries =
      <(String, String, String)>[
        ('Главный', 'Трекер дня и очки', AppRoutes.rostokHome),
        ('Профиль', 'Уровень и достижения', AppRoutes.rostokProfile),
        ('Челленджи', 'Квесты недели и дня', AppRoutes.rostokChallenges),
        ('Награда', 'Экран нового уровня', AppRoutes.rostokReward),
      ];

  @override
  Widget build(BuildContext context) {
    return RostokScaffold(
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: RostokColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Text('росток', style: RostokText.display(size: 26)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Экраны редизайна', style: RostokText.body(size: 15)),
          const SizedBox(height: 20),
          for (final (String title, String subtitle, String route) in _entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GalleryTile(
                title: title,
                subtitle: subtitle,
                onTap: () => context.push(route),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RostokColors.card,
        borderRadius: RostokDimens.row,
        boxShadow: RostokDimens.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: RostokDimens.row,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: RostokText.body(
                          size: 16,
                          weight: FontWeight.w700,
                          color: RostokColors.inkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: RostokText.body(
                          size: 13,
                          color: RostokColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: RostokColors.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

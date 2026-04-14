import 'package:flutter/material.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final DailyLogItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = item.completedCount >= item.targetCount;
    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text('${item.completedCount}/${item.targetCount} completed'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: item.completedCount > 0 ? onDecrement : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.add_circle_outline,
                color: isCompleted ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

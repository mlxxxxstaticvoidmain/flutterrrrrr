import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _formattedDate {
    final d = note.updatedAt;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.text,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                ),
                IconButton(
                  tooltip: 'Редактировать',
                  icon: const Icon(Icons.edit_outlined),
                  color: theme.colorScheme.primary,
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Удалить',
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  note.updatedAt.isAfter(note.createdAt)
                      ? Icons.edit_note
                      : Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  note.updatedAt.isAfter(note.createdAt)
                      ? 'Изменено $_formattedDate'
                      : 'Создано $_formattedDate',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../widgets/note_card.dart';

/// Главный экран приложения «Заметки».
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Note> _notes = <Note>[];
  final FocusNode _inputFocus = FocusNode();

  int _lastId = 0;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: action,
        ),
      );
  }

  void _saveNote() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      _showMessage('Введите текст заметки');
      return;
    }

    final now = DateTime.now();
    setState(() {
      _lastId++;
      _notes.insert(
        0,
        Note(
          id: 'note_$_lastId',
          text: text,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    _inputController.clear();
    _inputFocus.requestFocus();
    _showMessage('Заметка сохранена');
  }

  Future<void> _editNote(Note note) async {
    final controller = TextEditingController(text: note.text);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Редактирование заметки'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Текст заметки',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    // Даём диалогу завершить анимацию закрытия, затем освобождаем контроллер.
    Future<void>.delayed(const Duration(milliseconds: 400), controller.dispose);

    final text = result?.trim() ?? '';
    if (text.isEmpty || text == note.text) return;

    setState(() {
      final index = _notes.indexWhere((item) => item.id == note.id);
      if (index != -1) {
        _notes[index] = note.copyWith(text: text, updatedAt: DateTime.now());
      }
    });
    _showMessage('Изменения сохранены');
  }

  void _deleteNote(Note note) {
    final index = _notes.indexWhere((item) => item.id == note.id);

    setState(() {
      _notes.removeWhere((item) => item.id == note.id);
    });

    _showMessage(
      'Заметка удалена',
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          setState(() {
            final insertIndex = index < 0 ? 0 : index.clamp(0, _notes.length);
            _notes.insert(insertIndex, note);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sticky_note_2_outlined),
            SizedBox(width: 10),
            Text('Заметки'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'Всего: ${_notes.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _inputController,
                          focusNode: _inputFocus,
                          minLines: 2,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            labelText: 'Новая заметка',
                            hintText: 'Введите текст заметки...',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _saveNote,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _notes.isEmpty
                      ? _EmptyState(theme: theme)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return NoteCard(
                              key: ValueKey(note.id),
                              note: note,
                              onEdit: () => _editNote(note),
                              onDelete: () => _deleteNote(note),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Заметок пока нет',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Введите текст выше и нажмите «Сохранить»',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

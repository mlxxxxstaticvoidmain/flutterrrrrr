class Note {
  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({String? text, DateTime? updatedAt}) {
    return Note(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

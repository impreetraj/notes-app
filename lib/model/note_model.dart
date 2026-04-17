class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final int updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'updatedAt': updatedAt,
      };

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      updatedAt: map['updatedAt'] ?? 0,
    );
  }
}
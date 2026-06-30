class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String platform; 
  final String timeSlot;
  final String scheduleDay; 
  final int updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.platform,
    required this.timeSlot,
    required this.scheduleDay,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'platform': platform,
        'timeSlot': timeSlot,
        'scheduleDay': scheduleDay,
        'updatedAt': updatedAt,
      };

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      platform: map['platform'] ?? 'Google',
      timeSlot: map['timeSlot'] ?? '09:00',
      scheduleDay: map['scheduleDay'] ?? 'Today',
      updatedAt: map['updatedAt'] ?? 0,
    );
  }
}
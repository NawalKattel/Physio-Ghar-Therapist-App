class Note {
  const Note({
    required this.id,
    required this.patientId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
  });

  factory Note.fromJson(Map<String, dynamic> json, {required DateTime today}) {
    final [hour, minute] = (json['time'] as String)
        .split(':')
        .map(int.parse)
        .toList();
    return Note(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime(
        today.year,
        today.month,
        today.day + (json['dayOffset'] as int),
        hour,
        minute,
      ),
    );
  }

  factory Note.fromSaved(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    patientId: json['patientId'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    sessionId: json['sessionId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'sessionId': sessionId,
  };

  final String id;
  final String patientId;
  final String title;
  final String body;
  final DateTime createdAt;

  final DateTime? updatedAt;
  final String? sessionId;

  bool get isEdited => updatedAt != null;

  Note copyWith({String? title, String? body, DateTime? updatedAt}) => Note(
    id: id,
    patientId: patientId,
    title: title ?? this.title,
    body: body ?? this.body,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sessionId: sessionId,
  );
}

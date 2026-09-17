enum ComplaintCategory {
  patient('Patient Issue'),
  booking('Booking Issue'),
  payment('Payment Issue'),
  technical('Technical Issue'),
  other('Other');

  const ComplaintCategory(this.label);

  final String label;
}

class Complaint {
  const Complaint({
    required this.id,
    required this.reference,
    required this.category,
    required this.subject,
    required this.description,
    required this.submittedAt,
  });

  factory Complaint.fromJson(
    Map<String, dynamic> json, {
    required DateTime today,
  }) {
    final [hour, minute] = (json['time'] as String)
        .split(':')
        .map(int.parse)
        .toList();
    return Complaint(
      id: json['id'] as String,
      reference: json['reference'] as String,
      category: ComplaintCategory.values.byName(json['category'] as String),
      subject: json['subject'] as String,
      description: json['description'] as String,
      submittedAt: DateTime(
        today.year,
        today.month,
        today.day + (json['dayOffset'] as int),
        hour,
        minute,
      ),
    );
  }

  factory Complaint.fromSaved(Map<String, dynamic> json) => Complaint(
    id: json['id'] as String,
    reference: json['reference'] as String,
    category: ComplaintCategory.values.byName(json['category'] as String),
    subject: json['subject'] as String,
    description: json['description'] as String,
    submittedAt: DateTime.parse(json['submittedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'category': category.name,
    'subject': subject,
    'description': description,
    'submittedAt': submittedAt.toIso8601String(),
  };

  final String id;

  final String reference;
  final ComplaintCategory category;
  final String subject;
  final String description;
  final DateTime submittedAt;
}

class Therapist {
  const Therapist({
    required this.name,
    required this.email,
    required this.phone,
    required this.experienceYears,
    required this.specialization,
    required this.address,
    required this.isAvailable,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) => Therapist(
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    experienceYears: json['experienceYears'] as int,
    specialization: json['specialization'] as String,
    address: json['address'] as String,
    isAvailable: json['isAvailable'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'experienceYears': experienceYears,
    'specialization': specialization,
    'address': address,
    'isAvailable': isAvailable,
  };

  final String name;
  final String email;
  final String phone;
  final int experienceYears;
  final String specialization;
  final String address;

  final bool isAvailable;

  Therapist copyWith({
    String? name,
    String? email,
    String? phone,
    int? experienceYears,
    String? specialization,
    String? address,
    bool? isAvailable,
  }) => Therapist(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    experienceYears: experienceYears ?? this.experienceYears,
    specialization: specialization ?? this.specialization,
    address: address ?? this.address,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

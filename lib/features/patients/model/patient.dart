class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.condition,
    required this.treatmentPlan,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
    gender: json['gender'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    condition: json['condition'] as String,
    treatmentPlan: json['treatmentPlan'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'phone': phone,
    'address': address,
    'condition': condition,
    'treatmentPlan': treatmentPlan,
  };

  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String condition;
  final String treatmentPlan;
}

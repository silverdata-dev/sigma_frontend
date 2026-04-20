class Subject {
  final String? id;
  final String cedula;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final int? sex;
  final String? dateBirth;
  final Map<String, dynamic>? metadataJson;
  final String? createdAt;

  Subject({
    this.id,
    required this.cedula,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.sex,
    this.dateBirth,
    this.metadataJson,
    this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      cedula: json['cedula'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      sex: json['sex'],
      dateBirth: json['date_birth'],
      metadataJson: json['metadata_json'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (sex != null) 'sex': sex,
      if (dateBirth != null) 'date_birth': dateBirth,
      if (metadataJson != null) 'metadata_json': metadataJson,
    };
  }
}

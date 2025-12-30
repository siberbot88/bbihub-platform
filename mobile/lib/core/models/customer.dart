class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: (json['address'] ?? json['alamat'])?.toString(),
    );
  }

  // Getter compatibility
  String? get phoneNumber => phone;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (address != null) 'address': address,
  };
}

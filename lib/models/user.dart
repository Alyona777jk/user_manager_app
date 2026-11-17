class Geo {
  final String lat;
  final String lng;

  Geo({required this.lat, required this.lng});

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: json['lat']?.toString() ?? '0.0',
      lng: json['lng']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Address({
    required this.street,
    this.suite = '',
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? 'Не вказано',
      suite: json['suite'] ?? '',
      city: json['city'] ?? 'Не вказано',
      zipcode: json['zipcode'] ?? '',
      geo: json['geo'] != null
          ? Geo.fromJson(json['geo'])
          : Geo(lat: '0.0', lng: '0.0'),
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'suite': suite,
        'city': city,
        'zipcode': zipcode,
        'geo': geo.toJson(),
      };
}

class Company {
  final String name;
  final String catchPhrase;

  Company({required this.name, this.catchPhrase = ''});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? 'Не вказано',
      catchPhrase: json['catchPhrase'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'catchPhrase': catchPhrase,
      };
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final Address address;
  final Company company;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address(
              street: 'Не вказано',
              city: 'Не вказано',
              zipcode: '00000',
              geo: Geo(lat: '0.0', lng: '0.0'),
            ),
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : Company(name: 'Незалежний спеціаліст'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address.toJson(),
        'company': company.toJson(),
      };

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    Address? address,
    Company? company,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      company: company ?? this.company,
    );
  }
}

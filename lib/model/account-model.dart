class AccountModel {
  String firstname;
  String lastname;
  String email;
  String password;
  String? city;
  String phonenumber; // استخدمت String بدل int
  int synced;

  AccountModel({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    this.city,
    required this.phonenumber,
    this.synced = 0,
  });

  // تحويل للكلاس إلى Map
  Map<String, dynamic> toMap() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'password': password,
    'city': city,
    'phonenumber': phonenumber,
    'synced': synced,
  };

  // إنشاء الكلاس من Map
  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
    firstname: map['firstname'],
    lastname: map['lastname'],
    email: map['email'],
    password: map['password'],
    city: map['city'],
    phonenumber: map['phonenumber'].toString(),
    synced: map['synced'] ?? 0,
  );
}

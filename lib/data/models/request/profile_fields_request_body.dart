
class ProfileFieldsRequestBody {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? country;
  final String? dob;          // yyyy-MM-dd
  final String? gender;       // 'M' / 'F' 
  final String? citizenship;
  final String? address;
  final Map<String, dynamic>? customFields; // { backendKey : value }

  const ProfileFieldsRequestBody({
    this.fullName,
    this.email,
    this.phone,
    this.country,
    this.dob,
    this.gender,
    this.citizenship,
    this.address,
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    void put(String key, dynamic v) {
      if (v == null) return;
      map[key] = v;
    }

    put('full_name', fullName);
    put('email', email);
    put('phone', phone);
    put('country', country);
    put('dob', dob);
    put('gender', gender);
    put('citizenship', citizenship);
    put('address', address);
    
    if (customFields != null && customFields!.isNotEmpty) {
      map['custom_fields'] = customFields;
    } else {
      map['custom_fields'] = {};
    }
    return map;
  }
}
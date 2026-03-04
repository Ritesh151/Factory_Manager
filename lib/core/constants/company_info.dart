/// Company information constants for SmartERP
class CompanyInfo {
  // Basic Company Details
  static const String name = 'LAXMANJI RAVTAJI';
  static const String address = '114/80, LAXMANJI RAVTAJI COMPOUND, MANDI KUVA ROAD, O/S SHAHPUR GATE, NEAR MUNICIPAL QUARTER KAZIPUR DARIYAPUR, AHMEDABAD - 380004';
  static const String email = 'siddhivinayak0330@gmail.com';
  static const String phone = '9974884444';
  static const String gstin = '24BCTPC3372F1ZO';
  
  // Formatted versions
  static String get formattedPhone => '+91 $phone';
  static String get fullAddress => '$name\n$address';
  
  // Map for easy access
  static Map<String, String> get all => {
    'name': name,
    'address': address,
    'email': email,
    'phone': phone,
    'gstin': gstin,
  };
}

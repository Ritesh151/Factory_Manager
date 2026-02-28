/// Firestore paths and collection names. All under users/{userId}/.
class FirebaseConstants {
  FirebaseConstants._();

  static String usersPath(String uid) => 'users/$uid';
  static String productsPath(String uid) => 'users/$uid/products';
  static String productPath(String uid, String id) => 'users/$uid/products/$id';
  static String salesPath(String uid) => 'users/$uid/sales';
  static String salePath(String uid, String id) => 'users/$uid/sales/$id';
  static String purchasesPath(String uid) => 'users/$uid/purchases';
  static String purchasePath(String uid, String id) =>
      'users/$uid/purchases/$id';
  static String expensesPath(String uid) => 'users/$uid/expenses';
  static String expensePath(String uid, String id) =>
      'users/$uid/expenses/$id';
  static String employeesPath(String uid) => 'users/$uid/employees';
  static String employeePath(String uid, String id) =>
      'users/$uid/employees/$id';
  static String salaryPaymentsPath(String uid) => 'users/$uid/salary_payments';
  static String salaryPaymentPath(String uid, String id) =>
      'users/$uid/salary_payments/$id';
  static String profilePath(String uid) => 'users/$uid/profile';
  static String settingsPath(String uid) => 'users/$uid/settings';
}

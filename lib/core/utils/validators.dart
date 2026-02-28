/// Input validators. Used in forms and domain validation.
class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null) return 'Required';
    if (value.trim().length < min) return 'Min $min characters';
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) return 'Max $max characters';
    return null;
  }

  static String? hsnCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (!RegExp(r'^\d{4,8}$').hasMatch(value.trim())) {
      return 'HSN must be 4–8 digits';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) return 'Must be greater than 0';
    return null;
  }

  static String? nonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value.trim());
    if (n == null || n < 0) return 'Cannot be negative';
    return null;
  }

  static String? nonNegativeInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = int.tryParse(value.trim());
    if (n == null || n < 0) return 'Cannot be negative';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }
}

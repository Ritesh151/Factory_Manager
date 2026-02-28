import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserCredential> execute(String email, String password) async {
    return await _repository.registerWithEmailAndPassword(email, password);
  }
}

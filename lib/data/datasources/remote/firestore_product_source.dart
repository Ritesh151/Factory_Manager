import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/product_dto.dart';
import '../../../core/constants/firebase_constants.dart';

class FirestoreProductSource {
  FirestoreProductSource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection(FirebaseConstants.productsPath(uid));

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchAll(
      String userId) {
    return _col(userId)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAll(
      String userId) async {
    final s = await _col(userId).orderBy('name').get();
    return s.docs;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getById(
      String userId, String productId) async {
    return await _col(userId).doc(productId).get();
  }

  Future<String> create(String userId, ProductDto dto) async {
    final ref = await _col(userId).add(dto.toMap());
    return ref.id;
  }

  Future<void> update(String userId, String productId, ProductDto dto) async {
    await _col(userId).doc(productId).update(dto.toMap());
  }

  Future<void> delete(String userId, String productId) async {
    await _col(userId).doc(productId).update({'isActive': false});
  }

  Future<void> updateStock(
      String userId, String productId, int newStock) async {
    await _col(userId).doc(productId).update({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> batchUpdateStock(
    String userId,
    List<MapEntry<String, int>> updates,
  ) async {
    final batch = _firestore.batch();
    for (final e in updates) {
      batch.update(_col(userId).doc(e.key), {
        'stock': e.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}

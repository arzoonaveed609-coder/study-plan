import 'package:cloud_firestore/cloud_firestore.dart';

class ParentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get parent data
  Future<Map<String, dynamic>?> getParentData(String parentId) async {
    try {
      DocumentSnapshot document = await _firestore
          .collection('parents')
          .doc(parentId)
          .get();

      if (document.exists) {
        return document.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get parent data: $e');
    }
  }

  // Save parent data
  Future<void> saveParentData(
      String parentId,
      Map<String, dynamic> data,
      ) async {
    try {
      await _firestore
          .collection('parents')
          .doc(parentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save parent data: $e');
    }
  }

  // Get children linked with parent
  Future<List<Map<String, dynamic>>> getChildren(String parentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get children: $e');
    }
  }
}
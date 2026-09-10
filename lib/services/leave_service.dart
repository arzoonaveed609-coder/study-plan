import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a leave request
  Future<void> submitLeaveRequest(
      String parentId,
      Map<String, dynamic> leaveData,
      ) async {
    try {
      await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('leaveRequests')
          .add({
        ...leaveData,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit leave request: $e');
    }
  }

  // Get all leave requests
  Future<List<Map<String, dynamic>>> getLeaveRequests(
      String parentId,
      ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('leaveRequests')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leave requests: $e');
    }
  }
}
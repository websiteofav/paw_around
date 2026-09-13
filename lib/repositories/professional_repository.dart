import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/sitters/professional_model.dart';

class ProfessionalRepository {
  final FirebaseFirestore _firestore;

  ProfessionalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sittersRef =>
      _firestore.collection('sitters');

  // All pet-sitting professionals available for booking
  Future<List<ProfessionalModel>> getAllProfessionals() async {
    final snapshot = await _sittersRef.get();
    return snapshot.docs.map(ProfessionalModel.fromFirestore).toList();
  }
}

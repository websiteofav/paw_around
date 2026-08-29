import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';

class AddressRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  AddressRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  // Get reference to current user's addresses collection
  CollectionReference<Map<String, dynamic>> get _addressesRef {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Add a new address, returns the new document id
  Future<String> addAddress(AddressModel address) async {
    final docRef = await _addressesRef.add(address.toFirestore());
    return docRef.id;
  }

  // Get all saved addresses for the current user
  Future<List<AddressModel>> getAllAddresses() async {
    final snapshot =
        await _addressesRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => AddressModel.fromFirestore(doc)).toList();
  }
}

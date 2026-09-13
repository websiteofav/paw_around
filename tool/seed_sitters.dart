// Seeds the top-level `sitters` collection in Firestore using the Firebase
// Admin SDK, so BookSittersProfessionalSelector has real data to show.
//
// Get a service account key from Firebase Console > Project Settings >
// Service Accounts > Generate new private key. Do NOT commit that file —
// keep it outside the repo, or somewhere already covered by .gitignore.
//
// Usage:
//   dart run tool/seed_sitters.dart <path-to-service-account.json>

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

const _projectId = 'paw-around-f487d';

const _sitters = <String, Map<String, Object>>{
  'priya-sharma': {
    'name': 'Priya Sharma',
    'role': 'Pet Care Professional',
    'isAvailable': true,
    'rating': 4.8,
    'reviewCount': 203,
  },
  'arjun-mehta': {
    'name': 'Arjun Mehta',
    'role': 'Pet Care Professional',
    'isAvailable': true,
    'rating': 4.6,
    'reviewCount': 128,
  },
  'stella-fernandes': {
    'name': 'Stella Fernandes',
    'role': 'Certified Dog Trainer',
    'isAvailable': false,
    'rating': 4.9,
    'reviewCount': 311,
  },
};

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
        'Usage: dart run tool/seed_sitters.dart <path-to-service-account.json>');
    exit(1);
  }

  final credentialFile = File(args.first);
  if (!credentialFile.existsSync()) {
    stderr.writeln('Service account file not found: ${args.first}');
    exit(1);
  }

  final admin = FirebaseAdminApp.initializeApp(
    _projectId,
    Credential.fromServiceAccount(credentialFile),
  );

  final sittersRef = Firestore(admin).collection('sitters');

  for (final entry in _sitters.entries) {
    await sittersRef.doc(entry.key).set(entry.value);
    print('Seeded sitter: ${entry.key}');
  }

  await admin.close();
  print('Done — seeded ${_sitters.length} sitters.');
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/navigation/pending_intent.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/router/app_router.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingIntentService {
  PendingIntentService._();
  static final PendingIntentService instance = PendingIntentService._();

  static const String _storageKey = 'pending_intent_v1';
  String? _lastResolvedKey;

  Future<void> save(PendingIntent intent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(intent.toJson()));
  }

  Future<PendingIntent?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PendingIntent.fromJson(decoded);
    } catch (e) {
      debugPrint('Error decoding pending intent: $e');
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<bool> resolveIfPossible() async {
    final intent = await get();
    if (intent == null) {
      return false;
    }

    final isAuthenticated = sl<AuthRepository>().isLoggedIn;
    if (!isAuthenticated && intent.requiresAuth) {
      return false;
    }

    if (_lastResolvedKey == intent.dedupeKey) {
      await clear();
      return false;
    }

    _lastResolvedKey = intent.dedupeKey;
    await clear();

    if (isAuthenticated) {
      AppRouter.router.go(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _navigateIntent(intent, isAuthenticated: true);
      });
      return true;
    }

    await _navigateIntent(intent, isAuthenticated: false);
    return true;
  }

  Future<void> _navigateIntent(
    PendingIntent intent, {
    required bool isAuthenticated,
  }) async {
    switch (intent.type) {
      case PendingIntentType.actionReminder:
        await _navigateActionReminder(intent.payload);
        break;
      case PendingIntentType.route:
        _navigateRoute(intent.payload, isAuthenticated: isAuthenticated);
        break;
    }
  }

  Future<void> _navigateActionReminder(Map<String, dynamic> payload) async {
    final petId = payload['petId'] as String?;
    final reminderType = payload['reminderType'] as String?;
    final vaccineId = payload['vaccineId'] as String?;

    if (petId == null || reminderType == null) {
      debugPrint('Pending reminder intent missing required payload fields');
      return;
    }

    final pet = await sl<PetRepository>().getPetById(petId);
    if (pet == null) {
      AppRouter.router.go(AppRoutes.home);
      return;
    }

    if (reminderType == 'vaccine') {
      final vaccine = _findVaccine(pet, vaccineId);
      if (vaccine == null) {
        AppRouter.router.go(AppRoutes.home);
        return;
      }

      AppRouter.router.pushNamed(
        AppRoutes.actionDetail,
        extra: ActionCardData(
          actionType: ActionType.vaccine,
          pet: pet,
          vaccine: vaccine,
          customTitle: vaccine.vaccineName,
        ),
      );
      return;
    }

    if (reminderType == 'grooming') {
      AppRouter.router.pushNamed(
        AppRoutes.actionDetail,
        extra: ActionCardData(
          actionType: ActionType.grooming,
          pet: pet,
        ),
      );
      return;
    }

    if (reminderType == 'tickFlea') {
      AppRouter.router.pushNamed(
        AppRoutes.actionDetail,
        extra: ActionCardData(
          actionType: ActionType.tickFlea,
          pet: pet,
        ),
      );
      return;
    }

    AppRouter.router.go(AppRoutes.home);
  }

  void _navigateRoute(
    Map<String, dynamic> payload, {
    required bool isAuthenticated,
  }) {
    final rawPath = payload['path'] as String?;
    final path = _normalizePath(rawPath);
    if (path == null || path.isEmpty || path == AppRoutes.home) {
      return;
    }

    if (!isAuthenticated && _routeRequiresAuth(path)) {
      return;
    }

    AppRouter.router.push(path);
  }

  String? _normalizePath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(path);
    if (parsed == null || !parsed.hasScheme) {
      return path;
    }

    final normalizedPath = parsed.path.isEmpty ? '/' : parsed.path;
    if (parsed.query.isEmpty) {
      return normalizedPath;
    }
    return '$normalizedPath?${parsed.query}';
  }

  VaccineModel? _findVaccine(PetModel pet, String? vaccineId) {
    if (pet.vaccines.isEmpty) {
      return null;
    }

    if (vaccineId == null || vaccineId.isEmpty) {
      return pet.vaccines.first;
    }

    for (final vaccine in pet.vaccines) {
      if (vaccine.id == vaccineId) {
        return vaccine;
      }
    }
    return pet.vaccines.first;
  }

  bool routeRequiresAuth(String path) {
    return _routeRequiresAuth(path);
  }

  bool _routeRequiresAuth(String path) {
    if (path == AppRoutes.intro ||
        path == AppRoutes.onboarding ||
        path == AppRoutes.phoneLogin ||
        path == AppRoutes.otpVerification) {
      return false;
    }
    return !path.startsWith('/p/');
  }
}

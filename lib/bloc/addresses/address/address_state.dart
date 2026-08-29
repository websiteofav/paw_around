import 'package:equatable/equatable.dart';
import 'package:paw_around/models/addresses/address_model.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;

  const AddressLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;

  const AddressError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Transient signal that a new address was just saved — listen for this to
/// drive one-off side effects (haptic + navigation), not to render a screen.
class AddressSaved extends AddressState {
  final String addressId;

  const AddressSaved({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class AddressSaveError extends AddressState {
  final String message;

  const AddressSaveError({required this.message});

  @override
  List<Object?> get props => [message];
}

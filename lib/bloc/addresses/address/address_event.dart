import 'package:equatable/equatable.dart';
import 'package:paw_around/models/addresses/address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class AddAddress extends AddressEvent {
  final AddressModel address;

  const AddAddress({required this.address});

  @override
  List<Object?> get props => [address];
}

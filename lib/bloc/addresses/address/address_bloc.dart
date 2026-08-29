import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_event.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/repositories/address_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc({required AddressRepository addressRepository})
      : _addressRepository = addressRepository,
        super(const AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
  }

  Future<void> _onLoadAddresses(
      LoadAddresses event, Emitter<AddressState> emit) async {
    // Only show loading on the first fetch, not on silent refreshes.
    if (state is! AddressLoaded) {
      emit(const AddressLoading());
    }
    try {
      final addresses = await _addressRepository.getAllAddresses();
      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  Future<void> _onAddAddress(
      AddAddress event, Emitter<AddressState> emit) async {
    try {
      final id = await _addressRepository.addAddress(event.address);
      emit(AddressSaved(addressId: id));
      add(const LoadAddresses()); // Reload the list after adding
    } catch (e) {
      emit(AddressSaveError(message: e.toString()));
    }
  }
}

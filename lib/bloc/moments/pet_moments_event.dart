import 'package:equatable/equatable.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';

abstract class PetMomentsEvent extends Equatable {
  const PetMomentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoments extends PetMomentsEvent {
  const LoadMoments();
}

class LoadMyMoments extends PetMomentsEvent {
  final String userId;
  const LoadMyMoments(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateMoment extends PetMomentsEvent {
  final PetMoment moment;
  const CreateMoment(this.moment);

  @override
  List<Object?> get props => [moment];
}

class LikeMoment extends PetMomentsEvent {
  final String momentId;
  final String userId;
  const LikeMoment({required this.momentId, required this.userId});

  @override
  List<Object?> get props => [momentId, userId];
}

class AddComment extends PetMomentsEvent {
  final String momentId;
  final String userId;
  final String userName;
  final String text;
  const AddComment({
    required this.momentId,
    required this.userId,
    required this.userName,
    required this.text,
  });

  @override
  List<Object?> get props => [momentId, userId, userName, text];
}

class DeleteMoment extends PetMomentsEvent {
  final String momentId;
  const DeleteMoment(this.momentId);

  @override
  List<Object?> get props => [momentId];
}

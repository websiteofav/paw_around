import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/action_type.dart';

enum TimelineEntryStatus {
  completed,
  skipped,
}

class ActionTimelineEntry extends Equatable {
  final String id;
  final String actionName;
  final DateTime? date;
  final TimelineEntryStatus status;
  final ActionType actionType;

  const ActionTimelineEntry({
    required this.id,
    required this.actionName,
    this.date,
    required this.status,
    required this.actionType,
  });

  @override
  List<Object?> get props => [id, actionName, date, status, actionType];
}

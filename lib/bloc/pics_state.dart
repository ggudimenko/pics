part of 'pics_bloc.dart';

@immutable
abstract class PicsState {}

class PicsInitial extends PicsState {}

class PicsEmptyList extends PicsState {}

class PicsLoadInProgress extends PicsState {}

class PicsLoadSuccess extends PicsState {
  final List<Pic> pics;

  PicsLoadSuccess({required this.pics});
}

class PicsLoadFailure extends PicsState {
  final String error;

  PicsLoadFailure({required this.error});
}


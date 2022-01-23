part of 'pics_bloc.dart';

@immutable
abstract class PicsEvent {}

class ReloadRequest extends PicsEvent {}

class LoadPic extends PicsEvent {
  final XFile? file;

  LoadPic({required this.file});
}

class RemovePic extends PicsEvent {
  final Pic pic;

  RemovePic({required this.pic});
}
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:pics/data/models/pic.dart';
import 'package:pics/data/repositories/auth_repository.dart';
import 'package:pics/data/repositories/pics_repository.dart';
import 'package:pics/data/data_providers/cloud_storage_service.dart';

part 'pics_event.dart';

part 'pics_state.dart';

class PicsBloc extends Bloc<PicsEvent, PicsState> {
  final _cloudStorageService = CloudStorageService();
  final _picsRepository = PicsRepository();
  final AuthRepository authRepository;

  List<Pic> pics = [];

  PicsBloc({required this.authRepository}) : super(PicsInitial()) {
    on<ReloadRequest>((event, emit) async {
      emit(PicsLoadInProgress());
      pics = await _picsRepository.fetchPics(authRepository.currentUser!.id);
      return emit(PicsLoadSuccess(pics: pics));
    });

    on<RemovePic>((event, emit) async {
      await _picsRepository.removePic(authRepository.currentUser!.id, event.pic);
      pics.remove(event.pic);
      return emit(PicsLoadSuccess(pics: pics));
    });

    on<LoadPic>((event, emit) async {
      if (event.file == null) {
        emit(PicsLoadFailure(error: "No file was selected"));
      } else {
        var pic = Pic(id: "", ts: Timestamp.fromDate(DateTime.now()), url: "");
        pics.add(pic);
        PicsLoadSuccess(pics: pics);
        var uploadTask = await _cloudStorageService.uploadImage(imageToUpload: File(event.file!.path));
        emit(PicsLoadSuccess(pics: pics));
        await uploadTask;
        pic.url = await uploadTask.snapshot.ref.getDownloadURL();
        await _picsRepository.addPic(authRepository.currentUser!.id, pic);
        return emit(PicsLoadSuccess(pics: pics));
      }
    });
  }
}

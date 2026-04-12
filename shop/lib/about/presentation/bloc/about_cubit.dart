import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/about/domain/abstract_about_repository.dart';
import 'package:shop/about/domain/model/about_content.dart';

// ─── State ────────────────────────────────────────────────────────────────────

abstract class AboutState {}

class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  AboutLoaded(this.content);
  final AboutContent content;
}

class AboutError extends AboutState {
  AboutError(this.message);
  final String message;
}

class AboutSaving extends AboutState {
  AboutSaving(this.content);
  final AboutContent content;
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class AboutCubit extends Cubit<AboutState> {
  AboutCubit(this._repo) : super(AboutLoading());

  final AbstractAboutRepository _repo;

  Future<void> load() async {
    emit(AboutLoading());
    try {
      final content = await _repo.get();
      emit(AboutLoaded(content));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }

  Future<void> save(AboutContent content) async {
    emit(AboutSaving(content));
    try {
      await _repo.save(content);
      emit(AboutLoaded(content));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }
}

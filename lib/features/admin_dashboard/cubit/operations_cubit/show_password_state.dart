import 'package:equatable/equatable.dart';

abstract class ShowPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShowPasswordInitial extends ShowPasswordState {}

class ShowPasswordLoading extends ShowPasswordState {}

class ShowPasswordSuccess extends ShowPasswordState {
  final String password;
  ShowPasswordSuccess(this.password);
}
class ShowPasswordHidden extends ShowPasswordState {}

class ShowPasswordError extends ShowPasswordState {
  final String message;
  ShowPasswordError(this.message);
}

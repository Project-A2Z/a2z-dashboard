abstract class ReplyState {}

class ReplyInitial extends ReplyState {}

class ReplyLoading extends ReplyState {}

class ReplySuccess extends ReplyState {}

class ReplyError extends ReplyState {
  final String error;
  ReplyError({required this.error});
}

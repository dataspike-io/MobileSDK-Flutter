abstract class MessageState {}

class MessageStateSuccess extends MessageState {
  final String message;

  MessageStateSuccess({
    required this.message,
  });
}

class MessageStateError extends MessageState {
  final String error;
  final String details;

  MessageStateError({
    required this.error,
    required this.details,
  });
}
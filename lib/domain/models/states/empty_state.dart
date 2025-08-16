abstract class EmptyState {}

class EmptyStateSuccess extends EmptyState {}

class EmptyStateError extends EmptyState {
  final String error;
  final String details;

  EmptyStateError({
    required this.error,
    required this.details,
  });
}
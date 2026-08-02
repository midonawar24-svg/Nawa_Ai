/// V14 - Result/Failure - Error Handling موحد

/// Represents success or failure
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final dynamic error;
  const Failure(this.message, [this.error]);
}

/// Usage:
/// Result<String> result = await someOperation();
/// if (result is Success) { print(result.data); }
/// if (result is Failure) { print(result.message); }

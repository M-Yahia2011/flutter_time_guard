/// Utility class that simplifies handling errors.
///
/// Return a [Result] from a function to indicate success or failure.
///
/// A [Result] is either an [Ok] with a value of type [T]
/// or an [Error] with an [Exception].
///
/// Use [Result.ok] to create a successful result with a value of type [T].
/// Use [Result.error] to create an error result with an [Exception].
sealed class Result<T> {
  const Result();

  /// Creates an instance of Result containing a value
  factory Result.ok(T value) => Ok(value);

  /// Create an instance of Result containing an error
  factory Result.error(Failure error) => Error(error);
}

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  /// Creates an instance of Result containing a value
  const Ok(this.value);

  /// Returned value in result
  final T value;
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  /// Creates an instance of Result containing an error
  const Error(this.error);

  /// Returned error in result
  final Failure error;
}

/// A class that represents a failure.
class Failure {
  /// [message] is the message of the failure.
  final String message;

  /// [cause] is the cause of the failure.
  final Exception? cause;

  /// Creates a new instance of [Failure].
  const Failure(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

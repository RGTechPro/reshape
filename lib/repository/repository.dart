enum ApiStatus { init, loading, success, failed }

abstract class Repository {}

abstract class RepositoryRequest {
  const RepositoryRequest();
  Map<String, dynamic> toPayload({Map<String, dynamic>? parameters});
}

abstract class RepositorySuccess {
  String? message;

  RepositorySuccess({
    this.message,
  }) {
    message ??= 'Success';
  }
}

abstract class RepositoryFailure {
  String? message;
  final int? statusCode;

  RepositoryFailure({
    this.statusCode,
    this.message,
  }) {
    message ??= 'Oops! Something went wrong.';
  }
}

///------Responses Abstracts------

Result<S, F> success<S, F>(S s) => Success<S, F>(s);
Result<S, F> failure<S, F>(F f) => Failure<S, F>(f);

// Any repository or API call can return this type.
abstract class Result<S, F> {
  const Result();

  bool isSuccess() {
    return resolve<bool>((_) => true, (_) => false);
  }

  bool isFailure() {
    return resolve<bool>((_) => false, (_) => true);
  }

  // Benefit here is that `Success` comes before `Failure`. Optimistic!
  B resolve<B>(B Function(S s) onSuccess, B Function(F f) onFailure);
}

class Failure<S, F> extends Result<S, F> {
  final F _f;

  const Failure(this._f);

  F get value => _f;

  @override
  B resolve<B>(B Function(S s) onSuccess, B Function(F f) onFailure) => onFailure(_f);

  @override
  bool operator ==(other) => other is Failure && other._f == _f;

  @override
  int get hashCode => _f.hashCode;
}

class Success<S, F> extends Result<S, F> {
  final S _s;

  const Success(this._s);

  S get value => _s;

  @override
  B resolve<B>(B Function(S s) onSuccess, B Function(F f) onFailure) => onSuccess(_s);

  @override
  bool operator ==(other) => other is Success && other._s == _s;

  @override
  int get hashCode => _s.hashCode;
}
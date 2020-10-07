package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import extype.Nullable;

abstract NullablePromise<T>(Promise<Nullable<T>>) from Promise<Nullable<T>> to Promise<Nullable<T>> {
  public static inline function thenToMaybe<T>(promise:NullablePromise<T>):Promise<Maybe<T>> {
      return promise.then(x -> x.toMaybe());
  }

  public static inline function thenIsEmpty<T>(promise:NullablePromise<T>):Promise<Bool> {
      return promise.then(x -> x.isEmpty());
  }

  public static inline function thenNonEmpty<T>(promise:NullablePromise<T>):Promise<Bool> {
      return promise.then(x -> x.nonEmpty());
  }

  public static inline function thenGet<T>(promise:NullablePromise<T>):Promise<Null<T>> {
      return promise.then(x -> x.get());
  }

  public static inline function thenGetUnsafe<T>(promise:NullablePromise<T>):Promise<T> {
      return promise.then(x -> x.getUnsafe());
  }

  public static inline function thenGetOrThrow<T>(promise:NullablePromise<T>, ?errorFn:() -> Dynamic):Promise<T> {
      return promise.then(x -> x.getOrThrow(errorFn));
  }

  public static inline function thenGetOrElse<T>(promise:NullablePromise<T>, value:T):Promise<T> {
      return promise.then(x -> x.getOrElse(value));
  }

  public static inline function thenOrElse<T>(promise:NullablePromise<T>, value:Nullable<T>):NullablePromise<T> {
      return promise.then(x -> x.orElse(value));
  }

  public static inline function thenMap<T, U>(promise:NullablePromise<T>, fn:PromiseHandler<T, U>):Promise<Nullable<U>> {
      return promise.then(x -> x.map(cast fn));
  }

  public static inline function thenFlatMap<T, U>(promise:NullablePromise<T>, fn:PromiseHandler<T, Nullable<U>>):Promise<Nullable<U>> {
      return promise.then(x -> x.flatMap(cast fn));
  }

  public static inline function thenHas<T>(promise:NullablePromise<T>, value:T):Promise<Bool> {
      return promise.then(x -> x.has(value));
  }

  public static inline function thenExists<T>(promise:NullablePromise<T>, fn:T->Bool):Promise<Bool> {
      return promise.then(x -> x.exists(fn));
  }

  public static inline function thenFind<T>(promise:NullablePromise<T>, fn:T->Bool):Promise<Null<T>> {
      return promise.then(x -> x.find(fn));
  }

  public static inline function thenFilter<T>(promise:NullablePromise<T>, fn:PromiseHandler<T, Bool>):NullablePromise<T> {
      return promise.then((value -> {
          value.fold(() -> Promise.resolve(Nullable.empty()), x -> {
              final ret = fn.call(x);
              if (EqualsTools.strictEqual(ret, true)) {
                  Promise.resolve(Nullable.of(x));
              } else if (EqualsTools.strictEqual(ret, false)) {
                  Promise.resolve(Nullable.empty());
              } else {
                  final p:Promise<Bool> = cast ret;
                  p.then(y -> y ? Nullable.of(x) : Nullable.empty());
              }
          });
      } : PromiseHandler<Nullable<T>, Nullable<T>>));
  }

  public static inline function thenFold<T, U>(promise:NullablePromise<T>, ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
      return promise.then(x -> x.fold(ifEmpty, cast fn));
  }

  public static inline function thenIter<T>(promise:NullablePromise<T>, fn:(value:T) -> Void):Promise<Void> {
      return promise.then(x -> x.iter(fn));
  }

  public static inline function thenMatch<T>(promise:NullablePromise<T>, fn:PromiseHandler<T, Void>, ifEmpty:PromiseHandler0<T, Void>):Promise<Void> {
      return promise.then(x -> x.match(cast fn, ifEmpty));
  }

  public static function resolveOf<T>(x:T):NullablePromise<T> {
      return Promise.resolve(Nullable.of(x));
  }

  public static function resolveEmpty<T>():NullablePromise<T> {
      return Promise.resolve(Nullable.empty());
  }
}

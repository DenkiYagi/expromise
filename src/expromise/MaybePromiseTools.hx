package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import haxe.ds.Option;

class MaybePromiseTools {
    public static inline function thenToOption<T>(promise:Promise<Maybe<T>>):Promise<Option<T>> {
        return promise.then(x -> x.toOption());
    }
    public static inline function thenGet<T>(promise:Promise<Maybe<T>>):Promise<Null<T>> {
        return promise.then(x -> x.get());
    }

    public static inline function thenGetUnsafe<T>(promise:Promise<Maybe<T>>):Promise<T> {
        return promise.then(x -> x.getUnsafe());
    }

    public static inline function thenGetOrThrow<T>(promise:Promise<Maybe<T>>, ?errorFn:() -> Dynamic):Promise<T> {
        return promise.then(x -> x.getOrThrow(errorFn));
    }

    public static inline function thenGetOrElse<T>(promise:Promise<Maybe<T>>, value:T):Promise<T> {
        return promise.then(x -> x.getOrElse(value));
    }

    public static inline function thenOrElse<T>(promise:Promise<Maybe<T>>, value:Maybe<T>):Promise<Maybe<T>> {
        return promise.then(x -> x.orElse(value));
    }

    public static inline function thenIsEmpty<T>(promise:Promise<Maybe<T>>):Promise<Bool> {
        return promise.then(x -> x.isEmpty());
    }

    public static inline function thenNonEmpty<T>(promise:Promise<Maybe<T>>):Promise<Bool> {
        return promise.then(x -> x.nonEmpty());
    }

    public static inline function thenMap<T, U>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, U>):Promise<Maybe<U>> {
        return promise.then(x -> x.map(cast fn));
    }

    public static inline function thenFlatMap<T, U>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, Maybe<U>>):Promise<Maybe<U>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function thenFilter<T>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, Bool>):Promise<Maybe<T>> {
        return promise.then((value -> {
            value.fold(() -> Promise.resolve(Maybe.empty()), x -> {
                final ret = fn.call(x);
                if (EqualsTools.strictEqual(ret, true)) {
                    Promise.resolve(Maybe.of(x));
                } else if (EqualsTools.strictEqual(ret, false)) {
                    Promise.resolve(Maybe.empty());
                } else {
                    final p:Promise<Bool> = cast ret;
                    p.then(y -> y ? Maybe.of(x) : Maybe.empty());
                }
            });
        } : PromiseHandler<Maybe<T>, Maybe<T>>));
    }

    public static inline function thenFold<T, U>(promise:Promise<Maybe<T>>, ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
        return promise.then(x -> x.fold(ifEmpty, cast fn));
    }

    public static inline function thenIter<T>(promise:Promise<Maybe<T>>, fn:(value:T) -> Void):Promise<Void> {
        return promise.then(x -> x.iter(fn));
    }

    public static inline function thenMatch<T>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, Void>, ifEmpty:PromiseHandler0<T, Void>):Promise<Void> {
        return promise.then(x -> x.match(cast fn, ifEmpty));
    }

    public static function resolveOf<T>(x:T):Promise<Maybe<T>> {
        return Promise.resolve(Maybe.of(x));
    }

    public static function resolveEmpty<T>():Promise<Maybe<T>> {
        return Promise.resolve(Maybe.empty());
    }
}

package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import extype.Nullable;
import haxe.ds.Option;

class NullablePromiseTools {
    public static inline function thenToMaybe<T>(promise:Promise<Nullable<T>>):Promise<Maybe<T>> {
        return promise.then(x -> x.toMaybe());
    }

    public static inline function thenGet<T>(promise:Promise<Nullable<T>>):Promise<Null<T>> {
        return promise.then(x -> x.get());
    }

    public static inline function thenGetUnsafe<T>(promise:Promise<Nullable<T>>):Promise<T> {
        return promise.then(x -> x.getUnsafe());
    }

    public static inline function thenGetOrThrow<T>(promise:Promise<Nullable<T>>, ?errorFn:() -> Dynamic):Promise<T> {
        return promise.then(x -> x.getOrThrow(errorFn));
    }

    public static inline function thenGetOrElse<T>(promise:Promise<Nullable<T>>, value:T):Promise<T> {
        return promise.then(x -> x.getOrElse(value));
    }

    public static inline function thenOrElse<T>(promise:Promise<Nullable<T>>, value:Nullable<T>):Promise<Nullable<T>> {
        return promise.then(x -> x.orElse(value));
    }

    public static inline function thenIsEmpty<T>(promise:Promise<Nullable<T>>):Promise<Bool> {
        return promise.then(x -> x.isEmpty());
    }

    public static inline function thenNonEmpty<T>(promise:Promise<Nullable<T>>):Promise<Bool> {
        return promise.then(x -> x.nonEmpty());
    }

    public static inline function thenMap<T, U>(promise:Promise<Nullable<T>>, fn:PromiseHandler<T, U>):Promise<Nullable<U>> {
        return promise.then(x -> x.map(cast fn));
    }

    public static inline function thenFlatMap<T, U>(promise:Promise<Nullable<T>>, fn:PromiseHandler<T, Nullable<U>>):Promise<Nullable<U>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function thenFilter<T>(promise:Promise<Nullable<T>>, fn:PromiseHandler<T, Bool>):Promise<Nullable<T>> {
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

    public static inline function thenFold<T, U>(promise:Promise<Nullable<T>>, ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
        return promise.then(x -> x.fold(ifEmpty, cast fn));
    }

    public static inline function thenIter<T>(promise:Promise<Nullable<T>>, fn:(value:T) -> Void):Promise<Void> {
        return promise.then(x -> x.iter(fn));
    }

    public static inline function thenMatch<T>(promise:Promise<Nullable<T>>, fn:PromiseHandler<T, Void>, ifEmpty:PromiseHandler0<T, Void>):Promise<Void> {
        return promise.then(x -> x.match(cast fn, ifEmpty));
    }

    public static function resolveOf<T>(x:T):Promise<Nullable<T>> {
        return Promise.resolve(Nullable.of(x));
    }

    public static function resolveEmpty<T>():Promise<Nullable<T>> {
        return Promise.resolve(Nullable.empty());
    }
}

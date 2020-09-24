package exasync;

import exasync.PromiseCallback;
import extools.EqualsTools;
import extype.Maybe;

class MaybePromiseTools {
    public static inline function mapThen<T, U>(promise:Promise<Maybe<T>>, fn:PromiseCallback<T, U>):Promise<Maybe<U>> {
        return promise.then(x -> x.map(fn));
    }

    public static inline function flatMapThen<T, U>(promise:Promise<Maybe<T>>, fn:PromiseCallback<T, Maybe<U>>):Promise<Maybe<U>> {
        return promise.then(x -> x.flatMap(fn));
    }

    public static inline function filterThen<T>(promise:Promise<Maybe<T>>, fn:PromiseCallback<T, Bool>):Promise<Maybe<T>> {
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
        } : PromiseCallback<Maybe<T>, Maybe<T>>));
    }

    public static inline function foldThen<T, U>(promise:Promise<Maybe<T>>, ifEmpty:PromiseCallback0<U>, fn:PromiseCallback<T, U>):Promise<U> {
        return promise.then(x -> x.fold(ifEmpty, fn));
    }
}

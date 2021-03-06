package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import extype.Nullable;

class MaybePromiseTools {
    public static inline function thenToNullable<T>(promise:Promise<Maybe<T>>):Promise<Nullable<T>> {
        return promise.then(x -> x.toNullable());
    }

    public static inline function thenIsEmpty<T>(promise:Promise<Maybe<T>>):Promise<Bool> {
        return promise.then(x -> x.isEmpty());
    }

    public static inline function thenNonEmpty<T>(promise:Promise<Maybe<T>>):Promise<Bool> {
        return promise.then(x -> x.nonEmpty());
    }

    public static inline function thenGet<T>(promise:Promise<Maybe<T>>):Promise<Null<T>> {
        return promise.then(x -> x.get());
    }

    #if !target.static
    public static inline function thenGetUnsafe<T>(promise:Promise<Maybe<T>>):Promise<T> {
        return promise.then(x -> x.getUnsafe());
    }
    #end

    public static inline function thenGetOrThrow<T>(promise:Promise<Maybe<T>>, ?errorFn:() -> Dynamic):Promise<T> {
        return promise.then(x -> x.getOrThrow(errorFn));
    }

    public static inline function thenGetOrElse<T>(promise:Promise<Maybe<T>>, value:T):Promise<T> {
        return promise.then(x -> x.getOrElse(value));
    }

    public static inline function thenOrElse<T>(promise:Promise<Maybe<T>>, value:Maybe<T>):Promise<Maybe<T>> {
        return promise.then(x -> x.orElse(value));
    }

    public static inline function thenMap<T, U>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, U>):Promise<Maybe<U>> {
        return promise.then((x -> switch (x) {
            case Some(t):
                final ret = fn.call(t);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<U> = cast ret;
                    p.then(u -> Some(u));
                } else {
                    Promise.resolve(Some(ret));
                }
            case None:
                Promise.resolve(None);
            } : PromiseHandler<Maybe<T>, Maybe<U>>));
    }

    public static inline function thenFlatMap<T, U>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, Maybe<U>>):Promise<Maybe<U>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function thenFlatten<T>(promise:Promise<Maybe<Maybe<T>>>):Promise<Maybe<T>> {
        return promise.then(x -> x.flatten());
    }

    public static inline function thenHas<T>(promise:Promise<Maybe<T>>, value:T):Promise<Bool> {
        return promise.then(x -> x.has(value));
    }

    public static inline function thenExists<T>(promise:Promise<Maybe<T>>, fn:T->Bool):Promise<Bool> {
        return promise.then(x -> x.exists(fn));
    }

    public static inline function thenFind<T>(promise:Promise<Maybe<T>>, fn:T->Bool):Promise<Null<T>> {
        return promise.then(x -> x.find(fn));
    }

    public static inline function thenFilter<T>(promise:Promise<Maybe<T>>, fn:PromiseHandler<T, Bool>):Promise<Maybe<T>> {
        return promise.then((value -> {
            value.fold(() -> Promise.resolve(None), x -> {
                final ret = fn.call(x);
                if (EqualsTools.strictEqual(ret, true)) {
                    Promise.resolve(Some(x));
                } else if (EqualsTools.strictEqual(ret, false)) {
                    Promise.resolve(None);
                } else {
                    final p:Promise<Bool> = cast ret;
                    p.then(y -> y ? Some(x) : None);
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

    public static inline function thenMatch<T>(promise:Promise<Maybe<T>>, fn:(value:T)->Void, ifEmty:()->Void):Promise<Void> {
        return promise.then(x -> x.match(fn, ifEmty));
    }

    public static function resolveSome<T>(x:T):Promise<Maybe<T>> {
        return Promise.resolve(Some(x));
    }

    public static function resolveNone<T>():Promise<Maybe<T>> {
        return Promise.resolve(None);
    }
}

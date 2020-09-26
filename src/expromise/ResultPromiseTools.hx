package expromise;

import expromise.PromiseHandler;
import extype.Result;

class ResultPromiseTools {
    public static inline function thenIsSuccess<T, E>(promise:Promise<Result<T, E>>):Promise<Bool> {
        return promise.then(x -> x.isSuccess());
    }

    public static inline function thenIsFailure<T, E>(promise:Promise<Result<T, E>>):Promise<Bool> {
        return promise.then(x -> x.isFailure());
    }

    public static inline function thenGet<T, E>(promise:Promise<Result<T, E>>):Promise<Null<T>> {
        return promise.then(x -> x.get());
    }

    public static inline function thenGetUnsafe<T, E>(promise:Promise<Result<T, E>>):Promise<T> {
        return promise.then(x -> x.getUnsafe());
    }

    public static inline function thenGetOrThrow<T, E>(promise:Promise<Result<T, E>>, ?errorFn:() -> Dynamic):Promise<T> {
        return promise.then(x -> x.getOrThrow(errorFn));
    }

    public static inline function thenGetOrElse<T, E>(promise:Promise<Result<T, E>>, value:T):Promise<T> {
        return promise.then(x -> x.getOrElse(value));
    }

    public static inline function thenOrElse<T, E>(promise:Promise<Result<T, E>>, value:Result<T, E>):Promise<Result<T, E>> {
        return promise.then(x -> x.orElse(value));
    }

    public static inline function thenMap<T, E, U>(promise:Promise<Result<T, E>>, fn:PromiseHandler<T, U>):Promise<Result<U, E>> {
        return promise.then((x -> switch (x) {
            case Success(v):
                final ret = fn.call(v);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<U> = cast ret;
                    p.then(u -> Success(u));
                } else {
                    Promise.resolve(Success(ret));
                }
            case Failure(e):
                Promise.resolve(Failure(e));
        } : PromiseHandler<Result<T, E>, Result<U, E>>));
    }

    public static inline function thenFlatMap<T, E, U>(promise:Promise<Result<T, E>>, fn:PromiseHandler<T, Result<U, E>>):Promise<Result<U, E>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function thenMapFailure<T, E, EE>(promise:Promise<Result<T, E>>, fn:PromiseHandler<E, EE>):Promise<Result<T, EE>> {
        return promise.then((x -> switch (x) {
            case Failure(e):
                final ret = fn.call(e);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<EE> = cast ret;
                    p.then(ee -> Failure(ee));
                } else {
                    final e:EE = cast ret;
                    Promise.resolve(Failure(e));
                }
            case Success(v):
                Promise.resolve(Success(v));
        } : PromiseHandler<Result<T, E>, Result<T, EE>>));
    }

    public static inline function thenFlatMapFailure<T, E, EE>(promise:Promise<Result<T, E>>, fn:PromiseHandler<E, Result<T, EE>>):Promise<Result<T, EE>> {
        return promise.then(x -> x.flatMapFailure(cast fn));
    }

    public static inline function thenFlatten<T, E>(promise:Promise<Result<Result<T, E>, E>>):Promise<Result<T, E>> {
        return promise.then(x -> x.flatten());
    }

    public static inline function thenExists<T, E>(promise:Promise<Result<T, E>>, value:T):Promise<Bool> {
        return promise.then(x -> x.exists(value));
    }

    public static inline function thenNotExists<T, E>(promise:Promise<Result<T, E>>, value:T):Promise<Bool> {
        return promise.then(x -> x.notExists(value));
    }

    public static inline function thenFind<T, E>(promise:Promise<Result<T, E>>, fn:T->Bool):Promise<Bool> {
        return promise.then(x -> x.find(fn));
    }

    public static inline function thenFilterOrElse<T, E>(promise:Promise<Result<T, E>>, fn:T->Bool, error:E):Promise<Result<T, E>> {
        return promise.then(x -> x.filterOrElse(fn, error));
    }

    public static inline function thenFold<T, E, U>(promise:Promise<Result<T, E>>, fn:PromiseHandler<T, U>, ifFailure:PromiseHandler<E, U>):Promise<U> {
        return promise.then(x -> x.fold(cast fn, cast ifFailure));
    }

    public static inline function thenIter<T, E>(promise:Promise<Result<T, E>>, fn:(value:T) -> Void):Promise<Void> {
        return promise.then(x -> x.iter(fn));
    }

    public static inline function thenMatch<T, E>(promise:Promise<Result<T, E>>, fn:(value:T)->Void, ifFailure:(e:E)->Void):Promise<Void> {
        return promise.then(x -> x.match(fn, ifFailure));
    }

    public static inline function resolveSuccess<T, E>(x:T):Promise<Result<T, E>> {
        return Promise.resolve(Success(x));
    }

    public static inline function resolveFailure<T, E>(e:E):Promise<Result<T, E>> {
        return Promise.resolve(Failure(e));
    }
}

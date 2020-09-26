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

    public static inline function resolveSuccess<T, E>(x:T):Promise<Result<T, E>> {
        return Promise.resolve(Success(x));
    }

    public static inline function resolveFailure<T, E>(e:E):Promise<Result<T, E>> {
        return Promise.resolve(Failure(e));
    }
}

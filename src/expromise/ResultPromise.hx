package expromise;

import expromise.PromiseHandler;
import extype.Result;

abstract ResultPromise<T, E>(Promise<Result<T, E>>) from Promise<Result<T, E>> to Promise<Result<T, E>> {
    public inline extern function new(executor:(Result<T, E>->Void)->(Dynamic->Void)->Void) {
        this = new Promise(executor);
    }

    public inline function then<T, U>(fulfilled:Null<PromiseHandler<Result<T, E>, U>>, ?rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        return cast this.then(fulfilled, rejected);
    }

    public inline extern function catchError<U>(rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        return cast this.catchError(rejected);
    }

    public inline extern function finally(onFinally:Void->Void):Promise<T> {
        return cast this.finally(onFinally);
    }

    public inline function thenIsSuccess<T, E>():Promise<Bool> {
        return this.then(x -> x.isSuccess());
    }

    public inline function thenIsFailure<T, E>():Promise<Bool> {
        return this.then(x -> x.isFailure());
    }

    public inline function thenGet<T, E>():Promise<Null<T>> {
        return this.then(x -> x.get());
    }

    #if !target.static
    public inline function thenGetUnsafe<T, E>():Promise<T> {
        return this.then(x -> x.getUnsafe());
    }
    #end

    public inline function thenGetOrThrow<T, E>(?errorFn:() -> Dynamic):Promise<T> {
        return this.then(x -> x.getOrThrow(errorFn));
    }

    public inline function thenGetOrElse<T, E>(value:T):Promise<T> {
        return this.then(x -> x.getOrElse(value));
    }

    public inline function thenOrElse<T, E>(value:Result<T, E>):ResultPromise<T, E> {
        return this.then(x -> x.orElse(value));
    }

    public inline function thenMap<T, E, U>(fn:PromiseHandler<T, U>):Promise<Result<U, E>> {
        return this.then((x -> switch (x) {
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

    public inline function thenFlatMap<T, E, U>(fn:PromiseHandler<T, Result<U, E>>):Promise<Result<U, E>> {
        return this.then(x -> x.flatMap(cast fn));
    }

    public inline function thenMapFailure<T, E, EE>(fn:PromiseHandler<E, EE>):Promise<Result<T, EE>> {
        return this.then((x -> switch (x) {
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

    public inline function thenFlatMapFailure<T, E, EE>(fn:PromiseHandler<E, Result<T, EE>>):Promise<Result<T, EE>> {
        return this.then(x -> x.flatMapFailure(cast fn));
    }

    public inline function thenHas<T, E>(value:T):Promise<Bool> {
        return this.then(x -> x.has(value));
    }

    public inline function thenExists<T, E>(fn:T->Bool):Promise<Bool> {
        return this.then(x -> x.exists(fn));
    }

    public inline function thenFind<T, E>(fn:T->Bool):Promise<Null<T>> {
        return this.then(x -> x.find(fn));
    }

    public inline function thenFilterOrElse<T, E>(fn:T->Bool, error:E):ResultPromise<T, E> {
        return this.then(x -> x.filterOrElse(fn, error));
    }

    public inline function thenFold<T, E, U>(fn:PromiseHandler<T, U>, ifFailure:PromiseHandler<E, U>):Promise<U> {
        return this.then(x -> x.fold(cast fn, cast ifFailure));
    }

    public inline function thenIter<T, E>(fn:(value:T) -> Void):Promise<Void> {
        return this.then(x -> x.iter(fn));
    }

    public inline function thenMatch<T, E>(fn:(value:T)->Void, ifFailure:(e:E)->Void):Promise<Void> {
        return this.then(x -> x.match(fn, ifFailure));
    }

    public static inline function resolveSuccess<T, E>(x:T):ResultPromise<T, E> {
        return Promise.resolve(Success(x));
    }

    public static inline function resolveFailure<T, E>(e:E):ResultPromise<T, E> {
        return Promise.resolve(Failure(e));
    }
}

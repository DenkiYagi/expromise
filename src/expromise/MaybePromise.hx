package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import extype.Nullable;

abstract MaybePromise<T>(Promise<Maybe<T>>) from Promise<Maybe<T>> to Promise<Maybe<T>> {
    public inline extern function new(executor:(Maybe<T>->Void)->(Dynamic->Void)->Void) {
        this = new Promise(executor);
    }

    public inline function then<T, U>(fulfilled:Null<PromiseHandler<Maybe<T>, U>>, ?rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        return cast this.then(fulfilled, rejected);
    }

    public inline extern function catchError<U>(rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        return cast this.catchError(rejected);
    }

    public inline extern function finally(onFinally:Void->Void):MaybePromise<T> {
        return cast this.finally(onFinally);
    }

    public inline function thenToNullable<T>():Promise<Nullable<T>> {
        return this.then(x -> x.toNullable());
    }

    public inline function thenIsEmpty<T>():Promise<Bool> {
        return this.then(x -> x.isEmpty());
    }

    public inline function thenNonEmpty<T>():Promise<Bool> {
        return this.then(x -> x.nonEmpty());
    }

    public inline function thenGet<T>():Promise<Null<T>> {
        return this.then(x -> x.get());
    }

    #if !target.static
    public inline function thenGetUnsafe<T>():Promise<T> {
        return this.then(x -> x.getUnsafe());
    }
    #end

    public inline function thenGetOrThrow<T>(?errorFn:() -> Dynamic):Promise<T> {
        return this.then(x -> x.getOrThrow(errorFn));
    }

    public inline function thenGetOrElse<T>(value:T):Promise<T> {
        return this.then(x -> x.getOrElse(value));
    }

    public inline function thenOrElse<T>(value:Maybe<T>):MaybePromise<T> {
        return this.then(x -> x.orElse(value));
    }

    public inline function thenMap<T, U>(fn:PromiseHandler<T, U>):MaybePromise<U> {
        return this.then((x -> switch (x) {
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

    public inline function thenFlatMap<T, U>(fn:PromiseHandler<T, Maybe<U>>):MaybePromise<U> {
        return this.then(x -> x.flatMap(cast fn));
    }

    public inline function thenHas<T>(value:T):Promise<Bool> {
        return this.then(x -> x.has(value));
    }

    public inline function thenExists<T>(fn:T->Bool):Promise<Bool> {
        return this.then(x -> x.exists(fn));
    }

    public inline function thenFind<T>(fn:T->Bool):Promise<Null<T>> {
        return this.then(x -> x.find(fn));
    }

    public inline function thenFilter<T>(fn:PromiseHandler<T, Bool>):MaybePromise<T> {
        return this.then((value -> {
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

    public inline function thenFold<T, U>(ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
        return this.then(x -> x.fold(ifEmpty, cast fn));
    }

    public inline function thenIter<T>(fn:(value:T) -> Void):Promise<Void> {
        return this.then(x -> x.iter(fn));
    }

    public inline function thenMatch<T>(fn:(value:T)->Void, ifEmty:()->Void):Promise<Void> {
        return this.then(x -> x.match(fn, ifEmty));
    }

    public static function resolveSome<T>(x:T):MaybePromise<T> {
        return Promise.resolve(Some(x));
    }

    public static function resolveNone<T>():MaybePromise<T> {
        return Promise.resolve(None);
    }
}

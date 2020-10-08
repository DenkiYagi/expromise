package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import extype.Maybe;
import extype.Nullable;

abstract NullablePromise<T>(Promise<Nullable<T>>) from Promise<Nullable<T>> to Promise<Nullable<T>> {
    public inline extern function new(executor:(Nullable<T>->Void)->(Dynamic->Void)->Void) {
        this = new Promise(executor);
    }

    public inline function then<T, U>(fulfilled:Null<PromiseHandler<Nullable<T>, U>>, ?rejected:PromiseHandler<Dynamic, U>):Promise<Nullable<T>> {
        return cast this.then(fulfilled, rejected);
    }

    public inline function thenToMaybe<T>():Promise<Maybe<T>> {
        return this.then(x -> x.toMaybe());
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

    public inline function thenGetUnsafe<T>():Promise<T> {
        return this.then(x -> x.getUnsafe());
    }

    public inline function thenGetOrThrow<T>(?errorFn:() -> Dynamic):Promise<T> {
        return this.then(x -> x.getOrThrow(errorFn));
    }

    public inline function thenGetOrElse<T>(value:T):Promise<T> {
        return this.then(x -> x.getOrElse(value));
    }

    public inline function thenOrElse<T>(value:Nullable<T>):NullablePromise<T> {
        return this.then(x -> x.orElse(value));
    }

    public inline function thenMap<T, U>(fn:PromiseHandler<T, U>):NullablePromise<U> {
        return this.then(x -> x.map(cast fn));
    }

    public inline function thenFlatMap<T, U>(fn:PromiseHandler<T, Nullable<U>>):NullablePromise<U> {
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

    public inline function thenFilter<T>(fn:PromiseHandler<T, Bool>):NullablePromise<T> {
        return this.then((value -> {
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

    public inline function thenFold<T, U>(ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
        return this.then(x -> x.fold(ifEmpty, cast fn));
    }

    public inline function thenIter<T>(fn:(value:T) -> Void):Promise<Void> {
        return this.then(x -> x.iter(fn));
    }

    public inline function thenMatch<T>(fn:PromiseHandler<T, Void>, ifEmpty:PromiseHandler0<T, Void>):Promise<Void> {
        return this.then(x -> x.match(cast fn, ifEmpty));
    }

    public static function resolveOf<T>(x:T):NullablePromise<T> {
        return Promise.resolve(Nullable.of(x));
    }

    public static function resolveEmpty<T>():NullablePromise<T> {
        return Promise.resolve(Nullable.empty());
    }
}

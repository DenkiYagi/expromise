package exasync;

#if !js
import exasync._internal.DelayedPromise;
#end

abstract Promise<T>(IPromise<T>) from IPromise<T> {
    public inline extern function new(executor:(?T->Void)->(?Dynamic->Void)->Void) {
        #if js
        this = cast new js.lib.Promise(cast executor);
        #else
        this = new DelayedPromise(executor);
        #end
    }

    public inline extern function then<U>(fulfilled:Null<PromiseCallback<T, U>>, ?rejected:PromiseCallback<Dynamic, U>):Promise<U> {
        return this.then(fulfilled, rejected);
    }

    public inline extern function catchError<U>(rejected:PromiseCallback<Dynamic, U>):Promise<U> {
        #if js
        return js.Syntax.code("{0}.catch({1})", this, rejected);
        #else
        return this.catchError(rejected);
        #end
    }

    public inline extern function finally(onFinally:Void->Void):Promise<T> {
        #if js
        return js.Syntax.code("{0}.finally({1})", this, onFinally);
        #else
        return this.finally(onFinally);
        #end
    }

    public inline extern function tap(fulfilled:T->Void):Promise<T> {
        return this.then(x -> {
            try {
                fulfilled(x);
            } catch (ex) {
                #if debug
                trace(ex);
                #end
            }
            x;
        });
    }

    public inline extern function tapError(rejected:Dynamic->Void):Promise<T> {
        #if js
        return js.Syntax.code("{0}.catch({1})", this, e -> {
        #else
        return this.catchError(e -> {
        #end
            try {
                rejected(e);
            } catch (ex) {
                #if debug
                trace(ex);
                #end
            }
            cast Promise.reject(e);
        });
    }

    public static inline function resolve<T>(?value:T):Promise<T> {
        #if js
        return js.Syntax.code("Promise.resolve({0})", value);
        #else
        return DelayedPromise.resolve(value);
        #end
    }

    public static inline function reject<T>(?error:Dynamic):Promise<T> {
        #if js
        return js.Syntax.code("Promise.reject({0})", error);
        #else
        return DelayedPromise.reject(error);
        #end
    }

    #if js
    public static inline function all<T>(iterable:Array<Promise<T>>):Promise<Array<T>> {
        return js.Syntax.code("Promise.all({0})", iterable);
    }
    #else
    public static function all<T>(iterable:Array<Promise<T>>):Promise<Array<T>> {
        var length = iterable.length;
        return if (length <= 0) {
            DelayedPromise.resolve([]);
        } else {
            new DelayedPromise((fulfill, reject) -> {
                final values = [for (i in 0...length) null];
                var count = 0;
                for (i in 0...length) {
                    iterable[i].then(v -> {
                        values[i] = v;
                        if (++count >= length) fulfill(values);
                    }, reject);
                }
            });
        }
    }
    #end

    #if js
    public static inline function race<T>(iterable:Array<Promise<T>>):Promise<T> {
        return js.Syntax.code("Promise.race({0})", iterable);
    }
    #else
    public static function race<T>(iterable:Array<Promise<T>>):Promise<T> {
        return if (iterable.length <= 0) {
            new DelayedPromise((fulfill, reject) -> {});
        } else {
            new DelayedPromise((fulfill, reject) -> {
                for (p in iterable) {
                    p.then(fulfill, reject);
                }
            });
        }
    }
    #end

    #if js
    @:from
    public static inline extern function fromJsPromise<T>(promise:js.lib.Promise<T>):Promise<T> {
        return cast promise;
    }

    @:to
    public inline extern function toJsPromise():js.lib.Promise<T> {
        return cast this;
    }
    #end
}

package expromise;

import haxe.Timer;
#if js
import js.lib.Promise in JsPromise;
#else
import expromise._internal.DelayedPromise;
#end

#if js
abstract Promise<T>(JsPromise<T>)
#else
abstract Promise<T>(IPromise<T>) from IPromise<T> to IPromise<T>
#end
{
    #if js
    @:from public static inline extern function fromJsPromise<T>(promise:js.lib.Promise<T>):Promise<T> {
        return cast promise;
    }

    @:to public inline extern function toJsPromise():js.lib.Promise<T> {
        return this;
    }
    #end

    public inline extern function new(executor:(T->Void)->(Dynamic->Void)->Void) {
        #if js
        this = cast new JsPromise(cast executor);
        #else
        this = new DelayedPromise(executor);
        #end
    }

    public inline extern function then<U>(fulfilled:Null<PromiseHandler<T, U>>, ?rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        #if (haxe >= version("4.2.0"))
        return this.then(fulfilled, rejected);
        #else
        return cast this.then(fulfilled, rejected);
        #end
    }

    public inline extern function catchError<U>(rejected:PromiseHandler<Dynamic, U>):Promise<U> {
        #if (haxe >= version("4.2.0"))
        return this.catchError(rejected);
        #else
        return cast this.then(fulfilled, rejected);
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
        return (this : Promise<T>).catchError(e -> {
        #end
            try {
                rejected(e);
            } catch (ex) {
                #if debug
                trace(ex);
                #end
            }
            Promise.reject(e);
        });
    }

    public inline extern function delay(milliseconds:Int):Promise<T> {
        return (this : Promise<T>).then(x -> new Promise((f, _) -> {
            Timer.delay(() -> f(x), milliseconds);
        }));
    }

    // incompatible with JsPromise.resolve()
    #if js
    public static inline function resolve<T>(?value:T):Promise<T> {
        return js.Syntax.code("Promise.resolve({0})", value);
    }
    #else
    public static function resolve<T>(?value:T):Promise<T> {
        return (DelayedPromise.resolve(value) : Promise<T>);
    }
    #end

    #if js
    public static inline function reject<T>(?error:Dynamic):Promise<T> {
        return js.Syntax.code("Promise.reject({0})", error);
    }
    #else
    public static function reject<T>(?error:Dynamic):Promise<T> {
        return (DelayedPromise.reject(error) : Promise<T>);
    }
    #end

    #if js
    public static inline function all<T>(iterable:Array<Promise<T>>):Promise<Array<T>> {
        return js.Syntax.code("Promise.all({0})", iterable);
    }
    #else
    public static function all<T>(iterable:Array<Promise<T>>):Promise<Array<T>> {
        final length = iterable.length;
        return if (length <= 0) {
            Promise.resolve([]);
        } else {
            (new DelayedPromise((fulfill, reject) -> {
                final values = [for (i in 0...length) null];
                var count = 0;
                for (i in 0...length) {
                    iterable[i].then(v -> {
                        values[i] = v;
                        if (++count >= length) fulfill(values);
                    }, reject);
                }
            }) : Promise<Array<T>>);
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
    public static inline extern function fromCancelablePromise<T>(promise:CancelablePromise<T>):Promise<T> {
        return cast promise;
    }
    #end
}

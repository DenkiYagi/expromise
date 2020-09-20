package exasync;

import extype.extern.Mixed;
import exasync._internal.IPromise;
#if !js
import exasync._internal.DelayedPromise;
#end
using extools.EqualsTools;

abstract Promise<T>(IPromise<T>) from IPromise<T> {
    public inline function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void) {
        #if js
        // workaround for js__$Boot_HaxeError
        this = js.Syntax.code("new Promise({0})", function (fulfill, reject) {
            try {
                executor(fulfill, reject);
            } catch (e: Dynamic) {
                reject(e);
            }
        });
        #else
        this = new DelayedPromise(executor);
        #end
    }

    #if js
    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return if (Std.is(this, js.lib.Promise)) {
            this.then(
                (fulfilled != null) ? onFulfilled.bind(fulfilled) : null,
                (rejected != null) ? onRejected.bind(cast rejected) : null
            );
        } else {
            this.then(fulfilled, rejected);
        }
    }
    #else
    public inline function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.then(fulfilled, rejected);
    }
    #end

    #if js
    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return if (rejected != null && Std.is(this, js.lib.Promise)) {
            this.then(null, onRejected.bind(cast rejected));
        } else {
            this.catchError(rejected);
        }
    }
    #else
    public inline function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.catchError(rejected);
    }
    #end

    #if js
    static function onFulfilled<T, TOut>(fulfilled: T -> Dynamic, value: T): Promise<TOut> {
        try {
            return fulfilled(value);
        } catch (e: Dynamic) {
            return cast SyncPromise.reject(e);
        }
    }

    static function onRejected<TOut>(rejected: Dynamic -> Dynamic, error: Dynamic): Promise<TOut> {
        try {
            return rejected(error);
        } catch (e: Dynamic) {
            return SyncPromise.reject(e);
        }
    }
    #end

    public inline function finally(onFinally: Void -> Void): Promise<T> {
        #if js
        return then(
            function (x) { onFinally(); return x; },
            function (e) { onFinally(); return reject(e); }
        );
        #else
        return this.finally(onFinally);
        #end
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        #if js
        return js.Syntax.code("Promise.resolve({0})", value);
        #else
        return DelayedPromise.resolve(value);
        #end
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        #if js
        return js.Syntax.code("Promise.reject({0})", error);
        #else
        return DelayedPromise.reject(error);
        #end
    }

    #if js
    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        return js.Syntax.code("Promise.all({0})", iterable);
    }
    #else
    public static function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        var length = iterable.length;
        return if (length <= 0) {
            DelayedPromise.resolve([]);
        } else {
            new DelayedPromise(function (fulfill, reject) {
                var values = [for (i in 0...length) null];
                var count = 0;
                for (i in 0...length) {
                    var p = iterable[i];
                    p.then(function (v) {
                        values[i] = v;
                        if (++count >= length) fulfill(values);
                    }, reject);
                }
            });
        }
    }
    #end

    #if js
    public static inline function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return js.Syntax.code("Promise.race({0})", iterable);
    }
    #else
    public static function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return if (iterable.length <= 0) {
            new DelayedPromise(function (_, _) {});
        } else {
            new DelayedPromise(function (fulfill, reject) {
                for (p in iterable) {
                    p.then(fulfill, reject);
                }
            });
        }
    }
    #end

    #if js
    @:from @:extern
    public static inline function fromJsPromise<T>(promise: js.lib.Promise<T>): Promise<T> {
        return cast promise;
    }

    @:to @:extern
    public inline function toJsPromise(): js.lib.Promise<T> {
        return cast this;
    }
    #end
}

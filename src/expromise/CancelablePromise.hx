package expromise;

import expromise.Promise;
import expromise._internal.Delegate;
import expromise._internal.Dispatcher;
import extype.Maybe;
import extype.Result;

using extools.EqualsTools;

class CancelablePromise<T> #if !js implements IPromise<T> #end {
    var result:Maybe<Result<T>>;
    var onFulfilledHanlders:Delegate<T>;
    var onRejectedHanlders:Delegate<Dynamic>;
    var cancelCallback:Maybe<Void->Void>;

    #if js
    static function __init__() {
        // Make this class compatible with js.lib.Promise
        final prototype = js.lib.Object.create(untyped js.lib.Promise.prototype);
        final orignal = untyped CancelablePromise.prototype;
        for (k in js.lib.Object.getOwnPropertyNames(orignal)) {
            Reflect.setField(prototype, k, Reflect.field(orignal, k));
        }
        prototype.constructor = CancelablePromise;
        Reflect.setField(prototype, "catch", prototype.catchError);
        untyped CancelablePromise.prototype = prototype;
    }
    #end

    public function new(executor:(T->Void)->(Dynamic->Void)->(Void->Void)) {
        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();
        cancelCallback = Maybe.empty();

        if (result.isEmpty()) {
            try {
                cancelCallback = Maybe.of(executor(onFulfilled, onRejected));
            } catch (e) {
                onRejected(e);
            }
        }
    }

    function onFulfilled(?value:T):Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Success(value));
            onFulfilledHanlders.invokeAsync(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error:Dynamic):Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Failure(error));
            onRejectedHanlders.invokeAsync(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers():Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(fulfilled:Null<PromiseHandler<T, TOut>>, ?rejected:PromiseHandler<Dynamic, TOut>):CancelablePromise<TOut> {
        return new CancelablePromise<TOut>(function(_fulfill, _reject) {
            final handleFulfilled = if (fulfilled != null) {
                function chain(value:T) {
                    try {
                        final next = fulfilled.call(value);
                        if (Std.isOfType(next, #if js js.lib.Promise #else IPromise #end)) {
                            final p:Promise<TOut> = cast next;
                            p.then(_fulfill, _reject);
                        } else {
                            _fulfill(next);
                        }
                    } catch (e) {
                        _reject(e);
                    }
                }
            } else {
                function passValue(value:T) {
                    _fulfill(cast value);
                }
            }

            final handleRejected = if (rejected != null) {
                function rescue(error:Dynamic) {
                    try {
                        final next = rejected.call(error);
                        if (Std.isOfType(next, #if js js.lib.Promise #else IPromise #end)) {
                            final p:Promise<TOut> = cast next;
                            p.then(_fulfill, _reject);
                        } else {
                            _fulfill(next);
                        }
                    } catch (e) {
                        _reject(e);
                    }
                }
            } else {
                function passError(error:Dynamic) {
                    try {
                        _reject(error);
                    } catch (e) {
                        trace(e);
                    }
                }
            }

            if (result.isEmpty()) {
                onFulfilledHanlders.add(handleFulfilled);
                onRejectedHanlders.add(handleRejected);
            } else {
                switch (result.get()) {
                    case Success(v):
                        Dispatcher.dispatch(handleFulfilled.bind(v));
                    case Failure(e):
                        Dispatcher.dispatch(handleRejected.bind(e));
                }
            }
            return cancel;
        });
    }

    public function catchError<TOut>(rejected:PromiseHandler<Dynamic, TOut>):CancelablePromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally:Void->Void):CancelablePromise<T> {
        return then(x -> {
            onFinally();
            x;
        }, e -> {
            onFinally();
            (CancelablePromise.reject(e) : Promise<T>);
        });
    }

    public inline extern function tap(fulfilled:T->Void):CancelablePromise<T> {
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

    public inline extern function tapError(rejected:Dynamic->Void):CancelablePromise<T> {
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
            cast CancelablePromise.reject(e);
        });
    }

    /**
     * Camce; this promise.
     */
    public function cancel():Void {
        if (result.isEmpty()) {
            if (cancelCallback.nonEmpty()) {
                final fn = cancelCallback.get();
                cancelCallback = Maybe.empty();
                fn();
            }
            onRejected(new CanceledError("canceled"));
        }
    }

    public static function resolve<T>(?value:T):CancelablePromise<T> {
        return new CancelablePromise((f, _) -> {
            f(value);
            null;
        });
    }

    public static function reject<T>(?error:Dynamic):CancelablePromise<T> {
        return new CancelablePromise((_, r) -> {
            r(error);
            null;
        });
    }
}

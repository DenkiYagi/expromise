package exasync;

import exasync._internal.IPromise;
import extype.Maybe;
import extype.Result;
import extype.extern.Mixed;
import exasync._internal.Delegate;
import exasync._internal.Dispatcher;

using extools.EqualsTools;

class AbortablePromise<T> implements IPromise<T> {
    var result:Maybe<Result<T>>;
    var onFulfilledHanlders:Delegate<T>;
    var onRejectedHanlders:Delegate<Dynamic>;
    var abortCallback:Maybe<Void->Void>;

    #if js
    static function __init__() {
        // Make this class compatible with js.lib.Promise
        final prototype = js.lib.Object.create(untyped js.lib.Promise.prototype);
        final orignal = untyped AbortablePromise.prototype;
        for (k in js.lib.Object.getOwnPropertyNames(orignal)) {
            Reflect.setField(prototype, k, Reflect.field(orignal, k));
        }
        prototype.constructor = AbortablePromise;
        Reflect.setField(prototype, "catch", prototype.catchError);
        untyped AbortablePromise.prototype = prototype;
    }
    #end

    public function new(executor:(?T->Void)->(?Dynamic->Void)->(Void->Void)) {
        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();
        abortCallback = Maybe.empty();

        if (result.isEmpty()) {
            try {
                abortCallback = Maybe.of(executor(onFulfilled, onRejected));
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

    public function then<TOut>(fulfilled:Null<PromiseCallback<T, TOut>>,
            ?rejected:Mixed2<Dynamic->Void, PromiseCallback<Dynamic, TOut>>):AbortablePromise<TOut> {
        return new AbortablePromise<TOut>(function(_fulfill, _reject) {
            final handleFulfilled = if (fulfilled != null) {
                function chain(value:T) {
                    try {
                        final next = (fulfilled : T->Dynamic)(value);
                        if (#if js Std.is(next, js.lib.Promise) || #end Std.is(next, IPromise)) {
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

            var handleRejected = if (rejected != null) {
                function rescue(error:Dynamic) {
                    try {
                        var next = (rejected : Dynamic->Dynamic)(error);
                        if (#if js Std.is(next, js.lib.Promise) || #end Std.is(next, IPromise)) {
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
            return abort;
        });
    }

    public function catchError<TOut>(rejected:Mixed2<Dynamic->Void, PromiseCallback<Dynamic, TOut>>):AbortablePromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally:Void->Void):AbortablePromise<T> {
        return then(x -> {
            onFinally();
            x;
        }, e -> {
            onFinally();
            reject(e);
        });
    }

    /**
     * Abort this promise.
     */
    public function abort():Void {
        if (result.isEmpty()) {
            if (abortCallback.nonEmpty()) {
                final fn = abortCallback.get();
                abortCallback = Maybe.empty();
                fn();
            }
            onRejected(new AbortedError("aborted"));
        }
    }

    public static function resolve<T>(?value:T):AbortablePromise<T> {
        return new AbortablePromise((f, _) -> {
            f(value);
            null;
        });
    }

    public static function reject<T>(error:Dynamic):AbortablePromise<T> {
        return new AbortablePromise((_, r) -> {
            r(error);
            null;
        });
    }
}

package exasync;

import extype.Maybe;
import extype.Result;
import extype.extern.Mixed;
import exasync._internal.IPromise;
import exasync._internal.Delegate;

using extools.EqualsTools;

class SyncPromise<T> implements IPromise<T> {
    var result:Maybe<Result<T>>;
    var onFulfilledHanlders:Delegate<T>;
    var onRejectedHanlders:Delegate<Dynamic>;

    #if js
    static function __init__() {
        // Make this class compatible with js.lib.Promise
        final prototype = js.lib.Object.create(untyped js.lib.Promise.prototype);
        final orignal = untyped SyncPromise.prototype;
        for (k in js.lib.Object.getOwnPropertyNames(orignal)) {
            Reflect.setField(prototype, k, Reflect.field(orignal, k));
        }
        prototype.constructor = SyncPromise;
        Reflect.setField(prototype, "catch", prototype.catchError);
        untyped SyncPromise.prototype = prototype;
    }
    #end

    public function new(executor:(?T->Void)->(?Dynamic->Void)->Void) {
        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();

        try {
            executor(onFulfilled, onRejected);
        } catch (e) {
            onRejected(e);
        }
    }

    function onFulfilled(?value:T):Void {
        if (result.isEmpty()) {
            result = Maybe.of(Success(value));
            onFulfilledHanlders.invoke(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error:Dynamic):Void {
        if (result.isEmpty()) {
            result = Maybe.of(Failure(error));
            onRejectedHanlders.invoke(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers():Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(fulfilled:Null<PromiseCallback<T, TOut>>, ?rejected:Mixed2<Dynamic->Void, PromiseCallback<Dynamic, TOut>>):SyncPromise<TOut> {
        return new SyncPromise<TOut>(function(_fulfill, _reject) {
            var handleFulfilled = if (fulfilled != null) {
                function transformValue(value:T) {
                    try {
                        var next = (fulfilled : T->Dynamic)(value);
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

            final handleRejected = if (rejected != null) {
                function transformError(error:Dynamic) {
                    try {
                        final next = (rejected : Dynamic->Dynamic)(error);
                        if (#if js Std.is(next, js.lib.Promise) || #end Std.is(next, IPromise)) {
                            final p:Promise<TOut> = cast next;
                            p.then(_fulfill, _reject);
                        } else {
                            _fulfill(next);
                        }
                    } catch (e:Dynamic) {
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
                        handleFulfilled(v);
                    case Failure(e):
                        handleRejected(e);
                }
            }
        });
    }

    public function catchError<TOut>(rejected:Mixed2<Dynamic->Void, PromiseCallback<Dynamic, TOut>>):SyncPromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally:Void->Void):SyncPromise<T> {
        return then(x -> {
            onFinally();
            return x;
        }, e -> {
            onFinally();
            return reject(e);
        });
    }

    public static function resolve<T>(?value:T):SyncPromise<T> {
        return new SyncPromise((f, _) -> f(value));
    }

    public static function reject<T>(error:Dynamic):SyncPromise<T> {
        return new SyncPromise((_, r) -> r(error));
    }
}

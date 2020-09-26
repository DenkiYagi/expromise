#if !js
package expromise._internal;

import expromise.Promise;
import expromise.PromiseHandler;
import extype.Nullable;
import extype.Result;

using extools.EqualsTools;

class DelayedPromise<T> implements IPromise<T> {
    var result:Nullable<Result<T, Dynamic>>;
    final onFulfilledHanlders:Delegate<T>;
    final onRejectedHanlders:Delegate<Dynamic>;

    public function new(executor:(fulfill:?T->Void, reject:?Dynamic->Void)->Void) {
        result = Nullable.empty();
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
            result = Nullable.of(Success(value));
            onFulfilledHanlders.invokeAsync(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error:Dynamic):Void {
        if (result.isEmpty()) {
            result = Nullable.of(Failure(error));
            onRejectedHanlders.invokeAsync(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers():Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(fulfilled:Null<PromiseHandler<T, TOut>>, ?rejected:PromiseHandler<Dynamic, TOut>):DelayedPromise<TOut> {
        return new DelayedPromise<TOut>((_fulfill, _reject) -> {
            final handleFulfilled = if (fulfilled != null) {
                function transformValue(value:T) {
                    try {
                        final next = fulfilled.call(value);
                        if (Std.isOfType(next, IPromise)) {
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
                        final next = rejected.call(error);
                        if (Std.isOfType(next, IPromise)) {
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
                        handleFulfilled(v);
                    case Failure(e):
                        handleRejected(e);
                }
            }
        });
    }

    public function catchError<TOut>(rejected:PromiseHandler<Dynamic, TOut>):DelayedPromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally:Void->Void):DelayedPromise<T> {
        return then(x -> {
            onFinally();
            return x;
        }, e -> {
            onFinally();
            return reject(e);
        });
    }

    public static function resolve<T>(?value:T):DelayedPromise<T> {
        return new DelayedPromise((f, _) -> f(value));
    }

    public static function reject<T>(error:Dynamic):DelayedPromise<T> {
        return new DelayedPromise((_, r) -> r(error));
    }
}
#end

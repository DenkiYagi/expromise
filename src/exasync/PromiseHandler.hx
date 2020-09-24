package exasync;

import exasync.CancelablePromise;
#if js
import js.lib.Promise.PromiseHandler in JsPromiseHandler;

abstract PromiseHandler<T, U>(T->Dynamic)
    from T->U
    from T->Promise<U>
    from T->CancelablePromise<U>
    to JsPromiseHandler<T, U>
{
    public inline extern function call(x:T):Dynamic {
        return this(x);
    }
}
abstract PromiseHandler0<T, U>(Void->Dynamic)
    from ()->U
    from ()->Promise<U>
    from ()->CancelablePromise<U>
    to Void->Dynamic
{
    @:to function toJsPromiseHandler():JsPromiseHandler<T, U> {
        return _ -> this();
    }
}
#else
abstract PromiseHandler<T, U>(T->Dynamic)
    from T->U
    from T->Promise<U>
    from T->CancelablePromise<U>
{
    public inline extern function call(x:T):Dynamic {
        return this(x);
    }
}

abstract PromiseHandler0<T, U>(Void->Dynamic)
    from ()->U
    from ()->Promise<U>
    from ()->CancelablePromise<T>
    to Void->Dynamic
{
}
#end

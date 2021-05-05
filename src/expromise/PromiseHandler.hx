package expromise;

import expromise.CancelablePromise;
#if js
import js.lib.Promise.PromiseHandler in JsPromiseHandler;

abstract PromiseHandler<T, U>(T->Dynamic)
    from T->CancelablePromise<U>
    from T->Promise<U>
    from T->js.lib.Promise<U>
    from T->U
    to JsPromiseHandler<T, U>
{
    public inline extern function call(x:T):Dynamic {
        return this(x);
    }
}
abstract PromiseHandler0<T, U>(Void->Dynamic)
    from ()->CancelablePromise<U>
    from ()->Promise<U>
    from ()->U
    to Void->Dynamic
{
    @:to function toJsPromiseHandler():JsPromiseHandler<T, U> {
        return _ -> this();
    }
}
#else
abstract PromiseHandler<T, U>(T->Dynamic)
    from T->CancelablePromise<U>
    from T->Promise<U>
    from T->U
{
    public inline extern function call(x:T):Dynamic {
        return this(x);
    }
}

abstract PromiseHandler0<T, U>(Void->Dynamic)
    from ()->CancelablePromise<T>
    from ()->Promise<U>
    from ()->U
    to Void->Dynamic
{
}
#end

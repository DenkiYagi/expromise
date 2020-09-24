package exasync;

import extype.extern.Mixed;

abstract PromiseCallback<T, U>(T -> Dynamic)
    #if js
    from Mixed4<
        T -> js.lib.Promise<U>,
        T -> CancelablePromise<U>,
        T -> Promise<U>,
        T -> U
    >
    #else
    from Mixed3<
        T -> CancelablePromise<U>,
        T -> Promise<U>,
        T -> U
    >
    #end
    to T -> Dynamic
{
    public inline extern function call(x:T):Dynamic return this(x);
}

abstract PromiseCallback0<U>(()->Dynamic)
    #if js
    from Mixed4<
        () -> js.lib.Promise<U>,
        () -> CancelablePromise<U>,
        () -> Promise<U>,
        () -> U
    >
    #else
    from Mixed3<
        () -> CancelablePromise<U>,
        () -> Promise<U>,
        () -> U
    >
    #end
    to ()->Dynamic
{
    public inline extern function call():Dynamic return this();
}

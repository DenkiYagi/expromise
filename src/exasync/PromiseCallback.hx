package exasync;

abstract PromiseCallback<T, U>(T->Dynamic)
    #if js
    from T->js.lib.Promise<U>
    from T->Promise<U>
    #end
    from T->Promise<U>
    from T->IPromise<U>
    from T->U
    to T->Dynamic
{
    public inline extern function call(x:T):Dynamic return this(x);
}

abstract PromiseCallback0<U>(()->Dynamic)
    #if js
    from ()->js.lib.Promise<U>
    from ()->Promise<U>
    #end
    from ()->Promise<U>
    from ()->IPromise<U>
    from ()->U
    to ()->Dynamic
{
    public inline extern function call():Dynamic return this();
}

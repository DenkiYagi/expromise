package exasync;

import exasync._internal.IPromise;

abstract PromiseCallback<T, U>(T->Dynamic)
    #if js
    from T->js.lib.Promise<U>
    #end
    from T->CancelablePromise<U>
    from T->Promise<U>
    from T->IPromise<U>
    from T->U
    to T->Dynamic
{}

abstract PromiseCallback0<U>(()->Dynamic)
    #if js
    from ()->js.lib.Promise<U>
    #end
    from ()->CancelablePromise<U>
    from ()->Promise<U>
    from ()->IPromise<U>
    from ()->U
    to ()->Dynamic
{}

package exasync;

import exasync._internal.IPromise;

abstract PromiseCallback<T, U>(T->Dynamic)
    #if js
    from T->js.lib.Promise<U>
    #end
    from T->SyncPromise<U>
    from T->CancelablePromise<U>
    from T->Promise<U>
    from T->IPromise<U>
    from T->U
    to T->Dynamic
{}

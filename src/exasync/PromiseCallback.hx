package exasync;

import exasync._internal.IPromise;
import extype.extern.Mixed;

abstract PromiseCallback<T, U>(T -> Dynamic)
    #if js
    from Mixed6<
        T -> js.lib.Promise<U>,
        T -> SyncPromise<U>,
        T -> CancelablePromise<U>,
        T -> Promise<U>,
        T -> IPromise<U>,
        T -> U
    >
    #else
    from Mixed5<
        T -> SyncPromise<U>,
        T -> CancelablePromise<U>,
        T -> Promise<U>,
        T -> IPromise<U>,
        T -> U
    >
    #end
    to T -> Dynamic
{}

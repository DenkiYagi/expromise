package exasync;

import extype.extern.Mixed;
import exasync._internal.IPromise;

abstract PromiseCallback<T, TOut>(T -> Dynamic)
    #if js
    from Mixed6<
        T -> js.lib.Promise<TOut>,
        T -> SyncPromise<TOut>,
        T -> AbortablePromise<TOut>,
        T -> Promise<TOut>,
        T -> IPromise<TOut>,
        T -> TOut
    >
    #else
    from Mixed5<
        T -> SyncPromise<TOut>,
        T -> AbortablePromise<TOut>,
        T -> Promise<TOut>,
        T -> IPromise<TOut>,
        T -> TOut
    >
    #end
    to T -> Dynamic
{}
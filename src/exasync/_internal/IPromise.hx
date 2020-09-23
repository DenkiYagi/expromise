package exasync._internal;

import extype.extern.Mixed;

interface IPromise<T> {
    function then<TOut>(fulfilled:Null<PromiseCallback<T, TOut>>, ?rejected:PromiseCallback<Dynamic, TOut>): Promise<TOut>;
    function catchError<TOut>(rejected:PromiseCallback<Dynamic, TOut>): Promise<TOut>;
    function finally(onFinally:Void->Void): Promise<T>;
}

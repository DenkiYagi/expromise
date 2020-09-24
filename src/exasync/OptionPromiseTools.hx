package exasync;

import exasync.PromiseCallback;
import extools.EqualsTools;
import haxe.ds.Option;

using extools.OptionTools;

class OptionPromiseTools {
    public static inline function mapThen<T, U>(promise:Promise<Option<T>>, fn:PromiseCallback<T, U>):Promise<Option<U>> {
        return promise.then((x -> switch (x) {
            case Some(t):
                final ret = fn.call(t);
                if (#if js Std.isOfType(ret, js.lib.Promise) || #end Std.isOfType(ret, IPromise)) {
                    final p:Promise<U> = cast ret;
                    p.then(u -> Some(u));
                } else {
                    Promise.resolve(Some(ret));
                }
            case None:
                Promise.resolve(None);
            } : PromiseCallback<Option<T>, Option<U>>));
    }

    public static inline function flatMapThen<T, U>(promise:Promise<Option<T>>, fn:PromiseCallback<T, Option<U>>):Promise<Option<U>> {
        return promise.then(x -> x.flatMap(fn));
    }

    public static inline function filterThen<T>(promise:Promise<Option<T>>, fn:PromiseCallback<T, Bool>):Promise<Option<T>> {
        return promise.then((value -> {
            value.fold(() -> Promise.resolve(None), x -> {
                final ret = fn.call(x);
                if (EqualsTools.strictEqual(ret, true)) {
                    Promise.resolve(Some(x));
                } else if (EqualsTools.strictEqual(ret, false)) {
                    Promise.resolve(None);
                } else {
                    final p:Promise<Bool> = cast ret;
                    p.then(y -> y ? Some(x) : None);
                }
            });
        } : PromiseCallback<Option<T>, Option<T>>));
    }

    public static inline function foldThen<T, U>(promise:Promise<Option<T>>, ifEmpty:PromiseCallback0<U>, fn:PromiseCallback<T, U>):Promise<U> {
        return promise.then(x -> x.fold(ifEmpty, fn));
    }
}

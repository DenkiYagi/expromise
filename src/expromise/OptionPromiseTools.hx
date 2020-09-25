package expromise;

import expromise.PromiseHandler;
import extools.EqualsTools;
import haxe.ds.Option;

using extools.OptionTools;

class OptionPromiseTools {
    public static inline function thenMap<T, U>(promise:Promise<Option<T>>, fn:PromiseHandler<T, U>):Promise<Option<U>> {
        return promise.then((x -> switch (x) {
            case Some(t):
                final ret = fn.call(t);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<U> = cast ret;
                    p.then(u -> Some(u));
                } else {
                    Promise.resolve(Some(ret));
                }
            case None:
                Promise.resolve(None);
            } : PromiseHandler<Option<T>, Option<U>>));
    }

    public static inline function thenFlatMap<T, U>(promise:Promise<Option<T>>, fn:PromiseHandler<T, Option<U>>):Promise<Option<U>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function thenFilter<T>(promise:Promise<Option<T>>, fn:PromiseHandler<T, Bool>):Promise<Option<T>> {
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
        } : PromiseHandler<Option<T>, Option<T>>));
    }

    public static inline function thenFold<T, U>(promise:Promise<Option<T>>, ifEmpty:PromiseHandler0<T, U>, fn:PromiseHandler<T, U>):Promise<U> {
        return promise.then(x -> x.fold(ifEmpty, cast fn));
    }

    public static function resolveSome<T>(x:T):Promise<Option<T>> {
        return Promise.resolve(Some(x));
    }

    public static function resolveNone<T>():Promise<Option<T>> {
        return Promise.resolve(None);
    }
}

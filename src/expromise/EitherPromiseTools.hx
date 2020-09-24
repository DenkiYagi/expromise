package expromise;

import expromise.PromiseHandler;
import haxe.ds.Either;

using extools.EitherTools;

class EitherPromiseTools {
    public static inline function swap<A, B>(promise:Promise<Either<A, B>>):Promise<Either<B, A>> {
        return promise.then(EitherTools.swap);
    }

    public static inline function mapThen<A, B, BB>(promise:Promise<Either<A, B>>, fn:PromiseHandler<B, BB>):Promise<Either<A, BB>> {
        return promise.then((x -> switch (x) {
            case Right(b):
                final ret = fn.call(b);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<BB> = cast ret;
                    p.then(bb -> Right(bb));
                } else {
                    Promise.resolve(Right(ret));
                }
            case Left(a):
                Promise.resolve(Left(a));
        } : PromiseHandler<Either<A, B>, Either<A, BB>>));
    }

    public static inline function flatMapThen<A, B, BB>(promise:Promise<Either<A, B>>, fn:PromiseHandler<B, Either<A, BB>>):Promise<Either<A, BB>> {
        return promise.then(x -> x.flatMap(cast fn));
    }

    public static inline function mapLeftThen<A, B, AA>(promise:Promise<Either<A, B>>, fn:PromiseHandler<A, AA>):Promise<Either<AA, B>> {
        return promise.then((x -> switch (x) {
            case Left(a):
                final ret = fn.call(a);
                if (Std.isOfType(ret, #if js js.lib.Promise #else IPromise #end)) {
                    final p:Promise<AA> = cast ret;
                    p.then(bb -> Left(bb));
                } else {
                    Promise.resolve(Left(ret));
                }
            case Right(b):
                Promise.resolve(Right(b));
        } : PromiseHandler<Either<A, B>, Either<AA, B>>));
    }

    public static inline function flatMapLeftThen<A, B, AA>(promise:Promise<Either<A, B>>, fn:PromiseHandler<A, Either<AA, B>>):Promise<Either<AA, B>> {
        return promise.then(x -> x.flatMapLeft(cast fn));
    }

    public static inline function resolveRight<A, B>(x:B):Promise<Either<A, B>> {
        return Promise.resolve(Right(x));
    }

    public static inline function resolveLeft<A, B>(x:A):Promise<Either<A, B>> {
        return Promise.resolve(Left(x));
    }
}

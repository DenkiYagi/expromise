package exasync;

import haxe.Exception;
import haxe.ds.Either;

abstract Task<TSuccess, TFailure>(Promise<TSuccess>) {
    public inline extern function new(executor:(?TSuccess->Void)->(?TFailure->Void)->Void) {
        this = new Promise((fulfill, reject) -> {
            executor(fulfill, (?err) -> reject(TaskError.Failure(err)));
        }).catchError(ex -> {
            if (Std.isOfType(ex, TaskError)) {
                Promise.reject(cast ex);
            } else {
                Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function map<TNewSuccess>(fn:(value:TSuccess)->TNewSuccess):Task<TNewSuccess, TFailure> {
        return cast this.then(value -> {
            try {
                Promise.resolve(fn(value));
            } catch (ex) {
                Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function flatMap<TNewSuccess>(fn:(value:TSuccess)->Task<TNewSuccess, TFailure>):Task<TNewSuccess, TFailure> {
        return cast this.then(value -> {
            try {
                cast fn(value);
            } catch (ex) {
                Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function mapFailure<TNewFailure>(fn:(error:TFailure)->TNewFailure):Task<TSuccess, TNewFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    Promise.reject(try {
                        TaskError.Failure(fn(error));
                    } catch (ex) {
                        TaskError.Exception(ex);
                    });
                case Exception(ex):
                    Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function flatMapFailure<TNewFailure>(fn:(error:TFailure)->Task<TSuccess, TNewFailure>):Task<TSuccess, TNewFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    try {
                        cast fn(error);
                    } catch (ex) {
                        Promise.reject(TaskError.Exception(ex));
                    }
                case Exception(ex):
                    Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function rescue(fn:Exception->Task<TSuccess, TFailure>):Task<TSuccess, TFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    Promise.reject(TaskError.Failure(error));
                case Exception(ex):
                    try {
                        cast fn(ex);
                    } catch (ex) {
                        Promise.reject(TaskError.Exception(ex));
                    }
            }
        });
    }

    public function onComplete(fn:TaskResult<TSuccess, TFailure> -> Void):Void {
        this.then(value -> {
            fn(TaskResult.Success(value));
        }, (e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    fn(TaskResult.Failure(error));
                case Exception(ex):
                    fn(TaskResult.Exception(ex));
            }
        });
    }

    @:to
    public extern inline function toPromise():Promise<Either<TFailure, TSuccess>> {
        return this.then(
            x -> Right(x),
            e -> {
                return switch ((e : TaskError<TFailure>)) {
                    case TaskError.Failure(error): Promise.resolve(Left(error));
                    case TaskError.Exception(ex): Promise.reject(ex);
                }
            }
        );
    }

    @:from
    public extern inline static function fromPromise<T>(promise:Promise<T>):Task<T, Void> {
        return cast promise.catchError(e -> Promise.reject(TaskError.Exception(Std.isOfType(e, Exception) ? e : new Exception(Std.string(e)))));
    }

    @:from
    public extern inline static function fromEitherPromise<TSuccess, TFailure>(promise:Promise<Either<TFailure, TSuccess>>):Task<TSuccess, TFailure> {
        return cast promise.then(x -> switch (x) {
            case Right(v): Promise.resolve(v);
            case Left(v): Promise.reject(TaskError.Failure(v));
        }, e -> Promise.reject(TaskError.Exception(Std.isOfType(e, Exception) ? e : new Exception(Std.string(e)))));
    }

    static function toException(e:Dynamic):Exception {
        return if (Std.isOfType(e, Exception)) {
            (e : Exception);
        #if js
        } else if (Std.isOfType(e, js.lib.Error)) {
            new Exception((e : js.lib.Error).message, null, e);
        #elseif java
        } else if (Std.isOfType(e, java.lang.Throwable)) {
            new Exception((e : java.lang.Throwable).getMessage(), null, e);
        #elseif cs
        } else if (Std.isOfType(e, cs.system.Exception)) {
            new Exception((e : cs.system.Exception).Message, null, e);
        #elseif flash
        } else if (Std.isOfType(e, flash.errors.Error)) {
            new Exception((e : flash.errors.Error).message, null, e);
        #elseif php
        } else if (Std.isOfType(e, php.Throwable)) {
            new Exception((e : php.Throwable).getMessage(), null, e);
        #elseif python
        } else if (Std.isOfType(e, python.BaseException)) {
            new Exception(Std.string(e), null, e);
        #end
        } else {
            new Exception(Std.string(e));
        }
    }

    public static inline extern function success<TSuccess, TFailure>(?value:TSuccess):Task<TSuccess, TFailure> {
        return cast Promise.resolve(value);
    }

    public static inline extern function failure<TSuccess, TFailure>(?error:TFailure):Task<TSuccess, TFailure> {
        return cast Promise.reject(TaskError.Failure(error));
    }

    public static inline extern function exception<TSuccess, TFailure>(exception:Exception):Task<TSuccess, TFailure> {
        return cast Promise.reject(TaskError.Exception(exception));
    }
}

enum TaskResult<TSuccess, TFailure> {
    Success(value:TSuccess);
    Failure(error:TFailure);
    Exception(exception:Exception);
}

private enum TaskError<T> {
    Failure(error:T);
    Exception(exception:Exception);
}

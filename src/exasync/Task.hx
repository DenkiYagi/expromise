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

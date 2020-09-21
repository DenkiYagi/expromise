package exasync;

import haxe.Exception;

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
                    try {
                        TaskError.Failure(fn(error));
                    } catch (ex) {
                        TaskError.Exception(ex);
                    }
                case Exception(exception):
                    TaskError.Exception(exception);
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
                case Exception(exception):
                    Promise.reject(TaskError.Exception(exception));
            }
        });
    }

    public function rescue(fn:Exception->Task<TSuccess, TFailure>):Task<TSuccess, TFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    Task.failure(error);
                case Exception(exception):
                    cast fn(exception);
            }
        });
    }

    public function onSuccess(fn:TSuccess->Void):Task<TSuccess, TFailure> {
        return cast this.then(value -> {
            try {
                fn(value);
                Promise.resolve(value);
            } catch (ex) {
                Promise.reject(TaskError.Exception(ex));
            }
        });
    }

    public function onFailure(fn:TFailure->Void):Task<TSuccess, TFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    try {
                        fn(error);
                        Promise.reject(e);
                    } catch (ex) {
                        Promise.reject(TaskError.Exception(ex));
                    }
                case Exception(exception):
                    Promise.reject(e);
            }
        });
    }

    public function onException(fn:Exception->Void):Task<TSuccess, TFailure> {
        return cast this.catchError((e:TaskError<TFailure>) -> {
            switch (e) {
                case Failure(error):
                    Promise.reject(e);
                case Exception(exception):
                    try {
                        fn(exception);
                        Promise.reject(e);
                    } catch (ex) {
                        Promise.reject(TaskError.Exception(ex));
                    }
            }
        });
    }

    public function onFinally(fn:Void->Void):Task<TSuccess, TFailure> {
        return cast this.finally(fn);
    }

    @:to
    public extern inline function toPromise():Promise<TaskResult<TSuccess, TFailure>> {
        return this.then(
            x -> TaskResult.Success(x),
            e -> {
                return switch ((e : TaskError<TFailure>)) {
                    case TaskError.Failure(error): Promise.resolve(TaskResult.Failure(error));
                    case TaskError.Exception(exception): Promise.reject(exception);
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
}

private enum TaskError<T> {
    Failure(error:T);
    Exception(exception:Exception);
}

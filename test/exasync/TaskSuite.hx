package exasync;

class TaskSuite extends BuddySuite {
    public function new() {
        describe("Task.new()", {
            timeoutMs = 100;

            #if js
            beforeAll({
                js.Syntax.code("process.on('unhandledRejection', {0})", _ -> {});
            });
            afterAll({
                js.Syntax.code("process.removeListener('unhandledRejection', {0})", _ -> {});
            });
            #end

            describe("executor", {
                it("should call", done -> {
                    new Task(function(_, _) {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", done -> {
                    new Task(function(_, _) {}).onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should pass", {
                    new Task((fulfill, _) -> {
                        fulfill();
                    });
                });

                it("should pass when it is taken none value", done -> {
                    new Task((fulfill, _) -> {
                        wait(5, fulfill.bind());
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some value", done -> {
                    new Task((fulfill, _) -> {
                        wait(5, fulfill.bind(1));
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(1);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: failure", {
                it("should pass", {
                    new Task((_, reject) -> {
                        reject();
                    });
                });

                it("should pass when it is taken none failure value", done -> {
                    new Task((_, reject) -> {
                        wait(5, reject.bind());
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some failure value", done -> {
                    new Task((_, reject) -> {
                        wait(5, reject.bind("error"));
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken an exception", done -> {
                    new Task((_, reject) -> {
                        reject(new Exception("error"));
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.message.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: exception", {
                it("should pass when it is thrown error", done -> {
                    new Task((_, reject) -> {
                        throw "error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("Task.success()", {
                it("should pass when it is taken none value", done -> {
                    Task.success()
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some value", done -> {
                    Task.success(100)
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("Task.failure()", {
                it("should pass when it is taken none failure value", done -> {
                    Task.failure()
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some failure value", done -> {
                    Task.failure("error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("Task.exception()", {
                it("should pass", done -> {
                    Task.exception(new Exception("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.onComplete()", {
            it("should call all callbacks when it taken none value", done -> {
                var count = 0;
                final task = Task.success();
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        (value:Null<Any>).should.be(null);
                        count++;
                    case Failure(error): fail(error);
                    case Exception(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        (value:Null<Any>).should.be(null);
                        count++;
                    case Failure(error): fail(error);
                    case Exception(exception): fail(exception);
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });

            it("should call all callbacks when it taken some value", done -> {
                var count = 0;
                final task = Task.success(100);
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        value.should.be(100);
                        count++;
                    case Failure(error): fail(error);
                    case Exception(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        value.should.be(100);
                        count++;
                    case Failure(error): fail(error);
                    case Exception(exception): fail(exception);
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });

            it("should call all callbacks when it taken none failure value", done -> {
                var count = 0;
                final task = Task.failure();
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        (error:Null<Any>).should.be(null);
                        count++;
                    case Exception(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        (error:Null<Any>).should.be(null);
                        count++;
                    case Exception(exception): fail(exception);
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });

            it("should call all callbacks when it taken some failure value", done -> {
                var count = 0;
                final task = Task.failure("error");
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        error.should.be("error");
                        count++;
                    case Exception(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        error.should.be("error");
                        count++;
                    case Exception(exception): fail(exception);
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });

            it("should call all callbacks when it taken an exception", done -> {
                var count = 0;
                final task = Task.exception(new Exception("error"));
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error): fail(error);
                    case Exception(exception):
                        exception.message.should.be("error");
                        count++;
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error): fail(error);
                    case Exception(exception):
                        exception.message.should.be("error");
                        count++;
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });
        });

        describe("Task.map()", {
            describe("pending", {
                it("should not call", done -> {
                    new Task((_, _) -> {}).map(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should call when it is taken none value", done -> {
                    Task.success().map(x -> {
                        (x:Null<Any>).should.be(null);
                        "hello";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be("hello");
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should call when it is taken some value", done -> {
                    Task.success(100).map(x -> {
                        x.should.be(100);
                        x * 2;
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.success(100).map(x -> {
                        throw "error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("result: failure", {
                it("should not call when it is taken none failure value", done -> {
                    Task.failure().map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some empty failure value", done -> {
                    Task.failure("error").map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: exception", {
                it("should not call", done -> {
                    Task.exception(new Exception("error")).map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail();
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.flatMap()", {
            describe("pending", {
                it("should not call", done -> {
                    new Task((_, _) -> {}).flatMap(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should call when it is taken none value", done -> {
                    Task.success().flatMap(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                        null;
                    });
                });

                it("should call when it is taken some value", done -> {
                    Task.success(100).flatMap(x -> {
                        x.should.be(100);
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.success(100).flatMap(x -> Task.success(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.success(100).flatMap(x -> Task.failure("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.success(100).flatMap(x -> Task.exception(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.success(100).flatMap(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("result: failure", {
                it("should not call when it is taken none failure value", done -> {
                    Task.failure().flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some empty failure value", done -> {
                    Task.failure("error").flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: exception", {
                it("should not call", done -> {
                    Task.exception(new Exception("error")).flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.mapFailure()", {
            describe("pending", {
                it("should not call", done -> {
                    new Task((_, _) -> {}).mapFailure(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should not call when it is taken none value", done -> {
                    Task.success().mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.success(100).mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: failure", {
                it("should call when it is taken none failure value", done -> {
                    Task.failure().mapFailure(x -> {
                        (x:Null<Any>).should.be(null);
                        "hello";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("hello");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should call when it is taken some failure value", done -> {
                    Task.failure("error").mapFailure(x -> {
                        x.should.be("error");
                        x + "_mod";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error_mod");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.failure("error").mapFailure(x -> {
                        throw "new error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("new error");
                            done();
                    });
                });
            });

            describe("result: exception", {
                it("should not call", done -> {
                    Task.exception(new Exception("error")).mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.flatMapFailure()", {
            describe("pending", {
                it("should not call", done -> {
                    new Task((_, _) -> {}).flatMapFailure(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should not call when it is taken none value", done -> {
                    Task.success().flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.success(100).flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: failure", {
                it("should call when it is taken none value", done -> {
                    Task.failure().flatMapFailure(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                        null;
                    });
                });

                it("should call when it is taken some value", done -> {
                    Task.failure("error").flatMapFailure(x -> {
                        x.should.be("error");
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.failure(100).flatMapFailure(x -> Task.success(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.failure(100).flatMapFailure(x -> Task.failure("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.failure(100).flatMapFailure(x -> Task.exception(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should be an exception when it is thrown an exception", done -> {
                    Task.failure(100).flatMapFailure(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("result: exception", {
                it("should not call", done -> {
                    Task.exception(new Exception("error")).flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.rescue()", {
            describe("pending", {
                it("should not call", done -> {
                    new Task((_, _) -> {}).rescue(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("result: success", {
                it("should not call when it is taken none value", done -> {
                    Task.success().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.success(100).rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: failure", {
                it("should not call when it is taken none failure value", done -> {
                    Task.failure().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some failure value", done -> {
                    Task.failure(100).rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be(100);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("result: exception", {
                it("should call", done -> {
                    Task.exception(new Exception("error")).rescue(x -> {
                        x.message.should.be("error");
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.exception(new Exception("error")).rescue(x -> Task.success(100))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.exception(new Exception("error")).rescue(x -> Task.failure("error2"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.exception(new Exception("error")).rescue(x -> Task.exception(new Exception("error2")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.exception(new Exception("error")).rescue(x -> throw "error2")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });
            });
        });

        describe("Task.toPromise()", {
            it("should convert from none success value", done -> {
                Task.success().toPromise().then(x -> {
                    switch (x) {
                        case Right(v): (v:Null<Any>).should.be(null);
                        case Left(v): fail(v);
                    }
                    done();
                });
            });

            it("should convert from some success value", done -> {
                Task.success(100).toPromise().then(x -> {
                    switch (x) {
                        case Right(v): v.should.be(100);
                        case Left(v): fail(v);
                    }
                    done();
                });
            });

            it("should convert from none failure value", done -> {
                Task.failure().toPromise().then(x -> {
                    switch (x) {
                        case Right(v): fail(v);
                        case Left(v): (v:Null<Any>).should.be(null);
                    }
                    done();
                });
            });

            it("should convert from none failure value", done -> {
                Task.failure("error").toPromise().then(x -> {
                    switch (x) {
                        case Right(v): fail(v);
                        case Left(v): v.should.be("error");
                    }
                    done();
                });
            });

            it("should convert from an exception", done -> {
                Task.exception(new Exception("error")).toPromise().catchError(x -> {
                    (x : Exception).message.should.be("error");
                    done();
                });
            });
        });
    }
}

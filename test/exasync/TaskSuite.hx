package exasync;

import haxe.ds.Either;

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

            describe("Task.successful()", {
                it("should pass when it is taken none value", done -> {
                    Task.successful()
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some value", done -> {
                    Task.successful(100)
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("Task.failed()", {
                it("should pass when it is taken none failure value", done -> {
                    Task.failed()
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some failure value", done -> {
                    Task.failed("error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });
            });

            describe("Task.abended()", {
                it("should pass", done -> {
                    Task.abended(new Exception("error"))
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
                final task = Task.successful();
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
                final task = Task.successful(100);
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
                final task = Task.failed();
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
                final task = Task.failed("error");
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
                final task = Task.abended(new Exception("error"));
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
                    Task.successful().map(x -> {
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
                    Task.successful(100).map(x -> {
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
                    Task.successful(100).map(x -> {
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
                    Task.failed().map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some empty failure value", done -> {
                    Task.failed("error").map(x -> { fail(); null; })
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
                    Task.abended(new Exception("error")).map(x -> { fail(); null; })
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
                    Task.successful().flatMap(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                        null;
                    });
                });

                it("should call when it is taken some value", done -> {
                    Task.successful(100).flatMap(x -> {
                        x.should.be(100);
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.successful(100).flatMap(x -> Task.successful(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.successful(100).flatMap(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.successful(100).flatMap(x -> Task.abended(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.successful(100).flatMap(x -> throw "error")
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
                    Task.failed().flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some empty failure value", done -> {
                    Task.failed("error").flatMap(x -> { fail(); null; })
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
                    Task.abended(new Exception("error")).flatMap(x -> { fail(); null; })
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
                    Task.successful().mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.successful(100).mapFailure(x -> { fail(); null; })
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
                    Task.failed().mapFailure(x -> {
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
                    Task.failed("error").mapFailure(x -> {
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
                    Task.failed("error").mapFailure(x -> {
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
                    Task.abended(new Exception("error")).mapFailure(x -> { fail(); null; })
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
                    Task.successful().flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.successful(100).flatMapFailure(x -> { fail(); null; })
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
                    Task.failed().flatMapFailure(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                        null;
                    });
                });

                it("should call when it is taken some value", done -> {
                    Task.failed("error").flatMapFailure(x -> {
                        x.should.be("error");
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.successful(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.abended(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should be an exception when it is thrown an exception", done -> {
                    Task.failed(100).flatMapFailure(x -> throw "error")
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
                    Task.abended(new Exception("error")).flatMapFailure(x -> { fail(); null; })
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
                    Task.successful().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.successful(100).rescue(x -> { fail(); null; })
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
                    Task.failed().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some failure value", done -> {
                    Task.failed(100).rescue(x -> { fail(); null; })
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
                    Task.abended(new Exception("error")).rescue(x -> {
                        x.message.should.be("error");
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.abended(new Exception("error")).rescue(x -> Task.successful(100))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.abended(new Exception("error")).rescue(x -> Task.failed("error2"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Exception(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.abended(new Exception("error")).rescue(x -> Task.abended(new Exception("error2")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Exception(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.abended(new Exception("error")).rescue(x -> throw "error2")
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
                Task.successful().toPromise().then(x -> {
                    switch (x) {
                        case Right(v): (v:Null<Any>).should.be(null);
                        case Left(v): fail(v);
                    }
                    done();
                });
            });

            it("should convert from some success value", done -> {
                Task.successful(100).toPromise().then(x -> {
                    switch (x) {
                        case Right(v): v.should.be(100);
                        case Left(v): fail(v);
                    }
                    done();
                });
            });

            it("should convert from none failure value", done -> {
                Task.failed().toPromise().then(x -> {
                    switch (x) {
                        case Right(v): fail(v);
                        case Left(v): (v:Null<Any>).should.be(null);
                    }
                    done();
                });
            });

            it("should convert from none failure value", done -> {
                Task.failed("error").toPromise().then(x -> {
                    switch (x) {
                        case Right(v): fail(v);
                        case Left(v): v.should.be("error");
                    }
                    done();
                });
            });

            it("should convert from an exception", done -> {
                Task.abended(new Exception("error")).toPromise().catchError(x -> {
                    (x : Exception).message.should.be("error");
                    done();
                });
            });
        });

        describe("Task.fromPromise()", {
            it("should convert from fulfilled value", done -> {
                final task:Task<Int, Void> = Promise.resolve(100);
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        value.should.be(100);
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected value", done -> {
                final task:Task<Int, Void> = Promise.reject("error");
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected value", done -> {
                final task:Task<Int, Void> = Promise.reject("error");
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected Exception", done -> {
                final task:Task<Int, Void> = Promise.reject(new Exception("error"));
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            #if js
            it("should convert from rejected JS Error", done -> {
                final task:Task<Int, Void> = Promise.reject(new js.lib.Error("error"));
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("Error: error");
                        (error.native : js.lib.Error).message.should.be("Error: error");
                        done();
                    case _: fail();
                });
            });
            #end
            // TODO other platform test
        });

        describe("Task.fromEitherPromise()", {
            it("should convert from fulfilled value", done -> {
                final task:Task<Int, String> = Promise.resolve(Either.Right(100));
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        value.should.be(100);
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected value", done -> {
                final task:Task<Int, String> = Promise.resolve(Either.Left("error"));
                task.onComplete(x -> switch (x) {
                    case Failure(error):
                        error.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected value", done -> {
                final task:Task<Int, String> = (Promise.reject("error") : Promise<Either<String, Int>>);
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected Exception", done -> {
                final task:Task<Int, String> = (Promise.reject(new Exception("error")) : Promise<Either<String, Int>>);
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            #if js
            it("should convert from rejected JS Error", done -> {
                final task:Task<Int, String> = (Promise.reject(new js.lib.Error("error")) : Promise<Either<String, Int>>);
                task.onComplete(x -> switch (x) {
                    case Exception(error):
                        error.message.should.be("Error: error");
                        (error.native : js.lib.Error).message.should.be("Error: error");
                        done();
                    case _: fail();
                });
            });
            #end
            // TODO other platform test
        });
    }
}

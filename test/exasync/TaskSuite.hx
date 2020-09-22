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
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
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
                        case Abend(exception): fail(exception);
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
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from failed", {
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
                        case Abend(exception): fail(exception);
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
                        case Abend(exception): fail(exception);
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
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from aborted", {
                it("should pass when it is thrown error", done -> {
                    new Task((_, reject) -> {
                        throw "error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
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
                        case Abend(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some value", done -> {
                    Task.successful(100)
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
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
                        case Abend(exception): fail(exception);
                    });
                });

                it("should pass when it is taken some failure value", done -> {
                    Task.failed("error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("Task.aborted()", {
                it("should pass", done -> {
                    Task.aborted(new Exception("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
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
                    case Abend(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        (value:Null<Any>).should.be(null);
                        count++;
                    case Failure(error): fail(error);
                    case Abend(exception): fail(exception);
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
                    case Abend(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value):
                        value.should.be(100);
                        count++;
                    case Failure(error): fail(error);
                    case Abend(exception): fail(exception);
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
                    case Abend(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        (error:Null<Any>).should.be(null);
                        count++;
                    case Abend(exception): fail(exception);
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
                    case Abend(exception): fail(exception);
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error):
                        error.should.be("error");
                        count++;
                    case Abend(exception): fail(exception);
                });
                task.onComplete(_ -> {
                    count.should.be(2);
                    done();
                });
            });

            it("should call all callbacks when it taken an exception", done -> {
                var count = 0;
                final task = Task.aborted(new Exception("error"));
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error): fail(error);
                    case Abend(exception):
                        exception.message.should.be("error");
                        count++;
                });
                task.onComplete(x -> switch (x) {
                    case Success(value): fail(value);
                    case Failure(error): fail(error);
                    case Abend(exception):
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
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).map(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should process `empty -> U`", done -> {
                    Task.successful().map(x -> {
                        (x:Null<Any>).should.be(null);
                        "hello";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be("hello");
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty -> throw`", done -> {
                    Task.successful().map(x -> {
                        throw "error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `some -> U`", done -> {
                    Task.successful(100).map(x -> {
                        x.should.be(100);
                        x * 2;
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some -> throw`", done -> {
                    Task.successful(100).map(x -> {
                        throw "error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("from failed", {
                it("should never call callback when it taken `empty failure`", done -> {
                    Task.failed().map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should never call callback when it taken `some failure`", done -> {
                    Task.failed("error").map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).map(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail();
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.flatMap()", {
            describe("pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).flatMap(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {

                it("should process `empty value -> Successful<U>`", done -> {
                    Task.successful().flatMap(x -> Task.successful(100))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty value -> Failure<U>`", done -> {
                    Task.successful().flatMap(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty value -> Abend`", done -> {
                    Task.successful().flatMap(x -> Task.aborted(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `empty value -> throw`", done -> {
                    Task.successful().flatMap(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `T -> Successful<U>`", done -> {
                    Task.successful(100).flatMap(x -> Task.successful(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `T -> Failure<U>`", done -> {
                    Task.successful(100).flatMap(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `T -> Abend`", done -> {
                    Task.successful(100).flatMap(x -> Task.aborted(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `T -> throw`", done -> {
                    Task.successful(100).flatMap(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("from failed", {
                it("should never call callback when it is taken `empty failure`", done -> {
                    Task.failed().flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should never call callback when it is taken `some failure`", done -> {
                    Task.failed("error").flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).flatMap(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.mapFailure()", {
            describe("pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).mapFailure(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should never call callback when it is taken `empty value`", done -> {
                    Task.successful().mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should never call callback when it is taken `some value`", done -> {
                    Task.successful(100).mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from failed", {
                it("should process `empty failure -> Failure<U>`", done -> {
                    Task.failed().mapFailure(x -> {
                        (x:Null<Any>).should.be(null);
                        "hello";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("hello");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failure -> Failure<U>`", done -> {
                    Task.failed("error").mapFailure(x -> {
                        x.should.be("error");
                        x + "_mod";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error_mod");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failure -> throw`", done -> {
                    Task.failed("error").mapFailure(x -> {
                        throw "new error";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("new error");
                            done();
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).mapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.flatMapFailure()", {
            describe("pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).flatMapFailure(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should never call callback when it is taken `empty value`", done -> {
                    Task.successful().flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should never call callback when it is taken `some value`", done -> {
                    Task.successful(100).flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from failed", {
                it("should process `empty failure -> Successful<U>`", done -> {
                    Task.failed().flatMapFailure(x -> Task.successful(100))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failure -> Failure<U>`", done -> {
                    Task.failed().flatMapFailure(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failure -> Abend`", done -> {
                    Task.failed().flatMapFailure(x -> Task.aborted(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `empty failure -> throw`", done -> {
                    Task.failed().flatMapFailure(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `some failure -> Successful<U>`", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.successful(x * 2))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failure -> Failure<U>`", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.failed("error"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failure -> Abend`", done -> {
                    Task.failed(100).flatMapFailure(x -> Task.aborted(new Exception("error")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `some failure -> throw`", done -> {
                    Task.failed(100).flatMapFailure(x -> throw "error")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).flatMapFailure(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.match()", {
            describe("from pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).match(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should process `empty successful -> Right`", done -> {
                    Task.successful().match(x -> switch (x) {
                        case Right(v): Right(100);
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty successful -> Left`", done -> {
                    Task.successful().match(x -> switch (x) {
                        case Right(v): Left("error");
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty successful -> throw`", done -> {
                    Task.successful().match(x -> switch (x) {
                        case Right(v): throw "error";
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `some successful -> Right`", done -> {
                    Task.successful(100).match(x -> switch (x) {
                        case Right(v): Right(v * 2);
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some successful -> Left`", done -> {
                    Task.successful(100).match(x -> switch (x) {
                        case Right(v): Left("error");
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some successful -> throw`", done -> {
                    Task.successful(100).match(x -> switch (x) {
                        case Right(v): throw "error";
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("from failed", {
                it("should process `empty failed -> Right`", done -> {
                    Task.failed().match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Right(100);
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failed -> Left`", done -> {
                    Task.failed().match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Left("error2");
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failed -> throw`", done -> {
                    Task.failed().match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): throw "error2";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });

                it("should process `some failed -> Right`", done -> {
                    Task.failed(100).match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Right(100);
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failed -> Left`", done -> {
                    Task.failed(100).match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Left("error2");
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failed -> throw`", done -> {
                    Task.failed(100).match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): throw "error2";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).match(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.flatMatch()", {
            describe("pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).flatMatch(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should process `empty successful -> Success<U>`", done -> {
                    Task.successful().flatMatch(x -> switch (x) {
                        case Right(v): Task.successful(100);
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty successful -> Failure<U>`", done -> {
                    Task.successful().flatMatch(x -> switch (x) {
                        case Right(v): Task.failed("error");
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty successful -> throw`", done -> {
                    Task.successful().flatMatch(x -> switch (x) {
                        case Right(v): throw "error";
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });

                it("should process `some successful -> Success<U>`", done -> {
                    Task.successful(100).flatMatch(x -> switch (x) {
                        case Right(v): Task.successful(v * 2);
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(200);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some successful -> Failure<U>`", done -> {
                    Task.successful(100).flatMatch(x -> switch (x) {
                        case Right(v): Task.failed("error");
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some successful -> throw`", done -> {
                    Task.successful(100).flatMatch(x -> switch (x) {
                        case Right(v): throw "error";
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });

            describe("from failed", {
                it("should process `empty failed -> Success<U>`", done -> {
                    Task.failed().flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Task.successful(100);
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failed -> Failure<U>`", done -> {
                    Task.failed().flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Task.failed("error2");
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `empty failed -> throw`", done -> {
                    Task.failed().flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): throw "error2";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });

                it("should process `some failed -> Success<U>`", done -> {
                    Task.failed(100).flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Task.successful(100);
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failed -> Failure<U>`", done -> {
                    Task.failed(100).flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): Task.failed("error2");
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should process `some failed -> throw`", done -> {
                    Task.failed(100).flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): throw "error2";
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });
            });

            describe("from aborted", {
                it("should never call callback", done -> {
                    Task.aborted(new Exception("error")).flatMatch(x -> switch (x) {
                        case Right(v): { fail(); null; }
                        case Left(v): { fail(); null; }
                    })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error");
                            done();
                    });
                });
            });
        });

        describe("Task.rescue()", {
            describe("pending", {
                it("should never call callback", done -> {
                    new Task((_, _) -> {}).rescue(_ -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                    wait(5, done);
                });
            });

            describe("from successful", {
                it("should not call when it is taken none value", done -> {
                    Task.successful().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            (value:Null<Any>).should.be(null);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some value", done -> {
                    Task.successful(100).rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from failed", {
                it("should not call when it is taken none failure value", done -> {
                    Task.failed().rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            (error:Null<Any>).should.be(null);
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should not call when it is taken some failure value", done -> {
                    Task.failed(100).rescue(x -> { fail(); null; })
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be(100);
                            done();
                        case Abend(exception): fail(exception);
                    });
                });
            });

            describe("from aborted", {
                it("should call", done -> {
                    Task.aborted(new Exception("error")).rescue(x -> {
                        x.message.should.be("error");
                        done();
                        null;
                    });
                });

                it("should transform a new success value", done -> {
                    Task.aborted(new Exception("error")).rescue(x -> Task.successful(100))
                    .onComplete(result -> switch (result) {
                        case Success(value):
                            value.should.be(100);
                            done();
                        case Failure(error): fail(error);
                        case Abend(exception): fail(exception);
                    });
                });

                it("should transform a new failure value", done -> {
                    Task.aborted(new Exception("error")).rescue(x -> Task.failed("error2"))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error):
                            error.should.be("error2");
                            done();
                        case Abend(exception): fail(exception);
                    });
                });

                it("should transform a new exception", done -> {
                    Task.aborted(new Exception("error")).rescue(x -> Task.aborted(new Exception("error2")))
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
                            exception.message.should.be("error2");
                            done();
                    });
                });

                it("should be an exception when it is thrown exception", done -> {
                    Task.aborted(new Exception("error")).rescue(x -> throw "error2")
                    .onComplete(result -> switch (result) {
                        case Success(value): fail(value);
                        case Failure(error): fail(error);
                        case Abend(exception):
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
                Task.aborted(new Exception("error")).toPromise().catchError(x -> {
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
                    case Abend(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected value", done -> {
                final task:Task<Int, Void> = Promise.reject("error");
                task.onComplete(x -> switch (x) {
                    case Abend(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected Exception", done -> {
                final task:Task<Int, Void> = Promise.reject(new Exception("error"));
                task.onComplete(x -> switch (x) {
                    case Abend(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            #if js
            it("should convert from rejected JS Error", done -> {
                final task:Task<Int, Void> = Promise.reject(new js.lib.Error("error"));
                task.onComplete(x -> switch (x) {
                    case Abend(error):
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
                    case Abend(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            it("should convert from rejected Exception", done -> {
                final task:Task<Int, String> = (Promise.reject(new Exception("error")) : Promise<Either<String, Int>>);
                task.onComplete(x -> switch (x) {
                    case Abend(error):
                        error.message.should.be("error");
                        done();
                    case _: fail();
                });
            });

            #if js
            it("should convert from rejected JS Error", done -> {
                final task:Task<Int, String> = (Promise.reject(new js.lib.Error("error")) : Promise<Either<String, Int>>);
                task.onComplete(x -> switch (x) {
                    case Abend(error):
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

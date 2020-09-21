package exasync;

class TaskSuite extends BuddySuite {
    public function new() {
        describe("Task.new()", {
            timeoutMs = 100;

            #if js
            function suppress(error:Dynamic) {}

            beforeAll({
                js.Syntax.code("process.on('unhandledRejection', {0})", suppress);
            });
            afterAll({
                js.Syntax.code("process.removeListener('unhandledRejection', {0})", suppress);
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
                    new Task(function(_, _) {})
                    .onSuccess(_ -> fail())
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> fail());
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                it("should pass", {
                    new Task((fulfill, _) -> {
                        fulfill();
                    });
                });

                it("should pass when it is taken none fulfilled value", done -> {
                    var called = false;
                    new Task((fulfill, _) -> {
                        wait(5, fulfill.bind());
                    })
                    .onSuccess(_ -> called = true)
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is taken some fulfilled value", done -> {
                    var called = false;
                    new Task((fulfill, _) -> {
                        wait(5, fulfill.bind(1));
                    })
                    .onSuccess(x -> {
                        called = true;
                        x.should.be(1);
                    })
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });
            });

            describe("rejected", {
                it("should pass", {
                    new Task((_, reject) -> {
                        reject();
                    });
                });

                it("should pass when it is taken none rejected value", done -> {
                    var called = false;
                    new Task((_, reject) -> {
                        wait(5, reject.bind());
                    })
                    .onSuccess(_ -> fail())
                    .onFailure(e -> {
                        (e:Null<Any>).should.be(null);
                        called = true;
                    })
                    .onException(e -> fail(e))
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is taken some rejected value", done -> {
                    var called = false;
                    new Task((_, reject) -> {
                        wait(5, reject.bind("error"));
                    })
                    .onSuccess(_ -> fail())
                    .onFailure(e -> {
                        e.should.be("error");
                        called = true;
                    })
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is taken an Exception", done -> {
                    var called = false;
                    new Task((_, reject) -> {
                        reject(new Exception("error"));
                    })
                    .onSuccess(_ -> fail())
                    .onFailure(e -> {
                        e.message.should.be("error");
                        called = true;
                    })
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is thrown error", done -> {
                    var called = false;
                    new Task((_, reject) -> {
                        throw "error";
                    })
                    .onSuccess(_ -> fail())
                    .onFailure(e -> fail(e))
                    .onException(e -> {
                        e.message.should.be("error");
                        called = true;
                    })
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });
            });

            describe("Task.success()", {
                it("should pass when it is taken emtpty value", done -> {
                    var called = false;

                    Task.success()
                    .onSuccess(x -> {
                        (x:Null<Any>).should.be(null);
                        called = true;
                    })
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is taken some value", done -> {
                    var called = false;

                    Task.success(100)
                    .onSuccess(x -> {
                        x.should.be(100);
                        called = true;
                    })
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });
            });

            describe("Task.failure()", {
                it("should pass when it is taken emtpty rejected value", done -> {
                    var called = false;

                    Task.failure()
                    .onSuccess(_ -> fail())
                    .onFailure(e -> {
                        (e:Null<Any>).should.be(null);
                        called = true;
                    })
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });

                it("should pass when it is taken some rejected value", done -> {
                    var called = false;

                    Task.failure("error")
                    .onSuccess(_ -> fail())
                    .onFailure(e -> {
                        (e:String).should.be("error");
                        called = true;
                    })
                    .onException(_ -> fail())
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });
            });

            describe("Task.exception()", {
                it("should pass", done -> {
                    var called = false;

                    Task.exception(new Exception("error"))
                    .onSuccess(_ -> fail())
                    .onFailure(_ -> fail())
                    .onException(e -> {
                        e.message.should.be("error");
                        called = true;
                    })
                    .onFinally(() -> {
                        called.should.be(true);
                        done();
                    });
                });
            });

            });


        });
    }
}

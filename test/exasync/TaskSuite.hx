package exasync;

class TaskSuite extends BuddySuite {
    public function new() {
        describe("Task.new()", {
            timeoutMs = 100;

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
                    new Task(function(fulfill, _) {
                        fulfill();
                    });
                });

                it("should pass when it is taken no fulfilled value", done -> {
                    var called = false;
                    new Task(function(fulfill, _) {
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
                    new Task(function(fulfill, _) {
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


        });
    }
}

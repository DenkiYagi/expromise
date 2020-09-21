package exasync;

import buddy.BuddySuite;
import TestTools.wait;

using extools.EqualsTools;
using buddy.Should;

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

                it("should pass when it's taken no fulfilled value", done -> {
                    new Task(function(fulfill, _) {
                        fulfill();
                    })
                    .onSuccess(_ -> done())
                    .onFailure(_ -> fail())
                    .onException(_ -> fail())
                    .onFinally(() -> fail());
                });

                // it("should call fulfilled(_)",  done -> {
                //     new Task(function(fulfill, _) {
                //         fulfill();
                //     }).then(function(_) {
                //         done();
                //     }, function(_) {
                //         fail();
                //     });
                // });

                // it("should call fulfilled(x)",  done -> {
                //     new Task(function(fulfill, _) {
                //         fulfill(1);
                //     }).then(function(x) {
                //         x.should.be(1);
                //         done();
                //     }, function(_) {
                //         fail();
                //     });
                // });
            });


        });
    }
}

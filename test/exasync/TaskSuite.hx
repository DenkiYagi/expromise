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
                it("should call", function(done) {
                    new Task(function(_, _) {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", function(done) {
                    new Task(function(_, _) {}).toPromise().then(function(_) {
                        fail();
                    }, function(_) {
                        fail();
                    });
                    wait(5, done);
                });
            });




        });
    }
}

package exasync;

import haxe.Exception;
import buddy.BuddySuite;
import extype.Unit;
import TestTools.wait;

using extools.EqualsTools;
using buddy.Should;

class PromiseSuite extends BuddySuite {
    public function new() {
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

        describe("Promise.new()", {
            describe("executor", {
                it("should call", function(done) {
                    new Promise(function(_, _) {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", function(done) {
                    new Promise(function(_, _) {}).then(function(_) {
                        fail();
                    }, function(_) {
                        fail();
                    });
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                it("should pass", {
                    new Promise(function(fulfill, _) {
                        fulfill();
                    });
                });

                it("should pass when it have no fulfilled", {
                    new Promise(function(fulfill, _) {
                        fulfill();
                    }).then(null, function(_) {
                        fail();
                    });
                });

                it("should call fulfilled(_)", function(done) {
                    new Promise(function(fulfill, _) {
                        fulfill();
                    }).then(function(_) {
                        done();
                    }, function(_) {
                        fail();
                    });
                });

                it("should call fulfilled(x)", function(done) {
                    new Promise(function(fulfill, _) {
                        fulfill(1);
                    }).then(function(x) {
                        x.should.be(1);
                        done();
                    }, function(_) {
                        fail();
                    });
                });
            });

            describe("rejected", {
                it("should pass", {
                    new Promise(function(_, reject) {
                        reject();
                    });
                });

                it("should pass when it have no rejected", {
                    new Promise(function(_, reject) {
                        reject();
                    }).then(function(_) {
                        fail();
                    });
                });

                it("should call rejected(_)", function(done) {
                    new Promise(function(_, reject) {
                        reject();
                    }).then(function(_) {
                        fail();
                    }, function(e) {
                        (e == null).should.be(true);
                        done();
                    });
                });

                it("should call rejected(_)", function(done) {
                    new Promise(function(_, reject) {
                        reject();
                    }).then(function(_) {
                        fail();
                    }, function(e) {
                        (e == null).should.be(true);
                        done();
                    });
                });

                it("should call rejected(x)", function(done) {
                    new Promise(function(_, reject) {
                        reject("error");
                    }).then(function(_) {
                        fail();
                    }, function(e) {
                        (e : String).should.be("error");
                        done();
                    });
                });

                it("should call rejected when it is thrown error", function(done) {
                    new Promise(function(_, _) {
                        throw "error";
                    }).then(function(_) {
                        fail();
                    }, function(e) {
                        (e : Exception).message.should.be("error");
                        done();
                    });
                });
            });

            #if js
            describe("JavaScript compatibility", {
                it("should be js.lib.Promise", {
                    var promise = new Promise(function(_, _) {});
                    promise.should.beType(js.lib.Promise);
                });
            });
            #end
        });

        describe("Promise.resolve()", {
            it("should call resolved(_)", function(done) {
                Promise.resolve().then(function(_) {
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should call resolved(x)", function(done) {
                Promise.resolve(1).then(function(x) {
                    x.should.be(1);
                    done();
                }, function(_) {
                    fail();
                });
            });
        });

        describe("Promise.reject()", {
            it("should call rejected(x)", function(done) {
                Promise.reject("error").then(function(_) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should call rejected(_)", function(done) {
                Promise.reject("error").then(function(_) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("Promise.then()", {
            it("should call fulfilled", function(done) {
                new Promise(function(fulfill, _) {
                    fulfill(100);
                }).then(function(x) {
                    x.should.be(100);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should call rejected", function(done) {
                new Promise(function(_, reject) {
                    reject("error");
                }).then(function(_) {
                    fail();
                }, function(e) {
                    (e : String).should.be("error");
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return x + 1;
                        }).then(function(x) {
                            return x + 100;
                        }).then(function(x) {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", function(done) {
                        Promise.resolve(1).then(null, function(e) {
                            fail();
                            return -1;
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using Promise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return new Promise(function(f, _) f("hello"));
                        }).then(function(x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return Promise.resolve("hello");
                        }).then(function(x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return Promise.reject("error");
                        }).then(null, function(e) {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return SyncPromise.resolve("hello");
                        }).then(function(x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return SyncPromise.reject("error");
                        }).then(null, function(e) {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return js.lib.Promise.resolve("hello");
                        }).then(function(x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", function(done) {
                        Promise.resolve(1).then(function(x) {
                            return js.lib.Promise.reject("error");
                        }).then(null, function(e) {
                            (e : String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function(done) {
                        Promise.resolve(1).then(function(x):Unit {
                            throw "error";
                        }).then(null, function(e) {
                            (e : haxe.Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", function(done) {
                        Promise.reject("error").then(null, function(e) {
                            return 1;
                        }).then(function(x) {
                            return x + 100;
                        }).then(function(x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", function(done) {
                        Promise.reject("error").then(function(x) {
                            fail();
                            return -1;
                        }).then(null, function(e) {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return Promise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return Promise.reject("error");
                        }).then(null, function(e) {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return SyncPromise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return AbortablePromise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function(e) {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return js.lib.Promise.resolve("hello");
                        }).then(function(x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", function(done) {
                        Promise.reject("error").then(null, function(x) {
                            return js.lib.Promise.reject("rewrited error");
                        }).then(null, function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function(done) {
                        Promise.reject("error").then(null, function(x):Unit {
                            throw "rewrited error";
                        }).then(null, function(e) {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("Promise.catchError()", {
            it("should not call", function(done) {
                new Promise(function(fulfill, _) {
                    fulfill(100);
                }).catchError(function(_) {
                    fail();
                });
                wait(5, done);
            });

            it("should call", function(done) {
                new Promise(function(_, reject) {
                    reject("error");
                }).catchError(function(e) {
                    (e : String).should.be("error");
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", function(done) {
                        Promise.resolve(1).catchError(function(e) {
                            fail();
                            return -1;
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return 1;
                        }).then(function(x) {
                            return x + 100;
                        }).then(function(x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return Promise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return Promise.reject("rewrited error");
                        }).catchError(function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return SyncPromise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return AbortablePromise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return js.lib.Promise.resolve(1);
                        }).then(function(x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", function(done) {
                        Promise.reject("error").catchError(function(e) {
                            return js.lib.Promise.reject("rewrited error");
                        }).then(null, function(e) {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function(done) {
                        Promise.reject("error").catchError(function(e):Unit {
                            throw "rewrited error";
                        }).then(null, function(e) {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("Promise.finally()", {
            it("should call when it is fulfilled", function(done) {
                new Promise(function(fulfill, _) {
                    fulfill(100);
                }).finally(function() {
                    done();
                });
            });

            it("should call when it is rejected", function(done) {
                new Promise(function(_, reject) {
                    reject("error");
                }).finally(function() {
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", function(done) {
                        Promise.resolve(1).finally(function() {}).then(function(x) {
                            return x + 100;
                        }).then(function(x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", function(done) {
                        Promise.resolve(1).finally(function() {
                            throw "error";
                        }).catchError(function(e) {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", function(done) {
                        Promise.reject("error").finally(function() {}).catchError(function(e) {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", function(done) {
                        Promise.reject("error").finally(function() {
                            throw "rewrited error";
                        }).catchError(function(e) {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        #if js
        describe("Promise cast", {
            it("should cast from js.lib.Promise", function(done) {
                var jsPromise = js.lib.Promise.resolve(1);
                var promise:Promise<Int> = jsPromise;
                promise.then(function(v) {
                    v.should.be(1);
                    done();
                });
            });

            it("should cast to js.lib.Promise", function(done) {
                var promise = Promise.resolve(1);
                var jsPromise:js.lib.Promise<Int> = promise;
                jsPromise.then(function(v) {
                    EqualsTools.deepEqual(v, 1).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Promise.all()", {
            it("should resolve empty array", function(done) {
                Promise.all([]).then(function(values) {
                    EqualsTools.deepEqual(values, []).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should resolve", function(done) {
                Promise.all([Promise.resolve(1)]).then(function(values) {
                    EqualsTools.deepEqual(values, [1]).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should reject", function(done) {
                Promise.all([Promise.reject("error")]).then(function(values) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve ordered values", function(done) {
                Promise.all([
                    new Promise(function(f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function(values) {
                    EqualsTools.deepEqual(values, [1, 2, 3]).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should reject by 2nd promise", function(done) {
                Promise.all([
                    new Promise(function(_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function(_, r) {
                        wait(5, r.bind("error3"));
                    })
                ]).then(function(values) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error2").should.be(true);
                    done();
                });
            });

            it("should reject by 3rd promise", function(done) {
                Promise.all([Promise.resolve(1), Promise.resolve(2), Promise.reject("error3")]).then(function(values) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error3").should.be(true);
                    done();
                });
            });

            it("should process when it is mixed by Promise and Promise", function(done) {
                Promise.all([Promise.resolve(1), Promise.resolve(2)]).then(function(values) {
                    EqualsTools.deepEqual(values, [1, 2]).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });
        });

        describe("Promise.race()", {
            it("should be pending", function(done) {
                Promise.race([]).then(function(value) {
                    fail();
                }, function(_) {
                    fail();
                });
                wait(5, done);
            });

            it("should resolve", function(done) {
                Promise.race([Promise.resolve(1)]).then(function(value) {
                    EqualsTools.deepEqual(value, 1).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should reject", function(done) {
                Promise.race([Promise.reject("error")]).then(function(value) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve by 2nd promise", function(done) {
                Promise.race([
                    new Promise(function(f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function(value) {
                    value.should.be(2);
                    done();
                }, function(_) {
                    fail();
                });
            });

            it("should reject by 2nd promise", function(done) {
                Promise.race([
                    new Promise(function(_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function(_, r) {
                        wait(5, r.bind("error3"));
                    })
                ]).then(function(value) {
                    fail();
                }, function(e) {
                    EqualsTools.deepEqual(e, "error2").should.be(true);
                    done();
                });
            });

            it("should resolve by 1st promise", function(done) {
                Promise.race([Promise.resolve(1), Promise.resolve(2), Promise.reject("error3")]).then(function(value) {
                    EqualsTools.deepEqual(value, 1).should.be(true);
                    done();
                }, function(e) {
                    fail();
                });
            });

            it("should process when it is mixed by Promise and Promise", function(done) {
                Promise.race([Promise.resolve(1), Promise.resolve(2)]).then(function(values) {
                    EqualsTools.deepEqual(values, 1).should.be(true);
                    done();
                }, function(_) {
                    fail();
                });
            });
        });
    }
}

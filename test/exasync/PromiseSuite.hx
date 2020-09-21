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
                it("should call", done -> {
                    new Promise((_, _) -> {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", done -> {
                    new Promise((_, _) -> {}).then(_ -> {
                        fail();
                    }, _ -> {
                        fail();
                    });
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                it("should pass", {
                    new Promise((fulfill, _) -> {
                        fulfill();
                    });
                });

                it("should pass when it's taken no fulfilled value", done -> {
                    new Promise((fulfill, _) -> {
                        fulfill();
                    }).then(_ -> {
                        done();
                    }, _ -> {
                        fail();
                    });
                });

                it("should call fulfilled(x)", done -> {
                    new Promise((fulfill, _) -> {
                        fulfill(1);
                    }).then(x -> {
                        x.should.be(1);
                        done();
                    }, _ -> {
                        fail();
                    });
                });
            });

            describe("rejected", {
                it("should pass", {
                    new Promise((_, reject) -> {
                        reject();
                    });
                });

                it("should pass when it's taken no rejected value", done -> {
                    new Promise((_, reject) -> {
                        reject();
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e == null).should.be(true);
                        done();
                    });
                });

                it("should pass when it's taken some rejected value", done -> {
                    new Promise((_, reject) -> {
                        reject("error");
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e : String).should.be("error");
                        done();
                    });
                });

                it("should call rejected when it is thrown error", done -> {
                    new Promise((_, _) -> {
                        throw "error";
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e : Exception).message.should.be("error");
                        done();
                    });
                });
            });

            #if js
            describe("JavaScript compatibility", {
                it("should be js.lib.Promise", {
                    var promise = new Promise((_, _) -> {});
                    promise.should.beType(js.lib.Promise);
                });
            });
            #end
        });

        describe("Promise.resolve()", {
            it("should call resolved(_)", done -> {
                Promise.resolve().then(_ -> {
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should call resolved(x)", done -> {
                Promise.resolve(1).then(x -> {
                    x.should.be(1);
                    done();
                }, _ -> {
                    fail();
                });
            });
        });

        describe("Promise.reject()", {
            it("should call rejected(x)", done -> {
                Promise.reject("error").then(_ -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should call rejected(_)", done -> {
                Promise.reject("error").then(_ -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("Promise.then()", {
            it("should call fulfilled", done -> {
                new Promise((fulfill, _) -> {
                    fulfill(100);
                }).then(x -> {
                    x.should.be(100);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should call rejected", done -> {
                new Promise((_, reject) -> {
                    reject("error");
                }).then(_ -> {
                    fail();
                }, e -> {
                    (e : String).should.be("error");
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", done -> {
                        Promise.resolve(1).then(x -> {
                            x + 1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        Promise.resolve(1).then(null, e -> {
                            fail();
                            -1;
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using Promise", done -> {
                        Promise.resolve(1).then(x -> {
                            new Promise((f, _) -> f("hello"));
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        Promise.resolve(1).then(x -> {
                            Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        Promise.resolve(1).then(x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        Promise.resolve(1).then(x -> {
                            SyncPromise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        Promise.resolve(1).then(x -> {
                            SyncPromise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        Promise.resolve(1).then(x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        Promise.resolve(1).then(x -> {
                            js.lib.Promise.reject("error");
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        Promise.resolve(1).then(x -> {
                            throw "error";
                        }).then(null, e -> {
                            (e : haxe.Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", done -> {
                        Promise.reject("error").then(null, e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        Promise.reject("error").then(x -> {
                            fail();
                            -1;
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        Promise.reject("error").then(null, x -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        Promise.reject("error").then(null, x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        Promise.reject("error").then(null, x -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        Promise.reject("error").then(null, x -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        Promise.reject("error").then(null, x -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        Promise.reject("error").then(null, x -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        Promise.reject("error").then(null, x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        Promise.reject("error").then(null, x -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        Promise.reject("error").then(null, x -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("Promise.catchError()", {
            it("should not call", done -> {
                new Promise((fulfill, _) -> {
                    fulfill(100);
                }).catchError(_ -> {
                    fail();
                });
                wait(5, done);
            });

            it("should call", done -> {
                new Promise((_, reject) -> {
                    reject("error");
                }).catchError(e -> {
                    (e : String).should.be("error");
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", done -> {
                        Promise.resolve(1).catchError(e -> {
                            fail();
                            -1;
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", done -> {
                        Promise.reject("error").catchError(e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        Promise.reject("error").catchError(e -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        Promise.reject("error").catchError(e -> {
                            Promise.reject("rewrited error");
                        }).catchError(e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        Promise.reject("error").catchError(e -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        Promise.reject("error").catchError(e -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        Promise.reject("error").catchError(e -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        Promise.reject("error").catchError(e -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        Promise.reject("error").catchError(e -> {
                            js.lib.Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        Promise.reject("error").catchError(e -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        Promise.reject("error").catchError(e -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("Promise.finally()", {
            it("should call when it is fulfilled", done -> {
                new Promise((fulfill, _) -> {
                    fulfill(100);
                }).finally(() -> {
                    done();
                });
            });

            it("should call when it is rejected", done -> {
                new Promise((_, reject) -> {
                    reject("error");
                }).finally(() -> {
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", done -> {
                        Promise.resolve(1).finally(() -> {}).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        Promise.resolve(1).finally(() -> {
                            throw "error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", done -> {
                        Promise.reject("error").finally(() -> {}).catchError(e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        Promise.reject("error").finally(() -> {
                            throw "rewrited error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        #if js
        describe("Promise cast", {
            it("should cast from js.lib.Promise", done -> {
                var jsPromise = js.lib.Promise.resolve(1);
                var promise:Promise<Int> = jsPromise;
                promise.then(v -> {
                    v.should.be(1);
                    done();
                });
            });

            it("should cast to js.lib.Promise", done -> {
                var promise = Promise.resolve(1);
                var jsPromise:js.lib.Promise<Int> = promise;
                jsPromise.then(v -> {
                    EqualsTools.deepEqual(v, 1).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Promise.all()", {
            it("should resolve empty array", done -> {
                Promise.all([]).then(values -> {
                    EqualsTools.deepEqual(values, []).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should resolve", done -> {
                Promise.all([Promise.resolve(1)]).then(values -> {
                    EqualsTools.deepEqual(values, [1]).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should reject", done -> {
                Promise.all([Promise.reject("error")]).then(values -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve ordered values", done -> {
                Promise.all([
                    new Promise((f, _) -> {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(values -> {
                    EqualsTools.deepEqual(values, [1, 2, 3]).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should reject by 2nd promise", done -> {
                Promise.all([
                    new Promise((_, r) -> {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise((_, r) -> {
                        wait(5, r.bind("error3"));
                    })
                ]).then(values -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error2").should.be(true);
                    done();
                });
            });

            it("should reject by 3rd promise", done -> {
                Promise.all([Promise.resolve(1), Promise.resolve(2), Promise.reject("error3")]).then(values -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error3").should.be(true);
                    done();
                });
            });

            it("should process when it is mixed by Promise and Promise", done -> {
                Promise.all([Promise.resolve(1), Promise.resolve(2)]).then(values -> {
                    EqualsTools.deepEqual(values, [1, 2]).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });
        });

        describe("Promise.race()", {
            it("should be pending", done -> {
                Promise.race([]).then(value -> {
                    fail();
                }, _ -> {
                    fail();
                });
                wait(5, done);
            });

            it("should resolve", done -> {
                Promise.race([Promise.resolve(1)]).then(value -> {
                    EqualsTools.deepEqual(value, 1).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should reject", done -> {
                Promise.race([Promise.reject("error")]).then(value -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve by 2nd promise", done -> {
                Promise.race([
                    new Promise((f, _) -> {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(value -> {
                    value.should.be(2);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should reject by 2nd promise", done -> {
                Promise.race([
                    new Promise((_, r) -> {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise((_, r) -> {
                        wait(5, r.bind("error3"));
                    })
                ]).then(value -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error2").should.be(true);
                    done();
                });
            });

            it("should resolve by 1st promise", done -> {
                Promise.race([Promise.resolve(1), Promise.resolve(2), Promise.reject("error3")]).then(value -> {
                    EqualsTools.deepEqual(value, 1).should.be(true);
                    done();
                }, e -> {
                    fail();
                });
            });

            it("should process when it is mixed by Promise and Promise", done -> {
                Promise.race([Promise.resolve(1), Promise.resolve(2)]).then(values -> {
                    EqualsTools.deepEqual(values, 1).should.be(true);
                    done();
                }, _ -> {
                    fail();
                });
            });
        });
    }
}

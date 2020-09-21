package exasync;

import haxe.Exception;
import buddy.BuddySuite;
import TestTools.wait;

using extools.EqualsTools;
using buddy.Should;

class AbortablePromiseSuite extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("AbortablePromise.new()", {
            describe("executor", {
                it("should call", done -> {
                    new AbortablePromise((_, _) -> {
                        done();
                        () -> {};
                    });
                });
            });

            describe("pending", {
                it("should be not completed", done -> {
                    new AbortablePromise((_, _) -> {
                        () -> {};
                    }).then(_ -> {
                        fail();
                    }, _ -> {
                        fail();
                    });
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                describe("sync", {
                    it("should pass", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            fulfill();
                            () -> {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it's taken no fulfilled value", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            fulfill();
                            () -> {};
                        }).then(_ -> {
                            done();
                        }, _ -> {
                            fail();
                        });
                    });

                    it("should call fulfilled(x)", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            fulfill(1);
                            () -> {};
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        }, _ -> {
                            fail();
                        });
                    });
                });

                describe("async", {
                    it("should pass", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            wait(5, fulfill.bind());
                            () -> {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it's taken no fulfilled value", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            wait(5, fulfill.bind());
                            () -> {};
                        }).then(_ -> {
                            done();
                        }, _ -> {
                            fail();
                        });
                    });

                    it("should pass when it's taken some fulfilled value", done -> {
                        new AbortablePromise((fulfill, _) -> {
                            wait(5, fulfill.bind(1));
                            () -> {};
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        }, _ -> {
                            fail();
                        });
                    });
                });
            });

            describe("rejected", {
                describe("sync", {
                    it("should pass", done -> {
                        new AbortablePromise((_, reject) -> {
                            reject();
                            () -> {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it's taken no rejected value", done -> {
                        new AbortablePromise((_, reject) -> {
                            reject();
                            () -> {};
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            (e == null).should.be(true);
                            done();
                        });
                    });

                    it("should pass when it's taken some rejected value", done -> {
                        new AbortablePromise((_, reject) -> {
                            reject("error");
                            () -> {};
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should call rejected when it is thrown error", done -> {
                        new AbortablePromise((_, _) -> {
                            throw "error";
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("async", {
                    it("should pass", done -> {
                        new AbortablePromise((_, reject) -> {
                            wait(5, reject.bind());
                            () -> {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no rejected", done -> {
                        new AbortablePromise((_, reject) -> {
                            wait(5, reject.bind());
                            () -> {};
                        }).then(_ -> {
                            fail();
                        });
                        wait(5, done);
                    });

                    it("should call rejected(_)", done -> {
                        new AbortablePromise((_, reject) -> {
                            wait(5, reject.bind());
                            () -> {};
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            (e == null).should.be(true);
                            done();
                        });
                    });

                    it("should call rejected(_)", done -> {
                        new AbortablePromise((_, reject) -> {
                            wait(5, reject.bind());
                            () -> {};
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            (e == null).should.be(true);
                            done();
                        });
                    });

                    it("should call rejected(x)", done -> {
                        new AbortablePromise((_, reject) -> {
                            wait(5, reject.bind("error"));
                            () -> {};
                        }).then(_ -> {
                            fail();
                        }, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });
                });
            });

            #if js
            describe("JavaScript compatibility", {
                it("should be js.lib.Promise", {
                    var AbortablePromise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    AbortablePromise.should.beType(js.lib.Promise);
                });
            });
            #end
        });

        describe("AbortablePromise.resolve()", {
            it("should call resolved(_)", done -> {
                AbortablePromise.resolve().then(_ -> {
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should call resolved(x)", done -> {
                AbortablePromise.resolve(1).then(x -> {
                    x.should.be(1);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should not abort", done -> {
                var promise = AbortablePromise.resolve(1);
                promise.abort();
                promise.then(x -> {
                    x.should.be(1);
                    done();
                }, e -> {
                    fail();
                });
            });
        });

        describe("AbortablePromise.reject()", {
            it("should call rejected(x)", done -> {
                AbortablePromise.reject("error").then(_ -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should call rejected(_)", done -> {
                AbortablePromise.reject("error").then(_ -> {
                    fail();
                }, e -> {
                    EqualsTools.deepEqual(e, "error").should.be(true);
                    done();
                });
            });

            it("should not abort", done -> {
                var promise = AbortablePromise.reject("hello");
                promise.abort();
                promise.then(x -> {
                    fail();
                    done();
                }, e -> {
                    (e : String).should.be("hello");
                    done();
                });
            });
        });

        describe("AbortablePromise.then()", {
            describe("sync", {
                it("should call fulfilled", done -> {
                    var called = false;
                    new AbortablePromise((fulfill, _) -> {
                        fulfill(100);
                        () -> {};
                    }).then(x -> {
                        x.should.be(100);
                        called = true;
                        wait(5, done);
                    }, _ -> {
                        fail();
                    });
                    called.should.be(false);
                });

                it("should call rejected", done -> {
                    var called = false;
                    new AbortablePromise((_, reject) -> {
                        reject("error");
                        () -> {};
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e : String).should.be("error");
                        called = true;
                        wait(5, done);
                    });
                    called.should.be(false);
                });
            });

            describe("async", {
                it("should call fulfilled", done -> {
                    var called = false;
                    new AbortablePromise((fulfill, _) -> {
                        wait(5, () -> {
                            fulfill(100);
                        });
                        () -> {};
                    }).then(x -> {
                        x.should.be(100);
                        called = true;
                        wait(5, done);
                    }, _ -> {
                        fail();
                    });
                    called.should.be(false);
                });

                it("should call rejected", done -> {
                    var called = false;
                    new AbortablePromise((_, reject) -> {
                        wait(5, () -> {
                            reject("error");
                        });
                        () -> {};
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e : String).should.be("error");
                        called = true;
                        wait(5, done);
                    });
                    called.should.be(false);
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            x + 1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        AbortablePromise.resolve(1).then(null, e -> {
                            fail();
                            -1;
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            SyncPromise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            SyncPromise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            js.lib.Promise.reject("error");
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        AbortablePromise.resolve(1).then(x -> {
                            throw "error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", done -> {
                        AbortablePromise.reject("error").then(null, e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        AbortablePromise.reject("error").then(x -> {
                            fail();
                            -1;
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        AbortablePromise.reject("error").then(null, x -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.catchError()", {
            describe("sync", {
                it("should not call", done -> {
                    new AbortablePromise((fulfill, _) -> {
                        fulfill(100);
                        () -> {};
                    }).catchError(_ -> {
                        fail();
                    });
                    wait(5, done);
                });

                it("should call", done -> {
                    var called = false;
                    new AbortablePromise((_, reject) -> {
                        reject("error");
                        () -> {};
                    }).catchError(e -> {
                        (e : String).should.be("error");
                        called = true;
                        wait(5, done);
                    });
                    called.should.be(false);
                });
            });

            describe("async", {
                it("should not call", done -> {
                    new AbortablePromise((fulfill, _) -> {
                        wait(5, () -> {
                            fulfill(100);
                        });
                        () -> {};
                    }).catchError(_ -> {
                        fail();
                    });
                    wait(5, done);
                });

                it("should call", done -> {
                    new AbortablePromise((_, reject) -> {
                        wait(5, () -> {
                            reject("error");
                        });
                        () -> {};
                    }).catchError(e -> {
                        (e : String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", done -> {
                        AbortablePromise.resolve(1).catchError(e -> {
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
                        AbortablePromise.reject("error").catchError(e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            Promise.reject("rewrited error");
                        }).catchError(e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            js.lib.Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        AbortablePromise.reject("error").catchError(e -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.finally()", {
            describe("sync", {
                it("should call when it is fulfilled", done -> {
                    new AbortablePromise((fulfill, _) -> {
                        fulfill(100);
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });

                it("should call when it is rejected", done -> {
                    new AbortablePromise((_, reject) -> {
                        reject("error");
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });
            });

            describe("async", {
                it("should call when it is fulfilled", done -> {
                    new AbortablePromise((fulfill, _) -> {
                        wait(5, () -> {
                            fulfill(100);
                        });
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });

                it("should call when it is rejected", done -> {
                    new AbortablePromise((_, reject) -> {
                        wait(5, () -> {
                            reject("error");
                        });
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", done -> {
                        AbortablePromise.resolve(1).finally(() -> {}).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        AbortablePromise.resolve(1).finally(() -> {
                            throw "error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", done -> {
                        AbortablePromise.reject("error").finally(() -> {}).catchError(e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        AbortablePromise.reject("error").finally(() -> {
                            throw "rewrited error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.abort()", {
            describe("before execution", {
                it("should call rejected that is set before abort()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                    promise.abort();
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.abort();
                    promise.catchError(e -> {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                });

                it("should pass when it is called abort() 2-times", {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.abort();
                    promise.abort();
                });

                it("should not apply fulfill() when it is aborted", done -> {
                    var promise = new AbortablePromise((f, _) -> {
                        wait(5, f.bind(1));
                        () -> {};
                    });
                    promise.abort();
                    wait(10, () -> {
                        promise.catchError(e -> {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });

                it("should not apply reject() when it is aborted", done -> {
                    var promise = new AbortablePromise((_, r) -> {
                        wait(5, r.bind("error"));
                        () -> {};
                    });
                    promise.abort();
                    wait(10, () -> {
                        promise.catchError(e -> {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });
            });

            describe("pending call the abort callback", {
                it("should call onAbort", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {
                            done();
                        }
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                });

                it("should call rejected that is set before abort()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.abort();
                        promise.catchError(e -> {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var count = 0;
                    var promise = new AbortablePromise((_, _) -> {
                        () -> {
                            count++;
                        };
                    });
                    wait(5, () -> {
                        promise.abort();
                        count.should.be(1);
                    });
                    wait(10, () -> {
                        promise.abort();
                        count.should.be(1);
                        done();
                    });
                });
            });

            describe("fulfilled", {
                it("should not call the abort callback", done -> {
                    var promise = new AbortablePromise((f, _) -> {
                        f(1);
                        () -> {
                            fail();
                        }
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                    wait(10, done);
                });

                it("should call resolved that is set before abort()", done -> {
                    var promise = new AbortablePromise((f, _) -> {
                        f(1);
                        () -> {};
                    });
                    promise.then(x -> {
                        (x : Int).should.be(1);
                        done();
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                });

                it("should call resolved that is set after abort()", done -> {
                    var promise = new AbortablePromise((f, _) -> {
                        f(1);
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.abort();
                        promise.then(x -> {
                            (x : Int).should.be(1);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var promise = new AbortablePromise((f, _) -> {
                        f(1);
                        () -> {
                            fail();
                        };
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                    wait(10, () -> {
                        promise.abort();
                        done();
                    });
                });
            });

            describe("rejected", {
                it("should not call the abort callback", done -> {
                    var promise = new AbortablePromise((_, r) -> {
                        r("error");
                        () -> {
                            fail();
                        }
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                    wait(10, done);
                });

                it("should call rejected that is set before abort()", done -> {
                    var promise = new AbortablePromise((_, r) -> {
                        r("error");
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, AbortedError).should.be(false);
                        (e : String).should.be("error");
                        done();
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new AbortablePromise((_, r) -> {
                        r("error");
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.abort();
                        promise.catchError(e -> {
                            Std.is(e, AbortedError).should.be(false);
                            (e : String).should.be("error");
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var promise = new AbortablePromise((_, r) -> {
                        r("error");
                        () -> {
                            fail();
                        };
                    });
                    wait(5, () -> {
                        promise.abort();
                    });
                    wait(10, () -> {
                        promise.abort();
                        done();
                    });
                });
            });

            describe("chain", {
                it("should pass when it is using then()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        done;
                    }).then(_ -> {});

                    wait(5, promise.abort);
                });

                it("should pass when it is using catchError()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        done;
                    }).catchError(_ -> {});

                    wait(5, promise.abort);
                });

                it("should pass when it is using finally()", done -> {
                    var promise = new AbortablePromise((_, _) -> {
                        done;
                    }).finally(() -> {});

                    wait(5, promise.abort);
                });
            });
        });
    }
}

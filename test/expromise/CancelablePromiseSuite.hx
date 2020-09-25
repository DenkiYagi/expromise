package expromise;

class CancelablePromiseSuite extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("CancelablePromise.new()", {
            describe("executor", {
                it("should call", done -> {
                    new CancelablePromise((_, _) -> {
                        done();
                        () -> {};
                    });
                });
            });

            describe("pending", {
                it("should be not completed", done -> {
                    new CancelablePromise((_, _) -> {
                        () -> {};
                    }).then(_ -> {
                        fail();
                    }, _ -> {
                        fail();
                    });
                    wait(5, done);
                });
            });

            describe("result: fulfilled", {
                it("should pass with sync executor", done -> {
                    new CancelablePromise((fulfill, _) -> {
                        fulfill(1);
                        () -> {};
                    }).then(x -> {
                        x.should.be(1);
                        done();
                    }, _ -> {
                        fail();
                    });
                });

                it("should pass with async executor", done -> {
                    new CancelablePromise((fulfill, _) -> {
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

            describe("result: rejected", {
                it("should pass with sync executor", done -> {
                    new CancelablePromise((_, reject) -> {
                        reject("error");
                        () -> {};
                    }).then(_ -> {
                        fail();
                    }, e -> {
                        (e:String).should.be("error");
                        done();
                    });
                });

                it("should pass with async executor", done -> {
                    new CancelablePromise((_, reject) -> {
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

            #if js
            describe("JavaScript compatibility", {
                it("should be js.lib.Promise", {
                    var CancelablePromise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    CancelablePromise.should.beType(js.lib.Promise);
                });
            });
            #end
        });

        describe("CancelablePromise.resolve()", {
            it("should pass when it is taken empty value", done -> {
                CancelablePromise.resolve().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                }, _ -> {
                    fail();
                });
            });

            it("should pass when it is taken some value", done -> {
                CancelablePromise.resolve(1).then(x -> {
                    x.should.be(1);
                    done();
                }, _ -> {
                    fail();
                });
            });
        });

        describe("CancelablePromise.reject()", {
            it("should pass when is taken empty rejected value", done -> {
                CancelablePromise.reject().then(_ -> {
                    fail();
                }, e -> {
                    (e:Null<Any>).should.be(null);
                    done();
                });
            });

            it("should call rejected(x)", done -> {
                CancelablePromise.reject("error").then(_ -> {
                    fail();
                }, e -> {
                    (e : String).should.be("error");
                    done();
                });
            });
        });

        describe("CancelablePromise.then()", {
            describe("from pending", {
                it("should not call", done -> {
                    new CancelablePromise((_, _) -> () -> {}).then(_ -> fail(), _ -> fail());
                    wait(5, done);
                });
            });

            describe("from fulfilled", {
                it("should call onFulfilled when it is taken empty value", done -> {
                    CancelablePromise.resolve().then(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                    }, _ -> fail());
                });

                it("should call onFulfilled when it is taken some value", done -> {
                    CancelablePromise.resolve(100).then(x -> {
                        x.should.be(100);
                        done();
                    }, _ -> fail());
                });
            });

            describe("from rejected", {
                it("should call onRejected when it is taken empty value", done -> {
                    CancelablePromise.reject().then(x -> fail(), e -> {
                        (e:Null<Any>).should.be(null);
                        done();
                    });
                });

                it("should call onRejected when it is taken some value", done -> {
                    CancelablePromise.reject("error").then(x -> fail(), e -> {
                        (e:String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            x + 1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        CancelablePromise.resolve(1).then(null, e -> {
                            fail();
                            -1;
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            js.lib.Promise.reject("error");
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        CancelablePromise.resolve(1).then(x -> {
                            throw "error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", done -> {
                        CancelablePromise.reject("error").then(null, e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        CancelablePromise.reject("error").then(x -> {
                            fail();
                            -1;
                        }).then(null, e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved CancelablePromise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            CancelablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected CancelablePromise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            CancelablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        CancelablePromise.reject("error").then(null, x -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("CancelablePromise.catchError()", {
            describe("sync", {
                it("should not call", done -> {
                    new CancelablePromise((fulfill, _) -> {
                        fulfill(100);
                        () -> {};
                    }).catchError(_ -> {
                        fail();
                    });
                    wait(5, done);
                });

                it("should call", done -> {
                    var called = false;
                    new CancelablePromise((_, reject) -> {
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
                    new CancelablePromise((fulfill, _) -> {
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
                    new CancelablePromise((_, reject) -> {
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
                        CancelablePromise.resolve(1).catchError(e -> {
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
                        CancelablePromise.reject("error").catchError(e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            Promise.reject("rewrited error");
                        }).catchError(e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved CancelablePromise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            CancelablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected CancelablePromise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            CancelablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            js.lib.Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e : String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        CancelablePromise.reject("error").catchError(e -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("CancelablePromise.finally()", {
            describe("sync", {
                it("should call when it is fulfilled", done -> {
                    new CancelablePromise((fulfill, _) -> {
                        fulfill(100);
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });

                it("should call when it is rejected", done -> {
                    new CancelablePromise((_, reject) -> {
                        reject("error");
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });
            });

            describe("async", {
                it("should call when it is fulfilled", done -> {
                    new CancelablePromise((fulfill, _) -> {
                        wait(5, () -> {
                            fulfill(100);
                        });
                        () -> {};
                    }).finally(() -> {
                        done();
                    });
                });

                it("should call when it is rejected", done -> {
                    new CancelablePromise((_, reject) -> {
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
                        CancelablePromise.resolve(1).finally(() -> {}).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        CancelablePromise.resolve(1).finally(() -> {
                            throw "error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", done -> {
                        CancelablePromise.reject("error").finally(() -> {}).catchError(e -> {
                            (e : String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        CancelablePromise.reject("error").finally(() -> {
                            throw "rewrited error";
                        }).catchError(e -> {
                            (e : Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });


        describe("CancelablePromise.tap()", {
            it("should chain from fulfilled", done -> {
                CancelablePromise.resolve(100).tap(x -> {
                    x.should.be(100);
                })
                .then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should chain from fulfilled if tap func throws error", done -> {
                CancelablePromise.resolve(100).tap(x -> {
                    x.should.be(100);
                    throw "error";
                })
                .then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should never call from rejected", done -> {
                CancelablePromise.reject("error").tap(x -> {
                    fail();
                })
                .catchError(e -> {
                    (e:String).should.be("error");
                    done();
                });
            });
        });

        describe("CancelablePromise.tapError()", {
            it("should chain from rejected", done -> {
                CancelablePromise.reject("error").tapError(e -> {
                    (e:String).should.be("error");
                })
                .catchError(e -> {
                    (e:String).should.be("error");
                    done();
                });
            });

            it("should chain from rejected if tapError func throws error", done -> {
                CancelablePromise.reject("error").tapError(e -> {
                    (e:String).should.be("error");
                    throw "error inner";
                })
                .catchError(e -> {
                    (e:String).should.be("error");
                    done();
                });
            });

            it("should never call from fulfilled", done -> {
                CancelablePromise.resolve(100).tapError(x -> {
                    fail();
                })
                .then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("Cancelablepromise.cancel()", {
            describe("before execution", {
                it("should call rejected that is set before abort()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, CanceledException).should.be(true);
                        done();
                    });
                    promise.cancel();
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.cancel();
                    promise.catchError(e -> {
                        Std.is(e, CanceledException).should.be(true);
                        done();
                    });
                });

                it("should pass when it is called abort() 2-times", {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.cancel();
                    promise.cancel();
                });

                it("should not apply fulfill() when it is aborted", done -> {
                    var promise = new CancelablePromise((f, _) -> {
                        wait(5, f.bind(1));
                        () -> {};
                    });
                    promise.cancel();
                    wait(10, () -> {
                        promise.catchError(e -> {
                            Std.is(e, CanceledException).should.be(true);
                            done();
                        });
                    });
                });

                it("should not apply reject() when it is aborted", done -> {
                    var promise = new CancelablePromise((_, r) -> {
                        wait(5, r.bind("error"));
                        () -> {};
                    });
                    promise.cancel();
                    wait(10, () -> {
                        promise.catchError(e -> {
                            Std.is(e, CanceledException).should.be(true);
                            done();
                        });
                    });
                });
            });

            describe("pending call the abort callback", {
                it("should call onAbort", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {
                            done();
                        }
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                });

                it("should call rejected that is set before abort()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, CanceledException).should.be(true);
                        done();
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.cancel();
                        promise.catchError(e -> {
                            Std.is(e, CanceledException).should.be(true);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var count = 0;
                    var promise = new CancelablePromise((_, _) -> {
                        () -> {
                            count++;
                        };
                    });
                    wait(5, () -> {
                        promise.cancel();
                        count.should.be(1);
                    });
                    wait(10, () -> {
                        promise.cancel();
                        count.should.be(1);
                        done();
                    });
                });
            });

            describe("fulfilled", {
                it("should not call the abort callback", done -> {
                    var promise = new CancelablePromise((f, _) -> {
                        f(1);
                        () -> {
                            fail();
                        }
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                    wait(10, done);
                });

                it("should call resolved that is set before abort()", done -> {
                    var promise = new CancelablePromise((f, _) -> {
                        f(1);
                        () -> {};
                    });
                    promise.then(x -> {
                        (x : Int).should.be(1);
                        done();
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                });

                it("should call resolved that is set after abort()", done -> {
                    var promise = new CancelablePromise((f, _) -> {
                        f(1);
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.cancel();
                        promise.then(x -> {
                            (x : Int).should.be(1);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var promise = new CancelablePromise((f, _) -> {
                        f(1);
                        () -> {
                            fail();
                        };
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                    wait(10, () -> {
                        promise.cancel();
                        done();
                    });
                });
            });

            describe("rejected", {
                it("should not call the abort callback", done -> {
                    var promise = new CancelablePromise((_, r) -> {
                        r("error");
                        () -> {
                            fail();
                        }
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                    wait(10, done);
                });

                it("should call rejected that is set before abort()", done -> {
                    var promise = new CancelablePromise((_, r) -> {
                        r("error");
                        () -> {};
                    });
                    promise.catchError(e -> {
                        Std.is(e, CanceledException).should.be(false);
                        (e : String).should.be("error");
                        done();
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                });

                it("should call rejected that is set after abort()", done -> {
                    var promise = new CancelablePromise((_, r) -> {
                        r("error");
                        () -> {};
                    });
                    wait(5, () -> {
                        promise.cancel();
                        promise.catchError(e -> {
                            Std.is(e, CanceledException).should.be(false);
                            (e : String).should.be("error");
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", done -> {
                    var promise = new CancelablePromise((_, r) -> {
                        r("error");
                        () -> {
                            fail();
                        };
                    });
                    wait(5, () -> {
                        promise.cancel();
                    });
                    wait(10, () -> {
                        promise.cancel();
                        done();
                    });
                });
            });

            describe("chain", {
                it("should pass when it is using then()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        done;
                    }).then(_ -> {});

                    wait(5, promise.cancel);
                });

                it("should pass when it is using catchError()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        done;
                    }).catchError(_ -> {});

                    wait(5, promise.cancel);
                });

                it("should pass when it is using finally()", done -> {
                    var promise = new CancelablePromise((_, _) -> {
                        done;
                    }).finally(() -> {});

                    wait(5, promise.cancel);
                });
            });
        });
    }
}

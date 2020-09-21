package exasync;

class SyncPromiseSuite extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("SyncPromise.new()", {
            describe("executor", {
                it("should call", done -> {
                    new SyncPromise((_, _) -> {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", {
                    new SyncPromise((_, _) -> {}).then(
                        _ -> { fail(); },
                        _ -> { fail(); }
                    );
                });
            });

            describe("result: fulfilled", {
                it("should pass", {
                    new SyncPromise((fulfill, _) -> {
                        fulfill();
                    });
                });

                it("should pass when it is taken none fulfilled value", done -> {
                    new SyncPromise((fulfill, _) -> {
                        wait(5, fulfill.bind());
                    }).then(
                        _ -> { done(); },
                        _ -> { fail(); }
                    );
                });

                it("should pass when it is taken some fulfilled value", done -> {
                    new SyncPromise((fulfill, _) -> {
                        wait(5, fulfill.bind(1));
                    }).then(
                        x -> {
                            x.should.be(1);
                            done();
                        },
                        _ -> { fail(); }
                    );
                });
            });

            describe("result: rejected", {
                it("should pass", {
                    new SyncPromise((_, reject) -> {
                        reject();
                    });
                });

                it("should pass when it is takens none rejected value", done -> {
                    new SyncPromise((_, reject) -> {
                        wait(5, reject.bind());
                    }).then(
                        _ -> { fail(); },
                        e -> {
                            (e == null).should.be(true);
                            done();
                        }
                    );
                });

                it("should pass when it is takens some rejected value", done -> {
                    new SyncPromise((_, reject) -> {
                        wait(5, reject.bind("error"));
                    }).then(
                        _ -> { fail(); },
                        e -> {
                            (e: String).should.be("error");
                            done();
                        }
                    );
                });

                it("should pass when it is thrown error", done -> {
                    new SyncPromise((_, _) -> {
                        throw "error";
                    }).then(
                        _ -> { fail(); },
                        e -> {
                            (e: Exception).message.should.be("error");
                            done();
                        }
                    );
                });
            });

            #if js
            describe("JavaScript compatibility", {
                it("should be js.lib.Promise", {
                    var promise = new SyncPromise((_, _) -> {});
                    promise.should.beType(js.lib.Promise);
                });
            });
            #end
        });

        describe("SyncPromise.resolve()", {
            it("should pass when it is taken empty value", done -> {
                SyncPromise.resolve().then(
                    x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                    },
                    _ -> { fail(); }
                );
            });

            it("should pass when it is taken some value", done -> {
                SyncPromise.resolve(1).then(
                    x -> {
                        x.should.be(1);
                        done();
                    },
                    _ -> { fail(); }
                );
            });
        });

        describe("SyncPromise.reject()", {
            it("should pass when is taken empty rejected value", done -> {
                SyncPromise.reject().then(
                    _ -> { fail(); },
                    e -> {
                        (e:Null<Any>).should.be(null);
                        done();
                    }
                );
            });

            it("should call rejected(x)", done -> {
                SyncPromise.reject("error").then(
                    _ -> { fail(); },
                    e -> {
                        (e : String).should.be("error");
                        done();
                    }
                );
            });
        });

        describe("SyncPromise.then()", {
            describe("from pending", {
                it("should not call", done -> {
                    new SyncPromise((_, _) -> {}).then(_ -> fail(), _ -> fail());
                    wait(5, done);
                });
            });

            describe("from fulfilled", {
                it("should call onFulfilled when it is taken empty value", done -> {
                    SyncPromise.resolve().then(x -> {
                        (x:Null<Any>).should.be(null);
                        done();
                    }, _ -> fail());
                });

                it("should call onFulfilled when it is taken some value", done -> {
                    SyncPromise.resolve(100).then(x -> {
                        x.should.be(100);
                        done();
                    }, _ -> fail());
                });
            });

            describe("from rejected", {
                it("should call onRejected when it is taken empty value", done -> {
                    SyncPromise.reject().then(x -> fail(), e -> {
                        (e:Null<Any>).should.be(null);
                        done();
                    });
                });

                it("should call onRejected when it is taken some value", done -> {
                    SyncPromise.reject("error").then(x -> fail(), e -> {
                        (e:String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            x + 1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        SyncPromise.resolve(1)
                        .then(null, e -> {
                            fail();
                            -1;
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            SyncPromise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            SyncPromise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            js.lib.Promise.reject("error");
                        }).then(null, e -> {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        SyncPromise.resolve(1)
                        .then(x -> {
                            throw "error";
                        }).then(null, e -> {
                            (e: Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", done -> {
                        SyncPromise.reject("error")
                        .then(null, e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", done -> {
                        SyncPromise.reject("error")
                        .then(x -> {
                            fail();
                            -1;
                        }).then(null, e -> {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            Promise.reject("error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            EqualsTools.deepEqual(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            js.lib.Promise.resolve("hello");
                        }).then(x -> {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        SyncPromise.reject("error")
                        .then(null, x -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e: Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("SyncPromise.catchError()", {
            it("should not call", done -> {
                new SyncPromise((fulfill, _) -> {
                    fulfill(100);
                }).catchError(_ -> {
                    fail();
                });
                wait(5, done);
            });

            it("should call", done -> {
                new SyncPromise((_, reject) -> {
                    reject("error");
                }).catchError(e -> {
                    (e: String).should.be("error");
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", done -> {
                        SyncPromise.resolve(1)
                        .catchError(e -> {
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
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            1;
                        }).then(x -> {
                            x + 100;
                        }).then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            Promise.reject("rewrited error");
                        }).catchError(e -> {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            SyncPromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            SyncPromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            AbortablePromise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            AbortablePromise.reject("rewrited error");
                        }).then(null, e -> {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.lib.Promise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            js.lib.Promise.resolve(1);
                        }).then(x -> {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.lib.Promise", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            js.lib.Promise.reject("rewrited error");
                        }).then(null, e -> {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", done -> {
                        SyncPromise.reject("error")
                        .catchError(e -> {
                            throw "rewrited error";
                        }).then(null, e -> {
                            (e: Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("SyncPromise.finally()", {
            it("should call when it is fulfilled", done -> {
                new SyncPromise((fulfill, _) -> {
                    fulfill(100);
                }).finally(() -> {
                    done();
                });
            });

            it("should call when it is rejected", done -> {
                new SyncPromise((_, reject) -> {
                    reject("error");
                }).finally(() -> {
                    done();
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", done -> {
                        SyncPromise.resolve(1)
                        .finally(() -> {})
                        .then(x -> {
                            x + 100;
                        })
                        .then(x -> {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        SyncPromise.resolve(1)
                        .finally(() -> {
                            throw "error";
                        })
                        .catchError(e -> {
                            (e: Exception).message.should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", done -> {
                        SyncPromise.reject("error")
                        .finally(() -> {})
                        .catchError(e -> {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", done -> {
                        SyncPromise.reject("error")
                        .finally(() -> {
                            throw "rewrited error";
                        })
                        .catchError(e -> {
                            (e: Exception).message.should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });
    }
}

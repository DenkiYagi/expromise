package expromise;

import extype.Maybe;
import extype.NoDataException;

using expromise.MaybePromise;

class MaybePromiseSuite extends BuddySuite {
    public function new() {
        describe("MaybePromise.thenToNullable()", {
            it("should convert to Some(value)", done -> {
                MaybePromise.resolveSome(100).thenToNullable().then(x -> {
                    x.nonEmpty().should.be(true);
                    x.getOrThrow().should.be(100);
                    done();
                });
            });

            it("should convert to None", done -> {
                MaybePromise.resolveNone().thenToNullable().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromise.thenIsEmpty()", {
            it("should return false", done -> {
                MaybePromise.resolveSome(100).thenIsEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });

            it("should return true", done -> {
                MaybePromise.resolveNone().thenIsEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromise.thenNonEmpty()", {
            it("should return false", done -> {
                MaybePromise.resolveSome(100).thenNonEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });

            it("should return true", done -> {
                MaybePromise.resolveNone().thenNonEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromise.thenGet()", {
            it("should convert to value", done -> {
                MaybePromise.resolveSome("hello").thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                MaybePromise.resolveNone().thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("MaybePromise.thenGetUnsafe()", {
            it("should convert to value", done -> {
                MaybePromise.resolveSome(100).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("MaybePromise.thenGetOrThrow()", {
            it("should convert to value", done -> {
                MaybePromise.resolveSome(100).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                MaybePromise.resolveNone().thenGetOrThrow().catchError(e -> {
                    Std.isOfType(e, NoDataException).should.be(true);
                    done();
                });
            });

            it("should be rejected", done -> {
                MaybePromise.resolveNone().thenGetOrThrow(() -> "error").catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });
        });

        describe("MaybePromise.thenGetOrElse()", {
            it("should return value", done -> {
                MaybePromise.resolveSome(100).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                MaybePromise.resolveNone().thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("MaybePromise.thenOrElse()", {
            it("should return value", done -> {
                MaybePromise.resolveSome(100).thenOrElse(Some(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                MaybePromise.resolveNone().thenOrElse(Some(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return empty", done -> {
                MaybePromise.resolveNone().thenOrElse(None).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromise.thenMap()", {
            it("should map to U", done -> {
                MaybePromise.resolveSome(100).thenMap(x -> x * 2).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                MaybePromise.resolveSome(100).thenMap(x -> Promise.resolve(x * 2)).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });
        });

        // describe("MaybePromise.thenFlatten()", {
        //     it("should transform Some(Some(value))", done -> {
        //         Promise.resolve(Some(Some(1))).thenFlatten().then(x -> {
        //             x.should.equal(Some(1));
        //             done();
        //         });
        //     });
        //     it("should transform Some(None)", done -> {
        //         Promise.resolve(Some(None)).thenFlatten().then(x -> {
        //             x.should.equal(None);
        //             done();
        //         });
        //     });
        //     it("should transform None", done -> {
        //         MaybePromise.resolveNone().thenFlatten().then(x -> {
        //             x.should.equal(None);
        //             done();
        //         });
        //     });
        // });

        describe("MaybePromise.thenFlatMap()", {
            it("should flatMap to Some(U)", done -> {
                MaybePromise.resolveSome(100).thenFlatMap(x -> Some(x * 2)).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                MaybePromise.resolveSome(100).thenFlatMap(x -> None).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                MaybePromise.resolveSome(100).thenFlatMap(x -> Promise.resolve(Some(x * 2))).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                MaybePromise.resolveSome(100).thenFlatMap(x -> MaybePromise.resolveNone()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromise.thenHas()", {
            it("should be true", done -> {
                MaybePromise.resolveSome(100).thenHas(100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                MaybePromise.resolveSome(100).thenHas(-1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                MaybePromise.resolveNone().thenHas(100).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromise.thenExists()", {
            it("should be true", done -> {
                MaybePromise.resolveSome(100).thenExists(x -> x == 100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                MaybePromise.resolveSome(100).thenExists(x -> x == -1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                MaybePromise.resolveNone().thenExists(x -> true).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                MaybePromise.resolveNone().thenExists(x -> false).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromise.thenFind()", {
            it("should be some", done -> {
                MaybePromise.resolveSome(100).thenFind(x -> x == 100).then(x -> {
                    x.should.be(100);
                    done();
                });
            });
            it("should be null", done -> {
                MaybePromise.resolveSome(100).thenFind(x -> x == -1).then(x -> {
                    x.should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                MaybePromise.resolveNone().thenFind(x -> true).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                MaybePromise.resolveNone().thenFind(x -> false).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("MaybePromise.thenFilter()", {
            it("should pass when callback returns true", done -> {
                MaybePromise.resolveSome(100).thenFilter(x -> true).then(x -> {
                    x.should.equal(Some(100));
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                MaybePromise.resolveSome(100).thenFilter(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                MaybePromise.resolveSome(100).thenFilter(x -> Promise.resolve(true)).then(x -> {
                    x.should.equal(Some(100));
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                MaybePromise.resolveSome(100).thenFilter(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromise.thenFold()", {
            it("should pass `empty -> ifEmpty -> T`", done -> {
                MaybePromise.resolveNone().thenFold(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> T`", done -> {
                MaybePromise.resolveSome(100).thenFold(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<T>`", done -> {
                MaybePromise.resolveNone().thenFold(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> Promise<T>`", done -> {
                MaybePromise.resolveSome(100).thenFold(
                    () -> { fail(); Promise.resolve(-1); },
                    x -> Promise.resolve(x * 2)
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });
        });

        describe("MaybePromise.resolveSome()", {
            it("should pass", done -> {
                MaybePromise.resolveSome(10).thenIter(x -> {
                    x.should.be(10);
                    done();
                });
            });
        });

        describe("MaybePromise.resolveNone()", {
            it("should pass", done -> {
                MaybePromise.resolveNone().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });
    }
}

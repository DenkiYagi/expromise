package expromise;

import extype.Maybe;
import extype.NoDataException;

using expromise.MaybePromiseTools;

class MaybePromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("MaybePromiseTools.thenToNullable()", {
            it("should convert to Some(value)", done -> {
                Promise.resolve(Some(100)).thenToNullable().then(x -> {
                    x.nonEmpty().should.be(true);
                    x.getOrThrow().should.be(100);
                    done();
                });
            });

            it("should convert to None", done -> {
                Promise.resolve(None).thenToNullable().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenIsEmpty()", {
            it("should return false", done -> {
                Promise.resolve(Some(100)).thenIsEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });

            it("should return true", done -> {
                Promise.resolve(None).thenIsEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenNonEmpty()", {
            it("should return false", done -> {
                Promise.resolve(Some(100)).thenNonEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });

            it("should return true", done -> {
                Promise.resolve(None).thenNonEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGet()", {
            it("should convert to value", done -> {
                Promise.resolve(Some("hello")).thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                Promise.resolve(None).thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetUnsafe()", {
            it("should convert to value", done -> {
                Promise.resolve(Some(100)).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetOrThrow()", {
            it("should convert to value", done -> {
                Promise.resolve(Some(100)).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(None).thenGetOrThrow().catchError(e -> {
                    Std.isOfType(e, NoDataException).should.be(true);
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(None).thenGetOrThrow(() -> "error").catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Some(100)).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(None).thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Some(100)).thenOrElse(Some(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(None).thenOrElse(Some(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return empty", done -> {
                Promise.resolve(None).thenOrElse(None).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenMap()", {
            it("should map to U", done -> {
                Promise.resolve(Some(100)).thenMap(x -> x * 2).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                Promise.resolve(Some(100)).thenMap(x -> Promise.resolve(x * 2)).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFlatten()", {
            it("should transform Some(Some(value))", done -> {
                Promise.resolve(Some(Some(1))).thenFlatten().then(x -> {
                    x.should.equal(Some(1));
                    done();
                });
            });
            it("should transform Some(None)", done -> {
                Promise.resolve(Some(None)).thenFlatten().then(x -> {
                    x.should.equal(None);
                    done();
                });
            });
            it("should transform None", done -> {
                Promise.resolve(None).thenFlatten().then(x -> {
                    x.should.equal(None);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFlatMap()", {
            it("should flatMap to Some(U)", done -> {
                Promise.resolve(Some(100)).thenFlatMap(x -> Some(x * 2)).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                Promise.resolve(Some(100)).thenFlatMap(x -> None).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                Promise.resolve(Some(100)).thenFlatMap(x -> Promise.resolve(Some(x * 2))).then(x -> {
                    x.should.equal(Some(200));
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                Promise.resolve(Some(100)).thenFlatMap(x -> Promise.resolve(None)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenHas()", {
            it("should be true", done -> {
                Promise.resolve(Some(100)).thenHas(100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Some(100)).thenHas(-1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(None).thenHas(100).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenExists()", {
            it("should be true", done -> {
                Promise.resolve(Some(100)).thenExists(x -> x == 100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Some(100)).thenExists(x -> x == -1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(None).thenExists(x -> true).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(None).thenExists(x -> false).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFind()", {
            it("should be some", done -> {
                Promise.resolve(Some(100)).thenFind(x -> x == 100).then(x -> {
                    x.should.be(100);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(Some(100)).thenFind(x -> x == -1).then(x -> {
                    x.should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(None).thenFind(x -> true).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(None).thenFind(x -> false).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFilter()", {
            it("should pass when callback returns true", done -> {
                Promise.resolve(Some(100)).thenFilter(x -> true).then(x -> {
                    x.should.equal(Some(100));
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                Promise.resolve(Some(100)).thenFilter(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                Promise.resolve(Some(100)).thenFilter(x -> Promise.resolve(true)).then(x -> {
                    x.should.equal(Some(100));
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                Promise.resolve(Some(100)).thenFilter(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFold()", {
            it("should pass `empty -> ifEmpty -> T`", done -> {
                Promise.resolve(None).thenFold(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> T`", done -> {
                Promise.resolve(Some(100)).thenFold(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<T>`", done -> {
                Promise.resolve(None).thenFold(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> Promise<T>`", done -> {
                Promise.resolve(Some(100)).thenFold(
                    () -> { fail(); Promise.resolve(-1); },
                    x -> Promise.resolve(x * 2)
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.resolveSome()", {
            it("should pass", done -> {
                MaybePromiseTools.resolveSome(10).thenIter(x -> {
                    x.should.be(10);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.resolveNone()", {
            it("should pass", done -> {
                MaybePromiseTools.resolveNone().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });
    }
}

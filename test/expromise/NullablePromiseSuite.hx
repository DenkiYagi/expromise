package expromise;

import extype.NoDataException;
import extype.Nullable;

using expromise.NullablePromise;

class NullablePromiseSuite extends BuddySuite {
    public function new() {
        describe("NullablePromise.thenToMaybe()", {
            it("should convert to Some(value)", done -> {
                NullablePromise.resolveOf(100).thenToMaybe().then(x -> switch (x) {
                    case Some(v):
                        v.should.be(100);
                        done();
                    case None:
                        fail();
                });
            });

            it("should convert to None", done -> {
                NullablePromise.resolveEmpty().thenToMaybe().then(x -> switch (x) {
                    case Some(v):
                        fail();
                    case None:
                        done();
                });
            });
        });

        describe("NullablePromise.thenIsEmpty()", {
            it("should return false", done -> {
                NullablePromise.resolveOf(100).thenIsEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });

            it("should return true", done -> {
                NullablePromise.resolveEmpty().thenIsEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("NullablePromise.thenNonEmpty()", {
            it("should return false", done -> {
                NullablePromise.resolveOf(100).thenNonEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });

            it("should return true", done -> {
                NullablePromise.resolveEmpty().thenNonEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("NullablePromise.thenGet()", {
            it("should convert to value", done -> {
                NullablePromise.resolveOf("hello").thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                NullablePromise.resolveEmpty().thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("NullablePromise.thenGetUnsafe()", {
            it("should convert to value", done -> {
                NullablePromise.resolveOf(100).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("NullablePromise.thenGetOrThrow()", {
            it("should convert to value", done -> {
                NullablePromise.resolveOf(100).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                NullablePromise.resolveEmpty().thenGetOrThrow().catchError(e -> {
                    Std.isOfType(e, NoDataException).should.be(true);
                    done();
                });
            });

            it("should be rejected", done -> {
                NullablePromise.resolveEmpty().thenGetOrThrow(() -> "error").catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });
        });

        describe("NullablePromise.thenGetOrElse()", {
            it("should return value", done -> {
                NullablePromise.resolveOf(100).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                NullablePromise.resolveEmpty().thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("NullablePromise.thenOrElse()", {
            it("should return value", done -> {
                NullablePromise.resolveOf(100).thenOrElse(Nullable.of(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                NullablePromise.resolveEmpty().thenOrElse(Nullable.of(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return empty", done -> {
                NullablePromise.resolveEmpty().thenOrElse(Nullable.empty()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("NullablePromise.thenMap()", {
            it("should map to U", done -> {
                NullablePromise.resolveOf(100).thenMap(x -> x * 2).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                NullablePromise.resolveOf(100).thenMap(x -> Promise.resolve(x * 2)).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });
        });

        describe("NullablePromise.thenFlatMap()", {
            it("should flatMap to Some(U)", done -> {
                NullablePromise.resolveOf(100).thenFlatMap(x -> Nullable.of(x * 2)).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                NullablePromise.resolveOf(100).thenFlatMap(x -> Nullable.empty()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                NullablePromise.resolveOf(100).thenFlatMap(x -> Promise.resolve(Nullable.of(x * 2))).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                NullablePromise.resolveOf(100).thenFlatMap(x -> Promise.resolve(Nullable.empty())).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("NullablePromise.thenHas()", {
            it("should be true", done -> {
                NullablePromise.resolveOf(100).thenHas(100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                NullablePromise.resolveOf(100).thenHas(-1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                NullablePromise.resolveEmpty().thenHas(100).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("NullablePromise.thenExists()", {
            it("should be true", done -> {
                NullablePromise.resolveOf(100).thenExists(x -> x == 100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                NullablePromise.resolveOf(100).thenExists(x -> x == -1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                NullablePromise.resolveEmpty().thenExists(x -> true).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                NullablePromise.resolveEmpty().thenExists(x -> false).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("NullablePromise.thenFind()", {
            it("should be some", done -> {
                NullablePromise.resolveOf(100).thenFind(x -> x == 100).then(x -> {
                    x.should.be(100);
                    done();
                });
            });
            it("should be null", done -> {
                NullablePromise.resolveOf(100).thenFind(x -> x == -1).then(x -> {
                    x.should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                NullablePromise.resolveEmpty().thenFind(x -> true).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                NullablePromise.resolveEmpty().thenFind(x -> false).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("NullablePromise.thenFilter()", {
            it("should pass when callback returns true", done -> {
                NullablePromise.resolveOf(100).thenFilter(x -> true).then(x -> {
                    x.get().should.be(100);
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                NullablePromise.resolveOf(100).thenFilter(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                NullablePromise.resolveOf(100).thenFilter(x -> Promise.resolve(true)).then(x -> {
                    x.get().should.be(100);
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                NullablePromise.resolveOf(100).thenFilter(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("NullablePromise.thenFold()", {
            it("should pass `empty -> ifEmpty -> T`", done -> {
                NullablePromise.resolveEmpty().thenFold(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> T`", done -> {
                NullablePromise.resolveOf(100).thenFold(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<T>`", done -> {
                NullablePromise.resolveEmpty().thenFold(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> Promise<T>`", done -> {
                NullablePromise.resolveOf(100).thenFold(
                    () -> { fail(); Promise.resolve(-1); },
                    x -> Promise.resolve(x * 2)
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });
        });

        describe("NullablePromise.thenIter()", {
            it("should call", done -> {
                NullablePromise.resolveOf(100).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should never call", done -> {
                NullablePromise.resolveEmpty().thenIter(_ -> fail());
                wait(5, done);
            });
        });

        describe("NullablePromise.thenMatch()", {
            it("should call fn", done -> {
                NullablePromise.resolveOf(100).thenMatch(
                    x -> {
                        x.should.be(100);
                        done();
                    },
                    () -> fail()
                );
            });

            it("should call ifEmpty", done -> {
                NullablePromise.resolveEmpty().thenMatch(
                    x -> fail(),
                    () -> done()
                );
            });
        });

        describe("NullablePromise.resolveOf()", {
            it("should pass", done -> {
                NullablePromise.resolveOf(10).thenIter(x -> {
                    x.should.be(10);
                    done();
                });
            });
        });

        describe("NullablePromise.resolveEmpty()", {
            it("should pass", done -> {
                NullablePromise.resolveEmpty().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });

            });
        });
    }
}

package expromise;

import extype.Maybe;
import extype.NoDataException;

using expromise.MaybePromiseTools;

class MaybePromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("MaybePromiseTools.thenToOption()", {
            it("should convert to Some(value)", done -> {
                Promise.resolve(Maybe.of(100)).thenToOption().then(x -> switch (x) {
                    case Some(v):
                        v.should.be(100);
                        done();
                    case None:
                        fail();
                });
            });

            it("should convert to None", done -> {
                Promise.resolve(Maybe.empty()).thenToOption().then(x -> switch (x) {
                    case Some(v):
                        fail();
                    case None:
                        done();
                });
            });
        });

        describe("MaybePromiseTools.thenGet()", {
            it("should convert to value", done -> {
                Promise.resolve(Maybe.of("hello")).thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                Promise.resolve(Maybe.empty()).thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetUnsafe()", {
            it("should convert to value", done -> {
                Promise.resolve(Maybe.of(100)).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetOrThrow()", {
            it("should convert to value", done -> {
                Promise.resolve(Maybe.of(100)).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(Maybe.empty()).thenGetOrThrow().catchError(e -> {
                    Std.isOfType(e, NoDataException).should.be(true);
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(Maybe.empty()).thenGetOrThrow(() -> "error").catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenGetOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Maybe.of(100)).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(Maybe.empty()).thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Maybe.of(100)).thenOrElse(Maybe.of(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(Maybe.empty()).thenOrElse(Maybe.of(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return empty", done -> {
                Promise.resolve(Maybe.empty()).thenOrElse(Maybe.empty()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenIsEmpty()", {
            it("should return false", done -> {
                Promise.resolve(Maybe.of(100)).thenIsEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });

            it("should return true", done -> {
                Promise.resolve(Maybe.empty()).thenIsEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenNonEmpty()", {
            it("should return false", done -> {
                Promise.resolve(Maybe.of(100)).thenNonEmpty().then(x -> {
                    x.should.be(true);
                    done();
                });
            });

            it("should return true", done -> {
                Promise.resolve(Maybe.empty()).thenNonEmpty().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenMap()", {
            it("should map to U", done -> {
                Promise.resolve(Maybe.of(100)).thenMap(x -> x * 2).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                Promise.resolve(Maybe.of(100)).thenMap(x -> Promise.resolve(x * 2)).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFlatMap()", {
            it("should flatMap to Some(U)", done -> {
                Promise.resolve(Maybe.of(100)).thenFlatMap(x -> Maybe.of(x * 2)).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                Promise.resolve(Maybe.of(100)).thenFlatMap(x -> Maybe.empty()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                Promise.resolve(Maybe.of(100)).thenFlatMap(x -> Promise.resolve(Maybe.of(x * 2))).then(x -> {
                    x.get().should.be(200);
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                Promise.resolve(Maybe.of(100)).thenFlatMap(x -> Promise.resolve(Maybe.empty())).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFilter()", {
            it("should pass when callback returns true", done -> {
                Promise.resolve(Maybe.of(100)).thenFilter(x -> true).then(x -> {
                    x.get().should.be(100);
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                Promise.resolve(Maybe.of(100)).thenFilter(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                Promise.resolve(Maybe.of(100)).thenFilter(x -> Promise.resolve(true)).then(x -> {
                    x.get().should.be(100);
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                Promise.resolve(Maybe.of(100)).thenFilter(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenFold()", {
            it("should pass `empty -> ifEmpty -> T`", done -> {
                Promise.resolve(Maybe.empty()).thenFold(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> T`", done -> {
                Promise.resolve(Maybe.of(100)).thenFold(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<T>`", done -> {
                Promise.resolve(Maybe.empty()).thenFold(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> Promise<T>`", done -> {
                Promise.resolve(Maybe.of(100)).thenFold(
                    () -> { fail(); Promise.resolve(-1); },
                    x -> Promise.resolve(x * 2)
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.thenIter()", {
            it("should call", done -> {
                Promise.resolve(Maybe.of(100)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should never call", done -> {
                Promise.resolve(Maybe.empty()).thenIter(_ -> fail());
                wait(5, done);
            });
        });

        describe("MaybePromiseTools.thenMatch()", {
            it("should call fn", done -> {
                Promise.resolve(Maybe.of(100)).thenMatch(
                    x -> {
                        x.should.be(100);
                        done();
                    },
                    () -> fail()
                );
            });

            it("should call ifEmpty", done -> {
                Promise.resolve(Maybe.empty()).thenMatch(
                    x -> fail(),
                    () -> done()
                );
            });
        });

        describe("MaybePromiseTools.resolveJust()", {
            it("should pass", done -> {
                MaybePromiseTools.resolveJust(10).thenIter(x -> {
                    x.should.be(10);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.resolveEmpty()", {
            it("should pass", done -> {
                MaybePromiseTools.resolveEmpty().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });

            });
        });
    }
}

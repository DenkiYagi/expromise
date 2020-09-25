package expromise;

import extype.NoDataException;
import haxe.ds.Option;

using expromise.OptionPromiseTools;
using extools.OptionTools;

class OptionPromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("OptionPromiseTools.thenToMaybe()", {
            it("should convert to Some(value)", done -> {
                Promise.resolve(Some(100)).thenToMaybe().then(x -> {
                    x.nonEmpty().should.be(true);
                    x.getOrThrow().should.be(100);
                    done();
                });
            });

            it("should convert to None", done -> {
                Promise.resolve(None).thenToMaybe().then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("OptionPromiseTools.thenGet()", {
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

        describe("OptionPromiseTools.thenGetUnsafe()", {
            it("should convert to value", done -> {
                Promise.resolve(Some(100)).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("OptionPromiseTools.thenGetOrThrow()", {
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

        describe("OptionPromiseTools.thenGetOrElse()", {
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

        describe("OptionPromiseTools.thenOrElse()", {
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

        describe("OptionPromiseTools.thenIsEmpty()", {
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

        describe("OptionPromiseTools.thenNonEmpty()", {
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

        describe("OptionPromiseTools.thenMap()", {
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

        describe("OptionPromiseTools.thenFlatMap()", {
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

        describe("OptionPromiseTools.thenFilter()", {
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

        describe("OptionPromiseTools.thenFold()", {
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
    }
}

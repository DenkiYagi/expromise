package expromise;

import extype.Maybe;

using expromise.MaybePromiseTools;

class MaybePromiseToolsSuite extends BuddySuite {
    public function new() {
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
    }
}

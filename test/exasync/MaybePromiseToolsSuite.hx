package exasync;

import extype.Maybe;

using exasync.MaybePromiseTools;

class MaybePromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("MaybePromiseTools.mapThen()", {
            it("should map to U", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> x * 2).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> Promise.resolve(x * 2)).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.flatMapThen()", {
            it("should flatMap to Some(U)", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> Maybe.of(x * 2)).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> Maybe.empty()).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> Promise.resolve(Maybe.of(x * 2))).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                Promise.resolve(Maybe.of(100)).mapThen(x -> Promise.resolve(Maybe.empty())).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.filterThen()", {
            it("should pass when callback returns true", done -> {
                Promise.resolve(Maybe.of(100)).filterThen(x -> true).then(x -> {
                    x.getUnsafe().should.be(100);
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                Promise.resolve(Maybe.of(100)).filterThen(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                Promise.resolve(Maybe.of(100)).filterThen(x -> Promise.resolve(true)).then(x -> {
                    x.getUnsafe().should.be(100);
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                Promise.resolve(Maybe.of(100)).filterThen(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("MaybePromiseTools.foldThen()", {
            it("should pass `empty -> ifEmpty -> value`", done -> {
                Promise.resolve(Maybe.empty()).foldThen(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `value -> fn -> value`", done -> {
                Promise.resolve(Maybe.of(100)).foldThen(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<value>`", done -> {
                Promise.resolve(Maybe.empty()).foldThen(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `value -> fn -> Promise<value>`", done -> {
                Promise.resolve(Maybe.of(100)).foldThen(
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

package exasync;

import haxe.ds.Option;

using exasync.OptionPromiseTools;
using extools.OptionTools;

class OptionPromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("OptionPromiseTools.mapThen()", {
            it("should map to U", done -> {
                Promise.resolve(Some(100)).mapThen(x -> x * 2).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should map to Promise<U>", done -> {
                Promise.resolve(Some(100)).mapThen(x -> Promise.resolve(x * 2)).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });
        });

        describe("OptionPromiseTools.flatMapThen()", {
            it("should flatMap to Some(U)", done -> {
                Promise.resolve(Some(100)).flatMapThen(x -> Some(x * 2)).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should flatMap to Empty", done -> {
                Promise.resolve(Some(100)).flatMapThen(x -> None).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should flatMap to Promise<Some(U)>", done -> {
                Promise.resolve(Some(100)).flatMapThen(x -> Promise.resolve(Some(x * 2))).then(x -> {
                    x.getUnsafe().should.be(200);
                    done();
                });
            });

            it("should flatMap to Promise<Empty>", done -> {
                Promise.resolve(Some(100)).flatMapThen(x -> Promise.resolve(None)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("OptionPromiseTools.filterThen()", {
            it("should pass when callback returns true", done -> {
                Promise.resolve(Some(100)).filterThen(x -> true).then(x -> {
                    x.getUnsafe().should.be(100);
                    done();
                });
            });

            it("should block when callback returns true", done -> {
                Promise.resolve(Some(100)).filterThen(x -> false).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });

            it("should pass when callback returns Promise<true>", done -> {
                Promise.resolve(Some(100)).filterThen(x -> Promise.resolve(true)).then(x -> {
                    x.getUnsafe().should.be(100);
                    done();
                });
            });

            it("should block when callback returns Promise<false>", done -> {
                Promise.resolve(Some(100)).filterThen(x -> Promise.resolve(false)).then(x -> {
                    x.isEmpty().should.be(true);
                    done();
                });
            });
        });

        describe("OptionPromiseTools.foldThen()", {
            it("should pass `empty -> ifEmpty -> T`", done -> {
                Promise.resolve(None).foldThen(
                    () -> 100,
                    _ -> { fail(); -1; }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> T`", done -> {
                Promise.resolve(Some(100)).foldThen(
                    () -> { fail(); -1; },
                    x -> x * 2
                ).then(x -> {
                    x.should.be(200);
                    done();
                });
            });

            it("should pass `empty -> ifEmpty -> Promise<T>`", done -> {
                Promise.resolve(None).foldThen(
                    () -> Promise.resolve(100),
                    _ -> { fail(); Promise.resolve(-1); }
                ).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should pass `T -> fn -> Promise<T>`", done -> {
                Promise.resolve(Some(100)).foldThen(
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

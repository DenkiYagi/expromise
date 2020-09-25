package expromise;

import haxe.ds.Option;

using expromise.OptionPromiseTools;
using extools.OptionTools;

class OptionPromiseToolsSuite extends BuddySuite {
    public function new() {
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

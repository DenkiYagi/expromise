package expromise;

import haxe.ds.Either;

using expromise.EitherPromiseTools;

class EitherPromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("EitherPromiseTools.thenIsRight()", {
            it("should be true", done -> {
                Promise.resolve(Right(100)).thenIsRight().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Left(100)).thenIsRight().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("EitherPromiseTools.thenIsLeft()", {
            it("should be true", done -> {
                Promise.resolve(Left(100)).thenIsLeft().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Right(100)).thenIsLeft().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("EitherPromiseTools.swap()", {
            it("should pass `Right<T> -> Left<T>`", done -> {
                Promise.resolve(Right(100)).swap().then(x -> {
                    x.should.equal(Left(100));
                    done();
                });
            });
            it("should pass `Left<T> -> Right<T>`", done -> {
                Promise.resolve(Left(10)).swap().then(x -> {
                    x.should.equal(Right(10));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.thenMap()", {
            it("should pass `Right<B> -> (B -> BB) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).thenMap(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<BB>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).thenMap(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should never call callback from Left<T>", done -> {
                Promise.resolve(Left(100)).thenMap(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Left(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.thenFlatMap()", {
            it("should pass `Right<B> -> (B -> Right<BB>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).thenFlatMap(x -> Right(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Left<A>) -> Left<A>", done -> {
                Promise.resolve(Right(100)).thenFlatMap(x -> Left(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<Right<BB>>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).thenFlatMap(x -> Promise.resolve(Right(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<Left<A>>) -> Left<A>", done -> {
                Promise.resolve(Right(100)).thenFlatMap(x -> Promise.resolve(Left(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Left<T>", done -> {
                Promise.resolve(Left(100)).thenFlatMap(x -> { fail(); Right(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Left(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.thenMapLeft()", {
            it("should pass `Left<A> -> (A -> AA) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).thenMapLeft(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (A -> Promise<AA>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).thenMapLeft(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Right<T>", done -> {
                Promise.resolve(Right(100)).thenMapLeft(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Right(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.thenFlatMapLeft()", {
            it("should pass `Left<A> -> (A -> Right<B>) -> Right<B>", done -> {
                Promise.resolve(Left(100)).thenFlatMapLeft(x -> Right(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (A -> Left<AA>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).thenFlatMapLeft(x -> Left(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (B -> Promise<Right<B>>) -> Right<B>", done -> {
                Promise.resolve(Left(100)).thenFlatMapLeft(x -> Promise.resolve(Right(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (B -> Promise<Left<AA>>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).thenFlatMapLeft(x -> Promise.resolve(Left(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Right<T>", done -> {
                Promise.resolve(Right(100)).thenFlatMapLeft(x -> { fail(); Left(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Right(100));
                    done();
                });
            });
        });
    }
}

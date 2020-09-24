package expromise;

import haxe.ds.Either;

using expromise.EitherPromiseTools;

class EitherPromiseToolsSuite extends BuddySuite {
    public function new() {
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

        describe("EitherPromiseTools.mapThen()", {
            it("should pass `Right<B> -> (B -> BB) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).mapThen(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<BB>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).mapThen(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should never call callback from Left<T>", done -> {
                Promise.resolve(Left(100)).mapThen(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Left(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.flatMapThen()", {
            it("should pass `Right<B> -> (B -> Right<BB>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).flatMapThen(x -> Right(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Left<A>) -> Left<A>", done -> {
                Promise.resolve(Right(100)).flatMapThen(x -> Left(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<Right<BB>>) -> Right<BB>", done -> {
                Promise.resolve(Right(100)).flatMapThen(x -> Promise.resolve(Right(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Right<B> -> (B -> Promise<Left<A>>) -> Left<A>", done -> {
                Promise.resolve(Right(100)).flatMapThen(x -> Promise.resolve(Left(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Left<T>", done -> {
                Promise.resolve(Left(100)).flatMapThen(x -> { fail(); Right(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Left(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.mapLeftThen()", {
            it("should pass `Left<A> -> (A -> AA) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).mapLeftThen(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (A -> Promise<AA>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).mapLeftThen(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Right<T>", done -> {
                Promise.resolve(Right(100)).mapLeftThen(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Right(100));
                    done();
                });
            });
        });

        describe("EitherPromiseTools.flatMapLeftThen()", {
            it("should pass `Left<A> -> (A -> Right<B>) -> Right<B>", done -> {
                Promise.resolve(Left(100)).flatMapLeftThen(x -> Right(Std.string(x * 2))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (A -> Left<AA>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).flatMapLeftThen(x -> Left(Std.string(x * 2))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (B -> Promise<Right<B>>) -> Right<B>", done -> {
                Promise.resolve(Left(100)).flatMapLeftThen(x -> Promise.resolve(Right(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Right("200"));
                    done();
                });
            });

            it("should pass `Left<A> -> (B -> Promise<Left<AA>>) -> Left<AA>", done -> {
                Promise.resolve(Left(100)).flatMapLeftThen(x -> Promise.resolve(Left(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Left("200"));
                    done();
                });
            });

            it("should never call callback from Right<T>", done -> {
                Promise.resolve(Right(100)).flatMapLeftThen(x -> { fail(); Left(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Right(100));
                    done();
                });
            });
        });
    }
}

package expromise;

import extype.Result;

using expromise.ResultPromiseTools;

class ResultPromiseToolsSuite extends BuddySuite {
    public function new() {
        describe("ResultPromiseTools.thenIsSuccess()", {
            it("should be true", done -> {
                Promise.resolve(Success(100)).thenIsSuccess().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Failure(100)).thenIsSuccess().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenIsFailure()", {
            it("should be true", done -> {
                Promise.resolve(Success(100)).thenIsFailure().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Failure(100)).thenIsFailure().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenMap()", {
            it("should pass `Success<T> -> (T -> U) -> Success<U>", done -> {
                Promise.resolve(Success(100)).thenMap(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<U>) -> Success<U>", done -> {
                Promise.resolve(Success(100)).thenMap(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should never call callback from Failure<T>", done -> {
                Promise.resolve(Failure(100)).thenMap(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Failure(100));
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenFlatMap()", {
            it("should pass `Success<T> -> (T -> Success<U>) -> Success<U>", done -> {
                Promise.resolve(Success(100)).thenFlatMap(x -> Success(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Failure<E>) -> Failure<E>", done -> {
                Promise.resolve(Success(100)).thenFlatMap(x -> Failure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<Success<U>>) -> Success<U>", done -> {
                Promise.resolve(Success(100)).thenFlatMap(x -> Promise.resolve(Success(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<Failure<E>>) -> Failure<E>", done -> {
                Promise.resolve(Success(100)).thenFlatMap(x -> Promise.resolve(Failure(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Failure<T>", done -> {
                Promise.resolve(Failure(100)).thenFlatMap(x -> { fail(); Success(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Failure(100));
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenMapFailure()", {
            it("should pass `Failure<E> -> (E -> EE) -> Failure<EE>", done -> {
                Promise.resolve(Failure(100)).thenMapFailure(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<EE>) -> Failure<EE>", done -> {
                Promise.resolve(Failure(100)).thenMapFailure(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Success<T>", done -> {
                Promise.resolve(Success(100)).thenMapFailure(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Success(100));
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenFlatMapFailure()", {
            it("should pass `Failure<E> -> (E -> Success<T>) -> Success<T>", done -> {
                Promise.resolve(Failure(100)).thenFlatMapFailure(x -> Success(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Failure<EE>) -> Failure<EE>", done -> {
                Promise.resolve(Failure(100)).thenFlatMapFailure(x -> Failure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<Success<T>>) -> Success<T>", done -> {
                Promise.resolve(Failure(100)).thenFlatMapFailure(x -> Promise.resolve(Success(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<Failure<EE>>) -> Failure<EE>", done -> {
                Promise.resolve(Failure(100)).thenFlatMapFailure(x -> Promise.resolve(Failure(Std.string(x * 2)))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Success<T>", done -> {
                Promise.resolve(Success(100)).thenFlatMapFailure(x -> { fail(); Failure(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Success(100));
                    done();
                });
            });
        });
    }
}

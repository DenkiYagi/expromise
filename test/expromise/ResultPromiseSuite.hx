package expromise;

import extype.NoDataException;
import extype.Result;

using expromise.ResultPromise;

class ResultPromiseSuite extends BuddySuite {
    public function new() {
        describe("ResultPromise.thenIsSuccess()", {
            it("should be true", done -> {
                ResultPromise.resolveSuccess(100).thenIsSuccess().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveFailure(100).thenIsSuccess().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromise.thenIsFailure()", {
            it("should be true", done -> {
                ResultPromise.resolveSuccess(100).thenIsFailure().then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveFailure(100).thenIsFailure().then(x -> {
                    x.should.be(true);
                    done();
                });
            });
        });

        describe("ResultPromise.thenGet()", {
            it("should convert to value", done -> {
                ResultPromise.resolveSuccess("hello").thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                ResultPromise.resolveFailure("error").thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("ResultPromise.thenGetUnsafe()", {
            it("should convert to value", done -> {
                ResultPromise.resolveSuccess(100).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("ResultPromise.thenGetOrThrow()", {
            it("should convert to value", done -> {
                ResultPromise.resolveSuccess(100).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                ResultPromise.resolveFailure("error").thenGetOrThrow().catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });

            it("should be rejected", done -> {
                ResultPromise.resolveFailure("error").thenGetOrThrow(() -> "error2").catchError(e -> {
                    (e : Exception).message.should.be("error2");
                    done();
                });
            });
        });

        describe("ResultPromise.thenGetOrElse()", {
            it("should return value", done -> {
                ResultPromise.resolveSuccess(100).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                ResultPromise.resolveFailure("error").thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("ResultPromise.thenOrElse()", {
            it("should return value", done -> {
                ResultPromise.resolveSuccess(100).thenOrElse(Success(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                ResultPromise.resolveFailure("error").thenOrElse(Success(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return failure", done -> {
                ResultPromise.resolveFailure("error").thenOrElse(Failure("error2")).then(x -> {
                    x.isFailure().should.be(true);
                    done();
                });
            });
        });

        describe("ResultPromise.thenMap()", {
            it("should pass `Success<T> -> (T -> U) -> Success<U>", done -> {
                ResultPromise.resolveSuccess(100).thenMap(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<U>) -> Success<U>", done -> {
                ResultPromise.resolveSuccess(100).thenMap(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should never call callback from Failure<T>", done -> {
                ResultPromise.resolveFailure(100).thenMap(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Failure(100));
                    done();
                });
            });
        });

        describe("ResultPromise.thenFlatMap()", {
            it("should pass `Success<T> -> (T -> Success<U>) -> Success<U>", done -> {
                ResultPromise.resolveSuccess(100).thenFlatMap(x -> Success(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Failure<E>) -> Failure<E>", done -> {
                ResultPromise.resolveSuccess(100).thenFlatMap(x -> Failure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<Success<U>>) -> Success<U>", done -> {
                ResultPromise.resolveSuccess(100).thenFlatMap(x -> ResultPromise.resolveSuccess(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Success<T> -> (T -> Promise<Failure<E>>) -> Failure<E>", done -> {
                ResultPromise.resolveSuccess(100).thenFlatMap(x -> ResultPromise.resolveFailure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Failure<T>", done -> {
                ResultPromise.resolveFailure(100).thenFlatMap(x -> { fail(); Success(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Failure(100));
                    done();
                });
            });
        });

        describe("ResultPromise.thenMapFailure()", {
            it("should pass `Failure<E> -> (E -> EE) -> Failure<EE>", done -> {
                ResultPromise.resolveFailure(100).thenMapFailure(x -> Std.string(x * 2)).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<EE>) -> Failure<EE>", done -> {
                ResultPromise.resolveFailure(100).thenMapFailure(x -> Promise.resolve(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Success<T>", done -> {
                ResultPromise.resolveSuccess(100).thenMapFailure(x -> { fail(); Std.string(x * 2); }).then(x -> {
                    x.should.equal(Success(100));
                    done();
                });
            });
        });

        describe("ResultPromise.thenFlatMapFailure()", {
            it("should pass `Failure<E> -> (E -> Success<T>) -> Success<T>", done -> {
                ResultPromise.resolveFailure(100).thenFlatMapFailure(x -> Success(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Failure<EE>) -> Failure<EE>", done -> {
                ResultPromise.resolveFailure(100).thenFlatMapFailure(x -> Failure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<Success<T>>) -> Success<T>", done -> {
                ResultPromise.resolveFailure(100).thenFlatMapFailure(x -> ResultPromise.resolveSuccess(Std.string(x * 2))).then(x -> {
                    x.should.equal(Success("200"));
                    done();
                });
            });

            it("should pass `Failure<E> -> (E -> Promise<Failure<EE>>) -> Failure<EE>", done -> {
                ResultPromise.resolveFailure(100).thenFlatMapFailure(x -> ResultPromise.resolveFailure(Std.string(x * 2))).then(x -> {
                    x.should.equal(Failure("200"));
                    done();
                });
            });

            it("should never call callback from Success<T>", done -> {
                ResultPromise.resolveSuccess(100).thenFlatMapFailure(x -> { fail(); Failure(Std.string(x * 2)); }).then(x -> {
                    x.should.equal(Success(100));
                    done();
                });
            });
        });

        describe("ResultPromise.thenFlatten()", {
            it("should transform Success(Success(value))", done -> {
                ResultPromise.resolveSuccess(Success(1)).thenFlatten().then(x -> {
                    x.should.equal(Success(1));
                    done();
                });
            });
            it("should transform Success(Failure(e))", done -> {
                ResultPromise.resolveSuccess(Failure("error")).thenFlatten().then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
            it("should transform Failure(e)", done -> {
                ResultPromise.resolveFailure("error").thenFlatten().then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
        });

        describe("ResultPromise.thenHas()", {
            it("should be true", done -> {
                ResultPromise.resolveSuccess(100).thenHas(100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveSuccess(100).thenHas(-1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveFailure("error").thenHas(100).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromise.thenExists()", {
            it("should be true", done -> {
                ResultPromise.resolveSuccess(100).thenExists(x -> x == 100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveSuccess(100).thenExists(x -> x == -1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveFailure("error").thenExists(x -> true).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                ResultPromise.resolveFailure("error").thenExists(x -> false).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromise.thenFind()", {
            it("should be some", done -> {
                ResultPromise.resolveSuccess(100).thenFind(x -> x == 100).then(x -> {
                    x.should.be(100);
                    done();
                });
            });
            it("should be null", done -> {
                ResultPromise.resolveSuccess(100).thenFind(x -> x == -1).then(x -> {
                    x.should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                ResultPromise.resolveFailure("error").thenFind(x -> true).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                ResultPromise.resolveFailure("error").thenFind(x -> false).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("ResultPromise.thenFilterOrElse()", {
            it("should be Success(x)", done -> {
                ResultPromise.resolveSuccess(1).thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Success(1));
                    done();
                });
            });
            it("should be Failure(arg-error)", done -> {
                ResultPromise.resolveSuccess(2).thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Failure("notfound"));
                    done();
                });
            });
            it("should be Failure(orig-error)", done -> {
                ResultPromise.resolveFailure("error").thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
        });

        describe("ResultPromise.thenFold()", {
            it("should transform Success", done -> {
                ResultPromise.resolveSuccess(1).thenFold(x -> x + 100, e -> -1).then(x -> {
                    x.should.be(101);
                    done();
                });
            });
            it("should transform Failure", done -> {
                ResultPromise.resolveFailure("error").thenFold(x -> x + 100, e -> -1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("ResultPromise.thenIter()", {
            it("should call callback", done -> {
                ResultPromise.resolveSuccess(1).thenIter(x -> {
                    x.should.be(1);
                    done();
                });
            });
            it("should never call callback", done -> {
                ResultPromise.resolveFailure(1).thenIter(x -> fail());
                wait(5, done);
            });
        });

        describe("ResultPromise.thenMatch()", {
            it("should call ifSuccess", done -> {
                ResultPromise.resolveSuccess(1).thenMatch(
                    x -> {
                        x.should.be(1);
                        done();
                    },
                    x -> fail()
                );
            });
            it("should call ifSuccess", done -> {
                ResultPromise.resolveFailure(1).thenMatch(
                    x -> fail(),
                    x -> {
                        x.should.be(1);
                        done();
                    }
                );
            });
        });
    }
}

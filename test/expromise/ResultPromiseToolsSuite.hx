package expromise;

import extype.NoDataException;
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

        describe("ResultPromiseTools.thenGet()", {
            it("should convert to value", done -> {
                Promise.resolve(Success("hello")).thenGet().then(x -> {
                    x.should.be("hello");
                    done();
                });
            });

            it("should convert to null", done -> {
                Promise.resolve(Failure("error")).thenGet().then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenGetUnsafe()", {
            it("should convert to value", done -> {
                Promise.resolve(Success(100)).thenGetUnsafe().then(x -> {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenGetOrThrow()", {
            it("should convert to value", done -> {
                Promise.resolve(Success(100)).thenGetOrThrow().then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(Failure("error")).thenGetOrThrow().catchError(e -> {
                    (e : Exception).message.should.be("error");
                    done();
                });
            });

            it("should be rejected", done -> {
                Promise.resolve(Failure("error")).thenGetOrThrow(() -> "error2").catchError(e -> {
                    (e : Exception).message.should.be("error2");
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenGetOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Success(100)).thenGetOrElse(-1).then(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(Failure("error")).thenGetOrElse(-1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenOrElse()", {
            it("should return value", done -> {
                Promise.resolve(Success(100)).thenOrElse(Success(-1)).thenIter(x -> {
                    x.should.be(100);
                    done();
                });
            });

            it("should return alt value", done -> {
                Promise.resolve(Failure("error")).thenOrElse(Success(-1)).thenIter(x -> {
                    x.should.be(-1);
                    done();
                });
            });

            it("should return failure", done -> {
                Promise.resolve(Failure("error")).thenOrElse(Failure("error2")).then(x -> {
                    x.isFailure().should.be(true);
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

        describe("ResultPromiseTools.thenFlatten()", {
            it("should transform Success(Success(value))", done -> {
                Promise.resolve(Success(Success(1))).thenFlatten().then(x -> {
                    x.should.equal(Success(1));
                    done();
                });
            });
            it("should transform Success(Failure(e))", done -> {
                Promise.resolve(Success(Failure("error"))).thenFlatten().then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
            it("should transform Failure(e)", done -> {
                Promise.resolve(Failure("error")).thenFlatten().then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenHas()", {
            it("should be true", done -> {
                Promise.resolve(Success(100)).thenHas(100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Success(100)).thenHas(-1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Failure("error")).thenHas(100).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenExists()", {
            it("should be true", done -> {
                Promise.resolve(Success(100)).thenExists(x -> x == 100).then(x -> {
                    x.should.be(true);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Success(100)).thenExists(x -> x == -1).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Failure("error")).thenExists(x -> true).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
            it("should be false", done -> {
                Promise.resolve(Failure("error")).thenExists(x -> false).then(x -> {
                    x.should.be(false);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenFind()", {
            it("should be some", done -> {
                Promise.resolve(Success(100)).thenFind(x -> x == 100).then(x -> {
                    x.should.be(100);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(Success(100)).thenFind(x -> x == -1).then(x -> {
                    x.should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(Failure("error")).thenFind(x -> true).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
            it("should be null", done -> {
                Promise.resolve(Failure("error")).thenFind(x -> false).then(x -> {
                    (x:Null<Any>).should.be(null);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenFilterOrElse()", {
            it("should be Success(x)", done -> {
                Promise.resolve(Success(1)).thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Success(1));
                    done();
                });
            });
            it("should be Failure(arg-error)", done -> {
                Promise.resolve(Success(2)).thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Failure("notfound"));
                    done();
                });
            });
            it("should be Failure(orig-error)", done -> {
                Promise.resolve(Failure("error")).thenFilterOrElse(x -> x == 1, "notfound").then(x -> {
                    x.should.equal(Failure("error"));
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenFold()", {
            it("should transform Success", done -> {
                Promise.resolve(Success(1)).thenFold(x -> x + 100, e -> -1).then(x -> {
                    x.should.be(101);
                    done();
                });
            });
            it("should transform Failure", done -> {
                Promise.resolve(Failure("error")).thenFold(x -> x + 100, e -> -1).then(x -> {
                    x.should.be(-1);
                    done();
                });
            });
        });

        describe("ResultPromiseTools.thenIter()", {
            it("should call callback", done -> {
                Promise.resolve(Success(1)).thenIter(x -> {
                    x.should.be(1);
                    done();
                });
            });
            it("should never call callback", done -> {
                Promise.resolve(Failure(1)).thenIter(x -> fail());
                wait(5, done);
            });
        });

        describe("ResultPromiseTools.thenMatch()", {
            it("should call ifSuccess", done -> {
                Promise.resolve(Success(1)).thenMatch(
                    x -> {
                        x.should.be(1);
                        done();
                    },
                    x -> fail()
                );
            });
            it("should call ifSuccess", done -> {
                Promise.resolve(Failure(1)).thenMatch(
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

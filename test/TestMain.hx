import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    expromise.PromiseSuite,
    expromise.CancelablePromiseSuite,
    expromise.NullablePromiseSuite,
    expromise.MaybePromiseSuite,
    expromise.ResultPromiseSuite,
]> {}

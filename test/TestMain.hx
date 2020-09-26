import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    expromise.PromiseSuite,
    expromise.CancelablePromiseSuite,
    expromise.NullablePromiseToolsSuite,
    expromise.MaybePromiseToolsSuite,
    expromise.ResultPromiseToolsSuite,
]> {}

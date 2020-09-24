import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    expromise.PromiseSuite,
    expromise.CancelablePromiseSuite,
    expromise.MaybePromiseToolsSuite,
    expromise.OptionPromiseToolsSuite,
    expromise.EitherPromiseToolsSuite,
]> {}

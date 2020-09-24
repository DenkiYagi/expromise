import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    exasync.PromiseSuite,
    exasync.CancelablePromiseSuite,
    exasync.MaybePromiseToolsSuite,
    exasync.EitherPromiseToolsSuite,
    // exasync.TaskSuite,
]> {}

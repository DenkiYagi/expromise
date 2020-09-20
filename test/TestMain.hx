import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    exasync.PromiseSuite,
    exasync.SyncPromiseSuite,
    exasync.AbortablePromiseSuite,
    exasync.TaskSuite,
]> {}

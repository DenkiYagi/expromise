package;

import buddy.*;
import buddy.SuitesRunner;

class TestMain implements Buddy<[
    exasync.PromiseSuite,
    // exasync.SyncPromiseSuite,
    // exasync.AbortablePromiseSuite,
]> {}


// class TestMain {
//     public static function main() {
//         exasync.Promise.reject("error").then(null, function(e) {
//             return 1;
//         }).then(function(x) {
//             return x + 100;
//         }).then(function(x) {
//             trace(x);
//             trace("finish");
//         });
//     }
// }
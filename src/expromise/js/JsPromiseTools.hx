#if js
package expromise.js;

class JsPromiseTools {
    public static inline function toExpromise<T>(promise:js.lib.Promise<T>):Promise<T> {
        return Promise.fromJsPromise(promise);
    }
}
#end

package expromise.js;

#if js
class JsPromiseTools {
    public static inline function toExpromise<T>(promise:js.lib.Promise<T>):Promise<T> {
        return Promise.fromJsPromise(promise);
    }
}
#end

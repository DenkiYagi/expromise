package exasync._internal;

import haxe.MainLoop;
import extype.Unit;

class Dispatcher {
    #if js
    static final promise:Promise<Unit> = Promise.resolve(new Unit());
    #end

    public static function dispatch(fn:Void -> Void): Void {
        #if js
        promise.then(_ -> fn());
        #else
        haxe.Timer.delay(fn, 0);
        #end
    }
}

package exasync;

typedef Thenable<T> = {
	function then<T, U>(onFulfilled:Null<PromiseCallback<T, U>>, ?onRejected:PromiseCallback<Dynamic, U>):Thenable<U>;
}

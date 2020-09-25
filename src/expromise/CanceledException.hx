package expromise;

import extype.Exception;

class CanceledException extends Exception {
    public function new(message:String = "canceled") {
        super(message);
    }
}

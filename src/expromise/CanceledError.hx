package expromise;

import extype.Error;

class CanceledError extends Error {
    public function new(message:String = "canceled") {
        super(message);
        this.name = "CanceledError";
    }
}

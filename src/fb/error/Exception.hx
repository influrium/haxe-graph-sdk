package fb.error;

class Exception
{
    public var message : String;
    public var code : Int;
    public var previous : Exception;

    public function new( message : String, ?code : Int, ?previous : Exception )
    {
        this.message = message;
        this.code = code;
        this.previous = previous;
    }
}
package fb;

abstract GraphVersion(String)
{
    inline public function new( s : String )
    {
        this = s;
    }

    public function toString( ) : String
    {
        return this;
    }
}
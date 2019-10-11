package fb.util;

class MiscTools
{
    public static function uniqid( ) : String
    {
        var t = Sys.time();
        var s = Math.floor(t);
        return StringTools.hex(s) + StringTools.hex(Std.int((t - s) * 1000000));
    }
}
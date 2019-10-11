package fb.util;

class DateTime
{
    inline public static var ISO8601 = "%Y-%m-%dT%H:%M:%S%z"; // "Y-m-d\TH:i:sO" - example: 2005-08-15T15:52:01+0000
    inline public static var RFC1036 = "%a, %d %b %y %H:%M:%S %z"; // "D, d M y H:i:s O" - example: Mon, 15 Aug 05 15:52:01 +0000

    /**
     * Detects an ISO 8601 formatted string.
     *
     * @param string s
     *
     * @return boolean
     *
     * @see https://developers.facebook.com/docs/graph-api/using-graph-api/#readmodifiers
     * @see http://www.cl.cam.ac.uk/~mgk25/iso-time.html
     * @see http://en.wikipedia.org/wiki/ISO_8601
     */
    public static function isIso8601DateString( s : String ) : Bool
    {
        // This insane regex was yoinked from here:
        // http://www.pelagodesign.com/blog/2009/05/20/iso-8601-date-validation-that-doesnt-suck/
        // ...and I'm all like:
        // http://thecodinglove.com/post/95378251969/when-code-works-and-i-dont-know-why
        
        return crazyInsaneRegexThatSomehowDetectsIso8601.match(s);
    }
    static var crazyInsaneRegexThatSomehowDetectsIso8601 = ~/^([+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24:?00)([.,]\d+(?!:))?)?(\17[0-5]\d([.,]\d+)?)?([zZ]|([+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/;

    public static function parseIso8601DateString( s : String ) : Null<Date>
    {
        var erDateISO8601 : EReg = ~/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})[+-](\d{4})$/;
        return erDateISO8601.match(s) ? Date.fromString(erDateISO8601.matched(1) + ' ' + erDateISO8601.matched(2)) : null;
    }

    public static function formatUTC( d : Date, f : String ) : String
    {
    #if neko
        return new String(untyped date_utc_format(d.__t, f.__s));
    #else
        return DateTools.format(d, f);
    #end
    }

    #if neko
    static var date_utc_format = neko.Lib.load("std", "date_utc_format", 2);
    #end
}
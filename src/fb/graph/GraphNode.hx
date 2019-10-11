package fb.graph;

import fb.util.DateTime;
import fb.auth.AccessToken;
import haxe.Json;
import haxe.ds.StringMap;


class GraphNode extends Collection
{
    /**
     * array Maps object key names to Graph object types.
     */
    static var graphObjectMap : StringMap<Dynamic> = new StringMap();

    /**
     * Init this Graph object.
     * @param array $data
     */
    public function new( ?data : StringMap<Dynamic> )
    {
        data = data != null ? data : new StringMap();

        super(castItems(data));
    }

    /**
     * Iterates over an array and detects the types each node
     * should be cast to and returns all the items as an array.
     *
     * @TODO Add auto-casting to AccessToken entities.
     */
    public function castItems( data : StringMap<Dynamic> ) : StringMap<Dynamic>
    {
        var items : StringMap<Dynamic> = new StringMap();

        for (k in data.keys())
        {
            var v : Dynamic = data.get(k);

            if (shouldCastAsDateTime(k) && (Std.is(v, Int) || Std.is(v, Float) || isIso8601DateString(v)))
                items.set(k, castToDateTime(v));
            
            else if (k == 'birthday')
                items.set(k, castToBirthday(v));
            
            else if (k == 'access_token')
                items.set(k, new AccessToken(v));
            
            else
                items.set(k, v);
        }

        return items;
    }

    /**
     * Uncasts any auto-casted datatypes.
     * Basically the reverse of castItems().
     */
    public function uncastItems( )
    {
        var items = asObject();
        for (f in Reflect.fields(items))
        {
            var v = Reflect.field(items, f);
            if (Std.is(v, Date))
                Reflect.setField(items, f, DateTools.format(cast(v, Date), DateTime.ISO8601));
        }
        return items;
    }

    /**
     * Get the collection of items as JSON.
     */
    override public function asJson( options : Int = 0 ) : String
    {
        return Json.stringify(uncastItems());
    }

    public function isIso8601DateString( string : String ) : Bool return DateTime.isIso8601DateString(string);

    /**
     * Determines if a value from Graph should be cast to DateTime.
     */
    public function shouldCastAsDateTime( key : String ) : Bool
    {
        return dateFields.indexOf(key) > -1;
    }
    static var dateFields = [
        'created_time',
        'updated_time',
        'start_time',
        'end_time',
        'backdated_time',
        'issued_at',
        'expires_at',
        'publish_time',
        'joined'
    ];

    /**
     * Casts a date value from Graph to DateTime.
     * @param int|string $value
     * @return DateTime
     */
    public function castToDateTime( value : Dynamic ) : Date
    {
        if (Std.is(value, Float))
            return Date.fromTime(cast(value, Float) * 1000.0);
        
        else if (Std.is(value, String))
        {
            var s = cast(value, String);

            // 2013-12-24T00:34:20+0000
            if (DateTime.isIso8601DateString(s))
                return DateTime.parseIso8601DateString(s);
            else
                return Date.fromString(s);
        }
        
        return null;
    }

    /**
     * Casts a birthday value from Graph to Birthday
     */
    public function castToBirthday( value : String ) : Birthday return new Birthday(value);

    /**
     * Getter for $graphObjectMap.
     * @return array
     */
    public static function getObjectMap( )
    {
        return graphObjectMap;
    }
}

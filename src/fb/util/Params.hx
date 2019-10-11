package fb.util;

import haxe.ds.ArraySort;
import fb.auth.AccessToken;
import haxe.ds.StringMap;

using StringTools;


@:forward(keys,get,set)
abstract Params(StringMap<Dynamic>)
{
    public var isEmpty(get, never) : Bool;

    inline public function new( ?sm : StringMap<Dynamic> ) : Void
    {
        this = sm != null ? sm : new StringMap();
    }

    @:from inline static public function fromStringMap( sm : StringMap<Dynamic> ) : Params return new Params(sm);

    @:to inline public function toStringMap( ) : StringMap<Dynamic> return this;

    @:arrayAccess inline public function getValue( key : String ) return this.get(key);

    @:arrayAccess inline public function setValue<V>( k : String, v : V ) : V
    {
        this.set(k, v);
        return v;
    }

    public function toString( ) : String
    {
        var o = [];
        for (k in this.keys())
        {
            var v = this.get(k);
            o.push('$k => $v');
        }
        return '{' + o.join(', ') + '}';
    }

    inline public function has( k : String ) : Bool return this.exists(k);
    inline public function del( k : String ) : Void this.remove(k);
    inline public function clone( ) : Params return new Params(this.copy());
    function get_isEmpty( ) : Bool return !this.keys().hasNext();
    // inline public function keys( ) : Iterator<String> return this.keys();

    inline public function append( p : Params ) : Void
    {
        for (k in p.keys())
            if (!this.exists(k))
                this.set(k, p[k]);
    }
    /*
    inline public function appendObj( o : {} ) : Void
    {
        for (f in Reflect.fields(o))
            if (!this.exists(f))
                this.set(f, Reflect.field(o, f));
    }
    */

    inline public function toQuery( separator : String = '&' ) : String
    {
        var a = [];
        var keys = [];
        for (k in this.keys())
            keys.push(k);
        
        keys.sort(function(a, b) return a > b ? 1 : (a < b ? -1 : 0));
        
        for (k in keys)
            for (q in keyValueQuery(k, this.get(k)))
                a.push(q);
        return a.join(separator);
    }
    inline static function keyValueQuery( k : String, v : Dynamic ) : Array<String>
    {
        var a = [];

        var ke = k.urlEncode();
        if (k == 'access_token')
        {
            var at : AccessToken = v;
            a.push('$ke=' + '$at'.urlEncode());
        }
        else switch (Type.typeof(v))
        {
            case TInt, TFloat, TBool:
                var s = Std.string(v);
                a.push('$ke=' + s.urlEncode());
            
            case TClass(String):
                var s = cast(v, String);
                a.push('$ke=' + s.urlEncode().replace('%20', '+'));
            
            case TClass(Date):
                var d : Date = cast(v, Date);
                a.push('$ke=' + DateTools.format(d, DateTime.ISO8601).urlEncode());

            case TClass(Array):
                var arr : Array<Dynamic> = cast(v, Array<Dynamic>);
                for (i in 0...arr.length)
                    for (q in keyValueQuery('$k[$i]', arr[i]))
                        a.push(q);

            case TClass(StringMap):
                var sm : StringMap<Dynamic> = cast(v, StringMap<Dynamic>);
                for (key in sm.keys())
                    for (q in keyValueQuery('$k[$key]', sm.get(key)))
                        a.push(q);
            
            case TObject:
                for (key in Reflect.fields(v))
                    for (q in keyValueQuery('$k[$key]', Reflect.field(v, key)))
                        a.push(q);
            
            case TUnknown: // skip
            case TFunction: // skip
            case TNull: // skip
            case TEnum(_): // skip
            case TClass(c): // skip
        }
        return a;
    }

    public static function fromQuery( query : String ) : Params
    {
        var params = new Params();
        if (query == '')
            return params;
        
        var pairs = query.split('&');
        for( pair in pairs )
        {
            var kv = pair.split('=');
            params[kv[0]] = StringTools.urlDecode(kv[1]);
        }
        return params;
    }
}
package fb.util;

class ObjectTools
{
    // object += obj
    public static function append( obj : Dynamic, ext : Dynamic ) : Dynamic
    {
        var o = Reflect.copy(obj);
        if (ext == null)
            return o;
        
        for (f in Reflect.fields(ext))
            if (!Reflect.hasField(o, f) || Reflect.field(o, f) == null)
                Reflect.setField(o, f, Reflect.field(ext, f));
        
        return o;
    }

    // array_merge
    public static function merge<A>( obj : Dynamic, ext : A ) : A
    {
        var o = Reflect.copy(obj);
        if (ext == null)
            return o;
        for (f in Reflect.fields(ext))
        {
            var v = Reflect.field(ext, f);
            if (!Reflect.hasField(o, f) || v != null)
                Reflect.setField(o, f, v);
        }
        return o;
    }
}
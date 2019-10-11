package fb.graph;

import haxe.CallStack;
import haxe.Json;
import haxe.ds.StringMap;


class Collection // implements ArrayAccess, Countable, IteratorAggregate
{
    /**
     * The items contained in the collection.
     */
    var items : StringMap<Dynamic>;

    public var length(get, null) : Int;

    public function new( v : Dynamic )
    {
        switch (Type.typeof(v))
        {
            case TClass(Array):
                items = new StringMap();
                var ar : Array<Dynamic> = cast(v, Array<Dynamic>);
                for (i in 0...ar.length)
                    items.set(Std.string(i), ar[i]);
                
            case TClass(StringMap):
                items = cast(v, StringMap<Dynamic>).copy();

            case TObject:
                items = new StringMap();
                for (f in Reflect.fields(v))
                    items.set(f, Reflect.field(v, f));
            
            default:
                items = new StringMap();
        }
    }

    function get_length( ) : Int
    {
        var i = 0;
        for (item in items) i++;
        return i;
    }


    /**
     * Gets the value of a field from the Graph node.
     * @param string $name    The field to retrieve.
     * @param mixed  $default The default to return if the field doesn't exist.
     * @return mixed
     */
    public function getField<A>( name : String, ?def : A ) : A return items.exists(name) ? items.get(name) : def;

    /**
     * Gets the value of the named property for this graph object.
     * @param string $name    The property to retrieve.
     * @param mixed  $default The default to return if the property doesn't exist.
     * @return mixed
     * @deprecated 5.0.0 getProperty() has been renamed to getField()
     * @todo v6: Remove this method
     */
    public function getProperty<A>( name : String, ?def : A ) : A return getField(name, def);

    /**
     * Returns a list of all fields set on the object.
     * @return Array<String>
     */
    public function getFieldNames( ) : Array<String> return [for (k in items.keys()) k];

    /**
     * Returns a list of all properties set on the object.
     * @return Array<String>
     * @deprecated 5.0.0 getPropertyNames() has been renamed to getFieldNames()
     * @todo v6: Remove this method
     * TODO: [v6] Remove this method
     */
    public function getPropertyNames( ) : Array<String> return this.getFieldNames();

    /**
     * Get all of the items in the collection.
     */
    public function all( ) return this.items;

    /**
     * Get the collection of items as a plain array.
     */
    public function asObject( ) : Dynamic
    {
        var o = {};
        if (items != null) for (k in items.keys())
        {
            var v = items.get(k);
            var val = Std.is(v, Collection) ? cast (v, Collection).asObject() : v;
            Reflect.setField(o, k, val);
        }
        return o;
    }

    /**
     * Run a map over each of the items.
     * @param \Closure $callback
     * @return static
     */
/*
    public function map( callback : Closure )
    {
        return new static(array_map($callback, this.items, array_keys(this.items)));
    }
*/    

    /**
     * Get the collection of items as JSON.
     * @param int $options
     * @return string
     */
    public function asJson( options : Int = 0 ) : String
    {
        // return json_encode(this.asArray(), $options);
        return Json.stringify(asObject());
    }

    /**
     * Count the number of items in the collection.
     * @return Int
     */
    public function count( ) : Int return this.length;

    inline public function child<V:Collection>( i : Int ) : V return items.get(Std.string(i));


    public function iterator( ) : Iterator<Dynamic> return items.iterator();
    public function keyValueIterator( ) : KeyValueIterator<String, Dynamic> return items.keyValueIterator();
    public function set( key : String, value : Dynamic ) : Void items.set(key, value);
    public function get( key : String ) : Dynamic return items.get(key);

/*
    /**
     * Get an iterator for the items.
     *
     * @return ArrayIterator
     * /
    public function getIterator()
    {
        return new ArrayIterator(this.items);
    }

    /**
     * Determine if an item exists at an offset.
     *
     * @param mixed $key
     *
     * @return bool
     * /
    public function offsetExists($key)
    {
        return array_key_exists($key, this.items);
    }

    /**
     * Get an item at a given offset.
     *
     * @param mixed $key
     *
     * @return mixed
     * /
    public function offsetGet($key)
    {
        return this.items[$key];
    }

    /**
     * Set the item at a given offset.
     *
     * @param mixed $key
     * @param mixed $value
     *
     * @return void
     * /
    public function offsetSet($key, $value)
    {
        if (is_null($key)) {
            this.items[] = $value;
        } else {
            this.items[$key] = $value;
        }
    }

    /**
     * Unset the item at a given offset.
     *
     * @param string $key
     *
     * @return void
     * /
    public function offsetUnset($key)
    {
        unset(this.items[$key]);
    }
*/
    /**
     * Convert the collection to its string representation.
     * @return string
     */
    public function toString( ) : String
    {
        return this.asJson();
    }
}
package fb.persist;

import haxe.ds.StringMap;

class FacebookMemoryPersistentDataHandler implements PersistentDataInterface
{
    /**
     * @var array The session data to keep in memory.
     */
    var sessionData : StringMap<Dynamic> = new StringMap();

    public function new( )
    {

    }

    /**
     * @inheritdoc
     */
    public function get( key : String ) : Dynamic
    {
        return sessionData.get(key);
    }

    /**
     * @inheritdoc
     */
    public function set( key : String, value : Dynamic ) : Void
    {
        sessionData.set(key, value);
    }
}

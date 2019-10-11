package fixtures;

import fb.persist.PersistentDataInterface;

class FooPersistentDataInterface implements PersistentDataInterface
{
    public function new( )
    {
        
    }

    public function get( key : String ) : Dynamic
    {
        return 'foo';
    }

    public function set( key : String, value : Dynamic ) : Void
    {
        
    }
}

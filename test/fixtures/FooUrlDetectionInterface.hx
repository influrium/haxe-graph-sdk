package fixtures;

import fb.url.UrlDetectionInterface;

class FooUrlDetectionInterface implements UrlDetectionInterface
{
    public function new( )
    {
        
    }

    public function getCurrentUrl( ) : String
    {
        return 'https://foo.bar';
    }
}

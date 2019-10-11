package fb.httpclient;

import fb.error.*;


class HttpClientsFactory
{
    private function new( )
    {
        // a factory constructor should never be invoked
    }

    /**
     * HTTP client generation.
     *
     * @param FacebookHttpClientInterface|Client|string|null $handler
     * @return FacebookHttpClientInterface
     */
    public static function createHttpClient( ?handler : Dynamic ) : FacebookHttpClientInterface
    {
        if (handler == null)
            return detectDefaultClient();

        if (Std.is(handler, FacebookHttpClientInterface))
            return handler;

        if ('stream' == handler)
            return new FacebookHttpClient();
        
        if ('curl' == handler)
        {
        #if necurl
            return new FacebookCurlHttpClient();
        #else
            throw new Exception('The cURL extension must be loaded in order to use the "curl" handler.');
        #end
        
            return null;
        }

        throw new InvalidArgumentException('The http client handler must be set to "curl", "stream", be an instance of fb.httpclients.FacebookHttpClientInterface');
        return null;
    }

    /**
     * Detect default HTTP client.
     *
     * @return FacebookHttpClientInterface
     */
    private static function detectDefaultClient( ) : FacebookHttpClientInterface
    {
#if necurl
            return new FacebookCurlHttpClient();
#end
        return new FacebookHttpClient();
    }
}
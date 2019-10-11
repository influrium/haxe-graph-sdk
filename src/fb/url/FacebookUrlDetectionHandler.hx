package fb.url;

using StringTools;


class FacebookUrlDetectionHandler implements UrlDetectionInterface
{
    public function new( )
    {

    }

    /**
     * @inheritdoc
     */
    public function getCurrentUrl( )
    {
        // return getHttpScheme() + '://' + getHostName() + getRequestUri();
        return getHostName() + getRequestUri();
    }

    /**
     * Get the currently active URL scheme.
     */
    // function getHttpScheme( ) : String return isBehindSsl() ? 'https' : 'http';

    /**
     * Tries to detect if the server is running behind an SSL.
     */
/*
    function isBehindSsl( ) : Bool
    {
        // Check for proxy first
        var protocol = getHeader('X_FORWARDED_PROTO');
        if (protocol != null)
            return protocolWithActiveSsl(protocol);

        protocol = getServerVar('HTTPS');
        if (protocol != null)
            return protocolWithActiveSsl(protocol);

        return Std.string(getServerVar('SERVER_PORT')) == '443';
    }
*/
    /**
     * Detects an active SSL protocol value.
     */
    function protocolWithActiveSsl( protocol : String ) : Bool
    {
        return ['on', '1', 'https', 'ssl'].indexOf(protocol.toLowerCase()) > -1;
    }

    function getRequestUri( ) : String
    {
    #if neko
        return neko.Web.getURI();
    #else
        #error
    #end
        // return getServerVar('REQUEST_URI');
    }

    /**
     * Tries to detect the host name of the server.
     * Some elements adapted from
     * @see https://github.com/symfony/HttpFoundation/blob/master/Request.php
     */
    function getHostName( ) : String
    {
    #if neko
        return neko.Web.getHostName();
    #else
        #error
    #end
/*
        var host = '';
        // Check for proxy first
        
        var header = getHeader('X_FORWARDED_HOST');
        if (header != null && isValidForwardedHost(header))
        {
            var elements = header.split(',');
            host = elements[elements.length - 1];
        }
        else if ((host = getHeader('HOST')) != null)
            if ((host = getServerVar('SERVER_NAME')) != null)
                host = getServerVar('SERVER_ADDR');

        // trim and remove port number from host
        // host is lowercase as per RFC 952/2181
        host = ~/:\d+$/.replace(host.trim(), '').toLowerCase();

        // Port number
        var scheme = getHttpScheme();
        var port = getCurrentPort();
        var appendPort = ':$port';

        // Don't append port number if a normal port.
        if ((scheme == 'http' && port == '80') || (scheme == 'https' && port == '443'))
            appendPort = '';

        return host + appendPort;
*/
    }
/*
    function getCurrentPort( ) : String
    {
        // Check for proxy first
        var port = getHeader('X_FORWARDED_PORT');
        if (port != null)
            return port;

        var protocol = getHeader('X_FORWARDED_PROTO');
        if (protocol == 'https')
            return '443';

        return getServerVar('SERVER_PORT');
    }
*/
    /**
     * Returns the a value from the $_SERVER super global.
     */
/*
    function getServerVar( key : String ) : String
    {
        return $_SERVER[key] != null ? $_SERVER[key] : '';
    }
*/
    /**
     * Gets a value from the HTTP request headers.
     */
/*
    function getHeader( key : String ) : String
    {
        return getServerVar('HTTP_$key');
    }
*/
    /**
     * Checks if the value in X_FORWARDED_HOST is a valid hostname
     * Could prevent unintended redirections
     */
    function isValidForwardedHost( header : String ) : Bool
    {
        var elements = header.split(',');
        var host = elements[elements.length - 1];

/*        
        return preg_match("/^([a-z\d](-*[a-z\d])*)(\.([a-z\d](-*[a-z\d])*))*$/i", $host) //valid chars check
            && 0 < strlen($host) && strlen($host) < 254 //overall length check
            && preg_match("/^[^\.]{1,63}(\.[^\.]{1,63})*$/", $host); //length of each label
*/
        return erHostValidChars.match(host)         //valid chars check
            && 0 < host.length && host.length < 254 //overall length check
            && erHostLength.match(host); //length of each label
    }

    static var erHostValidChars : EReg = ~/^([a-z\d](-*[a-z\d])*)(\.([a-z\d](-*[a-z\d])*))*$/i;
    static var erHostLength : EReg = ~/^[^\.]{1,63}(\.[^\.]{1,63})*$/;
}
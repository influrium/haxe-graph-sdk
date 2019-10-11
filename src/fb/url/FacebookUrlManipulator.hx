package fb.url;

import fb.util.UrlTools;
import fb.util.Params;

// using fb.util.ObjectTools;


class FacebookUrlManipulator
{
    /**
     * Remove params from a URL.
     * @param url            The URL to filter.
     * @param paramsToFilter The params to filter from the URL.
     * @return String        The URL with the params removed.
     */
    public static function removeParamsFromUrl( url : String, paramsToFilter : Array<String> ) : String
    {
        var parts = UrlTools.urlparse(url);
        var query = '';
        if (parts.query != null)
        {
            var params = UrlTools.queryparse(parts.query);

            // Remove query params
            for (key in paramsToFilter)
                Reflect.deleteField(params, key);

            if ( Reflect.fields(params).length > 0)
                query = '?' + UrlTools.http_build_query(params);
        }

        var scheme = parts.scheme != null && parts.scheme.length > 0 ? parts.scheme + '://' : '';
        // var host = parts.host != null ? parts.host : '';
        // var port = parts.port != null ? ':' + parts.port : '';
        var netloc = parts.netloc != null && parts.netloc.length > 0 ? parts.netloc : '';

        var path = parts.path != null ? parts.path : '';
        var params = parts.params != null && parts.params.length > 0 ? ';' + parts.params : '';
        var fragment = parts.fragment != null && parts.fragment.length > 0 ? '#' + parts.fragment : '';

        // return scheme + host + port + path + query + fragment;
        return scheme + netloc + path + params + query + fragment;
    }

    /**
     * Gracefully appends params to the URL.
     * @param url       The URL that will receive the params.
     * @param newParams The params to append to the URL.
     * @return String
     */
    public static function appendParamsToUrl( url : String, ?newParams : Params ) : String
    {
        if (newParams == null || newParams.isEmpty)
            return url;
        
        if (url.indexOf('?') < 0)
            return url + '?' + newParams.toQuery();

        var pq = url.split('?');
        var existingParams = Params.fromQuery(pq[1]);

        // Favor params from the original URL over $newParams
        newParams.append(existingParams);

        // Sort for a predicable order
        // ksort(newParams);

        return pq[0] + '?' + newParams.toQuery();
    }

    /**
     * Returns the params from a URL in the form of an array.
     * @param url 
     * @return Dynamic<String>
     */
    public static function getParamsAsObject( url : String ) : Params
    {
        if (url == null)
            url = '';

        var query = UrlTools.urlparse(url).query;

        if (query == null || query.length == 0)
            return new Params();
        
        return Params.fromQuery(query);
    }

    /**
     * Adds the params of the first URL to the second URL.
     * Any params that already exist in the second URL will go untouched.
     * @param urlToStealFrom The URL harvest the params from.
     * @param urlToAddTo     The URL that will receive the new params.
     * @return String        The 'urlToAddTo' with any new params from 'urlToStealFrom'.
     */
    public static function mergeUrlParams( urlToStealFrom : String, urlToAddTo : String ) : String
    {
        var newParams : Params = getParamsAsObject(urlToStealFrom);

        // Nothing new to add, return as-is
        if (newParams == null && newParams.isEmpty)
            return urlToAddTo;
        
        return appendParamsToUrl(urlToAddTo, newParams);
    }

    /**
     * Check for a "/" prefix and prepend it if not exists.
     * @param string 
     * @return String
     */
    public static function forceSlashPrefix( ?s : String ) : String
    {
        if (s == null || s.length < 1)
            return s;
        
        return s.indexOf('/') == 0 ? s : '/' + s;
    }

    /**
     * Trims off the hostname and Graph version from a URL.
     * @param urlToTrim The URL the needs the surgery.
     * @return String   The 'urlToTrim' with the hostname and Graph version removed.
     */
    inline public static function baseGraphUrlEndpoint( urlToTrim : String ) : String
    {
        // return '/' . preg_replace('/^https:\/\/.+\.facebook\.com(\/v.+?)?\//', '', urlToTrim);
        return '/' + erUrlEndpoint.replace(urlToTrim, '');
    }
    static var erUrlEndpoint = ~/^https:\/\/.+\.facebook\.com(\/v.+?)?\//;
}
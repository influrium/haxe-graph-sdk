package fb.util;


class UrlTools
{
    public static function urlparse( url : String )
    {
        if(url == null)
            url = '';
		var er = ~/^((https?):\/\/)?([a-zA-Z\.0-9_-]+)?(:[0-9]+)?(.*)$/;

		if (!er.match(url))
			return null;
        
        var scheme = er.matched(2);
        var host = er.matched(3);
        var port = er.matched(4);
        var path = er.matched(5);

        var p1 = path.split('?');
        var p2 = p1[0] != null ? p1[0].split(';') : ['',''];
        var p3 = p1[1] != null ? p1[1].split('#') : ['',''];

        return {
            scheme: scheme,
            netloc: (host != null ? host : '') + (port != null ? port : ''),
            path: p2[0],
            params: p2[1],
            query: p3[0],
            fragment: p3[1],
        };
    }
    public static function queryparse( query : String ) : Dynamic<String>
    {
        var o = {};
        if (query == '')
            return o;
        
        var pairs = query.split('&');
        for( pair in pairs )
        {
            var kv = pair.split('=');
            var k = kv[0];
            var v = kv[1] != null ? StringTools.urlDecode(kv[1]) : '';
            Reflect.setField(o, k, v);
        }
        return o;
    }

    inline public static function http_build_query( params : Dynamic<String>, separator : String = '&' ) : String
        return [for(f in Reflect.fields(params)) f + '=' + StringTools.urlEncode(Reflect.field(params, f))].join(separator);

/*
    public static function queryParseParams( query : String ) : Params
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
    inline public static function http_build_query_params( params : Params, separator : String = '&' ) : String
        return [for(f in params.keys()) '$f=${params[f]}'].join(separator);
*/
}
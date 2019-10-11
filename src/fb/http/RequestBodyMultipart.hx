package fb.http;

import fb.util.*;
import fb.upload.FacebookFile;
import haxe.ds.StringMap;

/**
 * Class RequestBodyMultipartt
 * Some things copied from Guzzle
 * @see https://github.com/guzzle/guzzle/blob/master/src/Post/MultipartBody.php
 */
class RequestBodyMultipart implements RequestBodyInterface
{
    /**
     * The boundary.
     */
    public var boundary (default, null) : String;

    /**
     * The parameters to send with this request.
     */
    var params : Params;

    /**
     * The files to send with this request.
     */
    var files : StringMap<FacebookFile> = new StringMap();

    /**
     * @param params   The parameters to send with this request.
     * @param files    The files to send with this request.
     * @param boundary Provide a specific boundary.
     */
    public function new( params : Params, files : StringMap<FacebookFile>, ?boundary : String )
    {
        this.params = params;
        this.files = files;
        this.boundary = boundary != null ? boundary : MiscTools.uniqid();
    }

    /**
     * @inheritdoc
     */
    public function getBody( ) : String
    {
        var body = '';

        // Compile normal params
        var params : Params = getNestedParams(this.params);
        var keys = [for (k in params.keys()) k];
        keys.sort(function(a, b) return a > b ? 1 : (a < b ? -1 : 0));
        for (k in keys)
            body += getParamString(k, params[k]);
        
        // Compile files
        var keys = [for (k in files.keys()) k];
        keys.sort(function(a, b) return a > b ? 1 : (a < b ? -1 : 0));
        for (k in keys)
            body += getFileString(k, files.get(k));
        
        // Peace out
        body += '--$boundary--\r\n';

        return body;
    }

    /**
     * Get the string needed to transfer a file.
     * @param name 
     * @param file 
     * @return String
     */
    function getFileString( name : String, file : FacebookFile ) : String
    {
        var fileName : String = file.getFileName();
        var headers : String = getFileHeaders(file);
        var content : String = file.getContents();
        return '--$boundary\r\nContent-Disposition: form-data; name=\"$name\"; filename=\"$fileName\"$headers\r\n\r\n$content\r\n';
    }

    /**
     * Get the string needed to transfer a POST field.
     * @param name 
     * @param value 
     * @return String
     */
    function getParamString( name : String, value : String ) : String
    {
        return '--$boundary\r\nContent-Disposition: form-data; name=\"$name\"\r\n\r\n$value\r\n';
    }

    /**
     * Returns the params as an array of nested params.
     * @param params 
     * @return Dynamic<String>
     */
    function getNestedParams( params : Params ) : Params
    {
        var query = params.toQuery();
        var pairs : Array<String> = query.split('&');
        var result = new Params();
        for (pair in pairs)
        {
            var kv = pair.split('=');
            var k = StringTools.urlDecode(kv[0]);
            var v = StringTools.urlDecode(kv[1]);
            result[k] = v;
        }
        return result;
    }

    /**
     * Get the headers needed before transferring the content of a POST file.
     * @param file 
     * @return String
     */
    function getFileHeaders( file : FacebookFile ) : String
    {
        return '\r\nContent-Type: ${file.getMimetype()}';
    }
}
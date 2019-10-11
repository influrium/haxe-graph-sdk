package fixtures;

import haxe.CallStack;
import haxe.ds.StringMap;
import haxe.Json;

import fb.http.GraphRawResponse;
import fb.httpclient.FacebookHttpClientInterface;


class FakeGraphApiForResumableUpload implements FacebookHttpClientInterface
{
    public var transferCount = 0;
    var respondWith = 'SUCCESS';

    public function new( )
    {
        
    }

    public function failOnStart( )
    {
        respondWith = 'FAIL_ON_START';
    }

    public function failOnTransfer( )
    {
        respondWith = 'FAIL_ON_TRANSFER';
    }

    public function failOnTransferAndUploadNewChunk( )
    {
        respondWith = 'FAIL_ON_TRANSFER_AND_UPLOAD_NEW_CHUNK';
    }

    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse
    {
        // Could be start, transfer or finish
        if (body.indexOf('transfer') > -1)
            return respondTransfer();
        
        else if (body.indexOf('finish') > -1)
            return respondFinish();

        return respondStart();
    }

    function respondStart( )
    {
        if (respondWith == 'FAIL_ON_START')
            return new GraphRawResponse(
                '{"error":{"message":"Error validating access token: Session has expired on Monday, ' +
                '10-Aug-15 01:00:00 PDT. The current time is Monday, 10-Aug-15 01:14:23 PDT.",' +
                '"type":"OAuthException","code":190,"error_subcode":463}}',
                "HTTP/1.1 500 OK\r\nFoo: Bar"
            );

        return new GraphRawResponse(
            '{"video_id":"1337","start_offset":"0","end_offset":"20","upload_session_id":"42"}',
            "HTTP/1.1 200 OK\r\nFoo: Bar"
        );
    }

    function respondTransfer( )
    {
        if (respondWith == 'FAIL_ON_TRANSFER')
            return new GraphRawResponse(
                '{"error":{"message":"There was a problem uploading your video. Please try uploading it again.",' +
                '"type":"FacebookApiException","code":6000,"error_subcode":1363019}}',
                "HTTP/1.1 500 OK\r\nFoo: Bar"
            );

        if (respondWith == 'FAIL_ON_TRANSFER_AND_UPLOAD_NEW_CHUNK')
            return new GraphRawResponse(
                '{"error":{"message":"There was a problem uploading your video. Please try uploading it again.",' +
                '"type":"OAuthException","code":6001,"error_subcode":1363037,' +
                '"error_data":{"start_offset":40,"end_offset":50}}}',
                "HTTP/1.1 500 OK\r\nFoo: Bar"
            );

        var data = switch(transferCount)
        {
            case 0:  {start_offset: 20, end_offset: 40};
            case 1:  {start_offset: 40, end_offset: 50};
            default: {start_offset: 50, end_offset: 50};
        }

        transferCount++;

        return new GraphRawResponse(Json.stringify(data), "HTTP/1.1 200 OK\r\nFoo: Bar");
    }

    function respondFinish( )
    {
        return new GraphRawResponse('{"success":true}', "HTTP/1.1 200 OK\r\nFoo: Bar");
    }
}

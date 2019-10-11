package fb.upload;

import haxe.CallStack;
import fb.util.Params;
import fb.error.FacebookResumableUploadException;
import fb.error.FacebookResponseException;
import fb.util.ObjectTools;
import fb.auth.AccessToken;

class FacebookResumableUploader
{
    var app : FacebookApp;
    var accessToken : AccessToken;
    /**
     * The Facebook client service.
     */
    var client : FacebookClient;
    /**
     * Graph version to use for this request.
     */
    var graphVersion : GraphVersion;

    /**
     * @param FacebookApp             $app
     * @param FacebookClient          $client
     * @param AccessToken|string|null $accessToken
     * @param string                  $graphVersion
     */
    public function new( app : FacebookApp, client : FacebookClient, accessToken : AccessToken, graphVersion : GraphVersion )
    {
        this.app = app;
        this.client = client;
        this.accessToken = accessToken;
        this.graphVersion = graphVersion;
    }

    /**
     * Upload by chunks - start phase
     * @param string $endpoint
     * @param FacebookFile $file
     * @return FacebookTransferChunk
     */
    public function start( endpoint : String, file : FacebookFile ) : FacebookTransferChunk
    {
        var params = new Params([
            'upload_phase' => 'start',
            'file_size' => file.getSize(),
        ]);

        var response = sendUploadRequest(endpoint, params);

        return new FacebookTransferChunk(file, response.upload_session_id, response.video_id, response.start_offset, response.end_offset);
    }

    /**
     * Upload by chunks - transfer phase
     * @param string $endpoint
     * @param FacebookTransferChunk $chunk
     * @param boolean $allowToThrow
     * @return FacebookTransferChunk
     */
    public function transfer( endpoint : String, chunk : FacebookTransferChunk, allowToThrow : Bool = false) : FacebookTransferChunk
    {
        var params = new Params([
            'upload_phase' => 'transfer',
            'upload_session_id' => chunk.uploadSessionId,
            'start_offset' => chunk.startOffset,
            'video_file_chunk' => chunk.getPartialFile(),
        ]);

        var response = null;
        try
        {
            response = sendUploadRequest(endpoint, params);
        }
        catch ( e : FacebookResponseException )
        {
            var preException = e.previous;

            if (allowToThrow || !Std.is(preException, FacebookResumableUploadException))
            #if neko
                neko.Lib.rethrow(e);
            #else
                throw e;
            #end
            
            var pe : FacebookResumableUploadException = cast (preException, FacebookResumableUploadException);

            if (null != pe.startOffset && null != pe.endOffset)
            {
                return new FacebookTransferChunk(
                    chunk.file,
                    chunk.uploadSessionId,
                    chunk.videoId,
                    pe.startOffset,
                    pe.endOffset
                );
            }

            // Return the same chunk entity so it can be retried.
            return chunk;
        }
        return new FacebookTransferChunk(chunk.file, chunk.uploadSessionId, chunk.videoId, response.start_offset, response.end_offset);
    }

    /**
     * Upload by chunks - finish phase
     * @param string $endpoint
     * @param string $uploadSessionId
     * @param array $metadata The metadata associated with the file.
     */
    public function finish( endpoint : String, uploadSessionId : String, metadata : Params ) : Bool
    {
        var params : Params = metadata.clone();
        params.append(new Params([
            'upload_phase' => 'finish',
            'upload_session_id' => uploadSessionId,
        ]));

        var response = sendUploadRequest(endpoint, params);

        return response.success;
    }

    /**
     * Helper to make a FacebookRequest and send it.
     * @param string $endpoint The endpoint to POST to.
     * @param array $params The params to send with the request.
     */
    function sendUploadRequest( endpoint : String, params : Params ) : {video_id : String, upload_session_id: String, start_offset: Int, end_offset: Int, success: Bool}
    {
        var request = new FacebookRequest(app, accessToken, 'POST', endpoint, params, null, graphVersion);

        var body = client.sendRequest(request).decodedBody;
        return {
            video_id: body.video_id,
            upload_session_id: body.upload_session_id,
            start_offset: body.start_offset != null ? Std.parseInt(body.start_offset) : null,
            end_offset: body.end_offset != null ? Std.parseInt(body.end_offset) : null,
            success: body.success != null ? body.success : false,
        };
    }
}
package fb.error;


class FacebookResponseException extends FacebookSDKException
{
    /**
     * The response that threw the exception.
     */
    public var response (default, null) : FacebookResponse;

    /**
     * Decoded response.
     */
    public var responseData (default, null) : Dynamic<String>;

    /**
     * Creates a FacebookResponseException.
     * @param response          The response that threw the exception.
     * @param previousException The more detailed exception.
     */
    public function new( response : FacebookResponse, ?previousException : FacebookSDKException )
    {
        this.response = response;
        this.responseData = response.decodedBody;

        var errorMessage = this.get('message', 'Unknown error from Graph.');
        var errorCode = this.get('code', -1);

        super(errorMessage, errorCode, previousException);
    }

    /**
     * A factory for creating the appropriate exception based on the response from Graph.
     * @param response The response that threw the exception.
     * @return FacebookResponseException
     */
    public static function create( response : FacebookResponse ) : FacebookResponseException
    {
        var data : Dynamic = response.decodedBody;

        if (data.error.code == null && data.code != null)
            data = {error: data};

        var code = data.error.code != null ? data.error.code : null;
        var message = data.error.message != null ? data.error.message : 'Unknown error from Graph.';

        if (data.error.error_subcode != null)
        {
            switch (data.error.error_subcode)
            {
                // Other authentication issues
                case 458, 459, 460, 463, 464, 467:
                    return new FacebookResponseException(response, new FacebookAuthenticationException(message, code));
                
                // Video upload resumable error
                case 1363030, 1363019, 1363033, 1363021, 1363041:
                    return new FacebookResponseException(response, new FacebookResumableUploadException(message, code));
                
                case 1363037:
                    var previousException = new FacebookResumableUploadException(message, code);

                    var startOffset = data.error.error_data.start_offset != null ? Std.parseInt(data.error.error_data.start_offset) : null;
                    previousException.setStartOffset(startOffset);

                    var endOffset = data.error.error_data.end_offset != null ? Std.parseInt(data.error.error_data.end_offset) : null;
                    previousException.setEndOffset(endOffset);

                    return new FacebookResponseException(response, previousException);
            }
        }

        switch (code)
        {
            // Login status or token expired, revoked, or invalid
            case 100, 102, 190:
                return new FacebookResponseException(response, new FacebookAuthenticationException(message, code));

            // Server issue, possible downtime
            case 1, 2:
                return new FacebookResponseException(response, new FacebookServerException(message, code));

            // API Throttling
            case 4, 17, 32, 341, 613:
                return new FacebookResponseException(response, new FacebookThrottleException(message, code));

            // Duplicate Post
            case 506:
                return new FacebookResponseException(response, new FacebookClientException(message, code));
        }

        // Missing Permissions
        if (code == 10 || (code >= 200 && code <= 299))
            return new FacebookResponseException(response, new FacebookAuthorizationException(message, code));

        // OAuth authentication error
        if (data.error.type != null && data.error.type == 'OAuthException')
            return new FacebookResponseException(response, new FacebookAuthenticationException(message, code));

        // All others
        return new FacebookResponseException(response, new FacebookOtherException(message, code));
    }

    /**
     * Checks isset and returns that or a default value.
     * @param key 
     * @param def deafult
     * @return A
     */
    function get<A>( key : String, ?def : A ) : A
    {
        var v = Reflect.field(responseData.error, key);
        return v != null ? v : def;
    }

    /**
     * Returns the HTTP status code
     * @return Int
     */
    public function getHttpStatusCode( ) : Int return response.httpStatusCode;

    /**
     * Returns the sub-error code
     * @return Int
     */
    public function getSubErrorCode( ) : Int return get('error_subcode', -1);

    /**
     * Returns the error type
     * @return String
     */
    public function getErrorType( ) : String return get('type', '');

    /**
     * Returns the raw response used to create the exception.
     * @return String
     */
    public function getRawResponse( ) : String return response.body;
}
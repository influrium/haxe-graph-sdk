package fb.http;


interface RequestBodyInterface
{
    /**
     * Get the body of the request to send to Graph.
     * @return String
     */
    public function getBody( ) : String;
}
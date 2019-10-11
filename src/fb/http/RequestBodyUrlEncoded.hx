package fb.http;

import fb.util.Params;

class RequestBodyUrlEncoded implements RequestBodyInterface
{
    /**
     * The parameters to send with this request.
     */
    var params : Params;

    public function new( params : Params )
    {
        this.params = params;
    }

    /**
     * @inheritdoc
     */
    public function getBody( ) : String
    {
        return params.toQuery();
    }
}
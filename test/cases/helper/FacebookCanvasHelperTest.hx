package cases.helper;

import utest.Assert;

import fb.FacebookClient;
import fb.FacebookApp;
import fb.helpers.FacebookCanvasHelper;


class FacebookCanvasHelperTest extends utest.Test
{
    var rawSignedRequestAuthorized = 'vdZXlVEQ5NTRRTFvJ7Jeo_kP4SKnBDvbNP0fEYKS0Sg=.eyJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsImFsZ29yaXRobSI6IkhNQUMtU0hBMjU2IiwiaXNzdWVkX2F0IjoxNDAyNTUxMDMxLCJ1c2VyX2lkIjoiMTIzIn0=';

    var helper : FacebookCanvasHelper;

    function setup( )
    {
        var app = new FacebookApp('123', 'foo_app_secret');
        this.helper = new FacebookCanvasHelper(app, new FacebookClient());
    }

    public function testSignedRequestDataCanBeRetrievedFromPostData( )
    {
    #if neko
        untyped neko.Web.getParams = function() return ['signed_request' => this.rawSignedRequestAuthorized];
    #end
        var rawSignedRequest = this.helper.getRawSignedRequest();

        Assert.equals(this.rawSignedRequestAuthorized, rawSignedRequest);
    }
}
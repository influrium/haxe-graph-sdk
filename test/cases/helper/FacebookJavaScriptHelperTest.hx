package cases.helper;

import utest.Assert;

import fb.FacebookClient;
import fb.FacebookApp;
import fb.helpers.FacebookJavaScriptHelper;


class FacebookJavaScriptHelperTest extends utest.Test
{
    var rawSignedRequestAuthorized = 'vdZXlVEQ5NTRRTFvJ7Jeo_kP4SKnBDvbNP0fEYKS0Sg=.eyJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsImFsZ29yaXRobSI6IkhNQUMtU0hBMjU2IiwiaXNzdWVkX2F0IjoxNDAyNTUxMDMxLCJ1c2VyX2lkIjoiMTIzIn0=';

    public function testARawSignedRequestCanBeRetrievedFromCookieData( )
    {
    #if neko
        untyped neko.Web.getCookies = function() return ['fbsr_123' => this.rawSignedRequestAuthorized];
    #end
    
        var app = new FacebookApp('123', 'foo_app_secret');
        var helper = new FacebookJavaScriptHelper(app, new FacebookClient());

        var rawSignedRequest = helper.getRawSignedRequest();

        Assert.equals(this.rawSignedRequestAuthorized, rawSignedRequest);
    }
}
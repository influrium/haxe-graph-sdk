package cases.http;

import utest.Assert;

import fb.http.GraphRawResponse;

using StringTools;


class GraphRawResponseTest extends utest.Test
{
    var fakeRawProxyHeader = "HTTP/1.0 200 Connection established\r\nProxy-agent: Kerio Control/7.1.1 build 1971\r\n\r\n";
    var fakeRawHeader =
"HTTP/1.1 200 OK
Etag: \"9d86b21aa74d74e574bbb35ba13524a52deb96e3\"
Content-Type: text/javascript; charset=UTF-8
X-FB-Rev: 9244768
Date: Mon, 19 May 2014 18:37:17 GMT
X-FB-Debug: 02QQiffE7JG2rV6i/Agzd0gI2/OOQ2lk5UW0=
Access-Control-Allow-Origin: *\r\n\r\n";

    var fakeHeadersAsArray = [
        'Etag' => '"9d86b21aa74d74e574bbb35ba13524a52deb96e3"',
        'Content-Type' => 'text/javascript; charset=UTF-8',
        'X-FB-Rev' => '9244768',
        'Date' => 'Mon, 19 May 2014 18:37:17 GMT',
        'X-FB-Debug' => '02QQiffE7JG2rV6i/Agzd0gI2/OOQ2lk5UW0=',
        'Access-Control-Allow-Origin' => '*',
    ];

    var jsonFakeHeader = 'x-fb-ads-insights-throttle: {"app_id_util_pct": 0.00,"acc_id_util_pct": 0.00}';
    var jsonFakeHeaderAsArray = ['x-fb-ads-insights-throttle' => '{"app_id_util_pct": 0.00,"acc_id_util_pct": 0.00}'];

    public function testCanSetTheHeadersFromAnArray( )
    {
        var myHeaders = [
            'foo' => 'bar',
            'baz' => 'faz',
        ];
        var response = new GraphRawResponse(myHeaders, '');
        var headers = response.headers;

        Assert.equals(myHeaders, headers);
    }

    public function testCanSetTheHeadersFromAString( )
    {
        var response = new GraphRawResponse('', this.fakeRawHeader);
        var headers = response.headers;
        var httpResponseCode = response.httpResponseCode;

        Assert.same(this.fakeHeadersAsArray, headers, true);
        Assert.equals(200, httpResponseCode);
    }

    public function testWillIgnoreProxyHeaders( )
    {
        var response = new GraphRawResponse('', this.fakeRawProxyHeader + this.fakeRawHeader);
        var headers = response.headers;
        var httpResponseCode = response.httpResponseCode;

        Assert.same(this.fakeHeadersAsArray, headers, true);
        Assert.equals(200, httpResponseCode);
    }

    public function testCanTransformJsonHeaderValues( )
    {
        var response = new GraphRawResponse('', this.jsonFakeHeader);
        var headers = response.headers;

        Assert.equals(this.jsonFakeHeaderAsArray.get('x-fb-ads-insights-throttle'), headers.get('x-fb-ads-insights-throttle'));
    }
    
    public function testHttpResponseCode( )
    {
        // HTTP/1.0
        var headers = this.fakeRawHeader.replace('HTTP/1.1', 'HTTP/1.0');
        var response = new GraphRawResponse('', headers);
        Assert.equals(200, response.httpResponseCode);
        
        // HTTP/1.1
        var response = new GraphRawResponse('', this.fakeRawHeader);
        Assert.equals(200, response.httpResponseCode);
        
        // HTTP/2
        var headers = this.fakeRawHeader.replace('HTTP/1.1', 'HTTP/2');
        var response = new GraphRawResponse('', headers);
        Assert.equals(200, response.httpResponseCode);
    }
}
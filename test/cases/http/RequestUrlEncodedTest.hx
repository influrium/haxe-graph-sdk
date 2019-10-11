package cases.http;

import utest.Assert;

import haxe.ds.StringMap;

import fb.util.Params;
import fb.http.RequestBodyUrlEncoded;


class RequestUrlEncodedTest extends utest.Test
{
    public function testCanProperlyEncodeAnArrayOfParams( )
    {
        var message = new RequestBodyUrlEncoded(new Params([
            'foo' => 'bar',
            'scawy_vawues' => '@FooBar is a real twitter handle.',
        ]));
        var body = message.getBody();

        Assert.equals('foo=bar&scawy_vawues=%40FooBar+is+a+real+twitter+handle.', body);
    }

    public function testSupportsMultidimensionalParams()
    {
        var message = new RequestBodyUrlEncoded(new Params([
            'foo' => 'bar',
            'faz' => [1,2,3],
            'targeting' => ([
              'countries' => 'US,GB',
              'age_min' => 13,
            ]:StringMap<Dynamic>),
            'call_to_action' => ([
              'type' => 'LEARN_MORE',
              'value' => ([
                'link' => 'http://example.com',
                'sponsorship' => [
                  'image' => 'http://example.com/bar.jpg',
                ],
              ]:StringMap<Dynamic>),
            ]:StringMap<Dynamic>),
        ]));
        var body = message.getBody();
        var bs = [
          'call_to_action%5Btype%5D=LEARN_MORE',
          'call_to_action%5Bvalue%5D%5Bsponsorship%5D%5Bimage%5D=http%3A%2F%2Fexample.com%2Fbar.jpg',
          'call_to_action%5Bvalue%5D%5Blink%5D=http%3A%2F%2Fexample.com',
          'faz%5B0%5D=1',
          'faz%5B1%5D=2',
          'faz%5B2%5D=3',
          'foo=bar',
          'targeting%5Bage_min%5D=13',
          'targeting%5Bcountries%5D=US%2CGB',
        ].join('&');


        Assert.equals(bs, body);
    }
}
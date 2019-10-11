package cases.graph;

import fb.util.DateTime;
import utest.Assert;

import fb.graph.GraphNode;


class GraphNodeTest extends utest.Test
{
    public function testAnEmptyBaseGraphNodeCanInstantiate( )
    {
        var graphNode = new GraphNode();
        var backingData = graphNode.asObject();

        Assert.same({}, backingData, true);
    }

    public function testAGraphNodeCanInstantiateWithData( )
    {
        var graphNode = new GraphNode(['foo' => 'bar']);
        var backingData = graphNode.asObject();

        Assert.same({foo: 'bar'}, backingData, true);
    }

    public function testDatesThatShouldBeCastAsDateTimeObjectsAreDetected( )
    {
        var graphNode = new GraphNode();

        // Should pass
        var shouldPass = graphNode.isIso8601DateString('1985-10-26T01:21:00+0000');
        Assert.isTrue(shouldPass, 'Expected the valid ISO 8601 formatted date from Back To The Future to pass.');

        var shouldPass = graphNode.isIso8601DateString('1999-12-31');
        Assert.isTrue(shouldPass, 'Expected the valid ISO 8601 formatted date to party like it\'s 1999.');

        var shouldPass = graphNode.isIso8601DateString('2009-05-19T14:39Z');
        Assert.isTrue(shouldPass, 'Expected the valid ISO 8601 formatted date to pass.');

        var shouldPass = graphNode.isIso8601DateString('2014-W36');
        Assert.isTrue(shouldPass, 'Expected the valid ISO 8601 formatted date to pass.');

        // Should fail
        var shouldFail = graphNode.isIso8601DateString('2009-05-19T14a39r');
        Assert.isFalse(shouldFail, 'Expected the invalid ISO 8601 format to fail.');

        var shouldFail = graphNode.isIso8601DateString('foo_time');
        Assert.isFalse(shouldFail, 'Expected the invalid ISO 8601 format to fail.');
    }

    public function testATimeStampCanBeConvertedToADateTimeObject( )
    {
        var someTimeStampFromGraph = 1405547020;
        var graphNode = new GraphNode();

        var dateTime = graphNode.castToDateTime(someTimeStampFromGraph);
        Assert.is(dateTime, Date);

        var prettyDate = DateTools.format(dateTime, DateTime.RFC1036);
        Assert.equals('Thu, 17 Jul 14 00:43:40 +0300', prettyDate);

        var timeStamp = Std.int(dateTime.getTime() / 1000.0);
        Assert.equals(1405547020, timeStamp);
    }

    public function no_testAGraphDateStringCanBeConvertedToADateTimeObject( )
    {
        var someDateStringFromGraph = '2014-07-15T03:44:53+0000';
        var graphNode = new GraphNode();
        var dateTime = graphNode.castToDateTime(someDateStringFromGraph);
        var prettyDate = DateTools.format(dateTime, DateTime.RFC1036);
        var timeStamp = Std.int(dateTime.getTime() / 1000.0);

        Assert.is(dateTime, Date);
        Assert.equals('Tue, 15 Jul 14 03:44:53 +0000', prettyDate);
        Assert.equals(1405395893, timeStamp);
    }

    public function testUncastingAGraphNodeWillUncastTheDateTimeObject( )
    {
        // var collectionOne = new GraphNode(['foo', 'bar']);
        var collectionOne = new GraphNode(['0'=>'foo','1'=>'bar']);
        var collectionTwo = new GraphNode([
            'id' => '123',
            'date' => Date.fromString('2014-07-15 03:44:53'),
            'some_collection' => collectionOne,
        ]);

        var uncastArray = collectionTwo.uncastItems();

        Assert.same({
            id: '123',
            date: '2014-07-15T03:44:53+0000',
            some_collection: ['foo', 'bar'],
        }, uncastArray, true);
    }

    public function testGettingGraphNodeAsAnArrayWillNotUncastTheDateTimeObject()
    {
        var collection = new GraphNode([
            'id' => '123',
            'date' => DateTime.parseIso8601DateString('2014-07-15T03:44:53+0000'),
        ]);

        var collectionAsArray = collection.asObject();

        Assert.is(collectionAsArray.date, Date);
    }

    public function testReturningACollectionAsJasonWillSafelyRepresentDateTimes()
    {
        var collection = new GraphNode([
            'id' => '123',
            'date' => DateTime.parseIso8601DateString('2014-07-15T03:44:53+0000'),
        ]);

        var collectionAsString = collection.asJson();

        Assert.equals('{"date":"2014-07-15T03:44:53+0000","id":"123"}', collectionAsString);
    }
}
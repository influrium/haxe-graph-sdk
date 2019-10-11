package cases.graph;

import utest.Assert;

import haxe.ds.StringMap;

import fb.graph.Collection;


class CollectionTest extends utest.Test
{
    public function testAnExistingPropertyCanBeAccessed( )
    {
        var graphNode = new Collection(['foo' => 'bar']);

        var field = graphNode.getField('foo');
        Assert.equals('bar', field);

        // @todo v6: Remove this assertion
        var property = graphNode.getProperty('foo');
        Assert.equals('bar', property);
    }

    public function testAMissingPropertyWillReturnNull()
    {
        var graphNode = new Collection(['foo' => 'bar']);
        var field = graphNode.getField('baz');

        Assert.isNull(field, 'Expected the property to return null.');
    }

    public function testAMissingPropertyWillReturnTheDefault()
    {
        var graphNode = new Collection(['foo' => 'bar']);

        var field = graphNode.getField('baz', 'faz');
        Assert.equals('faz', field);

        // @todo v6: Remove this assertion
        var property = graphNode.getProperty('baz', 'faz');
        Assert.equals('faz', property);
    }

    public function testFalseDefaultsWillReturnSameType()
    {
        var graphNode = new Collection(['foo' => 'bar']);

        var field = graphNode.getField('baz', '');
        Assert.same('', field);

        var field = graphNode.getField('baz', 0);
        Assert.same(0, field);

        var field = graphNode.getField('baz', false);
        Assert.same(false, field);
    }

    public function testTheKeysFromTheCollectionCanBeReturned()
    {
        var graphNode = new Collection([
            'key1' => 'foo',
            'key2' => 'bar',
            'key3' => 'baz',
        ]);

        var fieldNames = graphNode.getFieldNames();
        Assert.same(['key1', 'key2', 'key3'], fieldNames, true);

        // @todo v6: Remove this assertion
        var propertyNames = graphNode.getPropertyNames();
        Assert.same(['key1', 'key2', 'key3'], propertyNames, true);
    }

    public function testAnArrayCanBeInjectedViaTheConstructor()
    {
        var collection = new Collection(['foo', 'bar']);
        Assert.same({'0': 'foo', '1': 'bar'}, collection.asObject(), true);
    }

    public function testACollectionCanBeConvertedToProperJson()
    {
        var collection = new Collection(['foo', 'bar', 123]);

        var collectionAsString = collection.asJson();

        // Assert.equals('["foo","bar",123]', collectionAsString);
        Assert.equals('{"0":"foo","1":"bar","2":123}', collectionAsString);
    }

    public function testACollectionCanBeCounted()
    {
        var collection = new Collection(['foo', 'bar', 'baz']);

        var collectionCount = collection.count();

        Assert.equals(3, collectionCount);
    }

    public function testACollectionCanBeAccessedAsAnArray()
    {
        var collection = new Collection(['foo' => 'bar', 'faz' => 'baz']);

        Assert.equals('bar', collection.getField('foo'));
        Assert.equals('baz', collection.getField('faz'));
    }

    public function testACollectionCanBeIteratedOver()
    {
        var collection = new Collection(['foo' => 'bar', 'faz' => 'baz']);

        // Assert.is(collection, Iterable);
        // Assert.is(collection, KeyValueIterator);

        var newArray = new StringMap();
        for (k=>v in collection)
        {
            newArray.set(k, v);
        }
/*
        foreach (collection as k => v) {
            newArray[k] = v;
        }
*/
        Assert.same(['foo' => 'bar', 'faz' => 'baz'], newArray, true);
    }
}
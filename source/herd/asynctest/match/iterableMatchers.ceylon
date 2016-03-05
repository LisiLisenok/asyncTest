import ceylon.collection {

	ArrayList
}

"Verifies if matching stream of `Iterable` is empty."
tagged( "Streams" )
by( "Lis" )
shared class Empty() satisfies Matcher<{Anything*}>
{
	shared actual MatchResult match( {Anything*} val ) => MatchResult( "empty", val.empty );
	
	shared actual String string => "empty stream";
}

"Verifies if matching stream of `Iterable` is not empty."
tagged( "Streams" )
by( "Lis" )
shared class NotEmpty() satisfies Matcher<{Anything*}>
{
	shared actual MatchResult match( {Anything*} val ) => MatchResult( "not empty", !val.empty );
	
	shared actual String string => "not empty stream";
}


"Merifies if matching stream of `Iterable` has the given `size`."
tagged( "Streams" )
by( "Lis" )
shared class SizeOf( "Target size the matching stream to be exactly." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual MatchResult match( {Anything*} val ) => MatchResult( "stream of size ``size``", val.size == size );
	
	shared actual String string => "stream of size ``size``";
}


"Verifies if matching stream of `Iterable` is shorter than the given `size`."
tagged( "Streams" )
by( "Lis" )
shared class ShorterThan( "Target size the matching stream to be shorter than." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual MatchResult match( {Anything*} val ) {
		Integer actualSize = val.size;
		return MatchResult( "stream of size ``actualSize`` shorter than ``size``", actualSize < size );
	}
	
	shared actual String string => "stream shorter than ``size``";
}


"Verifies if matching stream of `Iterable` is longer than the given `size`."
tagged( "Streams" )
by( "Lis" )
shared class LongerThan( "Target size the matching stream to be longer than." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual MatchResult match( {Anything*} val ) {
		Integer actualSize = val.size;
		return MatchResult( "stream of size ``actualSize`` longer than ``size``", actualSize > size );
	}
	
	shared actual String string => "stream longer than ``size``";
}


"Verifies if matching stream of `Iterable` contains the given `item`."
tagged( "Streams" )
by( "Lis" )
shared class Contains<Value>( "Item to check if matching stream contains." Object item ) satisfies Matcher<{Value*}>
{
	shared actual MatchResult match( {Value*} val ) => MatchResult( "stream contains ``item``", val.contains( item ) );
	
	shared actual String string => "stream contains ``item``";
}


"Verifies if matching stream of `Iterable` contains every item from the given `elements` stream."
tagged( "Streams" )
by( "Lis" )
shared class ContainsEvery<Value>( "Elements to check if matching stream contains every item from." {Value&Object*} elements )
		satisfies Matcher<{Value*}>
{
	shared actual MatchResult match( {Value*} val ) {
		ArrayList<Value> accepted = ArrayList<Value>();
		ArrayList<Value> rejected = ArrayList<Value>();
		for ( elem in elements ) {
			if ( val.contains( elem ) ) {
				accepted.add( elem );
			}
			else {
				rejected.add( elem );
			}
		}
		if ( rejected.empty ) {
			return MatchResult( "stream contains every ``elements``", true );
		}
		else {
			return MatchResult( "stream contains every: actualy contains->``accepted``, doesn't contains->``rejected``", false );
		}
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "stream contains every <``tVal``>";
	}
}


"Verifies if matching stream of `Iterable` contains at least one item from the given `elements` stream."
tagged( "Streams" )
by( "Lis" )
shared class ContainsAny<Value>( "Elements to check if matching stream contains any items from." {Value&Object*} elements )
		satisfies Matcher<{Value*}>
{
	shared actual MatchResult match( {Value*} val ) {
		ArrayList<Value> accepted = ArrayList<Value>();
		ArrayList<Value> rejected = ArrayList<Value>();
		for ( elem in elements ) {
			if ( val.contains( elem ) ) {
				accepted.add( elem );
			}
			else {
				rejected.add( elem );
			}
		}
		if ( accepted.empty ) {
			return MatchResult( "stream contains any ``elements``", false );
		}
		else {
			return MatchResult( "stream contains any: actualy contains->``accepted``, doesn't contains->``rejected``", true );
		}
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "stream contains every <``tVal``>";
	}
}


"Verifies if matching stream of `Iterable` has at least a one element that satisfies the given predicate function."
tagged( "Streams" )
by( "Lis" )
shared class Any<Value> (
	"The predicate that at least one element of the matching stream must satisfy."
	Boolean selecting( Value element )
)
		satisfies Matcher<{Value*}>
{
	shared actual MatchResult match( {Value*} val ) {
		value tVal = `Value`;
		return MatchResult( "any from stream <``tVal``>", val.any( selecting ) );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "any from stream <``tVal``>";
	}
}


"Verifies if matching stream of `Iterable` has all elements satisfy the given predicate function."
tagged( "Streams" )
by( "Lis" )
shared class Every<Value> (
	"The predicate that all elements of the matching stream must satisfy."
	Boolean selecting( Value element )
)
		satisfies Matcher<{Value*}>
{
	shared actual MatchResult match( {Value*} val ) {
		value tVal = `Value`;
		return MatchResult( "every from stream <``tVal``>", val.every( selecting ) );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "every from stream <``tVal``>";
	}
}


"Verifies if matching value is contained in the given stream of `Iterable`."
tagged( "Streams" )
by( "Lis" )
shared class Contained<Value> (
	"Stream to check if it contains matcing value." {Value*} stream
)
		satisfies Matcher<Value&Object>
{
	shared actual MatchResult match( Value&Object val )
			=> MatchResult( "``val`` is contained in the given stream", stream.contains( val ) );
	
	shared actual String string => "matching value to be contained in the given stream";
}


"Verifies if matching value is the first in the given stream of `Iterable`."
tagged( "Streams" )
by( "Lis" )
shared class First<Value> (
	"Stream to check if matcing value is the first in." {Value*} stream
)
		satisfies Matcher<Value&Object>
{
	shared actual MatchResult match( Value&Object val )
			=> MatchResult( "``val`` is the first in the given stream", stream.first?.equals( val ) else false );
	
	shared actual String string => "matching value to be the first in the given stream";
}


"Verifies if matching value is the last in the given stream of `Iterable`."
tagged( "Streams" )
by( "Lis" )
shared class Last<Value> (
	"Stream to check if matcing value is the last in." {Value*} stream
)
		satisfies Matcher<Value&Object>
{
	shared actual MatchResult match( Value&Object val )
			=> MatchResult( "``val`` is the last in the given stream", stream.last?.equals( val ) else false );
	
	shared actual String string => "matching value to be the last in the given stream";
}
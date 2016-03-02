
"Matching `Iterable` to be empty."
by( "Lis" )
shared class Empty() satisfies Matcher<{Anything*}>
{
	shared actual Matching match( {Anything*} val ) {
		return if ( val.empty ) then Accepted( "empty" ) else Rejected( "not empty" );
	}
	
	shared actual String string => "empty list";
}


"Matching `Iterable` to be of the given `size`."
by( "Lis" )
shared class SizeOf( "Target size the list to be exactly." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual Matching match( {Anything*} val ) {
		return	if ( val.size == size )
				then Accepted( "list of size ``size``" )
				else Rejected( "list of size ``size``" );
	}
	
	shared actual String string => "list of size ``size``";
}


"Matching `Iterable` to be shorter than the given `size`."
by( "Lis" )
shared class ShorterThan( "Target size the list to be shorter than." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual Matching match( {Anything*} val ) {
		Integer actualSize = val.size;
		return	if ( actualSize < size )
		then Accepted( "list of size ``actualSize`` shorter than ``size``" )
		else Rejected( "list of size ``actualSize`` shorter than ``size``" );
	}
	
	shared actual String string => "list shorter than ``size``";
}


"Matching `Iterable` to be longer than the given `size`."
by( "Lis" )
shared class LongerThan( "Target size the list to be longer than." Integer size ) satisfies Matcher<{Anything*}>
{
	shared actual Matching match( {Anything*} val ) {
		Integer actualSize = val.size;
		return	if ( actualSize > size )
		then Accepted( "list of size ``actualSize`` longer than ``size``" )
		else Rejected( "list of size ``actualSize`` longer than ``size``" );
	}
	
	shared actual String string => "list longer than ``size``";
}


"Matching `Iterable` to contain the given `item`."
by( "Lis" )
shared class Contains<Value>( "Item to check if list contains." Object item ) satisfies Matcher<{Value*}>
{
	shared actual Matching match( {Value*} val ) {
		return	if ( val.contains( item ) )
		then Accepted( "list contains ``item``" )
		else Rejected( "list contains ``item``" );
	}
	
	shared actual String string => "list contains ``item``";
}


"Matching `Iterable` to have at least a one element that satisfies the given predicate function."
by( "Lis" )
shared class Any<Value> (
	"The predicate that at least one element must satisfy."
	Boolean selecting( Value element )
)
		satisfies Matcher<{Value*}>
{
	shared actual Matching match( {Value*} val ) {
		value tVal = `Value`;
		return	if ( val.any( selecting ) )
		then Accepted( "any from list <``tVal``>" )
		else Rejected( "any from list <``tVal``>" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "any from list <``tVal``>";
	}
}


"Matching `Iterable` to have all elements satisfy the given predicate function."
by( "Lis" )
shared class Every<Value> (
	"The predicate that all elements must satisfy."
	Boolean selecting( Value element )
)
		satisfies Matcher<{Value*}>
{
	shared actual Matching match( {Value*} val ) {
		value tVal = `Value`;
		return	if ( val.every( selecting ) )
		then Accepted( "every from list <``tVal``>" )
		else Rejected( "every from list <``tVal``>" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "every from list <``tVal``>";
	}
}


"Matching value to be contained in the stream."
by( "Lis" )
shared class Contained<Value> (
	"Stream to check if it contains matcing value." {Value*} stream
)
		satisfies Matcher<Value&Object>
{
	shared actual Matching match( Value&Object val ) {
		return	if ( stream.contains( val ) )
		then Accepted( "``val`` is contained in the given stream" )
		else Rejected( "``val`` is contained in the given stream" );
	}
	
	shared actual String string => "matching value to be contained in the given stream";
}


"Matching value to be the first value in the stream."
by( "Lis" )
shared class First<Value> (
	"Stream to check if it contains matcing value." {Value*} stream
)
		satisfies Matcher<Value&Object>
{
	shared actual Matching match( Value&Object val ) {
		return	if ( stream.first?.equals( val ) else false )
		then Accepted( "``val`` is the first in the given stream" )
		else Rejected( "``val`` is the first the given stream" );
	}
	
	shared actual String string => "matching value to be the first in the given stream";
}


"Matching value to be the last value in the stream."
by( "Lis" )
shared class Last<Value> (
	"Stream to check if it contains matcing value." {Value*} stream
)
		satisfies Matcher<Value&Object>
		{
	shared actual Matching match( Value&Object val ) {
		return	if ( stream.last?.equals( val ) else false )
		then Accepted( "``val`` is the last in the given stream" )
		else Rejected( "``val`` is the last the given stream" );
	}
	
	shared actual String string => "matching value to be the last in the given stream";
}

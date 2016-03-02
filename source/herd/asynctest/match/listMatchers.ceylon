

"Matching `List` to start from the given `subList`."
by( "Lis" )
shared class StartsWith<Value>( List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual Matching match( List<Value> val ) {
		value tVal = `Value`;
		return	if ( val.startsWith( subList ) )
		then Accepted( "list of <``tVal``> starts with" )
		else Rejected( "list of <``tVal``> starts with" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``tVal``> starts with";
	}
}


"Matching `List` to end by the given `subList`."
by( "Lis" )
shared class EndsWith<Value>( List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual Matching match( List<Value> val ) {
		value tVal = `Value`;
		return	if ( val.endsWith( subList ) )
		then Accepted( "list of <``tVal``> ends with" )
		else Rejected( "list of <``tVal``> ends with" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``tVal``> ends with";
	}
}


"Matching `List` to be beginning of the given `list`."
by( "Lis" )
shared class Beginning<Value>( List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual Matching match( List<Value> val ) {
		value tVal = `Value`;
		return	if ( list.startsWith( val ) )
		then Accepted( "beginning list of <``tVal``>" )
		else Rejected( "beginning list of <``tVal``>" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "beginning list of <``tVal``>";
	}
}


"Matching `List` to be finishing of the given `list`."
by( "Lis" )
shared class Finishing<Value>( List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual Matching match( List<Value> val ) {
		value tVal = `Value`;
		return	if ( list.endsWith( val ) )
		then Accepted( "finishing list of <``tVal``>" )
		else Rejected( "finishing list of <``tVal``>" );
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "finishing list of <``tVal``>";
	}
}

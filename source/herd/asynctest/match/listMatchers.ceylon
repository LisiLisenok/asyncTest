

"Verifies if matching `List` value starts with the given `subList`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class StartsWith<Value>( "Sublist matching value to start with." List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult (
			"list ``stringify( val )`` starts with ``stringify( subList )``",
			val.startsWith( subList )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``tVal``> starts with";
	}
}


"Verifies if matching `List` value ends with the given `subList`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class EndsWith<Value>( "Sublist matching value to end with." List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult (
			"list ``stringify( val )`` ends with ``stringify( subList )``",
			val.endsWith( subList )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``tVal``> ends with";
	}
}


"Verifies if matching `List` value is beginning point of the given `list`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class Beginning<Value>( "List to start with matching value." List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult( "list ``stringify( val )`` is beginning of ``stringify( list )``", list.startsWith( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "beginning list of <``tVal``>";
	}
}


"Verifies if matching `List` value is finishing point of the given `list`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class Finishing<Value>( List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( "List to end with matching value."List<Value> val )
		=> MatchResult( "list ``stringify( val )`` is finishinig of ``stringify( list )``", list.endsWith( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "finishing list of <``tVal``>";
	}
}

import herd.asynctest.internal {

	stringify,
	typeName
}


"Maps matching value to another one using `convert` and passes converted value to the given `matcher`."
tagged( "Utilities" ) since( "0.4.0" ) by( "Lis" )
shared class Mapping<From, To>( To convert( From val ), Matcher<To> matcher )
		satisfies Matcher<From>
{
	shared actual MatchResult match( From val ) => matcher.match( convert( val ) );
	
	shared actual String string {
		value tFrom = `From`;
		value tTo = `To`;
		return "mapping from '``typeName( tFrom )``' to '``typeName( tTo )``' and match with '``matcher``'";
	}
}


"Maps matching value if it is not `null` to another type `To` using `convert`
 and passes converted to the given `matcher`.  
 Rejects matching if value is `null`."
tagged( "Utilities" ) since( "0.4.0" ) by( "Lis" )
shared class MapExisted<From, To>( To convert( From&Object val ), Matcher<To> matcher )
		satisfies Matcher<From>
{
	shared actual MatchResult match( From val ) {
		if ( exists from = val ) {
			return matcher.match( convert( from ) );
		}
		else {
			return MatchResult( "``string`` got <null>", false );
		}
	}
	
	shared actual String string {
		value tFrom = `From`;
		value tTo = `To`;
		return "map if exists from '``typeName( tFrom )``' to '``typeName( tTo )``' and match with '``matcher``'";
	}
}


"Pass matching value if it satisfies given type `Value` to another `matcher`.  
 Rejects matching if value is is not `Value`."
tagged( "Utilities" ) since( "0.4.0" ) by( "Lis" )
shared class PassType<Value>( Matcher<Value> matcher )
		satisfies Matcher<Anything>
{
	shared actual MatchResult match( Anything val ) {
		if ( is Value val ) {
			return matcher.match( val );
		}
		else {
			value tValue = `Value`;
			return MatchResult( "``stringify( val )`` is ``tValue``", false );
		}
	}
	
	shared actual String string {
		value tValue = `Value`;
		return "pass type '``typeName( tValue )``' to '``matcher``'";
	}
}


"Pass matching value to the given `matcher` if the value is not `null`.  
 Rejects matching if the value is `null`."
tagged( "Utilities" ) since( "0.4.0" ) by( "Lis" )
shared class PassExisted<Value>( Matcher<Value> matcher )
		satisfies Matcher<Value?>
		given Value satisfies Object
{
	shared actual MatchResult match( Value? val ) {
		if ( exists from = val ) {
			return matcher.match( from );
		}
		else {
			return MatchResult( "``string`` got <null>", false );
		}
	}
	
	shared actual String string {
		value tValue = `Value`;
		return "pass existed value '``typeName( tValue )``' to '``matcher``'";
	}
}


"Redirects matching to a `predicate` function.  
 If `predicate` returns `true` matching is accepted otherwise it is rejected"
tagged( "Utilities" ) since( "0.4.0" ) by( "Lis" )
shared class Predicate<Value>( Boolean predicate( Value val ) )
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) => MatchResult( "``string``", predicate( val ) );
	
	shared actual String string {
		value tValue = `Value`;
		return "predicate '``typeName( tValue )``'";
	}
}


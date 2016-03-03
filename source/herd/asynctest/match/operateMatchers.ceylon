

"Maps matching value to another one using `convert` and passes converted value to the given `matcher`."
by( "Lis" )
shared class Mapping<From, To>( To convert( From val ), Matcher<To> matcher )
		satisfies Matcher<From>
{
	shared actual MatchResult match( From val ) {
		return matcher.match( convert( val ) );
	}
	
	shared actual String string {
		value tFrom = `From`;
		value tTo = `To`;
		return "mapping from '``tFrom``' to '``tTo``' and match with '``matcher``'";
	}
}


"Maps matching value if it is not `null` to another one using `convert` and passes converted to the given `matcher`.  
 Rejects matching if value is `null`."
by( "Lis" )
shared class MapIfExists<From, To>( To convert( From&Object val ), Matcher<To> matcher )
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
		return "map if exists from '``tFrom``' to '``tTo``' and match with '``matcher``'";
	}
}


"Pass matching value to the given `matcher` if the value is not `null`.  
 Rejects matching if the value is `null`."
by( "Lis" )
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
		return "map existed value '``tValue``' and match with '``matcher``'";
	}
}


"Verifies if matching value equals to `merit` using operator `==`."
by( "Lis" )
shared class EqualObjects<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual MatchResult match( Value val ) => MatchResult( "``val`` == ``merit``", val == merit );

	shared actual String string {
		value tVal = `Value`;
		return "equal objects of '``tVal``'";
	}
}


"Verifies if matching value is identical to `merit` using operator `===`."
by( "Lis" )
shared class Identical<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Identifiable
{
	shared actual MatchResult match( Value val ) => MatchResult( "``val`` === ``merit``", val === merit );

	shared actual String string {
		value tVal = `Value`;
		return "identical <``tVal``>";
	}
}


"Verifies if matching value is of `Check` type."
by( "Lis" )
shared class IsType<Value, Check>()
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		value tCheck = `Check`;
		return MatchResult( "``val else "<null>"`` is ``tCheck``", if ( is Check val ) then true else false );
	}

	shared actual String string {
		value tCheck = `Check`;
		return "is <``tCheck``>";
	}
}


"Verifies if matching value is `null`."
by( "Lis" )
shared class IsNull() satisfies Matcher<Anything>
{
	shared actual MatchResult match( Anything val ) => MatchResult( "``val else "<null>"`` is <null>", !val exists );
	
	shared actual String string => "is <null>";
}


"Verifies if matching value is not `null`."
by( "Lis" )
shared class IsNotNull() satisfies Matcher<Anything> {
	shared actual MatchResult match( Anything val ) => MatchResult( "``val else "<null>"`` is not <null>", val exists );

	shared actual String string => "is not <null>";
}


"Verifies if matching value is `true`."
by( "Lis" )
shared class IsTrue() satisfies Matcher<Boolean> {
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <true>", val );

	shared actual String string => "is <true>";
}


"Verifies if matching value is `false`."
by( "Lis" )
shared class IsFalse() satisfies Matcher<Boolean> {
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <false>", !val );

	shared actual String string => "is <false>";
}

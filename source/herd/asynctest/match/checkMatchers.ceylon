
"Verifies if matching value equals to `merit` using operator `==`."
tagged( "Checkers" )
by( "Lis" )
shared class EqualObjects<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` == ``stringify( merit )``", val == merit );
	
	shared actual String string {
		value tVal = `Value`;
		return "equal objects of '``tVal``'";
	}
}


"Verifies if matching value is identical to `merit` using operator `===`."
tagged( "Checkers" )
by( "Lis" )
shared class Identical<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Identifiable
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` === ``stringify( merit )``", val === merit );
	
	shared actual String string {
		value tVal = `Value`;
		return "identical <``tVal``>";
	}
}


"Verifies if matching value is equal to `merit` using given comparator."
tagged( "Checkers" )
by( "Lis" )
shared class EqualWith<Value> (
	"Value to compare with matching one."
	Value merit,
	"Comparator used to compare matching value and merit.  
	 Has to return `true` if values are equal and `false` otherwise."
	Boolean comparator( Value first, Value second )
)
		satisfies Matcher<Value>
		given Value satisfies Identifiable
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` equal to ``stringify( merit )`` with comparator",
			comparator( val, merit )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "equal with comparator <``tVal``>";
	}
}


"Verifies if matching value is of `Check` type."
tagged( "Checkers" )
by( "Lis" )
shared class IsType<Value, Check>()
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		value tCheck = `Check`;
		return MatchResult( "``stringify( val )`` is ``tCheck``", if ( is Check val ) then true else false );
	}
	
	shared actual String string {
		value tCheck = `Check`;
		return "is <``tCheck``>";
	}
}


"Verifies if matching value is `null`."
tagged( "Checkers" )
by( "Lis" )
shared class IsNull() satisfies Matcher<Anything> 
{
	shared actual MatchResult match( Anything val ) => MatchResult( "``stringify( val )`` is <null>", !val exists );
	
	shared actual String string => "is <null>";
}


"Verifies if matching value is not `null`."
tagged( "Checkers" )
by( "Lis" )
shared class IsNotNull() satisfies Matcher<Anything> 
{
	shared actual MatchResult match( Anything val ) => MatchResult( "``stringify( val )`` is not <null>", val exists );
	
	shared actual String string => "is not <null>";
}


"Verifies if matching value is `true`."
tagged( "Checkers" )
by( "Lis" )
shared class IsTrue() satisfies Matcher<Boolean>
{
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <true>", val );
	
	shared actual String string => "is <true>";
}


"Verifies if matching value is `false`."
tagged( "Checkers" )
by( "Lis" )
shared class IsFalse() satisfies Matcher<Boolean>
{
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <false>", !val );
	
	shared actual String string => "is <false>";
}

import herd.asynctest.internal {

	stringify,
	typeName
}


"Verifies if matching value equals to `merit` using operator `==`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
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
		return "equal objects of '``typeName( tVal )``'";
	}
}


"Verifies if matching value is _not_ equal to `merit` using operator `!=`."
tagged( "Checkers" ) since( "0.6.1" ) by( "Lis" )
shared class NotEqualObjects<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` != ``stringify( merit )``", val != merit );
	
	shared actual String string {
		value tVal = `Value`;
		return "not equal objects of '``typeName( tVal )``'";
	}
}


"Verifies if matching value is identical to `merit` using operator `===`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
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
		return "identical <``typeName( tVal )``>";
	}
}


"Verifies if matching value is _not_ identical to `merit` using operator `===`."
tagged( "Checkers" ) since( "0.6.1" ) by( "Lis" )
shared class NotIdentical<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Identifiable
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` !== ``stringify( merit )``", !(val === merit) );
	
	shared actual String string {
		value tVal = `Value`;
		return "not identical <``typeName( tVal )``>";
	}
}


"The matcher is useful to test classes which implements `equals` method. It verifies value equality rules i.e.:
 * reflexivity, x==x  
 * symmetry, if x==y then y==x  
 * trasitivity, if x==y and y==z then x==z  
 * \'hashivity\', if x==y then x.hash==y.hash
 
 In order to have value to compare to `clone` function is used. The function has to return new object
 which has to be equal to the passed to.
 "
tagged( "Checkers" ) since( "0.6.0" ) by( "Lis" )
shared class ValueEquality<Value> (
	"Clones value to perform all required comparisons." Value clone( Value v )
)
	satisfies Matcher<Value>
	given Value satisfies Object
{
	
	shared actual MatchResult match( Value x ) {
		Value y = clone( x );
		Value z = clone( x );
		if ( x == y && x == z ) {
			return MatchResult( "reflexivity", x == x ).and (
				MatchResult( "symmetry", y == x ),
				MatchResult( "trasitivity", y == z ),
				MatchResult( "\'hashivity\'", x.hash == y.hash )
			);
		}
		else {
			return MatchResult( "`ValueEquality` matcher: clone method has to return equal object.", false );
		}
	}
	
	shared actual String string {
		value tVal = `Value`;
		return "value equality <``typeName( tVal )``>";
	}
	
}


"Verifies if matching value is equal to `merit` using given comparator."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class EqualWith<Value> (
	"Value to compare with matching one."
	Value merit,
	"Comparator used to compare matching value and merit.  
	 Has to return `true` if values are equal and `false` otherwise."
	Boolean comparator( Value first, Value second )
)
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` equal to ``stringify( merit )`` with comparator",
			comparator( val, merit )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "equal with comparator <``typeName( tVal )``>";
	}
}


"Verifies if matching value is _not_ equal to `merit` using given comparator."
tagged( "Checkers" ) since( "0.6.1" ) by( "Lis" )
shared class NotEqualWith<Value> (
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
		"``stringify( val )`` not equal to ``stringify( merit )`` with comparator",
		!comparator( val, merit )
	);
	
	shared actual String string {
		value tVal = `Value`;
		return "not equal with comparator <``typeName( tVal )``>";
	}
}


"Verifies if matching value is of `Check` type."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class IsType<Check>()
		satisfies Matcher<Anything>
{
	shared actual MatchResult match( Anything val ) {
		value tCheck = `Check`;
		return MatchResult( "``stringify( val )`` is ``tCheck``", val is Check );
	}
	
	shared actual String string {
		value tCheck = `Check`;
		return "is <``typeName( tCheck )``>";
	}
}


"Verifies if matching value is _not_ of `Check` type."
tagged( "Checkers" ) since( "0.6.1" ) by( "Lis" )
shared class IsNotType<Check>()
		satisfies Matcher<Anything>
{
	shared actual MatchResult match( Anything val ) {
		value tCheck = `Check`;
		return MatchResult( "``stringify( val )`` is ``tCheck``", !val is Check );
	}
	
	shared actual String string {
		value tCheck = `Check`;
		return "is not <``typeName( tCheck )``>";
	}
}


"Verifies if matching value is `null`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class IsNull() satisfies Matcher<Anything> 
{
	shared actual MatchResult match( Anything val ) => MatchResult( "``stringify( val )`` is <null>", !val exists );
	
	shared actual String string => "is <null>";
}


"Verifies if matching value is not `null`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class IsNotNull() satisfies Matcher<Anything> 
{
	shared actual MatchResult match( Anything val ) => MatchResult( "``stringify( val )`` is not <null>", val exists );
	
	shared actual String string => "is not <null>";
}


"Verifies if matching value is `true`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class IsTrue() satisfies Matcher<Boolean>
{
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <true>", val );
	
	shared actual String string => "is <true>";
}


"Verifies if matching value is `false`."
tagged( "Checkers" ) since( "0.4.0" ) by( "Lis" )
shared class IsFalse() satisfies Matcher<Boolean>
{
	shared actual MatchResult match( Boolean val ) => MatchResult( "is <false>", !val );
	
	shared actual String string => "is <false>";
}

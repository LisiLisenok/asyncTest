

"Matcher is a rule and verification method
 which identifies if submitted test value satisfies this rule or not.  
 
 Verification is performed using [[Matcher.match]] method. Result of verification
 isrepresented using [[MatchResult]].
 
 Matchers may be combined with each other using `and`, `or` and `xor` methods of [[Matcher]] interface.
 
 "
by( "Lis" )
shared interface Matcher<in Value> {
	
	"Returns `null` if `val` matches this matcher otherwise returns unMatchResult message."
	shared formal MatchResult match( Value val );
	
	
	"Combines this matcher with another one using logical <i>and</i>,
	 i.e. returns matcher which accepts if both `this` and `other` accept."
	shared default Matcher<Value&Other> and<Other>( Matcher<Other> other )
			=> AndMatcher<Value&Other>( this, other );
	
	"Combines this matcher with another one using logical <i>or</i>,
	 i.e. returns matcher which accepts if any `this` or `other` accepts."
	shared default Matcher<Value&Other> or<Other>( Matcher<Other> other )
			=> OrMatcher<Value&Other>( this, other );
	
	"Combines this matcher with another one using logical <i>xor</i>,
	 i.e. returns matcher which accepts if only one from `this` and `other` accepts."
	shared default Matcher<Value&Other> xor<Other>( Matcher<Other> other )
			=> XorMatcher<Value&Other>( this, other );
	
	"Reverted matcher using logical <i>not</i>,
	 i.e. returns matcher which rejects if this accepts and visa versa."
	shared default Matcher<Value> not()
			=> NotMatcher<Value>( this );
	
}


"Combination of matchers with logical <i>and</i>."
by( "Lis" )
class AndMatcher<Value>( Matcher<Value> first, Matcher<Value> second ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value fMatch = first.match( val );
		value sMatch = second.match( val );
		return fMatch.and( sMatch );
	}
	
	shared actual String string => "(``first``) and (``second``)";
	
}


"Combination of matchers with logical <i>or</i>."
by( "Lis" )
class OrMatcher<Value>( Matcher<Value> first, Matcher<Value> second ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value fMatch = first.match( val );
		value sMatch = second.match( val );
		return fMatch.or( sMatch );
	}
	
	shared actual String string => "(``first``) or (``second``)";
	
}


"Combination of matchers with logical <i>xor</i> - accepted if only one is accepted."
by( "Lis" )
class XorMatcher<Value>( Matcher<Value> first, Matcher<Value> second ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value fMatch = first.match( val );
		value sMatch = second.match( val );
		return fMatch.xor( sMatch );
	}
	
	shared actual String string => "(``first``) xor (``second``)";
	
}


"Logical <i>not</i> matcher."
by( "Lis" )
class NotMatcher<Value>( Matcher<Value> matcher ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value m = matcher.match( val );
		return m.not();
	}
	
	shared actual String string => "not(``matcher``)";
	
}

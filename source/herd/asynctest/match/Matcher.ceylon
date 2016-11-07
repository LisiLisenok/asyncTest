

"Matcher is a rule and verification method
 which identifies if submitted test value satisfies this rule or not.  
 
 Verification is performed using [[Matcher.match]] method. Result of verification
 is represented using [[MatchResult]].
 
 Matchers may be combined with each other using `and` or `or` methods of [[Matcher]] interface.
 
 --------------------------------------------
 "
since( "0.4.0" ) by( "Lis" )
shared interface Matcher<in Value> {
	
	"Performs verification if value `val` satisfies this matcher requirements.  
	 Returns [[MatchResult]] which contains `Boolean` result (accepted or rejected) and message."
	shared formal MatchResult match( "Value to be verified." Value val );
	
	
	"Combines this matcher with another one using logical <i>and</i>,
	 i.e. returns matcher which accepts if all from `this` and `other` accept."
	shared default Matcher<Value&Other> and<Other>( Matcher<Other>* other ) {
		if ( nonempty other ) {
			return AndMatcher<Value&Other>( [this, *other] );	
		}
		else {
			return this;
		}
	}
	
	"Combines this matcher with another one using logical <i>or</i>,
	 i.e. returns matcher which accepts if any from `this` and `other` accepts."
	shared default Matcher<Value&Other> or<Other>( Matcher<Other>* other ) {
		if ( nonempty other ) {
			return OrMatcher<Value&Other>( [this, *other] );	
		}
		else {
			return this;
		}
	}

	
	"Reverted matcher using logical <i>not</i>,
	 i.e. returns matcher which rejects if this accepts and visa versa."
	shared default Matcher<Value> not()
			=> NotMatcher<Value>( this );
	
}


"Combination of matchers with logical <i>and</i>."
since( "0.4.0" ) by( "Lis" )
class AndMatcher<Value>( [Matcher<Value>+] matchers ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value fMatch = matchers.first.match( val );
		return fMatch.and( *matchers.rest*.match( val ) );
	}
	
	shared actual String string {
		StringBuilder str = StringBuilder();
		str.append( "(``matchers.first.string``)" );
		for ( item in matchers.rest ) {
			str.append( "&&(``item.string``)" );
		}
		return str.string;
	}
	
}


"Combination of matchers with logical <i>or</i>."
since( "0.4.0" ) by( "Lis" )
class OrMatcher<Value>( [Matcher<Value>+] matchers ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value fMatch = matchers.first.match( val );
		return fMatch.or( *matchers.rest*.match( val ) );
	}
	
	shared actual String string {
		StringBuilder str = StringBuilder();
		str.append( "(``matchers.first.string``)" );
		for ( item in matchers.rest ) {
			str.append( "||(``item.string``)" );
		}
		return str.string;
	}
	
}


"Logical <i>not</i> matcher."
since( "0.4.0" ) by( "Lis" )
class NotMatcher<Value>( Matcher<Value> matcher ) satisfies Matcher<Value> {
	
	shared actual MatchResult match( Value val ) {
		value m = matcher.match( val );
		return m.not();
	}
	
	shared actual String string => "!``matcher``";
	
}

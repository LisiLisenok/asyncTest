
Boolean isAccepted( MatchResult res ) => res.accepted;
Boolean isRejected( MatchResult res ) => !res.accepted;

"Matches the list and returns tuple of `[accepted, rejected]`."
[{MatchResult*}, {MatchResult*}] matchList<Value>( Value val, {Matcher<Value>*} matchers ) {
	value arr = [for ( matcher in matchers ) matcher.match( val )];
	return [arr.filter( isAccepted ), arr.filter( isRejected )];
}


"Accepted if all matchers from the given list are accepted otherwise rejected."
by( "Lis" )
shared class AllOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		if ( matchers.empty ) {
			return MatchResult( "all of '[]'", true );
		}
		else {
			value [accepted, rejected] = matchList<Value>( val, matchers );
			if ( rejected.empty ) {
				return MatchResult( "all of: ``accepted``", true );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return MatchResult (
					"all of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``",
					false
				);
			}
		}
	}
		
	shared actual String string => "all of ``matchers``";
}


"Accepted if no one matcher from the given list is accepted
 and rejected if all matchers from the given list are rejected."
by( "Lis" )
shared class NoneOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		if ( matchers.empty ) {
			return MatchResult( "none of '[]'", true );
		}
		else {
			value [accepted, rejected] = matchList<Value>( val, matchers );
			if ( accepted.empty ) {
				return MatchResult( "none of: ``rejected``", true );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return MatchResult (
					"none of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``",
					false
				);
			}
		}
	}
	
	shared actual String string => "all of ``matchers``";
}


"Accepted if one and only one from the given matchers is accepted otherwise rejected."
by( "Lis" )
shared class OneOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		if ( matchers.empty ) {
			return MatchResult( "one of '[]'", true );
		}
		else {
			value [accepted, rejected] = matchList<Value>( val, matchers );
			if ( accepted.size == 1 ) {
				return MatchResult( "one of: ``accepted`` and other rejected ``rejected``", true );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return MatchResult (
					"one of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``",
					false
				);
			}
		}
	}
	
	shared actual String string => "one of ``matchers``";
}


"Accepted if some from the given matchers is accepted and rejected only if all matchers are rejected."
by( "Lis" )
shared class SomeOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val ) {
		if ( matchers.empty ) {
			return MatchResult( "some of '[]'", true );
		}
		else {
			value [accepted, rejected] = matchList<Value>( val, matchers );
			if ( accepted.empty ) {
				return MatchResult( "some of: ``rejected``", false );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return MatchResult (
					"some of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``",
					true
				);
			}
		}
	}
		
	shared actual String string => "some of ``matchers``";
}

import herd.asynctest.internal {
	typeName,
	stringify
}


"Verifies if matching set is subset of the given `superset`."
tagged( "Set" ) since( "0.7.0" ) by( "Lis" )
shared class SubsetOf<Value> (
	"Set which is expected to be superset of matching set." Set<Value> superset
)
		satisfies Matcher<Set<Value>>
{
	shared actual MatchResult match( Set<Value> val )
		=> MatchResult( "``stringify( val )`` is subset of ``stringify( superset )``", val.subset( superset ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "subset of Set<``typeName( tVal )``>";
	}
}


"Verifies if matching set is superset of the given `subset`."
tagged( "Set" ) since( "0.7.0" ) by( "Lis" )
shared class SupersetOf<Value> (
	"Set which is expected to be subset of matching set." Set<Value> subset
)
		satisfies Matcher<Set<Value>>
{
	shared actual MatchResult match( Set<Value> val )
		=> MatchResult( "``stringify( val )`` is superset of ``stringify( subset )``", val.superset( subset ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "superset of Set<``typeName( tVal )``>";
	}
}


"Verifies if the given `subset` is subset of matching set."
tagged( "Set" ) since( "0.7.0" ) by( "Lis" )
shared class Subset<Value> (
	"Set which is expected to be subset of matching set." Set<Value> subset
)
		satisfies Matcher<Set<Value>>
{
	shared actual MatchResult match( Set<Value> val )
			=> MatchResult( "``stringify( subset )`` is subset of ``stringify( val )``", subset.subset( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "subset of Set<``typeName( tVal )``>";
	}
}


"Verifies if the given `superset` is superset of matching set."
tagged( "Set" ) since( "0.7.0" ) by( "Lis" )
shared class Superset<Value> (
	"Set which is expected to be superset of matching set." Set<Value> superset
)
		satisfies Matcher<Set<Value>>
{
	shared actual MatchResult match( Set<Value> val )
			=> MatchResult( "``stringify( val )`` is superset of ``stringify( superset )``", superset.superset( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "superset of Set<``typeName( tVal )``>";
	}
}

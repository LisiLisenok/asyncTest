import herd.asynctest.internal {

	stringify,
	typeName
}


"Verifies if matching value is greater than given `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class Greater<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
 	shared actual MatchResult match( Value val )
 			=> MatchResult( "``stringify( val )`` > ``stringify( merit )``", val > merit );

 	shared actual String string {
 		value tVal = `Value`;
 		return "greater <``typeName( tVal )``>";
 	}
}


"Verifies if matching value is less than given `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class Less<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` < ``stringify( merit )``", val < merit );

	shared actual String string {
		value tVal = `Value`;
		return "less <``typeName( tVal )``>";
	}
}


"Verifies if matching value is less or equal to given `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class LessOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` <= ``stringify( merit )``", val <= merit );

	shared actual String string {
		value tVal = `Value`;
		return "less or equal <``typeName( tVal )``>";
	}
}


"Verifies if matching value is greater or equal to given `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class GreaterOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` >= ``stringify( merit )``", val >= merit );

	shared actual String string {
		value tVal = `Value`;
		return "greater or equal <``typeName( tVal )``>";
	}
}


"Verifies if matching value is within given range of `lower` to `upper` excluding bounds.
 This is equal to greater(lower).and(less(upper))."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class Within<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` is within ``stringify( lower )`` to ``stringify( upper )`` excluding bounds",
			val > lower && val < upper
		);

	shared actual String string {
		value tVal = `Value`;
		return "within <``typeName( tVal )``>";
	}
}


"Verifies if matching value is **not** within given range of `lower` to `upper` excluding bounds.
 This is equal to lessOrEqual(lower).or(greaterOrEqual(upper))."
tagged( "Comparators" ) since( "0.6.0" ) by( "Lis" )
shared class NotWithin<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult (
		"``stringify( val )`` is not within ``stringify( lower )`` to ``stringify( upper )`` excluding bounds",
		val <= lower || val >= upper
	);
	
	shared actual String string {
		value tVal = `Value`;
		return "not within <``typeName( tVal )``>";
	}
}


"Verifies if matching value is within given range of `lower` to `upper` including bounds.
 This is equal to greaterOrEqual(lower).and(lessOrEqual(upper))."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class InRange<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` is within ``stringify( lower )`` to ``stringify( upper )`` including bounds",
			val >= lower && val <= upper
		);

	shared actual String string {
		value tVal = `Value`;
		return "range <``typeName( tVal )``>";
	}
}


"Verifies if matching value is **not** within given range of `lower` to `upper` including bounds.
 This is equal to less(lower).or(greater(upper))."
tagged( "Comparators" ) since( "0.6.0" ) by( "Lis" )
shared class NotInRange<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult (
		"``stringify( val )`` is noy within ``stringify( lower )`` to ``stringify( upper )`` including bounds",
		val < lower && val > upper
	);
	
	shared actual String string {
		value tVal = `Value`;
		return "range <``typeName( tVal )``>";
	}
}


"Verifies if matching value is equal to `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class EqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` == ``stringify( merit )``", ( val <=> merit ) == equal );

	shared actual String string {
		value tVal = `Value`;
		return "equal <``typeName( tVal )``>";
	}
}


"Verifies if matching value is not equal to `merit`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class NotEqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` != ``stringify( merit )``", ( val <=> merit ) != equal );

	shared actual String string {
		value tVal = `Value`;
		return "not equal <``typeName( tVal )``>";
	}
}


"Verifies if matching value is close to `merit` with the given `tolerance`."
tagged( "Comparators" ) since( "0.4.0" ) by( "Lis" )
shared class CloseTo<Value> (
	"Value to compare with matching one." Value merit,
	"Tolerance to accept matching." Value tolerance
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value> & Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult (
				"``stringify( val )`` is close to ``stringify( merit )`` with tolerance of ``tolerance``",
				( val - merit ).magnitude < tolerance
			);

	shared actual String string => "close with tolerance ``tolerance``";
}

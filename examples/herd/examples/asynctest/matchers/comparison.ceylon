import ceylon.test {

	test,
	parameters,
	testSuite
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	EqualTo,
	NotEqualTo,
	GreaterOrEqual,
	LessOrEqual,
	Less,
	Greater,
	Within,
	Ranged
}


testSuite (
	{
		`function comparison`,
	 	`function comparisonNot`
	}
)
test void simpleComparisonSuite() {}


testSuite (
	{
		`function orComparison`,
		`function xorComparison`,
		`function andComparison`
	}
)
test void logicalComparisonSuite() {}


testSuite (
	{
		`function withinComparison`,
		`function rangeComparison`
	}
)
test void rangedComparisonSuite() {}



test parameters( `value comparisonStrings` )
void comparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"String to compare to" String expected
) {
	context.start();
	
	context.assertThat( toCompare, EqualTo( expected ), "equality" );
	context.assertThat( toCompare, NotEqualTo( expected ), "reverse equality" );
	context.assertThat( toCompare, GreaterOrEqual( expected ), "greater or equal" );
	context.assertThat( toCompare, LessOrEqual( expected ), "less or equal" );
	context.assertThat( toCompare, Less( expected ), "less" );
	context.assertThat( toCompare, Greater( expected ), "greater" );
	
	context.complete();
}

test parameters( `value comparisonStrings` )
void comparisonNot (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"String to compare to" String expected
) {
	context.start();
	
	context.assertThat( toCompare, EqualTo( expected ).not(), "equality" );
	context.assertThat( toCompare, NotEqualTo( expected ).not(), "reverse equality" );
	context.assertThat( toCompare, GreaterOrEqual( expected ).not(), "greater or equal" );
	context.assertThat( toCompare, LessOrEqual( expected ).not(), "less or equal" );
	context.assertThat( toCompare, Less( expected ).not(), "less" );
	context.assertThat( toCompare, Greater( expected ).not(), "greater" );
	
	context.complete();
}


test parameters( `value combinedComparisonStrings` )
void orComparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, EqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "equal or equal" );
	context.assertThat( toCompare, EqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "equal or not equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "not equal or equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "not equal or not equal" );
	context.assertThat( toCompare, Less( expectedFirst ).or( Less( expectedSecond ) ), "less or less" );
	context.assertThat( toCompare, Less( expectedFirst ).or( Greater( expectedSecond ) ), "less or greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).or( Greater( expectedSecond ) ), "greater or greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).or( Less( expectedSecond ) ), "greater or less" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void andComparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, EqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ), "equal and equal" );
	context.assertThat( toCompare, EqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ), "equal and not equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ), "not equal and equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ), "not equal and not equal" );
	context.assertThat( toCompare, Less( expectedFirst ).and( Less( expectedSecond ) ), "less and less" );
	context.assertThat( toCompare, Less( expectedFirst ).and( Greater( expectedSecond ) ), "less and greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).and( Greater( expectedSecond ) ), "greater and greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).and( Less( expectedSecond ) ), "greater and less" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void xorComparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, EqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ), "equal xor equal" );
	context.assertThat( toCompare, EqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ), "equal xor not equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ), "not equal xor equal" );
	context.assertThat( toCompare, NotEqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ), "not equal xor not equal" );
	context.assertThat( toCompare, Less( expectedFirst ).xor( Less( expectedSecond ) ), "less xor less" );
	context.assertThat( toCompare, Less( expectedFirst ).xor( Greater( expectedSecond ) ), "less xor greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).xor( Greater( expectedSecond ) ), "greater xor greater" );
	context.assertThat( toCompare, Greater( expectedFirst ).xor( Less( expectedSecond ) ), "greater xor less" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void withinComparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"Lower range bound." String lower,
	"Upper range bound." String upper
) {
	context.start();
	
	context.assertThat( toCompare, Within( lower, upper ), "within" );
	context.assertThat( toCompare, Greater( lower ).and( Less( upper ) ), "check within" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void rangeComparison (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"Lower range bound." String lower,
	"Upper range bound.." String upper
) {
	context.start();
	
	context.assertThat( toCompare, Ranged( lower, upper ), "range" );
	context.assertThat( toCompare, GreaterOrEqual( lower ).and( LessOrEqual( upper ) ), "check range" );
	
	context.complete();
}

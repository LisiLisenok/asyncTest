import herd.asynctest.match {

	Less,
	NotEqualTo,
	EqualTo,
	Greater
}
import ceylon.test {

	parameters,
	test
}
import herd.asynctest {

	AsyncTestContext
}


class OrCompare() {
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, EqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "equal or equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalOrNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, EqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "equal or not equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, NotEqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "not equal or equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualOrNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, NotEqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "not equal or not equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessOrLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, Less( expectedFirst ).or( Less( expectedSecond ) ), "less or less" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessOrGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, Less( expectedFirst ).or( Greater( expectedSecond ) ), "less or greater" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterOrGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, Greater( expectedFirst ).or( Greater( expectedSecond ) ), "greater or greater" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterOrLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, Greater( expectedFirst ).or( Less( expectedSecond ) ), "greater or less" );
		context.complete();
	}
}

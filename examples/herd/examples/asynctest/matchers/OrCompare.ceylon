import herd.asynctest.match {

	Less,
	NotEqualTo,
	EqualTo,
	Greater
}
import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext,
	parameterized
}


class OrCompare() {
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat(
			toCompare, EqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalOrNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, EqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, NotEqualTo( expectedFirst ).or( EqualTo( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualOrNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, NotEqualTo( expectedFirst ).or( NotEqualTo( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessOrLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat( toCompare, Less( expectedFirst ).or( Less( expectedSecond ) ), "", true );
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessOrGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, Less( expectedFirst ).or( Greater( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterOrGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, Greater( expectedFirst ).or( Greater( expectedSecond ) ), "", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterOrLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare, Greater( expectedFirst ).or( Less( expectedSecond ) ), "", true
		);
		context.complete();
	}
}

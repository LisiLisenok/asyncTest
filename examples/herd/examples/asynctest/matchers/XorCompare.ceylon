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


class XorCompare() {
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalXorEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalXorNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualXorEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualXorNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessXorLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Less( expectedFirst ).xor( Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessXorGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Less( expectedFirst ).xor( Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterXorGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).xor( Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterXorLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).xor( Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
}

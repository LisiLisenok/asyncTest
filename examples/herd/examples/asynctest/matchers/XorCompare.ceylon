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


class XorCompare() {
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalXorEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ),
			"equal xor equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalXorNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ),
			"equal xor not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualXorEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).xor( EqualTo( expectedSecond ) ),
			"not equal xor equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualXorNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).xor( NotEqualTo( expectedSecond ) ),
			"not equal xor not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessXorLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Less( expectedFirst ).xor( Less( expectedSecond ) ),
			"less xor less",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessXorGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Less( expectedFirst ).xor( Greater( expectedSecond ) ),
			"less xor greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterXorGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).xor( Greater( expectedSecond ) ),
			"greater xor greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterXorLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).xor( Less( expectedSecond ) ),
			"greater xor less",
			true
		);
		context.complete();
	}
}

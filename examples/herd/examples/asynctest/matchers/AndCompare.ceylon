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


class AndCompare() {
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ),
			"equal and equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void equalAndNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ),
			"equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ),
			"not equal and equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void notEqualAndNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ),
			"not equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessAndLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Less( expectedFirst ).and( Less( expectedSecond ) ),
			"less and less",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void lessAndGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Less( expectedFirst ).and( Greater( expectedSecond ) ),
			"less and greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterAndGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).and( Greater( expectedSecond ) ),
			"greater and greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void greaterAndLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).and( Less( expectedSecond ) ),
			"greater and less",
			true
		);
		context.complete();
	}
}

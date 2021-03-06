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

	AsyncTestContext
}
import herd.asynctest.parameterization {
	parameterized
}


class AndCompare() {
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void equalAndNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			EqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).and( EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void notEqualAndNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			NotEqualTo( expectedFirst ).and( NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessAndLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Less( expectedFirst ).and( Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void lessAndGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Less( expectedFirst ).and( Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterAndGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).and( Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void greaterAndLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			Greater( expectedFirst ).and( Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
}

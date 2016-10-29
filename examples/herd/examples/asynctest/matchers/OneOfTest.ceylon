import herd.asynctest.match {
	
	OneOf,
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


class OneOfTest()
{
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfEqualNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfNotEqualEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfNotEqualNotEqualTo (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfLessLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( Less( expectedFirst ), Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfLessGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( Less( expectedFirst ), Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfGreaterGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( Greater( expectedFirst ), Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void oneOfGreaterLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			OneOf( Greater( expectedFirst ), Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
}

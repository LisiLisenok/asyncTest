import herd.asynctest.match {
	
	OneOf,
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


class OneOfTest()
{
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"one of equal and equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfEqualNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"one of equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfNotEqualEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"one of not equal and equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfNotEqualNotEqualTo (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"one of not equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfLessLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( Less( expectedFirst ), Less( expectedSecond ) ),
			"one of less and less",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfLessGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( Less( expectedFirst ), Greater( expectedSecond ) ),
			"one of less and greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfGreaterGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( Greater( expectedFirst ), Greater( expectedSecond ) ),
			"one of greater and greater",
			true
		);
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void oneOfGreaterLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			OneOf( Greater( expectedFirst ), Less( expectedSecond ) ),
			"one of greater and less",
			true
		);
		context.complete();
	}
	
}

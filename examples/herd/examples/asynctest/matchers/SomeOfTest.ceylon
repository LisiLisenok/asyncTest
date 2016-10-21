import herd.asynctest.match {
	
	SomeOf,
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


class SomeOfTest()
{
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare, SomeOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "some of equal and equal", true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfEqualNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"some of equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfNotEqualEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"some of not equal and equal",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfNotEqualNotEqualTo (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"some of not equal and not equal",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfLessLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( Less( expectedFirst ), Less( expectedSecond ) ),
			"some of less and less",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfLessGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( Less( expectedFirst ), Greater( expectedSecond ) ),
			"some of less and greater",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfGreaterGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( Greater( expectedFirst ), Greater( expectedSecond ) ),
			"some of greater and greater",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void someOfGreaterLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat (
			toCompare,
			SomeOf( Greater( expectedFirst ), Less( expectedSecond ) ),
			"some of greater and less",
			true
		);
		context.complete();
	}
	
}

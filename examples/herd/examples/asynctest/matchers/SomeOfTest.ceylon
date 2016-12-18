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
	
	AsyncTestContext
}
import herd.asynctest.parameterization {
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
		context.assertThat (
			toCompare, SomeOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "", true
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
		context.assertThat (
			toCompare,
			SomeOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( Less( expectedFirst ), Less( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( Less( expectedFirst ), Greater( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( Greater( expectedFirst ), Greater( expectedSecond ) ),
			"",
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
		context.assertThat (
			toCompare,
			SomeOf( Greater( expectedFirst ), Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
}

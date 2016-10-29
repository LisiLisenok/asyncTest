import herd.asynctest.match {

	AllOf,
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


""
class AllOfTest()
{
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfEqualNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfNotEqualEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}

	test parameterized( `value combinedComparisonStrings` )
	shared void allOfNotEqualNotEqualTo (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( NotEqualTo( expectedFirst ),
				NotEqualTo( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfLessLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( Less( expectedFirst ), Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}

	test parameterized( `value combinedComparisonStrings` )
	shared void allOfLessGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( Less( expectedFirst ), Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfGreaterGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( Greater( expectedFirst ), Greater( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
	
	test parameterized( `value combinedComparisonStrings` )
	shared void allOfGreaterLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.assertThat (
			toCompare,
			AllOf( Greater( expectedFirst ), Less( expectedSecond ) ),
			"",
			true
		);
		context.complete();
	}
		
}

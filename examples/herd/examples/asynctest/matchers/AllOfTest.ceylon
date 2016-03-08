import herd.asynctest.match {

	AllOf,
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


""
class AllOfTest()
{
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfEqualAndEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "all of equal and equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfEqualNotEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "all of equal and not equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfNotEqualEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "all of not equal and equal" );
		context.complete();
	}

	test parameters( `value combinedComparisonStrings` )
	shared void allOfNotEqualNotEqualTo (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "all of not equal and not equal" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfLessLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( Less( expectedFirst ), Less( expectedSecond ) ), "all of less and less" );
		context.complete();
	}

	test parameters( `value combinedComparisonStrings` )
	shared void allOfLessGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( Less( expectedFirst ), Greater( expectedSecond ) ), "all of less and greater" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfGreaterGreater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( Greater( expectedFirst ), Greater( expectedSecond ) ), "all of greater and greater" );
		context.complete();
	}
	
	test parameters( `value combinedComparisonStrings` )
	shared void allOfGreaterLess (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"First string to compare to." String expectedFirst,
		"Second string to compare to." String expectedSecond
	) {
		context.start();
		context.assertThat( toCompare, AllOf( Greater( expectedFirst ), Less( expectedSecond ) ), "all of greater and less" );
		context.complete();
	}
		
}

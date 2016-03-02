import herd.asynctest.match {

	Less,
	NotEqualTo,
	EqualTo,
	Greater,
	AllOf,
	OneOf,
	SomeOf
}
import ceylon.test {

	parameters,
	test
}
import herd.asynctest {

	AsyncTestContext
}


test parameters( `value combinedComparisonStrings` )
void testAllOf (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, AllOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "all of equal and equal" );
	context.assertThat( toCompare, AllOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "all of equal and not equal" );
	context.assertThat( toCompare, AllOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "all of not equal and equal" );
	context.assertThat( toCompare, AllOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "all of not equal and not equal" );
	context.assertThat( toCompare, AllOf( Less( expectedFirst ), Less( expectedSecond ) ), "all of less and less" );
	context.assertThat( toCompare, AllOf( Less( expectedFirst ), Greater( expectedSecond ) ), "all of less and greater" );
	context.assertThat( toCompare, AllOf( Greater( expectedFirst ), Greater( expectedSecond ) ), "all of greater and greater" );
	context.assertThat( toCompare, AllOf( Greater( expectedFirst ), Less( expectedSecond ) ), "all of greater and less" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void testOneOf (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, OneOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "one of equal and equal" );
	context.assertThat( toCompare, OneOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "one of equal and not equal" );
	context.assertThat( toCompare, OneOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "one of not equal and equal" );
	context.assertThat( toCompare, OneOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "one of not equal and not equal" );
	context.assertThat( toCompare, OneOf( Less( expectedFirst ), Less( expectedSecond ) ), "one of less and less" );
	context.assertThat( toCompare, OneOf( Less( expectedFirst ), Greater( expectedSecond ) ), "one of less and greater" );
	context.assertThat( toCompare, OneOf( Greater( expectedFirst ), Greater( expectedSecond ) ), "one of greater and greater" );
	context.assertThat( toCompare, OneOf( Greater( expectedFirst ), Less( expectedSecond ) ), "one of greater and less" );
	
	context.complete();
}

test parameters( `value combinedComparisonStrings` )
void testSomeOf (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String toCompare,
	"First string to compare to." String expectedFirst,
	"Second string to compare to." String expectedSecond
) {
	context.start();
	
	context.assertThat( toCompare, SomeOf( EqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "some of equal and equal" );
	context.assertThat( toCompare, SomeOf( EqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "some of equal and not equal" );
	context.assertThat( toCompare, SomeOf( NotEqualTo( expectedFirst ), EqualTo( expectedSecond ) ), "some of not equal and equal" );
	context.assertThat( toCompare, SomeOf( NotEqualTo( expectedFirst ), NotEqualTo( expectedSecond ) ), "some of not equal and not equal" );
	context.assertThat( toCompare, SomeOf( Less( expectedFirst ), Less( expectedSecond ) ), "some of less and less" );
	context.assertThat( toCompare, SomeOf( Less( expectedFirst ), Greater( expectedSecond ) ), "some of less and greater" );
	context.assertThat( toCompare, SomeOf( Greater( expectedFirst ), Greater( expectedSecond ) ), "some of greater and greater" );
	context.assertThat( toCompare, SomeOf( Greater( expectedFirst ), Less( expectedSecond ) ), "some of greater and less" );
	
	context.complete();
}

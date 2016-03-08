import ceylon.test {

	test,
	parameters
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	EqualTo,
	NotEqualTo,
	GreaterOrEqual,
	LessOrEqual,
	Less,
	Greater
}


class Compare() {
	
	test parameters( `value comparisonStrings` )
	shared void equal (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, EqualTo( expected ), "equality" );
		context.assertThat( toCompare, EqualTo( expected ).not(), "reverted equality" );
		context.complete();
	}
	
	test parameters( `value comparisonStrings` )
	shared void notEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, NotEqualTo( expected ), "not equality" );
		context.assertThat( toCompare, NotEqualTo( expected ).not(), "reverted not equality" );
		context.complete();
	}
	
	test parameters( `value comparisonStrings` )
	shared void greaterOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, GreaterOrEqual( expected ), "greater or equal" );
		context.assertThat( toCompare, GreaterOrEqual( expected ).not(), "reverted greater or equal" );
		context.complete();
	}
	
	test parameters( `value comparisonStrings` )
	shared void lessOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, LessOrEqual( expected ), "less or equal" );
		context.assertThat( toCompare, LessOrEqual( expected ).not(), "reverted less or equal" );
		context.complete();
	}
	
	test parameters( `value comparisonStrings` )
	shared void less (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, Less( expected ), "less" );
		context.assertThat( toCompare, Less( expected ).not(), "reverted less" );
		context.complete();
	}
	
	test parameters( `value comparisonStrings` )
	shared void greater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.start();
		context.assertThat( toCompare, Greater( expected ), "greater" );
		context.assertThat( toCompare, Greater( expected ).not(), "reverted greater" );
		context.complete();
	}
}

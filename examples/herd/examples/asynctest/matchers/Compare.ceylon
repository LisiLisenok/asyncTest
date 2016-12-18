import ceylon.test {

	test
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
import herd.asynctest.parameterization {
	parameterized
}


class Compare() {
	
	test parameterized( `value comparisonStrings` )
	shared void equal (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, EqualTo( expected ), "equality", true );
		context.assertThat( toCompare, EqualTo( expected ).not(), "reverted equality", true );
		context.complete();
	}
	
	test parameterized( `value comparisonStrings` )
	shared void notEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, NotEqualTo( expected ), "not equality", true );
		context.assertThat( toCompare, NotEqualTo( expected ).not(), "reverted not equality", true );
		context.complete();
	}
	
	test parameterized( `value comparisonStrings` )
	shared void greaterOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, GreaterOrEqual( expected ), "greater or equal", true );
		context.assertThat( toCompare, GreaterOrEqual( expected ).not(), "reverted greater or equal", true );
		context.complete();
	}
	
	test parameterized( `value comparisonStrings` )
	shared void lessOrEqual (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, LessOrEqual( expected ), "less or equal", true );
		context.assertThat( toCompare, LessOrEqual( expected ).not(), "reverted less or equal", true );
		context.complete();
	}
	
	test parameterized( `value comparisonStrings` )
	shared void less (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, Less( expected ), "less", true );
		context.assertThat( toCompare, Less( expected ).not(), "reverted less", true );
		context.complete();
	}
	
	test parameterized( `value comparisonStrings` )
	shared void greater (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"String to compare to" String expected
	) {
		context.assertThat( toCompare, Greater( expected ), "greater", true );
		context.assertThat( toCompare, Greater( expected ).not(), "reverted greater", true );
		context.complete();
	}
}

import herd.asynctest.match {

	LessOrEqual,
	GreaterOrEqual,
	Less,
	Greater,
	InRange,
	Within
}
import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext,
	parameterized
}


class RangeCompare() {
	test parameterized( `value combinedComparisonStrings` )
	shared void withinComparison (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"Lower range bound." String lower,
		"Upper range bound." String upper
	) {
		context.assertThat( toCompare, Within( lower, upper ), "within", true );
		context.assertThat( toCompare, Greater( lower ).and( Less( upper ) ), "check within", true );
		
		context.complete();
	}
	
	
	test parameterized( `value combinedComparisonStrings` )
	shared void rangeComparison (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"Lower range bound." String lower,
		"Upper range bound.." String upper
	) {
		context.assertThat( toCompare, InRange( lower, upper ), "range", true );
		context.assertThat( toCompare, GreaterOrEqual( lower ).and( LessOrEqual( upper ) ), "check range", true );
		
		context.complete();
	}
}

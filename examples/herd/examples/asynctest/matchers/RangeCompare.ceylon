import herd.asynctest.match {

	LessOrEqual,
	GreaterOrEqual,
	Less,
	Greater,
	Ranged,
	Within
}
import ceylon.test {

	parameters,
	test
}
import herd.asynctest {

	AsyncTestContext
}


class RangeCompare() {
	test parameters( `value combinedComparisonStrings` )
	shared void withinComparison (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"Lower range bound." String lower,
		"Upper range bound." String upper
	) {
		context.start();
		
		context.assertThat( toCompare, Within( lower, upper ), "within" );
		context.assertThat( toCompare, Greater( lower ).and( Less( upper ) ), "check within" );
		
		context.complete();
	}
	
	
	test parameters( `value combinedComparisonStrings` )
	shared void rangeComparison (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String toCompare,
		"Lower range bound." String lower,
		"Upper range bound.." String upper
	) {
		context.start();
		
		context.assertThat( toCompare, Ranged( lower, upper ), "range" );
		context.assertThat( toCompare, GreaterOrEqual( lower ).and( LessOrEqual( upper ) ), "check range" );
		
		context.complete();
	}
}

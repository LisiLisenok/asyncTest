import herd.asynctest {
	AsyncPrePostContext
}


"Provides statistics of some variate values.  
 Statistic data is reseted before _each_ test.  "
see( `class StatisticSummary` )
by( "Lis" ) since( "0.6.0" )
shared class StatisticRule() satisfies TestRule
{

	"Calculations of the statistic data."
	StatisticCalculator calculator = StatisticCalculator();
	
	
	"Statistic summary accumulated up to the query moment."
	see( `function sample` )
	shared StatisticSummary statisticSummary => calculator.statisticSummary;
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary` )
	shared void sample( Float* values ) => calculator.sample( *values );
	
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		calculator.reset();
		context.proceed();
	}
	
}

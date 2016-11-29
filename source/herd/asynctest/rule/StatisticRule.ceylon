import herd.asynctest {
	AsyncPrePostContext
}


"Provides statistics of some variate values.  
 Statistic data is reseted before _each_ test.  "
see( `class StatisticSummary` )
tagged( "TestRule" ) by( "Lis" ) since( "0.6.0" )
shared class StatisticRule() satisfies TestRule
{

	"Calculations of the statistic data."
	CurrentTestStore<StatisticCalculator> calculator = CurrentTestStore<StatisticCalculator>( StatisticCalculator );
	
	
	"Statistic summary accumulated up to the query moment."
	see( `function sample` )
	shared StatisticSummary statisticSummary => calculator.element.statisticSummary;
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary` )
	shared void sample( Float* values ) => calculator.element.sample( *values );
	
	
	shared actual void after( AsyncPrePostContext context ) => calculator.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => calculator.before( context );
	
}

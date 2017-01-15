import herd.asynctest {
	AsyncPrePostContext
}
import herd.asynctest.benchmark {
	StatisticSummary
}
import herd.asynctest.internal {
	StatisticCalculator
}


"Lock-free and thread-safely accumulates statistics data of some variate values.  
 Doesn't collect values, just accumulates statistic data when sample added - see [[sample]] and [[samples]].  
 Statistic data is reseted before _each_ test.  "
see( `class StatisticSummary` )
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class StatisticRule() satisfies TestRule
{

	"Calculations of the statistic data."
	CurrentTestStore<StatisticCalculator> calculator = CurrentTestStore<StatisticCalculator>( StatisticCalculator );
	
	
	"Statistic summary accumulated up to the query moment."
	see( `function samples`, `function sample` )
	shared StatisticSummary statisticSummary => calculator.element.statisticSummary;
	
	"Thread-safely adds a one sample to the statistic."
	see( `value statisticSummary`, `function samples` )
	shared void sample( Float val ) => calculator.element.sample( val );
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary`, `function sample` )
	shared void samples( {Float*} values ) => calculator.element.samples( values );
	
	
	shared actual void after( AsyncPrePostContext context ) => calculator.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => calculator.before( context );
	
}

import herd.asynctest {
	AsyncPrePostContext,
	AsyncTestContext
}


"Applies suite rules in the given order.
 Initialization (i.e. `initialize` methods) is performed with iterating of the `rules` in direct order,
 while diposing (i.e. `dispose` methods) is performed in reverse order. So, the first initialized is
 the last disposed."
tagged( "SuiteRule" ) since( "0.6.0" ) by( "Lis" )
shared class SuiteRuleChain (
	"A list of the rules to be chained in order they are provided." SuiteRule* rules
) satisfies SuiteRule {
	
	Anything(AsyncPrePostContext)[] initializers = [for ( r in rules ) r.initialize ];
	Anything(AsyncPrePostContext)[] cleaners = [for ( r in rules ) r.dispose ].reversed;
	

	shared actual void dispose( AsyncPrePostContext context )
		=> ChainedPrePostContext( context, cleaners.iterator() ).start();
	
	shared actual void initialize( AsyncPrePostContext context )
		=> ChainedPrePostContext( context, initializers.iterator() ).start();
	
}


"Applies test rules in the given order.
 Initialization (i.e. `before` methods) is performed with iterating of the `rules` in direct order,
 while diposing (i.e. `after` methods) is performed in reverse order. So, the first initialized is
 the last disposed."
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class TestRuleChain (
	"A list of the rules to be chained in order they are provided." TestRule* rules
) satisfies TestRule {
	
	Anything(AsyncPrePostContext)[] initializers = [for ( r in rules ) r.before ];
	Anything(AsyncPrePostContext)[] cleaners = [for ( r in rules ) r.after ].reversed;
	
	
	shared actual void after( AsyncPrePostContext context )
		=> ChainedPrePostContext( context, cleaners.iterator() ).start();
	
	shared actual void before( AsyncPrePostContext context )
		=> ChainedPrePostContext( context, initializers.iterator() ).start();
	
}


"Applies test statements in the given order."
tagged( "TestStatement" ) since( "0.6.1" ) by( "Lis" )
shared class TestStatementChain (
	"A list of the statements to be applied in order they are provided." TestStatement* statements
) satisfies TestStatement {
	
	Anything(AsyncTestContext)[] statementFunctions = [for ( s in statements ) s.apply ];
	
	shared actual void apply( AsyncTestContext context )
		=> ChainedTestContext( context, statementFunctions.iterator() ).process();
}

import herd.asynctest {
	AsyncPrePostContext
}


"Chain of suite rules is indended to run suite rules in specific order.
 Initialization (i.e. `initialize` methods) is performed with iterating of the `rules` in direct order,
 while diposing (i.e. `dispose` methods) is performed in reverse order. So the first initialized is
 the last disposed."
tagged( "SuiteRule" ) since( "0.6.0" ) by( "Lis" )
shared class SuiteRuleChain (
	SuiteRule* rules
) satisfies SuiteRule {
	
	Anything(AsyncPrePostContext)[] initializers = [for ( r in rules ) r.initialize ];
	Anything(AsyncPrePostContext)[] cleaners = [for ( r in rules ) r.dispose ].reversed;
	

	shared actual void dispose( AsyncPrePostContext context ) {
		ChainedPrePostContext c = ChainedPrePostContext( context, cleaners.iterator() );
		c.start();
	}
	
	shared actual void initialize( AsyncPrePostContext context ) {
		ChainedPrePostContext c = ChainedPrePostContext( context, initializers.iterator() );
		c.start();
	}
	
}


"Chain of test rules is indended to run test rules in specific order.
 Initialization (i.e. `before` methods) is performed with iterating of the `rules` in direct order,
 while diposing (i.e. `after` methods) is performed in reverse order. So the first initialized is
 the last disposed."
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class TestRuleChain (
	TestRule* rules
) satisfies TestRule {
	
	Anything(AsyncPrePostContext)[] initializers = [for ( r in rules ) r.before ];
	Anything(AsyncPrePostContext)[] cleaners = [for ( r in rules ) r.after ].reversed;
	
	
	shared actual void after( AsyncPrePostContext context ) {
		ChainedPrePostContext c = ChainedPrePostContext( context, cleaners.iterator() );
		c.start();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		ChainedPrePostContext c = ChainedPrePostContext( context, initializers.iterator() );
		c.start();
	}
	
}

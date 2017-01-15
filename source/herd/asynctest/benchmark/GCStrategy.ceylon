import java.lang {
	System
}


"Executes garbage collector at the given `stage`."
tagged( "Callbacks" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared void gcCallback( "Stages GC has to be executed at." Stage+ stages )( "Current stage." Stage stage ) {
	if ( stage in stages ) {
		System.gc();
	}
}

"Executes garbage collector before warmup and measure rounds. "
tagged( "Callbacks" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared Anything(Stage) gcBeforeRounds = gcCallback( Stage.beforeWarmupRound, Stage.beforeMeasureRound );

"Executes garbage collector before measure round."
tagged( "Callbacks" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared Anything(Stage) gcBeforeMeasureRound = gcCallback( Stage.beforeMeasureRound );

"Executes garbage collector before each measure iteration."
tagged( "Callbacks" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared Anything(Stage) gcBeforeMeasureIteration = gcCallback( Stage.beforeMeasureIteration );

"Executes garbage collector before each warmup and measure iteration."
tagged( "Callbacks" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared Anything(Stage) gcBeforeIterations = gcCallback( Stage.beforeWarmupIteration, Stage.beforeMeasureIteration );

import java.lang {
	System
}


"Strategy to run garbage collector."
tagged( "Options" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared interface GCStrategy {
	"Runs garbage collector if all conditions meet the strategy."
	shared formal void gc( "Current execution stage." Stage stage );
}


"Identifies at which execution stages garbage collector has to be run."
tagged( "Options" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared final class GCStagedStrategy satisfies GCStrategy {
	
	Stage[] stageSet;
	
	
	"Runs GC at a number of stages."
	shared new combined( Stage+ stages ) {
		stageSet = stages;
	}
	
	"GC is to be never run."
	shared new never {
		stageSet = empty;
	}
	
	"Runs GC before warmup round only."
	shared new beforeWarmupRound {
		stageSet = [Stage.beforeWarmupRound];
	}
	
	"Runs GC before measure round only."
	shared new beforeMeasureRound {
		stageSet = [Stage.beforeMeasureRound];
	}
	
	"Runs GC before warmup and measure rounds."
	shared new beforeRounds {
		stageSet = [Stage.beforeWarmupRound, Stage.beforeMeasureRound];
	}
	
	"Runs GC before each iteration."
	shared new beforeEachIteration {
		stageSet = [Stage.beforeWarmupIteration, Stage.beforeMeasureIteration];
	}
	
	
	"Runs GC if `stage` satisfies the strategy requirements."
	shared actual void gc( "Current execution stage." Stage stage ) {
		if ( stageSet.contains( stage ) ) {
			System.gc();
		}
	}
	
}

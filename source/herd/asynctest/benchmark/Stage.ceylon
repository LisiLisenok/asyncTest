

"Identifies a stage of the bench execution."
see( `class Options`, `function gcCallback` )
tagged( "Options" )
since( "0.7.0" ) by( "Lis" )
shared class Stage
	of beforeWarmupRound | afterWarmupRound | beforeWarmupIteration | afterWarmupIteration
		| beforeMeasureRound | afterMeasureRound | beforeMeasureIteration | afterMeasureIteration
{
	shared actual String string;
	
	"Before warmup round."
	shared new beforeWarmupRound {
		string = "before warmup round stage";
	}
	
	"After warmup round."
	shared new afterWarmupRound {
		string = "after warmup round stage";
	}
	
	"Before warmup iteration."
	shared new beforeWarmupIteration {
		string = "before warmup iteration stage";
	}
	
	"After warmup iteration."
	shared new afterWarmupIteration {
		string = "after warmup iteration stage";
	}
	
	"Before measure round."
	shared new beforeMeasureRound {
		string = "before measure round stage";
	}
	
	"After measure round."
	shared new afterMeasureRound {
		string = "after measure round stage";
	}
	
	"Before measure iteration."
	shared new beforeMeasureIteration {
		string = "before measure iteration stage";
	}
	
	"After measure iteration."
	shared new afterMeasureIteration {
		string = "after measure iteration stage";
	}
	
}

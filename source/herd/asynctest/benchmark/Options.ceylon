

"Benchmark options."
tagged( "Options" )
see( `function benchmark`, `interface Bench` )
since( "0.7.0" ) by( "Lis" )
shared class Options (
	"Criterion which identifies when measure round have to be completed."
	shared CompletionCriterion measureCriterion,
	"Optional criterion which identifies when warmup round have to be completed.  
	 Warmup round is skipped if `null`."
	shared CompletionCriterion? warmupCriterion = null,
	"Number of iterations per a one loop.  
	 Total number of loops are identified by [[warmupCriterion]] for warmup round
	 and by [[measureCriterion]] for measure round."
	shared Integer iterationsPerLoop = 10,
	"Time unit the results have to be reported with."
	shared TimeUnit timeUnit = TimeUnit.seconds,
	"Clock factory (instantiated for each bench and each execution thread ).  
	 The clock is used to measure time intervals."
	shared Clock() clock = WallClock,
	"`true` if runs when GC has been started has to be skipped and `flase` otherwise."
	shared Boolean skipGCRuns = true
) {}

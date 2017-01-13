

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
	"Time unit the results have to be reported with.  Default is seconds."
	shared TimeUnit timeUnit = TimeUnit.seconds,
	"Clock to measure time intervals.  Default wall clock."
	shared Clock clock = WallClock(),
	"Identifies GC execution strategy, i.e. how often to run GC.  
	 By default GC is executed before warmup round and before iteraton round."
	shared GCStrategy gcStrategy = GCStagedStrategy.beforeRounds,
	"`true` if runs when GC has been started has to be skipped and `flase` otherwise.  
	 By default is `true`."
	shared Boolean skipGCRuns = true
) {
}

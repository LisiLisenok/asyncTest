

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
	"`true` if runs when GC has been started has to be skipped and `flase` otherwise.  
	 By default is `true`."
	shared Boolean skipGCRuns = true,
	"Callbacks executed at each stage.  
	 By default callback which executes garbage collector before warmup and measure rounds (see [[gcBeforeRounds]])."
	shared Anything(Stage)[] callbacks = [gcBeforeRounds]
) {
}


"Returns options with prepended callbacks."
since( "0.7.0" ) by( "Lis" )
Options prependCallbacksToOptions( Options options, Anything(Stage)+ callbacks ) 
	=> Options( options.measureCriterion, options.warmupCriterion, options.timeUnit, options.clock, options.skipGCRuns,
				options.callbacks.prepend( callbacks ) );

"Returns options with appended callbacks."
since( "0.7.0" ) by( "Lis" )
Options appendCallbacksToOptions( Options options, Anything(Stage)+ callbacks ) 
		=> Options( options.measureCriterion, options.warmupCriterion, options.timeUnit, options.clock, options.skipGCRuns,
			options.callbacks.append( callbacks ) );

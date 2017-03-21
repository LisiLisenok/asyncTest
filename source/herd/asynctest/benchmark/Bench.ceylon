

"Represents benchmark test parameterized with `Parameter` type."
tagged( "Bench" )
see( `function benchmark` )
since( "0.7.0" ) by( "Lis" )
shared interface Bench<in Parameter>
		given Parameter satisfies Anything[]
{
	
	"Bench title. Generally unique."
	shared formal String title;
	
	"Executes this bench with the given `Parameter` value.  
	 Returns statistic of operations per second for the execution."
	shared formal BenchResult execute (
		"Options of the bench execution." Options options,
		"Value of the parameter the bench is parameterized with." Parameter parameter
	);
	
}

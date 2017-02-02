

"Executes bench functions `benches` in separated threads.  
 Number of threads for each bench function is specified by the bench parameter with corresponding index.  
 I.e. given list of bench function `benches` and list of `Integer` (`parameter` argument of [[execute]]).  
 For each bench function with index `index` number of threads to execute the function is specified via
 item of `parameter` list with the same index `index`.   
 So the bench is parameterized by number of execution threads.   
 "
tagged( "Bench" )
since( "0.7.0" ) by( "Lis" )
shared class MultiBench (
	shared actual String title,
	"Bench functions." Anything() | BenchFlow<[]> + benchFunctions
)
		satisfies Bench<[Integer+]>
{	
	
	shared actual StatisticSummary execute( Options options, [Integer+] parameter )
		=> object extends ThreadableRunner( options ) {
			variable RunnableBench[] benchesMemo = [];
			shared actual RunnableBench[] benches
				=>	if ( benchesMemo nonempty ) then benchesMemo
					else ( benchesMemo = [
						for ( [func, threadNum] in zipPairs( benchFunctions, parameter ) )
							for ( i in 0 : threadNum )
								RunnableBench( if ( is BenchFlow<[]> func ) then func else EmptyBenchFlow( func ) )
						]
					);
		}.execute();
	
}

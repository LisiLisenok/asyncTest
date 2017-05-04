

"Flow which selects another bench function each given number of benchmark iterations.  
 `select` has to return currently selected bench function.  
 The bench functions are selected independently for each execution thread."
tagged( "Bench flow" )
see( `class SingleBench`, `class MultiBench` )
since( "0.7.0" ) by( "Lis" )
shared class SelectiveFlow<in Parameter> (
	shared actual Anything(*Parameter) select(),
	shared actual Integer | Integer() iterations = 0
)
		extends AbstractSelectiveFlow<Parameter>()
		given Parameter satisfies Anything[]
{}

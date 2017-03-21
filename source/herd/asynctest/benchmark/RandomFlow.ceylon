import java.util {
	Random
}


"Randomly selects benchmark function from the given list each time before execution.  
 Each function is paired with corresponding _selection probability_.
 Which identifies the selection frequency or distribution.     
 
 For example:  
 `[function1, 0.3], [function2, 0.7]` leads to `function1` calling of 30% and `function2` calling of 70%
 from total number of executions.  
 
 If total sum of probabilities does not equal to 1.0 the probability of any function calling is calculated as
 ratio of the given probability to the total sum of probabilities.  
 
 Bench functions are selected independently for each execution thread.
"
throws( `class AssertionError`, "selection probability (i.e. second item in each argument tuple) is not positive." )
tagged( "Bench flow" )
see( `class SingleBench`, `class MultiBench` )
since( "0.7.0" ) by( "Lis" )
shared class RandomFlow<in Parameter> (
	shared actual Integer | Integer() iterations,
	"A list of functions to be selected.
	 Each function is paired with corresponding _selection probability_ which has to be positive."
	[Anything(*Parameter), Float]+ benchFunctions
)
		extends AbstractSelectiveFlow<Parameter>()
		given Parameter satisfies Anything[]
{
	
	value actualBenches = reducedProbability( benchFunctions );
	Random rnd = Random();
	
	
	shared actual Anything(*Parameter) select() {
		Float probability = rnd.nextFloat();
		for ( item in actualBenches ) {
			if ( probability < item[1] ) {
				return item[0];
			}
		}
		return actualBenches.last[0];
	}
	
}

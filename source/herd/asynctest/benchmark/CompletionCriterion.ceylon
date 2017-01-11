

"Identifies if benchmark iterations have to be completed or continued."
tagged( "Options", "Criteria" )
see( `function benchmark`, `class Options` )
since( "0.7.0" ) by( "Lis" )
shared interface CompletionCriterion {
	
	"Resets criterion to an initial state."
	shared formal void reset();
	
	"Returns `true` if completion criterion is met and `false` otherwise."
	shared formal Boolean verify (
		"The latest execution time in the given time unit." Float delta,
		"Accumulated execution statistic of operations per given time unit." StatisticSummary result,
		"Time unit [[delta]] and [[result]] are measured in." TimeUnit timeUnit
	);
	
	"Combines `this` and `other` criterion using logical `and`.  
	 I.e. returned criterion completes only if both `this` and `other` are completed."
	shared default CompletionCriterion and( CompletionCriterion other ) {
		return AndCriterion( this, other );
	}
	
	"Combines `this` and `other` criterion using logical `or`.  
	 I.e. returned criterion completes if either `this` or `other` is completed."
	shared default CompletionCriterion or( CompletionCriterion other ) {
		return OrCriterion( this, other );
	}
	
}


"Logical and of two criteria."
since( "0.7.0" ) by( "Lis" )
class AndCriterion( CompletionCriterion+ criteria ) satisfies CompletionCriterion {

	shared actual void reset() {
		for ( item in criteria ) {
			item.reset();
		}
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit timeUnit ) {
		for ( item in criteria ) {
			if ( !item.verify( delta, result, timeUnit ) ) {
				return false;
			}
		}
		return true;
	}
	
	shared actual CompletionCriterion and( CompletionCriterion other ) {
		return AndCriterion( other, *criteria );
	}
	
}


"Logical or of two criteria."
since( "0.7.0" ) by( "Lis" )
class OrCriterion( CompletionCriterion+ criteria ) satisfies CompletionCriterion {
	
	shared actual void reset() {
		for ( item in criteria ) {
			item.reset();
		}
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit timeUnit ) {
		for ( item in criteria ) {
			if ( item.verify( delta, result, timeUnit ) ) {
				return true;
			}
		}
		return false;
	}
	
	shared actual CompletionCriterion or( CompletionCriterion other ) {
		return OrCriterion( other, *criteria );
	}

}

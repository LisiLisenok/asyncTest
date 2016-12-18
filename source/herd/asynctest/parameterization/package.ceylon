
"
 Value- and type- parameterized testing.  
 
 
 ### Base  
 
 In order to perform parameterized testing the test function has to be marked with annotation which supports
 [[TestVariantProvider]] interface. The interface has just a one method - `variants()`
 which has to provide [[TestVariantEnumerator]]. The enumerator produces a stream
 of the [[TestVariant]]'s and is iterated just a once.
 The test will be performed using all variants the enumerator produces.  
 
 > The enumerator may return test variants lazily, dynamicaly or even non-determenisticaly.  
 > Each [[TestVariant]] contains a list of generic type parameters and a list of function arguments.  
 
 
 ### Custom parameterization  
 
 1. Implement [[TestVariantEnumerator]] interface:
 		class MyTestVariantEnumerator(...) satisfies TestVariantEnumerator {
 			shared actual TestVariant|Finished current => ...;
 
 			shared actual void moveNext(TestVariantResult result) {
 				if (testToBeCompleted) {
 					// set `current` to `finished`
 				} else {
 					// set `current` to test variant to be tested next
 				}
 			}
 		}
 		
 2. Make an annotation which satisfies [[TestVariantProvider]] interface:
 		shared final annotation class MyParameterizedAnnotation(...)
 			satisfies SequencedAnnotation<MyParameterizedAnnotation, FunctionDeclaration>&TestVariantProvider
 		{
 			shared actual TestVariantEnumerator variants() => MyTestVariantEnumerator(...);
 		}
 		
 		shared annotation MyParameterizedAnnotation myParameterized(...) => MyParameterizedAnnotation(...);
 		
 
 3. Mark test function with created annotation:
 		myParameterized(...) void myTest(...) {...}
  
 
 ### Varianted testing  
 
 [[parameterized]] annotation satisfies [[TestVariantProvider]] interface and
 provides type- and value- parameterized testing based on collection of test variants.  
 
 
 ### Combinatorial testing    
 
 Combinatorial testing provides generation of test variants based on data sources of each test function argument.  
 
 #### Therminology
 
 * _Data source_ is a list of the values to be applied as particular value of the test function argument.  
 * _Variant generator_ is a function which generates test variants based on _data sources_ for each test function argument.  
 * _Argument kind_ is an indicator which is applied to each argument of test function
   and which _variant generator_ may used to identify particular strategy of the variants generation.  
 
 #### Usage
 
 1. Declare test function:
 		void combinatorialTest(Something arg1, Something arg2);  
 2. Declare _data sources_.  
 		Something[] arg1Source =>
 		Something[] arg2Source =>
 3. Apply _data source_ for each argument of the test function.  
 		void combinatorialTest(permutationSource(`arg1Source`) Something arg1,
 			permutationSource(`arg2Source`) Something arg2);
 4. Apply _variant generator_ to test function
 		permuting void combinatorialTest(permutationSource(`arg1Source`) Something arg1,
 			permutationSource(`arg2Source`) Something arg2);
 5. Mark the function with `async` and `test` annotations and run test 
 		async test permuting void combinatorialTest(permutationSource(`arg1Source`) Something arg1,
 			permutationSource(`arg2Source`) Something arg2);
 
 #### Argument kind
 
 The kind is used by _variant generator_ in order to identify strategy for the variant generations.  
 There are two kinds:  
 * [[ZippedKind]] indicates that the data has to be combined with others by zipping the sources,
   i.e. combine the values with the same index.  
 * [[PermutationKind]] indicates that the data has to be combined with others
   using all possible permutations of the source.  
 
 Custom kind has to extend [[CombinatorialKind]].  
 
 #### Data source
 
 [[DataSourceAnnotation]] provides for the marked argument of the test function:  
 * list of the argument values  
 * argument kind  
 
 There are three functions to apply the annotation:  
 1. [[dataSource]] which instantiates [[DataSourceAnnotation]] using both parameters.  
 2. [[zippedSource]] which provides a list of the argument values and mark argument as [[zippedKind]].  
 3. [[permutationSource]] which provides a list of the argument values and mark argument as [[permutationKind]].  
 
 > [[DataSourceAnnotation]] annotation has to be applied to the each argument of the test function.  
 
 #### Variant generator
 
 Is applied to a test function with [[CombinatorialAnnotation]] annotation.  
 There are four functions to apply the annotation:  
 * [[combinatorial]] applies custom _variant generator_  
 * [[zipping]] applies [[zippingCombinations]] _variant generator_ which zips the arguments
   (each argument has to be [[zippedKind]])
 * [[permuting]] applies [[permutingCombinations]] _variant generator_ which permutes all possible variants
   (each argument has to be [[permutationKind]])
 * [[mixing]] applies [[mixingCombinations]] _variant generator_ which mixes zipped and permuted arguments  
 
 > Custom _variant generator_ has to take a list of [[ArgumentVariants]] and has to return [[TestVariantEnumerator]].  
 
"
since( "0.6.1" ) by( "Lis" )
shared package herd.asynctest.parameterization;

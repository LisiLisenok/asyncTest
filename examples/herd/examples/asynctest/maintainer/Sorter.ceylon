import ceylon.test {

	parameters,
	test
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	EqualObjects
}


"Input for [[Sorter]]. Is used for conviniency in parameters representation in test reporting."
shared class SortInput (
	"To be sorted stream." shared Integer[] input,
	"Already sorted stream." shared Integer[] expected,
	"String representation to be shoen in `parameters` report" shared actual String string
) {
}


"Generating input for [[Sorter]]."
{[SortInput]*} generateSortInput() {
	
	Integer[] input1 = 1..100000;
	Integer[] input2 = 200000..100001;
	
	return {
		[SortInput( input1, input1, "direct" )],
		[SortInput( input2, input2.reversed, "reversed" )],
		[SortInput( input1.chain( input2 ).sequence(), input1.chain( input2.reversed ).sequence(), "combined" )]
	};
}


"Groups testing on sorting."
by( "Lis" )
shared class Sorter()
{
	
	"Sorts [[SortInput.input]] using `Sequential.sort`
	 and compares result to `SortInput.expected using operator `==`."
	test parameters( `function generateSortInput` )
	shared void sortWithExpected( AsyncTestContext context, SortInput input ) {
		context.start();
		context.assertThat (
			input.input.sort( increasing<Integer> ), EqualObjects( input.expected ), input.string, true
		);
		context.complete();
	}
	
}

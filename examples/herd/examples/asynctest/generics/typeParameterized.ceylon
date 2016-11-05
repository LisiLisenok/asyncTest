import ceylon.test {
	test
}
import herd.asynctest {
	parameterized,
	AsyncTestContext,
	TestVariant
}
import herd.asynctest.match {
	EqualObjects,
	EqualTo
}


"Parameters of [[testIdentity]]."
{TestVariant*} identityArgs => {
	TestVariant([`String`], ["stringIdentity"]),
	TestVariant([`Integer`], [1]),
	TestVariant([`Float`], [1.0])
};

"Type parameterized test of `ceylon.language::identity<Value>`.
 Type parameters and function arguments are specified via [[identityArgs]].
 "
shared test parameterized(`value identityArgs`)
void testIdentity<Value>(AsyncTestContext context, Value arg)
	given Value satisfies Object
{
	context.assertThat(identity<Value>(arg), EqualObjects<Value>(arg), "", true );
	context.complete();
}


"Parameters of [[testLargest]]."
{TestVariant*} largestArgs => {
	TestVariant([`Integer`], [1, 2, 2]),
	TestVariant([`Integer`], [3, 2, 3]),
	TestVariant([`Float`], [1.0, 2.0, 2.0]),
	TestVariant([`Float`], [2.5, 2.0, 2.5])
};

"Type parameterized test of `ceylon.language::largest<Element>`.
 Type parameters and function arguments are specified via [[largestArgs]].
 "
shared test parameterized(`value largestArgs`)
void testLargest<Element>(AsyncTestContext context, Element x, Element y, Element merit)
		given Element satisfies Comparable<Element>
{
	context.assertThat(largest<Element>(x, y), EqualTo<Element>(merit), "", true );
	context.complete();
}


"Parameters of [[testSort]]."
{TestVariant*} sortArgs => {
	TestVariant([`Integer`], [[3, 2, 1], [1, 2, 3]]),
	TestVariant([`Integer`], [[3, 2, 4, 1], [1, 2, 3, 4]]),
	TestVariant([`Float`], [[2.5, 3.5, 1.5], [1.5, 2.5, 3.5]]),
	TestVariant([`Float`], [[2.5, 3.5, 1.5, 4.5], [1.5, 2.5, 3.5, 4.5]])
};

"Parameters of [[testSort]]."
{TestVariant*} sortArgsString => {
	TestVariant([`String`], [["3", "2", "1"], ["1", "2", "3"]]),
	TestVariant([`String`], [["abc", "ghi", "def"], ["abc", "def", "ghi"]])
};

"Type parameterized test of `ceylon.language::sort<Element>`.
 Type parameters and function arguments are specified via [[sortArgs]] and [[sortArgsString]].
 "
shared test 
parameterized(`value sortArgs`)
parameterized(`value sortArgsString`)
void testSort<Element>(AsyncTestContext context, Element[] stream, Element[] merit)
		given Element satisfies Comparable<Element>
{
	context.assertThat(sort<Element>(stream), EqualObjects<Element[]>(merit), "", true );
	context.complete();
}

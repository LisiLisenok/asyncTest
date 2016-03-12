import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package
}


"Identifies a test group."
see( `interface TestMaintainer`, `class TestSummary` )
by( "Lis" )
shared final class TestGroup (
	"Container the group is originated for." shared ClassDeclaration | Package container
)
		extends Object()
		satisfies Comparable<TestGroup>
{
	"Group name."
	shared String name => container.qualifiedName;
	
	shared actual String string => "test group of ``container.qualifiedName``";
	
	shared actual Comparison compare( TestGroup other ) => name <=> other.name;
	
	shared actual Boolean equals( Object that ) {
		if ( is TestGroup that ) {
			return container == that.container;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash => container.hash;
	
}

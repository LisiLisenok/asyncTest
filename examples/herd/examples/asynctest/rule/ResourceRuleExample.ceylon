import herd.asynctest.rule {
	ResourceRule,
	testRule
}
import herd.asynctest {
	AsyncTestContext,
	async,
	arguments
}
import ceylon.test {
	test
}
import herd.asynctest.match {
	EqualObjects
}


"Returns file name and content."
String[2] resourceArgs() => ["file.txt", "Hello, World!"];

"Reads resource with name `fileName` and verifies that name is correct and resource content coincides with `fileContent`."
arguments( `function resourceArgs` )
class ResourceRuleExample( String fileName, String fileContent ) {
	
	shared testRule ResourceRule resource = ResourceRule( `module`, fileName );

	
	"Verifies that `resource` name is equal to `fileName`."
	shared test async void fileNameTest( AsyncTestContext context ) {
		context.assertThat( resource.name, EqualObjects( fileName ), "", true );
		context.complete();
	}
	
	"Verifies that `resource` content is equal to `fileContent`."
	shared test async void contentTest( AsyncTestContext context ) {
		context.assertThat( resource.textContent(), EqualObjects( fileContent ), "", true );
		context.complete();
	}
	
}
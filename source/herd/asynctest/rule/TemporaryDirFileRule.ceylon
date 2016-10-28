import herd.asynctest {
	AsyncPrePostContext
}
import ceylon.file {
	Directory,
	temporaryDirectory,
	File
}


"The rule which creates new temporary directory before _each_ test and destroyes it after."
since( "0.6.0" ) by( "Lis" )
shared class TemporaryDirectoryRule()
		satisfies TestRule
{
	
	variable Directory.TemporaryDirectory tempDir = temporaryDirectory.TemporaryDirectory( null );
	
	
	"The directory behinds this rule."
	shared Directory directory => tempDir;
	
	shared actual void after( AsyncPrePostContext context ) {
		tempDir.destroy( null );
		context.proceed();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		tempDir = temporaryDirectory.TemporaryDirectory( null );
		context.proceed();
	}
	
}


"The rule which creates new temporary file before _each_ test and destroyes it after."
since( "0.6.0" ) by( "Lis" )
shared class TemporaryFileRule()
	satisfies TestRule
{
	
	variable Directory.TemporaryFile tempFile = temporaryDirectory.TemporaryFile( null, null );
	
	
	"The file behinds this rule."
	shared File file => tempFile; 
	
	shared actual void after( AsyncPrePostContext context ) {
		tempFile.destroy( null );
		context.proceed();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		tempFile = temporaryDirectory.TemporaryFile( null, null );
		context.proceed();
	}
	
}

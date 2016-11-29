import herd.asynctest {
	AsyncPrePostContext
}
import ceylon.file {
	Directory,
	temporaryDirectory,
	File
}


"Creates new temporary directory before _each_ test and destroyes it after."
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class TemporaryDirectoryRule()
		satisfies TestRule
{
	
	CurrentTestStore<Directory.TemporaryDirectory> tempDir
			= CurrentTestStore<Directory.TemporaryDirectory>( () => temporaryDirectory.TemporaryDirectory( null ) );
	
	
	"The directory behinds this rule."
	shared Directory directory => tempDir.element;
	
	shared actual void after( AsyncPrePostContext context ) {
		tempDir.element.destroy( null );
		tempDir.after( context );
	}
	
	shared actual void before( AsyncPrePostContext context ) => tempDir.before( context );
	
}


"Creates new temporary file before _each_ test and destroyes it after."
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class TemporaryFileRule()
	satisfies TestRule
{
	
	CurrentTestStore<Directory.TemporaryFile> tempFile
			= CurrentTestStore<Directory.TemporaryFile>( () => temporaryDirectory.TemporaryFile( null, null ) );
	
	
	"The file behinds this rule."
	shared File file => tempFile.element; 
	
	shared actual void after( AsyncPrePostContext context ) {
		tempFile.element.destroy( null );
		tempFile.after( context );
	}
	
	shared actual void before( AsyncPrePostContext context ) => tempFile.before( context );
	
}

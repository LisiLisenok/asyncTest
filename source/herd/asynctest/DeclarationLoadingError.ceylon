

"Exception thrown when declaration is not found on module or package."
by( "Lis" )
shared abstract class DeclarationLoadingError( String message, Throwable? cause = null )
		of ModuleLoadingError | PackageLoadingError | TopLevelDeclarationLoadingError | DefaultConstructorNotFound
		extends Exception( message, cause )
{}


"Exception thrown when module is not found."
by( "Lis" )
shared class ModuleLoadingError (
	"name of the loaded module" shared String moduleName,
	"version of the loaded module" shared String moduleVersion,
	"name of the loaded declaration (top level function or class)" shared String declarationName,
	Throwable? cause = null
)
	extends DeclarationLoadingError (
		"loading ``declarationName``: unable to load module ``moduleName``/``moduleVersion``",
		cause
	)
{}


"Exception thrown when package is not found."
by( "Lis" )
shared class PackageLoadingError (
	"name of the loaded module" shared String moduleName,
	"version of the loaded module" shared String moduleVersion,
	"name of the loaded package" shared String packageName,
	"name of the loaded declaration (top level function or class)" shared String declarationName,
	Throwable? cause = null
)
	extends DeclarationLoadingError (
		"loading ``declarationName``: module ``moduleName``/``moduleVersion`` doesn't contain package ``packageName``",
		cause
	)
{}

	
"Exception thrown when top level declaration (function or class) is not found."
by( "Lis" )
shared class TopLevelDeclarationLoadingError (
	"name of the loaded module" shared String moduleName,
	"version of the loaded module" shared String moduleVersion,
	"name of the loaded package" shared String packageName,
	"name of the loaded declaration" shared String topLevelDeclaration,
	Throwable? cause = null
)
	extends DeclarationLoadingError (
		"package ``packageName``/``moduleVersion`` doesn't contain top level declaration ``topLevelDeclaration``",
		cause
	)
{}

	
"Exception thrown when loaded / instantiated class doesn't contain default constructor."
by( "Lis" )
shared class DefaultConstructorNotFound (
	"name of the loaded module" shared String moduleName,
	"version of the loaded module" shared String moduleVersion,
	"name of the loaded package" shared String packageName,
	"name of the loaded declaration" shared String className,
	Throwable? cause = null
)
	extends DeclarationLoadingError (
		"class ``packageName``::``className``/``moduleVersion`` doesn't have default constructor",
		cause
	)
{}




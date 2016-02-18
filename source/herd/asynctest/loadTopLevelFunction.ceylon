import ceylon.language.meta.model {

	Type,
	IncompatibleTypeException,
	TypeApplicationException
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}


"Loads shared or unshared function with name [[functionName]] from package [[packageName]]
 of module [[moduleName]], with version [[moduleVersion]].  
 The module has to be already loaded or has to be on your repo path.
 "
throws( `class ModuleLoadingError`, "Unable to load module." )
throws( `class PackageLoadingError`, "Unable to find package." )
throws( `class TopLevelDeclarationLoadingError`, "Unable to find class declaration." )
throws( `class IncompatibleTypeException`,
	"If the specified `Return` or `Arguments` type arguments are not compatible with the actual declaration.")
throws( `class TypeApplicationException`,
		"If the specified closed type argument values are not compatible with the actual result's type parameters.")
see( `function loadAndInstantiate`, `function FunctionDeclaration.apply` )
by( "Lis" )
shared Return(*Arguments) loadTopLevelFunction<Return, Arguments> (
	"name of the module which contains declaration" String moduleName,
	"version of the module" String moduleVersion,
	"full name (including module name) of the package which contains declaration" String packageName,
	"name of the loaded function" String functionName,
	"generic type arguments to be applied to declaration" Type<Anything>[] typeArguments
)
		given Arguments satisfies Anything[]
{
	if ( exists m = loadModule( moduleName, moduleVersion ) ) {
		if ( exists pac = m.findPackage( packageName ) ) {
			if ( exists fDecl = pac.getFunction( functionName ), fDecl.toplevel ) {
				return fDecl.apply<Return, Arguments>( *typeArguments );
			}
			else {
				throw TopLevelDeclarationLoadingError( moduleName, moduleVersion, packageName, functionName );
			}
		}
		else {
			throw PackageLoadingError( moduleName, moduleVersion, packageName, functionName );
		}
	}
	else {
		throw ModuleLoadingError( moduleName, moduleVersion, functionName );
	}
}

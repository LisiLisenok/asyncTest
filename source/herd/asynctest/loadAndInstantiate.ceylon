import ceylon.language.meta.model {

	Type,
	IncompatibleTypeException,
	InvocationException,
	CallableConstructor
}
import ceylon.language.meta.declaration {

	ClassDeclaration
}


"Loads and instantiates shared or unshared class with name [[className]] from package [[packageName]]
 of module [[moduleName]], with version [[moduleVersion]].  
 The object is instantiated using default contructor.  
 The module has to be already loaded or has to be on your repo path.
 "
throws( `class ModuleLoadingError`, "Unable to load module." )
throws( `class PackageLoadingError`, "Unable to find package." )
throws( `class TopLevelDeclarationLoadingError`, "Unable to find class declaration." )
throws( `class DefaultConstructorNotFound`, "Instantiated class doesn't contain default constructor." )
throws( `class IncompatibleTypeException`, "If any argument is not assignable to the default constructor corresponding parameter." )
throws( `class InvocationException`, "If there are not enough or too many provided arguments of the default constructor." )
see( `function loadTopLevelFunction`, `value ClassDeclaration.defaultConstructor` )
see( `function CallableConstructor.apply` )
by( "Lis" )
shared Result loadAndInstantiate<Result, Arguments> (
	"name of the module which contains declaration" String moduleName,
	"version of the module" String moduleVersion,
	"full name (including module name) of the package which contains declaration" String packageName,
	"name of the declaration" String className,
	"generic type arguments to be applied to declaration" Type<>[] typeArguments,
	"arguments of the default constructor" Arguments defaultConstructorArguments
)
		given Arguments satisfies Anything[]
{
	if ( exists m = loadModule( moduleName, moduleVersion ) ) {
		if ( exists pac = m.findPackage( packageName ) ) {
			if ( exists decl = pac.getMember<ClassDeclaration>( className ) ) {
				if ( exists const = decl.defaultConstructor ) {
					return const.apply<Result, Arguments>( *typeArguments ).apply( *defaultConstructorArguments );
				}
				else {
					throw DefaultConstructorNotFound( moduleName, moduleVersion, packageName, className );
				}
			}
			else {
				throw TopLevelDeclarationLoadingError( moduleName, moduleVersion, packageName, className );
			}
		}
		else {
			throw PackageLoadingError( moduleName, moduleVersion, packageName, className );
		}
	}
	else {
		throw ModuleLoadingError( moduleName, moduleVersion, className );
	}
}

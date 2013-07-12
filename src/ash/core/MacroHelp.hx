package ash.core;
import haxe.Log;
import haxe.macro.Context;
import haxe.macro.Expr;
/**
 * ...
 * @author Dairectx
 */
class MacroHelp
{

	public function new() 
	{
		
	}
	
	macro public static function getClassNameString<T>( componentClass:ExprOf<Class<T>>):ExprOf<String>
	{
		haxe.Log.trace( Context.typeof(componentClass) );
		var className:String;
		switch( Context.typeof(componentClass) )
		{
			case TType( t,_):
			{
				className = t.toString();
			}
			case _:
		}
		Context.warning(className, Context.currentPos());
		return macro $v{className};
	}
	
}
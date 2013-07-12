package ash.core;

import ash.signals.Signal2;
import haxe.ds.StringMap.StringMap;
import haxe.Log;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * An entity is composed from components. As such, it is essentially a collection object for components.
 * Sometimes, the entities in a game will mirror the actual characters and objects in the game, but this
 * is not necessary.
 *
 * <p>Components are simple value objects that contain data relevant to the entity. Entities
 * with similar functionality will have instances of the same components. So we might have
 * a position component</p>
 *
 * <p><code>class PositionComponent
 * {
 *   public var x:Float;
 *   public var y:Float;
 * }</code></p>
 *
 * <p>All entities that have a position in the game world, will have an instance of the
 * position component. Systems operate on entities based on the components they have.</p>
 */
class Entity
{
    private static var nameCount:Int = 0;

    /**
     * Optional, give the entity a name. This can help with debugging and with serialising the entity.
     */
    public var name(default, set_name):String;
    /**
     * This signal is dispatched when a component is added to the entity.
     */
    public var componentAdded(default, null):Signal2<Entity, String>;
    /**
     * This signal is dispatched when a component is removed from the entity.
     */
    public var componentRemoved(default, null):Signal2<Entity, String>;
    /**
     * Dispatched when the name of the entity changes. Used internally by the engine to track entities based on their names.
     */
    public var nameChanged:Signal2<Entity, String>;

    public var previous:Entity;
    public var next:Entity;
    public var components(default, null):StringMap<Dynamic>;

    public function new(name:String = "")
    {
        componentAdded = new Signal2<Entity, String>();
        componentRemoved = new Signal2<Entity, String>();
        nameChanged = new Signal2<Entity, String>();
        components = new StringMap();

        if (name != "")
            this.name = name;
        else
            this.name = "_entity" + (++nameCount);
    }

    private inline function set_name(value:String):String
    {
        if (name != value)
        {
            var previous = name;
            name = value;
            nameChanged.dispatch(this, previous);
        }
        return value;
    }

    /**
     * Add a component to the entity.
     *
     * @param component The component object to add.
     * @param componentClass The class of the component. This is only necessary if the component
     * extends another component class and you want the framework to treat the component as of
     * the base class type. If not set, the class type is determined directly from the component.
     *
     * @return A reference to the entity. This enables the chaining of calls to add, to make
     * creating and configuring entities cleaner. e.g.
     *
     * <code>var entity:Entity = new Entity()
     *     .add(new Position(100, 200)
     *     .add(new Display(new PlayerClip());</code>
     */

    public function add<T>(component:T, ?componentClass:Class<T>):Entity
    {
        if (componentClass == null)
            componentClass = Type.getClass(component);

		var componentClassName:String = Type.getClassName( componentClass );
		Log.trace(componentClassName);
        if (components.exists(componentClassName))
            remove_(componentClassName);

        components.set(componentClassName , component);
        componentAdded.dispatch(this, componentClassName);
        return this;
    }

    /**
     * Remove a component from the entity.
     *
     * @param componentClass The class of the component to be removed.
     * @return the component, or null if the component doesn't exist in the entity
     */

	 public function remove_(componentClassName:String)
	 {
		var component = components.get(componentClassName);
        if (component != null)
        {
            components.remove(componentClassName);
            componentRemoved.dispatch(this, componentClassName );
        }
		return component;
	 }
	 
    macro public function remove<T>( self:ExprOf<Entity>  , componentClass:ExprOf<Class<T>>):Expr
    {
		var componentClassName:String;
		switch(Context.typeof( componentClass ))
		{
			case TType( t, _):componentClassName = t.toString();
			var arr:Array<String> = componentClassName.split("#");
			componentClassName = arr[0] + arr[1];
			case _:
				
		}
		return macro {
			$self.remove_($v { componentClassName } );

        }
	}
    /**
     * Get a component from the entity.
     *
     * @param componentClass The class of the component requested.
     * @return The component, or null if none was found.
     */

    macro public function get<T>( self:ExprOf<Entity>  , componentClass:ExprOf<Class<T>>):Expr
    {
		var componentClassName:String;
		switch(Context.typeof( componentClass ))
		{
			case TType( t, _):componentClassName = t.toString();
			var arr:Array<String> = componentClassName.split("#");
			componentClassName = arr[0] + arr[1];
			case _:
				
		}
		
        return macro $self.components.get($v{componentClassName});
    }

    /**
     * Get all components from the entity.
     *
     * @return An array containing all the components that are on the entity.
     */

    public function getAll():Array<Dynamic>
    {
        var componentArray:Array<Dynamic> = new Array<Dynamic>();
        for (component in components)
            componentArray.push(component);
        return componentArray;
    }

    /**
     * Does the entity have a component of a particular type.
     *
     * @param componentClass The class of the component sought.
     * @return true if the entity has a component of the type, false if not.
     */

    macro public function has<T>( self:ExprOf<Entity> ,  componentClass:ExprOf<Class<Dynamic>>):Expr
    {
		var componentClassName:String;
		switch(Context.typeof( componentClass ))
		{
			case TType( t, _):componentClassName = t.toString();
			var arr:Array<String> = componentClassName.split("#");
			componentClassName = arr[0] + arr[1];
			case _:
				
		}
		
        return macro $self.components.exists($v{componentClassName});
    }
}

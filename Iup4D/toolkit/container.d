module toolkit.container;

import std.algorithm;
import std.conv;
import std.container.array;
import std.string;

import toolkit.event;


// Summary:
//     Supports a simple iteration over a generic collection.
//
// Type parameters:
//   T:
//     The type of objects to enumerate.This type parameter is covariant. That is,
//     you can use either the type you specified or any type that is more derived.
//     For more information about covariance and contravariance, see Covariance
//     and Contravariance in Generics.
public interface IEnumerator(T)
{
	// Summary:
	//     Gets the element in the collection at the current position of the enumerator.
	//
	// Returns:
	//     The element in the collection at the current position of the enumerator.
	@property T current();

	bool moveNext();
	void reset();
}



// Summary:
//     Exposes the enumerator, which supports a simple iteration over a collection
//     of a specified type.
//
// Type parameters:
//   T:
//     The type of objects to enumerate.This type parameter is covariant. That is,
//     you can use either the type you specified or any type that is more derived.
//     For more information about covariance and contravariance, see Covariance
//     and Contravariance in Generics.
public interface IEnumerable(T)
{
	// Summary:
	//     Returns an enumerator that iterates through the collection.
	//
	// Returns:
	//     A System.Collections.Generic.IEnumerator!(T) that can be used to iterate through
	//     the collection.
	@property IEnumerator!(T) enumerator();
}


/**
*/
public class ArrayEnumerator(T) : IEnumerator!(T)
{
	protected Array!T m_collection;
	private size_t index;

	this(Array!T collection)
	{
		m_collection = collection;
		index = -1;
	}

	@property T current()
	{
		return m_collection[index];
	}


	bool moveNext()
	{
		index++;
		if(index >= m_collection.length)
			return false;

		return true;

	}

	void reset()
	{
		index = -1;
	}
}


/**
*/
public class EnumerableCollection(T) : IEnumerable!(T)
{
	protected Array!T m_collection;

    this()
    {
    }
	
    this(Array!T collection)
	{
		m_collection = collection;
	}

    this(T[] items...)
	{
		m_collection.insertBack(items);
	}

    /* ************* Properties *************** */

    /**
    */
    @property size_t count() const
    {
        return m_collection.length;
    }

	@property public IEnumerator!(T) enumerator()
	{
		//throw new NotImplementedException();
		ArrayEnumerator!T arrayEnumerator = new ArrayEnumerator!T(m_collection);
		return arrayEnumerator;
	}

    /* ************* overload methods *************** */

    /**
    */
    size_t opDollar() const
    {
        return m_collection.length;
    }

    /**
    */
    T opIndex(size_t i)
    {
        return m_collection[i];
    }

    /**
    */
    void opIndexAssign(T value, size_t i)
    {
        m_collection[i] = value;
    }

    // TODO: opSlice

    //Range opSlice()
    //{
    //    return typeof(return)(this, 0, length);
    //}

}



/**
*/
class ItemCollection(T, bool isObservable=true) : EnumerableCollection!(T)
{

    this()
    {
        super();
    }

    this(Array!T collection)
	{
        super(collection);
	}

    this(T[] items...)
	{
        super(items);
	}


    /* ************* Events *************** */

    static if(isObservable)
    {
        EventHandler!(T[]) appended;
        EventHandler!(int, T[]) inserted;
        EventHandler!(int, int) removed;
        EventHandler!(int, T) updated;
        EventHandler!() cleared;
    }

    /* ************* Public methods *************** */

    /**
    */
	void append(T[] items...)
	{
        m_collection.insertBack(items);

        static if(isObservable)
        {
            appended(this, items); 
        }
	}

    /**
    */
    void clear()
    {
        static if(isObservable)
        {
            cleared(this);  // notify first
        }

        m_collection.clear();
    }

    /**
    Retrieves the index of the specified item in the collection.

    Returns: A zero-based index value that represents the position of the specified T in
    the ItemCollection, if found; otherwise, -1.
    */
    int indexOf(T item)
    {
        for(int i=0; i<m_collection.length; i++)
        {
            if(m_collection[i] == item) return i;
        }

        return -1;
    }

    /**
    */
    void insert(int index, T[] items...)
    {
        T current = m_collection[index];
        auto r = std.algorithm.find(m_collection[], current);
        m_collection.insertBefore(r, items);

        static if(isObservable)
        {
            inserted(this, index, items); 
        }

    }

    /**
    to be removed
    */
	void remove(T item)
	{
        int index = indexOf(item);
        if(index >=0)
            removeAt(index);
	}


    /// ditto
	void removeAt(size_t index)
	{
        removeRange(index, 1);
	}

    /// ditto
    void removeRange(size_t index, size_t count)
    {
        static if(isObservable)
        {
            removed(this, index,  count);  // notify first
        }

        auto items = m_collection[index .. (index+count)];
        m_collection.linearRemove(items);
    }

    /**
    */
    void update(size_t index, T value)
    {
        if(m_collection[index] != value)
        {
            static if(isObservable)
            {
                updated(this, index,  value);  // notify first
            }

            m_collection[index] = value;
        }
    }

    /// ditto
    override void opIndexAssign(T value, size_t index)
    {
        update(index, value);
    }

}


alias StringItemCollection = ItemCollection!string;


//
// Type parameters:
//   TKey:
//     The type of the keys in the dictionary.
//
//   TValue:
//     The type of the values in the dictionary.
class Dictionary(TKey, TValue) 
{
	private TValue[TKey] m_dict;
	private CaseSensitive cs;

	this(CaseSensitive cs = CaseSensitive.yes)
	{
		this.cs = cs;
	}


	public size_t count() @property
	{
		return m_dict.length;
	}


	public void add(TKey key, TValue value)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);
		m_dict[key] = value;
	}


	// Summary:
	//     Gets or sets the value associated with the specified key.
	//
	// Parameters:
	//   key:
	//     The key of the value to get or set.
	//
	// Returns:
	//     The value associated with the specified key. If the specified key is not
	//     found, a get operation throws a System.Collections.Generic.KeyNotFoundException,
	//     and a set operation creates a new element with the specified key.
	//
	// Exceptions:
	//   System.ArgumentNullException:
	//     key is null.
	//
	//   System.Collections.Generic.KeyNotFoundException:
	//     The property is retrieved and key does not exist in the collection.
	public TValue opIndex(TKey key)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);

		TValue *value_ptr = (key in m_dict);
		if(value_ptr !is null)
			return *value_ptr;

		throw new Exception(std.string.format("The key doesn't exist: %s", key));
	}


	public TValue opIndexAssign(TValue value, TKey key)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);

		m_dict[key] = value;
		return value;
	}

	//
	// Summary:
	//     Gets the value associated with the specified key.
	//
	// Parameters:
	//   key:
	//     The key of the value to get.
	//
	//   value:
	//     When this method returns, contains the value associated with the specified
	//     key, if the key is found; otherwise, the default value for the type of the
	//     value parameter. This parameter is passed uninitialized.
	//
	// Returns:
	//     true if the System.Collections.Generic.Dictionary<TKey,TValue> contains an
	//     element with the specified key; otherwise, false.
	//
	// Exceptions:
	//   System.ArgumentNullException:
	//     key is null.
	public bool tryGetValue(TKey key, out TValue value)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);

		TValue *value_ptr = (key in m_dict);
		if(value_ptr !is null)
		{
			value = *value_ptr;
			return true;
		}

		return false;
	}

	//
	// Summary:
	//     Removes the value with the specified key from the System.Collections.Generic.Dictionary<TKey,TValue>.
	//
	// Parameters:
	//   key:
	//     The key of the element to remove.
	//
	// Returns:
	//     true if the element is successfully found and removed; otherwise, false.
	//     This method returns false if key is not found in the System.Collections.Generic.Dictionary<TKey,TValue>.
	//
	// Exceptions:
	//   System.ArgumentNullException:
	//     key is null.
	public bool remove(TKey key)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);

		TValue *value_ptr = (key in m_dict);
		if(value_ptr !is null)
		{
			m_dict.remove(key);
			return true;
		}

		return false;
	}


	//
	// Summary:
	//     Removes all keys and values from the System.Collections.Generic.Dictionary<TKey,TValue>.
	public void clear()
	{
		foreach(TKey key; m_dict.keys)
		{
			m_dict.remove(key);
		}
	}

	//
	// Summary:
	//     Determines whether the System.Collections.Generic.Dictionary<TKey,TValue>
	//     contains the specified key.
	//
	// Parameters:
	//   key:
	//     The key to locate in the System.Collections.Generic.Dictionary<TKey,TValue>.
	//
	// Returns:
	//     true if the System.Collections.Generic.Dictionary<TKey,TValue> contains an
	//     element with the specified key; otherwise, false.
	//
	// Exceptions:
	//   System.ArgumentNullException:
	//     key is null.
	public bool containsKey(TKey key)
	{
		if( cs == CaseSensitive.no)
			key = std.string.toUpper(key);

		TValue *value_ptr = (key in m_dict);
		return value_ptr !is null;
	}


	//
	// Summary:
	//     Determines whether the System.Collections.Generic.Dictionary<TKey,TValue>
	//     contains a specific value.
	//
	// Parameters:
	//   value:
	//     The value to locate in the System.Collections.Generic.Dictionary<TKey,TValue>.
	//     The value can be null for reference types.
	//
	// Returns:
	//     true if the System.Collections.Generic.Dictionary<TKey,TValue> contains an
	//     element with the specified value; otherwise, false.
	public bool containsValue(TValue value)
	{
		foreach(TValue v; m_dict.values)
		{
			if(value == v)
				return true;
		}
		return false;
	}


	unittest
	{
		version(unittest)
		{
			import std.stdio;
		}

		alias Dictionary!(string, int) Dict;

		class TestClass
		{
			private Dict dict;

			this()
			{
				dict = new Dict();
			}

			ref Dict getDict()
			{
				return dict;
			}

			size_t checkDictLength()
			{
				//writefln("dict.length = %d", dict.count);
				return dict.count;
			}
		}


		TestClass c = new TestClass();

		auto dict = c.getDict();
		dict.add("a", 1);
		dict.add("b", 2);

		int len = dict.count;
		assert(len == c.checkDictLength());

		int v = dict["b"];
		assert(v == 2);

		try
		{
			v = dict["c"];
		}
		catch(Exception e)
		{
			//writefln(e.msg);
			assert(true, e.msg);
		}

		dict["c"] = 3;
		assert(dict["c"] == 3);

		assert(dict.containsKey("c"));
		assert(dict.containsValue(3));

		v = 4;
		dict.tryGetValue("d", v);
		assert(v == 0);

		dict.tryGetValue("c", v);
		assert(v == 3);

		dict.clear();
		assert(dict.count == 0);
	}
}

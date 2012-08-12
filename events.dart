

/**
 * Replace the DOM event in our custom handlers. It should be interchangeable
 * with the original one in all calls of this API.s
 */
class GenericEvent {
	/**
	 * A string describing the type of event.
	 */
	abstract String get type();
}


/**
 * Replaces the native event list with a custom one that allows adding, removing
 * and dispatching events.
 */
class EventListeners {
	List<Function> listeners;

	EventListeners()
	: listeners = new List<Function>();

	/**
	 * Adds a new [handler] to the list of listeners for this event.
	 */
	void add(Function handler) => listeners.add(handler);

	/**
	 * Removed a [handler] from the list of listeners for this event.
	 * If the event is not present, it won't fail.
	 */
	void remove(Function handler) {
		listeners = listeners.filter((x) => x != handler);
	}

	/**
	 * Trigger the [event] for all the listeners added to this list.
	 */
	void dispatch(GenericEvent event) => listeners.forEach((fn) => fn(event));
}


/**
 * Allows custom classes to implemente the "on" member (a list of EventListeners).
 * You have to implement the abstract method types() and then make a getter
 * for each one of them:
 *   EventListeners get example() => this['example'];
 */
class EventList {
	/**
	 * List of registered event listeners.
	 */
	Map<String, EventListeners> listeners;

	EventList()
	: listeners = new Map<String, EventListeners>()
	{
		types.forEach((t) {
			listeners[t] = new EventListeners();
		});
	}

	/**
	 * Return a list of strings with each of the events.
	 */
	abstract List<String> get types();

	/**
	 * Allow the [] operator to find events.
	 */
	EventListeners operator[](String type) {
		return listeners[type];
	}
}


/**
 * Saves together the handler and its target, for easier adding/removing.
 * It avoids the problem that Dart returns two different closures each time
 * we use the name of a function.
 */
class EventRegister {
	/**
	 * The EventListeners instances, or the native one.
	 */
	var listeners;

	/**
	 * The handler function.
	 */
	Function handler;

	/**
	 * True if the handler is active and registered.
	 */
	bool listening;

	EventRegister(this.listeners, this.handler)
	: listening = false;

	/**
	 * Register the handler to listen for events. You shouldn't use this directly,
	 * use events.listen() or EventsHandler.listen() instead.
	 */
	EventListenerList listen() {
		if(listening)
			throw new UnsupportedOperationException("Already listening this event");

		listeners.add(handler);
		listening = true;
	}

	/**
	 * Unregister the handler listening for events. You shouldn't use this directly,
	 * use events.unlisten() or EventsHandler.unlisten() instead.
	 */
	EventListenerList unlisten() {
		if(!listening)
			throw new UnsupportedOperationException("Already not listening the event");

		listeners.remove(handler);
		listening = false;
	}
}


/**
 * Saves some static members inside a class for easy use.s
 */
class events {
	/**
	 * Trigger some debug messages when rendering/disposing views to find leaks.
	 */
	static bool debugMode = false;

	/**
	 * The total number of events registered in the system right now.
	 */
	static num totalEvents = 0;

	/**
	 * Register the [handler] to listen for events coming from [listeners].
	 */
	static EventRegister listen(listeners, Function handler) {
		var reg = new EventRegister(listeners, handler);
		reg.listen();

		totalEvents++;

		return reg;
	}

	/**
	 * Removed the register [reg] from the list of listeners.
	 */
	static void unlisten(EventRegister reg) {
		reg.unlisten();

		totalEvents--;
	}
}


/**
 * Easier event handler. Each view has one of this, and you can create all the
 * instances you need of it. It manages a list of events registers.
 */
class EventHandler {
	List<EventRegister> registers;

	EventHandler()
	: registers = new List<EventRegister>();

	/**
	 * Listen to a new event.
	 */
	void listen(listeners, Function handler) {
		registers.add(events.listen(listeners, handler));
	}

	/**
	 * Remove all listeners associated with this handler instance.
	 */
	void clear() {
		for(var reg in registers) {
			events.unlisten(reg);
		}
		registers.clear();
	}
}

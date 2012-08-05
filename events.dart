

class EventListeners {
	List<Function> listeners;

	EventListeners()
	: listeners = new List<Function>();

	void add(Function handler) => listeners.add(handler);
	void dispatch(GenericEvent event) => listeners.forEach((fn) => fn(event));
}


class EventList {
	Map<String, EventListeners> listeners;

	EventList()
	: listeners = new Map<String, EventListeners>()
	{
		types.forEach((t) {
			listeners[t] = new EventListeners();
		});
	}

	abstract List<String> get types();

	EventListeners operator[](String type) {
		return listeners[type];
	}
}


class GenericEvent {
	abstract String get type();
}


class EventHandler {
	static num totalEvents = 0;

	List<EventRegister> listeners;

	EventHandler()
	: listeners = new List<EventRegister>();

	void listen(eventListeners, EventListener handler) {
		EventRegister reg = new EventRegister(eventListeners, handler);
		reg.add();

		listeners.add(reg);

		totalEvents++;
	}

	void clear() {
		for(var reg in listeners) {
			reg.remove();
			totalEvents--;
		}
		listeners.clear();
	}
}


class EventRegister {
	var eventListeners;
	EventListener handler;

	EventRegister(this.eventListeners, this.handler);

	EventListenerList add()    => eventListeners.add(handler);
	EventListenerList remove() => eventListeners.remove(handler);
}



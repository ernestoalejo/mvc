

class EventListeners {
	List<Function> listeners = [];
	void add(Function handler) => listeners.add(handler);
	void dispatch(GenericEvent event) => listeners.forEach((fn) => fn(event));
}


class EventList {
	Map<String, EventListeners> listeners;

	EventList() {
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




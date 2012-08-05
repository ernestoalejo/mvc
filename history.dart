

class HistoryTracker {
	static HistoryTracker _INSTANCE;

	factory HistoryTracker() {
		if(_INSTANCE == null)
			_INSTANCE = new HistoryTracker._internal();
		return _INSTANCE;
	}

	HistoryEvents on;
	String url;

	HistoryTracker._internal() {
		// Intercept link clicks and dispatch route events.
		// If it's meant to be a real link (or processed in any other way)
		// mark it with data-history="server".
		document.body.on.click.add((event) {
			Element elem = event.target;
			if(elem.tagName == "A" && elem.attributes['data-history'] != "server") {
				event.preventDefault();
				changeUrl(elem.attributes['href']);
			}
		});

		// Receive changes in the history
		window.on.popState.add((PopStateEvent event) {
			if(event.state != null) {
				if(event.state == url)
					return;

				url = event.state;
				on['change'].dispatch(new HistoryChangeEvent(url));
			}
		});

		// Dispatch the first history event with the current state
		url = window.location.pathname;
		on['change'].dispatch(new HistoryChangeEvent(url));
	}

	void changeUrl(String newUrl) {
		url = newUrl;
		window.history.pushState(url, "", url);
		on['change'].dispatch(new HistoryChangeEvent(url));
	}
}


class HistoryEvents extends EventList {
	get types() => ['change'];
	
	EventListeners get change() => this['change'];
}


class HistoryChangeEvent extends GenericEvent {
	String url;
	
	HistoryChangeEvent(this.url);

	get type() => "HistoryChangeEvent";
}



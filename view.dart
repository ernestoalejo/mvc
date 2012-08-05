

class View {
	bool _disposed, entered;
	Element elem, parent;
	var model, collection;

	List<View> children;

	EventHandler handler;

	View([this.parent, this.model, this.collection, this.elem])
	: entered = false,
	  _disposed = false,
	  children = new List<View>(),
	  handler = new EventHandler();

	void dispose() {
		if(!_disposed) {
			disposeInternal();
			exitDocument();

			for(var child in children) {
				child.dispose();
			}

			_disposed = true;
		}
	}

	void render(Element container) {
		if(elem == null)
			createDom();
			
		if(parent == null)
			parent = container;
		if(parent == null)
			throw new NotImplementedException("View should have a parent");

		for(var child in children) {
			child.render(elem);
		}

		enterDocument();
	}

	void createDom() {
		elem = new DivElement();
	}

	void enterDocument() {
		if(entered)
			return;
		if(elem == null)
			throw new NotImplementedException("Element should be assigned");

		for(var child in children) {
			child.enterDocument();
		}

		bindEvents();

		entered = true;

		if(parent != null && parent != elem)
			parent.nodes.add(elem);
	}

	void exitDocument() {
		if(elem != null)
			elem.remove();

		for(var child in children) {
			child.exitDocument();
		}

		handler.clear();

		entered = false;
	}

	void disposeInternal() {
	}

	Map<String, EventListener> get events() => null;

	void bindEvents() {
		if(events == null)
			return;

		events.forEach((k, v) {
			var parts = k.split(' ');
			if(parts.length > 2) {
				print('Invalid event: $k');
				throw new WrongArgumentCountException();
			}

			String type;
			List<Element> targets;
			if(parts.length == 1) {
				targets = <Element>[elem];
				type = parts[0];
			} else {
				targets = document.queryAll(parts[0]);
				type = parts[1];
			}

			if(targets.length == 0) {
				print("No elements match $k");
				throw new WrongArgumentCountException();
			}

			for(var target in targets) {
				handler.listen(target.on[type], v);
			}
		});
	}
}

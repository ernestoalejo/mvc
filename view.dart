

class View {
	bool _disposed, inDocument;
	Element elem, parent;
	var model, collection;

	List<View> children;

	EventHandler handler;

	View([this.parent, this.model, this.collection, this.elem])
	: inDocument = false,
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

		parent.nodes.add(elem);

		for(var child in children) {
			child.render(elem);
		}

		enterDocument();
	}

	void createDom() {
		elem = new DivElement();
	}

	void enterDocument() {
		if(inDocument)
			return;

		if(elem == null)
			throw new NotImplementedException("Element should be assigned");

		for(var child in children) {
			child.enterDocument();
		}

		bindEvents(events);

		inDocument = true;
	}

	void exitDocument() {
		if(!inDocument)
			return;

		if(elem != null)
			elem.remove();

		for(var child in children) {
			child.exitDocument();
		}

		handler.clear();

		inDocument = false;
	}

	void disposeInternal() {
	}

	Map<String, Function> get events() => null;

	void bindEvents(Map<String, Function> ev) {
		if(ev == null)
			return;

		ev.forEach((k, v) {
			var parts = k.split(' ');
			if(parts.length > 2) {
				print('Invalid event: $k');
				throw new WrongArgumentCountException();
			}

			bool isLoad = false;

			String type;
			List targets;
			if(parts.length == 1) {
				type = parts[0];
				targets = [elem];
			} else {
				type = parts[0];

				if(parts[1] == "model")
					targets = [model];
				else if(parts[1] == "collection")
					targets = [collection];
				else if(parts[1] == "document")
					targets = [document];
				else if(parts[1] == "window")
					targets = [window];
				else
					targets = elem.queryAll(parts[1]);

				isLoad = (parts[1] == "model" || parts[1] == "collection") &&
						type == 'load';
			}

			if(targets.length == 0) {
				print("No elements match $k");
				throw new WrongArgumentCountException();
			}

			for(var target in targets) {
				handler.listen(target.on[type], v);
			}

			if(isLoad) {
				if(targets[0].loaded)
					v(new ModelRpcEvent('load', targets[0]));
			}
		});
	}

	void addChildren(View view) {
		addChild(view);
	}

	void addChild(View view) {
		children.add(view);
		view.render(elem);
	}

	void removeChild(View view) {
		for(num i = 0; i < children.length; i++) {
			children[i].exitDocument();
			children[i].dispose();
			children.removeRange(i, 1);
		}
	}
}

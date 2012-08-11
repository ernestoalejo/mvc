

class View {
	bool _disposed, inDocument;
	Element elem, parent;

	List<View> children;

	EventHandler handler;

	View([this.parent, this.elem])
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

			if(elem != null)
				elem.remove();

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

	void disposeInternal() { }

	void addChildren(View view) {
		addChild(view);
	}

	void addChild(View view) {
		children.add(view);
		view.render(elem);
	}

	void removeChild(View view) {
		for(num i = 0; i < children.length; i++) {
			if(children[i] == view) {
				children[i].exitDocument();
				children[i].dispose();
				children.removeRange(i, 1);
			}
		}
	}
}



class Model {
	Map<String, Dynamic> attributes;
	String url;
	ModelEvents on;
	ModelCollection collection;

	bool loaded;

	String id;

	Model([Map<String, Dynamic> attrs])
	: attributes = new Map<String, Dynamic>(),
	  url = "",
	  loaded = false,
	  on = new ModelEvents()
	{
		setValues(attrs);
	}

	Dynamic operator[](String key) {
		return attributes[key];
	}

	void operator[]=(String key, Dynamic value) {
		var data = new Map<String, Dynamic>();
		data[key] = value;
		setValues(data);
	}

	void load([bool reload = true]) {
		if(loaded && !reload)
			return;

		loaded = false;
		rpc('load', 'GET', '$url/$id', null);
	}

	void delete() {
		rpc('delete', 'DELETE', '$url/$id', null);
	}

	void update() {
		rpc('update', 'PUT', '$url/$id', attributes);
	}

	void create() {
		rpc('create', 'POST', url, attributes);
	}

	void rpc(String type, String method, String u, Map<String, Dynamic> data) {
		if(u == "")
			throw new NotImplementedException("URL should be assigned");

		Future call = new Sync().rpc(method, u, data);
		call.handleException((exception) {
			var event = new ModelRpcEvent(type, this);
			if(collection != null)
				collection.onModel.error.dispatch(event);
			on.error.dispatch(event);

			return true;
		});
		call.then((resp) {
			if(type == 'load')
				loaded = true;

			setValues(resp);

			var event = new ModelRpcEvent(type, this);
			if(collection != null)
				collection.onModel[type].dispatch(event);
			on[type].dispatch(event);
		});
	}

	void setValues(Map<String, Dynamic> attrs) {
		if(attrs == null)
			return;

		List<String> keys = new List<String>();
		attrs.forEach((k, v) {
			if(attributes.containsKey(k)) {
				attributes[k] = v;
				keys.add(k);
			} else
				noSuchMethod('init:$k', [v]);
		});

		var event = new ModelChangeEvent(keys);
		if(collection != null)
			collection.onModel.change.dispatch(event);
		on.change.dispatch(event);
	}

	noSuchMethod(String name, List args) {
		if(name.startsWith('set:')) {
			String key = name.split(":")[1];
			if(attributes.containsKey(key)) {
				attributes[key] = args[0];

				var event = new ModelChangeEvent([key]);
				if(collection != null)
					collection.onModel.change.dispatch(event);
				on.change.dispatch(event);

				return;
			}
		} else if(name.startsWith('get:')) {
			String key = name.split(':')[1];
			if(attributes.containsKey(key))
				return attributes[key];
		} else if(name.startsWith('init:')) {
			String key = name.split(':')[1];
			return attributes[key] = args[0];
		}

		throw new NoSuchMethodException(this, name, args);
	}
}


class ModelEvents extends EventList {
	get types() => ['load', 'update', 'delete', 'error', 'change', 'create'];

	EventListeners get load()   => this['load'];
	EventListeners get update() => this['update'];
	EventListeners get delete() => this['delete'];
	EventListeners get error()  => this['error'];
	EventListeners get change() => this['change'];
	EventListeners get create() => this['create'];
}


class ModelRpcEvent extends GenericEvent {
	String action;
	Model instance;
	ModelRpcEvent(this.action, this.instance);

	get type() => 'ModelRpcEvent';
}


class ModelChangeEvent extends GenericEvent {
	List<String> keys;
	ModelChangeEvent(this.keys);

	get type() => 'ModelChangeEvent';
}



class ModelCollection<M extends Model> {
	ModelEvents onModel;
	CollectionEvents on;
	String url;
	List<M> models;

	bool loaded;

	ModelCollection()	
	: onModel = new ModelEvents(),
	  on = new CollectionEvents(),
	  url = "",
	  loaded = false,
	  models = new List<M>();

	abstract M builder();

	M operator[](int index) {
		return models[index];
	}

	void load() {
		loaded = false;

		if(url == "")
			throw new NotImplementedException("URL should be assigned");

		Future call = new Sync().rpc('GET', url, null);
		call.handleException((exception) {
			on.error.dispatch(null);
			return true;
		});
		call.then((resp) {
			if(hasItems)
				models = [];

			loaded = true;

			for(var item in resp) {
				M model = builder();
				model.setValues(item);
				model.collection = this;
				models.add(model);
			}
			on.load.dispatch(null);
			on.change.dispatch(null);
		});
	}

	void add(M item) {
		models.add(item);
		item.collection = this;
		on.change.dispatch(null);
	}

	void remove(M item) {
		models = models.filter((x) => x == item);
	}

	bool get hasItems() => models.length != 0;
	num get length() => models.length;
	bool get empty() => models.length == 0;
}


class CollectionEvents extends EventList {
	get types() => ['load', 'error', 'change'];

	EventListeners get load()   => this['load'];
	EventListeners get error()  => this['error'];
	EventListeners get change() => this['change'];
}


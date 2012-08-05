
typedef Future SyncFunc(String method, String url, Map<String, Dynamic> data);

List<String> allowedMethods = const['GET', 'POST', 'PUT', 'DELETE'];

class Sync {
	static Sync _INSTANCE;

	factory Sync() {
		if(_INSTANCE == null)
			_INSTANCE = new Sync._internal();
		return _INSTANCE;
	}

	SyncFunc rpc = defaultRpc;

	Sync._internal();
}

Future defaultRpc(String method, String url, Map<String, Dynamic> data) {
	var req = new XMLHttpRequest();
	var completer = new Completer();

	// Check for a valid HTTP method
	method = method.toUpperCase();
	if(allowedMethods.indexOf(method) == -1)
		throw new NotImplementedException();

	// Load/Error handlers
	req.on.load.add((e) {
		if(req.status == 200)
			completer.complete(JSON.parse(req.responseText));
		else
			completer.completeException(new SyncException(req.status, req.responseText));
	});
	req.on.error.add((e) {
		completer.completeException(new SyncException(req.status, req.responseText));
	});

	// Send the request
	req.open(method, url, /* async */ true);

	if(method == 'POST' || method == 'PUT') {
		req.setRequestHeader('Content-Type', 'application/json');
		req.send(JSON.stringify(data));
	} else
		req.send();

	return completer.future;
}


class SyncException implements Exception {
	int status;
	String responseText;
	SyncException(this.status, this.responseText);
}


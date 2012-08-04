

class View {

	bool _disposed;

	abstract void disposeInternal();

	void dispose() {
		if(!_disposed)
			disposeInternal();
		_disposed = true;
	}
	
}

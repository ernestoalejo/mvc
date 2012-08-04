

typedef View Handler(List<String> params);


class Router {
  Element container;
  View view;

  List<RegExp> regexps = <RegExp>[];
  List<Handler> funcs = <Handler>[];

  Router(this.container) {
    container.innerHTML = '';
    new HistoryTracker().on['change'].add(onHistory);
    initRoutes();
  }

  abstract Map<String, Handler> get routes();

  void onHistory(HistoryChangeEvent event) {
    if(view == null) {
      view.dispose();
      view = null;
    }

    for(var i = 0; i < regexps.length; i++) {
      Match params = regexps[i].firstMatch(event.url);
      if(params == null)
        continue;

      List<String> groups;
      for(var j = 0; j < params.groupCount(); j++)
        groups.add(params[j]);

      view = funcs[i](groups);
      if(view == null)
        throw new NotImplementedException("Handler didn't returned a view");
    }

    throw new NotImplementedException("Page not found");
  }

  RegExp initRoutes() {
    for(var route in routes.getKeys()) {
      List<String> parts = route.split('/').map((chunk) {
        return chunk.startsWith(':') ? '([^/]+)' : chunk;
      });

      return new RegExp(Strings.join(parts, '/'));
    }
  }
}

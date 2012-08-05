

typedef View Handler(List<String> params);


class Router {
  Element container;
  View view;

  List<RegExp> regexps;
  List<Handler> funcs;

  Router(this.container)
  : regexps = new List<RegExp>(),
    funcs = new List<Handler>()
  {
    container.innerHTML = '';
    new HistoryTracker().on['change'].add(onHistory);
    initRoutes();
  }

  abstract Map<String, Handler> get routes();

  void onHistory(HistoryChangeEvent event) {
    if(view != null) {
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
        
      view.render(container);
      return;
    }

    throw new NotImplementedException("Page not found");
  }

  void initRoutes() {
    for(String route in routes.getKeys()) {
      List<String> parts = route.split('/').map((chunk) {
        return chunk.startsWith(':') ? '([^/]+)' : chunk;
      });

      regexps.add(new RegExp(Strings.join(parts, '/'))) ;
      funcs.add(routes[route]);
    }
  }
}

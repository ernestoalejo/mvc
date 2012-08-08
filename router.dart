

typedef View Handler(List<String> params);


class Router {
  static String NOT_FOUND_HANDLER = "[error]";

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
    // Dispose the old view
    if(view != null) {
      view.dispose();
      view = null;
    }

    var notFoundHandler = "^$NOT_FOUND_HANDLER\$";

    for(var i = 0; i < regexps.length; i++) {
      List<String> groups;
      if(regexps[i].pattern != notFoundHandler) {
        // Try to match the URL against the pattern
        Match params = regexps[i].firstMatch(event.url);
        if(params == null)
          continue;

        // Extract the variables from the URL
        for(var j = 0; j < params.groupCount(); j++)
          groups.add(params[j]);
      }

      found(event.url);

      // Call the handler to create the view
      view = funcs[i](groups);
      if(view == null)
        throw new NotImplementedException("Handler didn't returned a view");
        
      // Render the view
      view.render(container);

      return;
    }

    notFound(event.url);
  }

  void initRoutes() {
    // Convert each URL to a RegExp replacing the variables
    for(String route in routes.getKeys()) {
      List<String> parts = route.split('/').map((chunk) {
        return chunk.startsWith(':') ? '([^/]+)' : chunk;
      });

      regexps.add(new RegExp("^${Strings.join(parts, '/')}\$")) ;
      funcs.add(routes[route]);
    }
  }

  void found(String url) { }

  void notFound(String url) {
    throw new NotImplementedException("Page not found: $url");
  }
}

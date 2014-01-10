(function() {

  (function($) {
    var onInsert;
    onInsert = function(options) {
      var selector, style,
        _this = this;
      selector = options.selector;
      style = "@keyframes _nodeInserted {\n	from: { outline: 0px solid transparent } to { outline: 1px solid transparent }\n}\n\n" + selector + " {\n	animation-duration: 0.001s;\n	animation-name: _nodeInserted;\n}";
      $('head').append(style);
      return $(document).on('animationstart', function() {
        return console.log(arguments);
      });
    };
    return $.event.special.everyInsert = {
      add: function(handleObj) {
        var preHandler, selector, _this;
        preHandler = function(ctx) {};
        _this = this;
        selector = $(_this).data("selector");
        $(this).each(function() {
          preHandler(this);
          return handleObj.handler.call(this);
        });
        window.setTimeout((function() {
          return $(_this).each(function() {
            preHandler(_this);
            return handleObj.handler.call(_this);
          });
        }), 19);
        if (selector) {
          return onInsert({
            selector: selector,
            el: $(this)
          });
        }
      }
    };
  })(jQuery);

}).call(this);

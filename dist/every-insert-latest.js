(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var animationCount, animationEvents, documentTagged, isTagged, listeners, onInsert, processedGUIDs, tag;
    listeners = [];
    animationCount = 0;
    animationEvents = "animationstart mozanimationstart webkitAnimationStart oAnimationStart msanimationstart";
    processedGUIDs = [];
    documentTagged = false;
    tag = function(el) {
      return $(el).prop('everyInsertTagged', true);
    };
    isTagged = function(el) {
      var _isTagged;
      if ($(el).prop('everyInsertTagged') != null) {
        _isTagged = true;
      } else {
        _isTagged = false;
      }
      return _isTagged;
    };
    onInsert = function(options, callback) {
      var animationName, cssPrefix, handleObj, index, namespacedAnimationEvents, ns, onAnimation, prefix, selector, styleTag, stylecontent, success,
        _this = this;
      selector = options.selector;
      success = options.success || Function.prototype;
      handleObj = options.handleObj;
      index = animationCount + 1;
      animationCount++;
      animationName = "_nodeInserted_" + index;
      prefix = (function() {
        var dom, pre, styles;
        styles = window.getComputedStyle(document.documentElement, "");
        pre = (Array.prototype.slice.call(styles).join("").match(/-(moz|webkit|ms)-/) || (styles.OLink === "" && ["", "o"]))[1];
        dom = "WebKit|Moz|MS|O".match(new RegExp("(" + pre + ")", "i"))[1];
        return {
          dom: dom,
          lowercase: pre,
          css: "-" + pre + "-",
          js: pre[0].toUpperCase() + pre.substr(1)
        };
      })();
      cssPrefix = prefix['css'];
      handleObj.data.styleTag = styleTag = $('<style type="text/css" />');
      stylecontent = "@" + cssPrefix + "keyframes " + animationName + " {\n	from: { outline: 0px solid transparent } to { outline: 1px solid transparent }\n}\n\n" + selector + " {\n	" + cssPrefix + "animation-duration: 0.001s;\n	" + cssPrefix + "animation-name: " + animationName + ";\n}";
      styleTag.html(stylecontent);
      $('head').append(styleTag);
      onAnimation = function(e) {
        var eventAnimationName, target;
        target = e.target;
        if (isTagged(target)) {
          return;
        }
        tag(target);
        eventAnimationName = e.originalEvent.animationName;
        if (!eventAnimationName) {
          eventAnimationName = e.originalEvent["" + prefix.dom + "AnimationName"];
        }
        if (eventAnimationName === animationName) {
          return success(e);
        }
      };
      handleObj.data.ns = ns = "." + handleObj.guid;
      namespacedAnimationEvents = animationEvents.replace(/[ ]/g, "" + ns + " ").trim() + ns;
      handleObj.data.namespacedAnimationEvents = namespacedAnimationEvents;
      return $(document).on(namespacedAnimationEvents, selector, onAnimation);
    };
    return $.event.special.everyInsert = {
      add: function(handleObj) {
        var callback, selector, _ref, _ref1,
          _this = this;
        if (_ref = handleObj.guid, __indexOf.call(processedGUIDs, _ref) >= 0) {
          return;
        }
        processedGUIDs.push(handleObj.guid);
        selector = handleObj.selector;
        handleObj.data = handleObj.data || {};
        callback = function(e) {
          var ctx;
          if (!e) {
            e === null;
          }
          if ((e != null ? e.currentTarget : void 0) != null) {
            ctx = $(e.currentTarget);
          } else if (e instanceof $) {
            ctx = e;
          } else {
            ctx = null;
          }
          return handleObj.handler.call(ctx, e);
        };
        if (!((handleObj != null ? (_ref1 = handleObj.data) != null ? _ref1.existing : void 0 : void 0) != null) || handleObj.data.existing === true) {
          $(this).find(selector).each(function() {
            return callback($(this));
          });
        }
        if (!documentTagged) {
          $(document).ready(function() {
            documentTagged = true;
            return $('body *').each(function() {
              return tag(this);
            });
          });
        }
        if (selector) {
          return onInsert({
            el: $(this),
            selector: selector,
            handleObj: handleObj,
            success: callback
          });
        }
      },
      remove: function(handleObj) {
        var data;
        data = handleObj['data'];
        $('head style').filter(function() {
          var styleTag;
          styleTag = handleObj['data']['styleTag'][0];
          if (this === styleTag) {
            return true;
          } else {
            return false;
          }
        }).remove();
        return $(document).off(data.namespacedAnimationEvents);
      }
    };
  })(jQuery);

}).call(this);

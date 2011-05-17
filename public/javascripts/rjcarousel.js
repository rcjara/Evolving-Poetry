(function rjcarousel($) {
  $.fn.initRJCarousel = function() {
    return this.each( function(idx, elem) {
      var _divId = $(elem).attr('id'),
          _index = 0,
          _fadeLength = 600,
          $elems = $("#" + _divId + " li"),
          $next = $('#' + _divId + '-next'),
          $prev = $('#' + _divId + '-prev'),
          divId       = function() { return _divId; },
          numElements = function() { return $elems.size(); };

      var setFadeLength = function(newSpeed) {
        _fadeLength = newSpeed;
      };

      var next = function() {
        $elems.eq(_index).fadeOut(_fadeLength, incIndex);
      };

      var prev = function() {
        $elems.eq(_index).fadeOut(_fadeLength, decIndex);
      };


      var incIndex = function() {
        _index += 1;
        _index %= numElements();
        showCurElement();
      };

      var decIndex = function() {
        _index -= 1;
        if(_index < 0) { _index += numElements(); }
        showCurElement();
      };

      var showCurElement = function() {
        $elems.eq(_index).fadeIn(_fadeLength);
      };

      $elems.css('display', 'none');
      $.each([$next, $prev], function(idx, $elem){ $elem.unbind();});
      $next.bind('click', function(e) {e.preventDefault(); next(); });
      $prev.bind('click', function(e) {e.preventDefault(); prev(); });

      $('#' + _divId).data('rjcarousel', {
        divId:         divId,
        setFadeLength: setFadeLength,
        numElements:   numElements,
        next:          next,
        prev:          prev
      });
    });
  };

  $.fn.setFadeLength = function(length) {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').setFadeLength(length);
    });
  };

  $.fn.next = function(length) {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').next();
    });
  };

  $.fn.prev = function(length) {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').prev();
    });
  };
})(jQuery);


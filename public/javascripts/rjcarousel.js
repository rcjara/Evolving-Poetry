(function rjcarousel($) {
  $.fn.initRJCarousel = function(options) {
    return this.each( function(idx, elem) {
      var _divId = $(elem).attr('id'),
          _index = -1,
          _fadeLength = 600,
          _hasCounter = false,
          $counter, $counterLis,
          $elems   = $('#' + _divId + ' li'),
          $next    = $('#' + _divId + '-next'),
          $prev    = $('#' + _divId + '-prev'),
          hasCounter  = function() { return _hasCounter; },
          divId       = function() { return _divId; },
          numElements = function() { return $elems.size(); };

      options = options || {};

      if(options['counter']) {
        (function() {
          _hasCounter = true;
          $counter = $('#' + _divId + '-counter');

          var $ul = $('<ul/>');
          $counter.append($ul);
          for(var i = 0; i < numElements(); i++) {
            $ul.append( $('<li/>') );
          }
          $counterLis = $ul.find('li');
        })();
      }

      var removeCounterMarks = function() {
        if(_hasCounter) {
          $counterLis.removeClass('carousel-selected carousel-unselected').
            addClass('carousel-unselected');
        }
      }

      var setFadeLength = function(newSpeed) {
        _fadeLength = newSpeed;
      };

      var next = function() {
        removeCounterMarks();
        $elems.eq(_index).fadeOut(_fadeLength, incIndex);
      };

      var prev = function() {
        removeCounterMarks();
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
        if(_hasCounter) {
          $counterLis.eq(_index).removeClass('carousel-unselected').
            addClass('carousel-selected');
        }
      };

      $elems.css('display', 'none');
      $.each([$next, $prev], function(idx, $elem){ $elem.unbind();});
      $next.bind('click', function(e) {e.preventDefault(); next(); });
      $prev.bind('click', function(e) {e.preventDefault(); prev(); });

      $('#' + _divId).data('rjcarousel', {
        divId:         divId,
        setFadeLength: setFadeLength,
        numElements:   numElements,
        hasCounter:    hasCounter,
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


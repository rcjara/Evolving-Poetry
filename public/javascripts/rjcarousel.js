(function rjcarousel($) {
  $.fn.initRJCarousel = function(options) {
    return this.each( function(idx, elem) {
      var _divId = $(elem).attr('id'),
          _index = -1,
          _fadeLength = 600,
          _hasCounter = false,
          _locked     = false,
          $counter, $counterLis,
          $elems   = $('#' + _divId + ' li'),
          $next    = $('#' + _divId + '-next'),
          $prev    = $('#' + _divId + '-prev'),
          hasCounter  = function() { return _hasCounter; },
          divId       = function() { return _divId; },
          numElements = function() { return $elems.size(); };

      var setupCounter = function() {
        _hasCounter = true;
        $counter = $('#' + _divId + '-counter');

        var $ul = $('<ul/>');
        $counter.append($ul);
        for(var i = 0; i < numElements(); i++) {
          var $newLi = $('<li/>');
          $ul.append($newLi);
          $newLi.data('index', i);
          $newLi.bind('click', $jump );
        }
        $counterLis = $ul.find('li');

        if(options['center']) {
          var totalWidth = $counterLis.outerWidth(true) * numElements() -
            parseInt( $counterLis.eq(0).css('margin-left') ) -
            parseInt( $counterLis.eq(-1).css('margin-right') );
          var spareWidth = $counter.innerWidth() - totalWidth;
          $ul.css('margin-left', spareWidth / 2);
          $counterLis.eq(0).css('margin-left', 0);
          console.log('$counter.outerWidth(): ' + $counter.outerWidth() );
        }
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
        $elems.eq(_index).fadeOut(_fadeLength, setIndex(_index + 1) );
      };

      var prev = function() {
        removeCounterMarks();
        $elems.eq(_index).fadeOut(_fadeLength, setIndex(_index - 1) );
      };

      var $jump = function(e) {
        var i = $(e.target).data('index');
        e.preventDefault();
        jump(i);
      };

      var jump = function(i) {
        removeCounterMarks();
        $elems.eq(_index).fadeOut(_fadeLength, setIndex(i) );
      };

      var setIndex = function(i) {
        _index = i;
        if(_index < 0) { _index += numElements(); }
        _index %= numElements();
        showCurElement();
      }

      var showCurElement = function() {
        $elems.hide();
        $elems.eq(_index).fadeIn(_fadeLength);
        if(_hasCounter) {
          removeCounterMarks();
          $counterLis.eq(_index).removeClass('carousel-unselected').
            addClass('carousel-selected');
        }
        _locked = false;
      };

      //setup
      options = options || {};

      if(options['counter']) {
        setupCounter();
      }

      $elems.css('display', 'none');
      $.each([$next, $prev], function(idx, $elem){ $elem.unbind();});
      $next.bind('click', function(e) {e.preventDefault(); next(); });
      $prev.bind('click', function(e) {e.preventDefault(); prev(); });

      $('#' + _divId).data('rjcarousel', {
        divId:         divId,
        setFadeLength: setFadeLength,
        numElements:   numElements,
        hasCounter:    hasCounter,
        jump:          jump,
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

  $.fn.next = function() {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').next();
    });
  };

  $.fn.prev = function() {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').prev();
    });
  };

  $.fn.jump = function(i) {
    return this.each( function(idx, elem) {
      $(elem).data('rjcarousel').jump(i);
    });
  };

})(jQuery);


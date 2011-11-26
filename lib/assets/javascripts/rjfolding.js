(function rjfolding($) {
  $.fn.initRJFolding = function(options) {
    return this.each( function(idx, elem) {
      var _divId       = $(elem).attr('id'),
          $foldRegion = $('#' + _divId),
          $folder      = $('#' + _divId + '-folder'),
          $unfolder    = $('#' + _divId + '-unfolder'),
          _folded;

      var init = function() {
        if(options['folded']) {
          _folded = true;
        } else {
          _folded = false;
        }

        if(_folded) {
          fold();
        } else {
          unfold();
        }

        $folder.bind('click', fold);
        $unfolder.bind('click', unfold);
      };

      var fold = function(e) {
        if(e) {
          e.preventDefault();
        }
        _folded = true;
        $folder.hide();
        $unfolder.show();
        $foldRegion.slideUp();
      };

      var unfold = function(e) {
        if(e) {
          e.preventDefault();
        }
        _folded = false;
        $folder.show();
        $unfolder.hide();
        $foldRegion.slideDown();
      };

      init();

      $foldRegion.data('rjfolding', {
        fold:   fold,
        unfold: unfold
      });
    });
  }
})(jQuery);

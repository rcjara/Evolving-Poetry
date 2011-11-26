/*
 * Takes an object of options.
 *   addlUnfoldFn
 * Hooks to allow for additional functions to be run while folding/unfolding
 *   Options: addlUnfoldFn, addlFoldFn
 *
 * Has a hook to run a function before unfolding.  It must accept a fn as an
 * argument which it must run as its last action.
 *   Option: preUnfoldFn
 *
 */

(function rjfolding($) {
  $.fn.initRJFolding = function(options) {
    return this.each( function(idx, elem) {
      var _divId          = $(elem).attr('id'),
          $foldRegion     =  $('#' + _divId),
          $folder         = $('#' + _divId + '-folder'),
          $unfolder       = $('#' + _divId + '-unfolder'),
          _addlFoldFn   = function() { return; },
          _addlUnfoldFn = function() { return; },
          _preUnfoldFn  = function() { return; },
          _hasPreUnfoldFn = false;
          _folded         = false;

      var init = function() {
        $folder.bind('click', fold);
        $unfolder.bind('click', unfold);

        if(options['folded']) {
          _folded = true;
        } else {
          _folded = false;
        }

        if(_folded) {
          $foldRegion.hide();
          $folder.hide();
        } else {
          $unfolder.hide();
        }

        if(options['addlFoldFn']) {
          _addlFoldFn = options['addlFoldFn'];
        }

        if(options['addlUnfoldFn']) {
          _addlFoldFn = options['addlUnfoldFn'];
        }

        if(options['preUnfoldFn']) {
          _preUnfoldFn  = options['preUnfoldFn'];
          _hasPreUnfoldFn = true;
          $unfolder.unbind('click');
          $unfolder.bind('click', preUnfold);
        }

      };

      var fold = function(e) {
        if(e) {
          e.preventDefault();
        }
        _folded = true;
        $folder.hide();
        $unfolder.show();
        $foldRegion.slideUp();
        _addlFoldFn();
      };

      var unfold = function(e) {
        if(e) {
          e.preventDefault();
        }
        _folded = false;
        $folder.show();
        $unfolder.hide();
        $foldRegion.slideDown();
        _addlUnfoldFn();
      };

      var preUnfold = function(e) {
        if(e) {
          e.preventDefault();
        }
        _preUnfoldFn( unfold );
      }

      init();

      $foldRegion.data('rjfolding', {
        fold:   fold,
        unfold: unfold
      });
    });
  }
})(jQuery);

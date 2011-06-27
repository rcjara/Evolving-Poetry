/* This is function was written quicky.
 * it assumes the class 'voting-container'
 *
 */
(function enableVoting($) {
  $.fn.enableVoting = function() {

    var enterColor  = '#DDF',
        exitColor   = '#EEE',
        targetClass = 'voting-container';

    var findElem = function(e) {
      var $elem = $(e.target);
      while( !$elem.hasClass(targetClass) ) {
        $elem = $elem.parent();
      }
      return $elem;
    }

    var submit = function(e) {
      findElem(e).find('form').submit();
    };

    var highlight = function(e) {
      findElem(e).animate({backgroundColor: enterColor});
    }

    var dehighlight = function(e) {
      findElem(e).animate({backgroundColor: exitColor});
    }

    return this.each( function(idx, voter) {
      voter.bind('click', submit);
      voter.children.bind('click', submit);

      voter.bind('mouseenter', highlight);
      voter.bind('mouseleave', dehighlight);
    });
  };
})();

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript-include-tag :defaults
//
var nonsenseEngine = {};

nonsenseEngine.inheritenceView = ( function() {

  var enable = function() {
    $(".new-text").css("background-color", "#9f9");
    $(".altered-text").css("background-color", "#f95");
    $(".from-first-parent").css("background-color", "#dda");
    $(".from-second-parent").css("background-color", "#aad");
    $(".deleted-text").css("display", "inline");
    $(".deleted-text").css("background-color", "#777");
    $(".deleted-text").css("text-color", "#ccc");

    $('#inheritence-enabler').addClass("disabled-link")
    $('#inheritence-enabler').bind('click', function(e) {
      e.preventDefault();
    });

    $('#inheritence-disabler').removeClass("disabled-link")
    $('#inheritence-disabler').bind('click', function(e) {
      e.preventDefault();
      disable();
    });
  };

  var disable = function() {
    $(".new-text, .from-first-parent, .from-second-parent, .altered-text").css("background-color", "transparent");
    $(".deleted-text").css("display", "none");

    $('#inheritence-disabler').addClass("disabled-link")
    $('#inheritence-disabler').bind('click', function(e) {
      e.preventDefault();
    });

    $('#inheritence-enabler').removeClass("disabled-link")
    $('#inheritence-enabler').bind('click', function(e) {
      e.preventDefault();
      enable();
    });
  }

  return {
    enable:  enable,
    disable: disable
  };
})();

nonsenseEngine.fullSize = ( function() {
  var $backdrop,
      $container;

  $(document).ready( function() {
    $container = $('<div/>');
    $container.prependTo(document.body);
    $container.addClass('full-sized-poem');

    $backdrop = $('<div/>');
    $backdrop.prependTo(document.body);
    $backdrop.addClass('backdrop');
    $backdrop.bind('click', close);
    $backdrop.css({opacity: 0.85});
  });

  var open = function(e) {
    e.preventDefault();

    $container.html( $(e.currentTarget).html() );
    $container.css('left',
      ($(window).width() - parseInt($container.css('width'))) / 2);
    $container.slideDown();
    $backdrop.fadeIn();
  };

  var close = function (e) {
    e.preventDefault();

    $container.slideUp();
    $backdrop.fadeOut();
  };

  return {
    open:  open,
    close: close,
    container:    function() { return $container; },
    backdrop:     function() { return $backdrop; } ,
  };
})();


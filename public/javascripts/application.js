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
    $(".new-text, .from-first-parent, .from-second-parent, .altered-text")
      .css("background-color", "transparent");
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
      $container,
      $close_btn,
      _setup,
      CLOSE_BTN_OFFSET = 18;

  var setup = function() {
    $container = $('<div/>');
    $container.prependTo(document.body);
    $container.addClass('full-sized-poem');

    $backdrop = $('<div/>');
    $backdrop.prependTo(document.body);
    $backdrop.addClass('backdrop');
    $backdrop.bind('click', close);
    $backdrop.css({opacity: 0.85});

    $close_btn = $('<img />');
    $close_btn.attr('src', '../images/close_button.png')
    $close_btn.addClass('close-btn');
    $close_btn.prependTo(document.body);
    $close_btn.bind('click', close);

    $container.bind('mouseover', show_btn);
    $backdrop .bind('mouseover', hide_btn);

    _setup = true;
  };

  var open = function(e) {
    e.preventDefault();

    if(!_setup) { setup(); }

    $container.html( $(e.currentTarget).html() );

    var container_left = ($(window).width() - parseInt($container.css('width'))) / 2;
    $container.css('left', container_left);
    $close_btn.css('left', container_left +
      parseInt($container.css('width')) + CLOSE_BTN_OFFSET);
    $close_btn.css('top',
      parseInt($container.css('top')) - CLOSE_BTN_OFFSET);
    $container.slideDown();
    $backdrop.fadeIn();
  };

  var close = function (e) {
    e.preventDefault();

    $container.slideUp();
    $close_btn.fadeOut();
    $backdrop.fadeOut();
  };

  var show_btn = function(e) {
    $close_btn.show();
  }

  var hide_btn = function(e) {
    $close_btn.hide();
  }


  return {
    setup:        setup,
    open:         open,
    close:        close,
    show_btn:     show_btn,
    hide_btn:     hide_btn,
    container:    function() { return $container; },
    backdrop:     function() { return $backdrop; } ,
    close_btn:    function() { return $close_btn; }
  };
})();

// This function assumes the class 'voting-container'
nonsenseEngine.enableVoting = function() {
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

  $voters = $('.' + targetClass);
  $voters.bind('click', submit);
  $voters.children().bind('click', submit);

  $voters.bind('mouseenter', highlight);
  $voters.bind('mouseleave', dehighlight);
};


nonsenseEngine.paragraphZoom = function() {
  var $ps = $('.second-row p');

  var findElem = function(e) {
    $elem = $(e.target);
    while(!$elem.is("p") ) {
      $elem = $elem.parent();
    }

    return $elem;
  };

  $ps.bind('mousemove', function(e) {
    var $elem   = findElem(e),
        offsetY = $elem.offset().top,
        height  = $elem.height(),
        relY    = e.pageY - offsetY,
        offMid  = Math.abs(relY - 0.5 * height) / 2.0;
    console.log("offsetY: " + offsetY + " height: " + height + " relY: " + relY + " offMid " + offMid);
    $elem.css('font-size', (1 - offMid) * 13 + 'px');
    $elem.css('line-height', (1 - offMid) * 16 + 'px');
  });

  $ps.bind('mouseleave', function(e) {
    $elem = findElem(e);
    $elem.css('font-size', '13px');
    $elem.css('line-height', '16px');
  });
};


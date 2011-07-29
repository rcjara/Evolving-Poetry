nonsenseEngine.markov = ( function() {
  var rand = function(i) {
    return Math.floor(Math.random() * i);
  };

  var word = function(_attr) {
    var attr = _attr;

    var getChild = function(excluding) {
      var target = rand(attr.children_count),
          i = 0;

      for(var key in attr.children) {
        i += attr.children[key]
        if(i >= target) {
          return key;
        }
      };
    };

    return {
      attr:     function() { return attr; },
      getChild: getChild
    };
  };

  var language = function() {
    var additionalCallback, words;

    var genWordArray = function() {
      var wordArray = [],
          curIdent = "__begin__",
          curWord = words[curIdent];

      while(true) {
        if(curWord.attr().sentence_end) {
          return wordArray;
        }
        curIdent = curWord.getChild();
        curWord = words[curIdent];
        wordArray.push(curWord);
      }
    };

    var initialize = function(data) {
      words = {};
      for(var key in data.words) {
        words[key] = nonsenseEngine.markov.word( data.words[key] );
      }
      if(additionalCallback) {
        additionalCallback(__interface__);
      }
    };

    var load = function(lang_id, callBack) {
      additionalCallback = callBack;
      $.ajax({
        url:      'languages/' + lang_id + '.json',
        dataType: 'json',
        success:  function(data) { initialize(data) }
      });
    };

    var __interface__ = {
      words:        function() { return words; },
      load:         load,
      genWordArray: genWordArray,
      initialize:   initialize
    };

    return __interface__;
  };

  var display = (function() {
    var $elem,
        curIndex = 0,
        displayWords = [];

    $(document).ready(function() {
      $elem = $('.main-left-column');
    });

    var wordArray = function(wArray, sentBegin) {
      $.each(wArray, function(i, mWord) {
        var attr = mWord.attr(),
            wText = attr.identifier;

        if(attr.proper) {
          wText = capitalize(wText);
        }
        if(rand(attr.count) < attr.shout_count) {
          wText = wText.toUpperCase();
        }

        if(!attr.punctuation) {
          wText = " " + wText;
        }
        var $word = $('<span>' + wText + '</span>');
        $word.css('display', 'none');
        $elem.append($word);
        displayWords.push($word);
      });

      appearAll();
    };

    var appearAll = function() {
      var delay = 0;

      for(; curIndex < displayWords.length; curIndex++) {
        displayWords[curIndex].delay(delay).fadeIn(1000);
        delay += 200;
      }
    };

    var capitalize = function(text) {
      return text.charAt(0).toUpperCase() + text.slice(1)
    };

    var language = function(language) {
      elementsFor(language.words(), 0);
    };

    var elementsFor = function(obj, indent) {
      if(typeof obj == "object") {
        for(var key in obj) {
          appendToElem(key, indent);
          if(key == "attr" && typeof(obj.attr) == "function") {
            elementsFor(obj.attr(), indent + 1);
          } else {
            elementsFor(obj[key], indent + 1);
          }
        }
      } else {
        appendToElem(obj, indent);
      }
    };

    var appendToElem = function(obj, indent) {
      var tab = "";
      for(var i = 0; i < indent; i++) {
        tab = tab + "&nbsp;&nbsp;&nbsp;&nbsp;"
      }

      $elem.append($('<p>' + tab + obj + '</p>'));
    };

    return {
      wordArray: wordArray,
      language:  language
    };
  })();

  return {
    language: language,
    word:     word,
    display:  display
  };
})();


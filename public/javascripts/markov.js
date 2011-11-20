nonsenseEngine.markov = ( function() {
  var rand = function(i) {
    return Math.floor(Math.random() * i);
  };

  var word = function(_attr) {
    var attr = _attr;

    var getChild = function(excluding) {
      var target,
          outOf = 0,
          tempChildren = {},
          i = 0;

      for(var key in attr.children) {
        if(key !== excluding && key !== "__proto__") {
          tempChildren[key] = attr.children[key];
          outOf += tempChildren[key];
        }
      }

      target = rand(outOf);

      for(var key in tempChildren) {
        i += tempChildren[key]
        if(i >= target) {
          return key;
        }
      };

      return null;
    };

    return {
      attr:     function() { return attr; },
      getChild: getChild
    };
  };

  var language = function() {
    var additionalCallback, words,
        wordArray = [];


    var genWords = function(curIdent, minLength, exclude) {
      var theseWords = []
      if(!curIdent) {
        curIdent = "__begin__";
      }
      if(!minLength) {
        minLength = 5;
      }
      var curWord = words[curIdent];

      while(true) {
        if(curWord.attr().sentence_end && wordArray.length > minLength + 1) {
          return theseWords;
        }
        curIdent = curWord.getChild(exclude);
        if(!curIdent) {
          curIdent = "__begin__";
        }
        exclude = null;
        curWord = words[curIdent];
        if(curIdent != "__begin__") {
          theseWords.push(curWord);
          wordArray.push(curWord);
        }
      }
    };

    var seedWith = function() {
      for(var i = 0; i < arguments.length; i++) {
        wordArray.push(words[ arguments[i] ]);
      }

      return wordArray;
    };

    var walkBackIndex = function(minBack) {
      var calcNumChildren = function(obj) {
        var i = 0;
        for(var key in obj) {
          i += 1;
        }
        return i;
      };

      if(!minBack) { minBack = 2; }
      var i = wordArray.length - 1,
          numChildren = 0,
          dist = 0;
      while(dist <= minBack) {
        dist += 1;
        i -= 1;
      }

      numChildren = calcNumChildren(wordArray[i].attr().children);
      while(i > 0 && numChildren < 3) {
        i -= 1;
        numChildren = calcNumChildren(wordArray[i].attr().children);
      }

      return i;
    };

    var walkBack = function(toIndex) {
      var deletedWord = wordArray[toIndex + 1].attr().identifier;

      while(wordArray.length > toIndex + 1) {
        wordArray.pop();
      }

      return deletedWord;
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

    var load = function(url, callBack) {
      additionalCallback = callBack;
      $.ajax({
        url:      url,
        dataType: 'json',
        success:  function(data) { initialize(data) }
      });
    };

    var lastMarkovWord = function() {
      if(wordArray.length > 0) {
        return wordArray[wordArray.length - 1];
      } else {
        return words["__begin__"];
      }
    };

    var lastWord = function() {
      return lastMarkovWord().attr().identifier;
    };

    var __interface__ = {
      words:          function() { return words; },
      length:         function() { return wordArray.length; },
      lastWord:       lastWord,
      lastMarkovWord: lastMarkovWord,
      load:           load,
      seedWith:       seedWith,
      walkBackIndex:  walkBackIndex,
      walkBack:       walkBack,
      genWords:       genWords,
      initialize:     initialize
    };

    return __interface__;
  };

  var controller = function(_url, lang, disp) {
    var language      = lang,
        url           = _url
        display       = disp,
        walkBackIndex = 0,
        maxLength     = 0,
        maxNumWords   = 75,
        retractDelay  = 2500,
        expandDelay   = 0;


    var start = function() {
      language.load(url, startMainLoop);
    };

    var startMainLoop = function() {
      var words = language.seedWith('welcome', 'to', 'nonsense', 'engine', '.');
      display.addWords(words);
      var delay = display.appearAll();


      setTimeout(retract, delay + retractDelay);
    };

    var retract = function() {
      maxLength = language.length();
      walkBackIndex = language.walkBackIndex();

      if(maxLength > maxNumWords) {
        maxLength = 3;
        walkBackIndex = 0;
      }

      var delay = display.walkBackDisplay(walkBackIndex);

      setTimeout(expand, delay + expandDelay);
    };

    var expand = function() {
      var words,
          exclude   = language.walkBack(walkBackIndex),
          sentBegin = language.lastMarkovWord().attr().sentence_end;

      display.walkBack(walkBackIndex);

      console.log("Expanding - last word: " + language.lastWord() );
      words = language.genWords(language.lastWord(),
        maxLength, exclude);

      display.addWords(words, sentBegin);
      var delay = display.appearAll();

      setTimeout(retract, delay + retractDelay);
    };

    return {
      start:      start
    };
  };

  var display = function(elem) {
    var $elem        = elem,
        curIndex     = 0,
        classes      = ['one', 'two', 'three', 'four'],
        displayWords = [];

    var addWords = function(wordArray, sentBegin) {
      $.each(wordArray, function(i, markovWord) {
        var attr = markovWord.attr(),
            wordText = attr.identifier;

        if(attr.proper || sentBegin) {
          wordText = capitalize(wordText);
        }
        if(rand(attr.count) < attr.shout_count) {
          wordText = wordText.toUpperCase();
        }
        if(!attr.punctuation) {
          wordText = " " + wordText;
        }

        sentBegin = attr.sentence_end
        var $word = $('<span>' + wordText + '</span>');
        $word.addClass(classes[0]);
        $word.css('display', 'none');
        $elem.append($word);
        displayWords.push($word);
      });

      shiftClass();
    };

    var shiftClass = function() {
      var old = classes.shift();
      classes.push(old);
    }

    //returns the total amount of time the walkback will take
    var walkBackDisplay = function(toIndex) {
      var delay = 0,
          fadeOutLength = 300;

      for(var i = displayWords.length - 1; i > toIndex; i--) {
        displayWords[i].delay(delay).fadeOut(fadeOutLength);
        delay += 50;
      }

      return delay + fadeOutLength;
    };

    var walkBack = function(toIndex) {
      for(var i = displayWords.length - 1; i > toIndex; i--) {
        displayWords[i].remove();
        displayWords.pop();
      }
      curIndex = toIndex + 1;
    };

    var appearAll = function() {
      var delay = 0,
          fadeInLength = 1000;

      for(; curIndex < displayWords.length; curIndex++) {
        displayWords[curIndex].delay(delay).fadeIn(fadeInLength);
        delay += 200;
      }

      return delay + fadeInLength;
    };

    var capitalize = function(text) {
      return text.charAt(0).toUpperCase() + text.slice(1)
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
      walkBackDisplay: walkBackDisplay,
      walkBack:        walkBack,
      appearAll:       appearAll,
      addWords:        addWords,
    };
  };

  return {
    language:   language,
    word:       word,
    controller: controller,
    display:    display
  };
})();


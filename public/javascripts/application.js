// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript-include-tag :defaults
//
var nonsenseEngine = ( function() {
  return {

  /* For the inheritence views:
   * make it so that they disable / enable their buttons as well */
   
    enableInheritenceView: function() {
      $(".new-text").css("background-color", "#9f9");
      $(".altered-text").css("background-color", "#f95");
      $(".from-first-parent").css("background-color", "#dda");
      $(".from-second-parent").css("background-color", "#aad");
      $(".deleted-text").css("display", "inline");
      $(".deleted-text").css("background-color", "#777");
      $(".deleted-text").css("text-color", "#ccc");

      $('#inheritence-enabler').addClass("disabled-link")
      $('#inheritence-enabler').click( function(){ return true; } );

      $('#inheritence-disabler').removeClass("disabled-link")
      $('#inheritence-disabler').click( function(){ nonsenseEngine.disableInheritenceView(); } );
      return false;
    },
    disableInheritenceView: function() {
      $(".new-text, .from-first-parent, .from-second-parent, .altered-text").css("background-color", "transparent");
      $(".deleted-text").css("display", "none");


      $('#inheritence-disabler').addClass("disabled-link")
      $('#inheritence-disabler').click( function(){ return true; } );

      $('#inheritence-enabler').removeClass("disabled-link")
      $('#inheritence-enabler').click( function(){ nonsenseEngine.enableInheritenceView(); } );
      return false;
    }
  };
})();

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
var nonsenseEngine = ( function() {
  return {
    enableInheritenceView: function() {
      $(".new-text").css("background-color", "#777");
      $(".altered-text").css("background-color", "#f95");
      $(".from-first-parent").css("background-color", "#dda");
      $(".from-second-parent").css("background-color", "#aad");
      $(".deleted-text").css("display", "inline");
      $(".deleted-text").css("background-color", "#777");
      $(".deleted-text").css("text-color", "#ccc");
    },
    disableInheritenceView: function() {
      $(".new-text, .from-first-parent, .from-second-parent, .altered-text").css("background-color", "transparent");
      $(".deleted-text").css("display", "none");
    }
  };
})();

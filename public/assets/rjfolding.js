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
(function a(a){a.fn.initRJFolding=function(b){return this.each(function(c,d){var e=a(d).attr("id"),f=a("#"+e),g=a("#"+e+"-folder"),h=a("#"+e+"-unfolder"),i=function(){return},j=function(){return},k=function(){return},l=!1;_folded=!1;var m=function(){g.bind("click",n),h.bind("click",o),b.folded?_folded=!0:_folded=!1,_folded?(f.hide(),g.hide()):h.hide(),b.addlFoldFn&&(i=b.addlFoldFn),b.addlUnfoldFn&&(i=b.addlUnfoldFn),b.preUnfoldFn&&(k=b.preUnfoldFn,l=!0,h.unbind("click"),h.bind("click",p))},n=function(a){a&&a.preventDefault(),_folded=!0,g.hide(),h.show(),f.slideUp(),i()},o=function(a){a&&a.preventDefault(),_folded=!1,g.show(),h.hide(),f.slideDown(),j()},p=function(a){a&&a.preventDefault(),k(o)};m(),f.data("rjfolding",{fold:n,unfold:o})})}})(jQuery)
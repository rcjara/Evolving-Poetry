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
(function(t){t.fn.initRJFolding=function(e){return this.each(function(n,r){var i=t(r).attr("id"),s=t("#"+i),o=t("#"+i+"-folder"),u=t("#"+i+"-unfolder"),a=function(){return},f=function(){return},l=function(){return},c=!1;_folded=!1;var h=function(){o.bind("click",p),u.bind("click",d),e.folded?_folded=!0:_folded=!1,_folded?(s.hide(),o.hide()):u.hide(),e.addlFoldFn&&(a=e.addlFoldFn),e.addlUnfoldFn&&(a=e.addlUnfoldFn),e.preUnfoldFn&&(l=e.preUnfoldFn,c=!0,u.unbind("click"),u.bind("click",v))},p=function(e){e&&e.preventDefault(),_folded=!0,o.hide(),u.show(),s.slideUp(),a()},d=function(e){e&&e.preventDefault(),_folded=!1,o.show(),u.hide(),s.slideDown(),f()},v=function(e){e&&e.preventDefault(),l(d)};h(),s.data("rjfolding",{fold:p,unfold:d})})}})(jQuery);
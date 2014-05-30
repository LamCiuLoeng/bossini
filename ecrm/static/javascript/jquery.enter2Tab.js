/*
 * jQuery enter2Tab plugin
 *
 * version 0.03 (05/12/2009)
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

/**
 * The enter2Tab() method provides a simple way of step into next input element.
 *
 * enter2Tab() takes a three option arguments:  
 *
 *   attr:  The attribute name used to sort the index order.The default value is 'enterindex'.
 *
 *   cycle: If set to true,when the last order element is press enter ,the first order element will be focus.
 *            Default is false , no cycle.
 *
 *   compare:  It's a function to compare the attribute value. By default,it's order lexicographically.
 *
 *
 * @example $(":input").enter2Tab();
 * @desc all the input element which has the attribute 'enterindex' will sort when press the 'ENTER' key.
 *
 * @example $(":input").enter2Tab({"attr":"next"});
 * @desc all the input element with the attribut "next" will sort.
 *
 * @example $(":input").enter2Tab({"attr":"next","cycle":true});
 * @desc when the last ordre element is press , the cursor will go back to the first element.
 *
 * @example $(":input").enter2Tab({"compare": function(a,b){if(a<b){return 1;} else if(a>b){return -1;} else{return 0;}}});
 * @desc sort the input element desc.
 *
 *
 * @name enter2Tab
 * @type jQuery
 * @param String options Options which control the corner style
 * @cat Plugins/keypress
 * @return jQuery
 * @author CL Lam (lamciuloeng@gmail.com)
 * @author Ray Zhang (Ray.zhang520@gmail.com)
 */

(function($) {
 
   $.fn.enter2Tab = function(settings) {
     var config = {'attr': 'enterindex',
				   'cycle' : false,
				   'compare' : function(a,b){ 
									if( a > b ) return 1;
									else if( a < b) return -1;
									else return 0;
							   }
				  };
 
     if (settings){ config = $.extend(config, settings); }

	 var result = $.map( this.filter("["+config.attr+"]"),$ );

	 result.sort(function(a,b){
		return config.compare( a.attr(config.attr),b.attr(config.attr) )
	 });

     this.each(function() {
       // element-specific code here
       var e = $(this);

		if(!e.attr(config.attr)){return this;}

       e.keydown(function(event){
		   if (event.keyCode != 13){ return;}

           var v = $(this).attr(config.attr);		
			var tmpList = result;
			if(config.cycle){
				tmpList = tmpList.concat(tmpList);
			}
			var lock = false;
			var next = null;
			for(var j=0;j<tmpList.length;j++){
				if(tmpList[j].attr(config.attr)==v){
					lock = true;
				}else if(lock && !tmpList[j].attr("disabled")){
					next = tmpList[j];
					break;
				}else if(!lock){
					continue;
				}
			}
			
			if(next){
				e.blur();
				next.focus();
			}
			
       });
     });
 
     return this;
 
   };

})(jQuery);

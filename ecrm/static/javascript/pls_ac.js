$(document).ready(function(){

    $(".ajaxSearchField").each(function(){
        var jqObj = $(this);

            //jqObj.autocomplete("/pls/getAjaxField", {
            jqObj.autocomplete("/publicaction/getAjaxField", {
                    extraParams: {
                       fieldName: jqObj.attr("fieldName")
                    },
                    formatItem: function(item){
                           return item[0]
                    },
                    matchCase : true
            });

    });

});

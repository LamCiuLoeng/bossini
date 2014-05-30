function getGMIInfo(id,hl,type){
    if( $("#gmidiv").length <1 ){}
        $.get("/pls/ajaxShowGMI/"+id+"?ds="+Date.parse(new Date())+"&type="+type,function(data){
        	if($("#gmidiv")){$("#gmidiv").remove();	}
        	        	
            var htmlStr = "<div id='gmidiv'>" + data + "</div>";
            var h = type == 1 ? (25*hl+550)+"px" : (25*hl+200)+"px"
            $("body").append(htmlStr);
            $("#gmidiv").dialog({
                title : "GMI Sample Submission History",
                width:"960px",
                height: h,
                modal: true,
				bgiframe : true,
				position : "center",
				buttons : { "Close":function(){$(this).dialog("close")} }
            })
        });
}
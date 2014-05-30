function indexof(l,value){
	for (var i=0;i<l.length;i++ )
	{
		if (l[i] == value)
		{
			return i;
		}
		else{
			continue;
		}
	}
}

$(document).ready(function(){
	var ids = new Array();
	$(":input[ray]").each(function(){
		ids.push($(this).attr('ray'));
	});
	l = ids.sort();

	$("input[ray]").keydown(function(event){
		if(event.keyCode == 13){
			var value = $(this).attr('ray');
			index = indexof(l,value) + 1;
			var next_value = l[index];
			$(":input[ray='" + next_value + "']").focus();
			//$($(this).next("input ['ray']")[0]).focus();
		}
	});

});

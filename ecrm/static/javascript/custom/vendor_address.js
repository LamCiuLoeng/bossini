function showNewDiv(){
	$('#new-address').slideDown();
}

function hideNewDiv(){
	$('#new-address').slideUp();
}

function showInput(id){
	var d = $("#"+id);
	$('.viewContent',d).hide();
	$('.editContent',d).show();
}

function hideInput(id){
	var d = $("#"+id);
	$('.viewContent',d).show();
	$('.editContent',d).hide();
}
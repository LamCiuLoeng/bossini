$(document).ready(function(){
		$('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });

});

function toExport(){
	if($('input[name=in_issue_date_fr]').val() && $('input[name=in_issue_date_to]').val()){
		$("form").submit();
	}else{
		$.prompt("Please input SO Issue Date range to generate the report!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
		return false;
	}
}
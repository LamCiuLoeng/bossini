var category = {
	'BD':'<option value="" selected="selected">(All)</option><option value="WRA">Wrapper / Belly</option><option value="PAP">Paper</option><option value="STK">Sticker</option>',
	'BG':'<option value="" selected="selected">(All)</option><option value="NWV">Non-woven</option><option value="POL">Polyester</option><option value="WFA">Woven Fabric</option>',
	'BT':'<option value="" selected="selected">(All)</option><option value="FAB">Fabric</option><option value="LEA">Leather</option><option value="PVC">PVC</option>',
	'BU':'<option value="" selected="selected">(All)</option><option value="MET">Metal</option><option value="PLA">Plastic</option><option value="POL">Polyester</option>',
	'BX':'<option value="" selected="selected">(All)</option><option value="C1S">C1S</option><option value="C2S">C2S</option><option value="CCN">CCNB</option><option value="COR">Corrugated</option><option value="FOI">Foil</option><option value="FUS">Foil US</option><option value="KRT">Kraft</option><option value="MAS">Master Packer</option><option value="PAL">Pallet Displays</option><option value="PDQ">PDQ</option><option value="PET">PET</option><option value="PVC">PVC</option><option value="RIG">Rigid</option><option value="RWM">Rigid with Magnet</option><option value="SBS">SBS</option><option value="SHI">Shipper Displays</option>',
	'IP':'<option value="" selected="selected">(All)</option><option value="COR">Corrugated</option><option value="CPF">Card Platform</option><option value="EPE">EPE</option><option value="FBF">Foil Box Foam Pad</option><option value="FIL">Flocked Inner Insert</option><option value="FVF">Flocked Vac Form</option><option value="SPO">Sponge</option><option value="STY">Styrofoam</option><option value="VAC">Vac Form</option>',
	'KF':'<option value="" selected="selected">(All)</option><option value="KFT">Kraft</option>',
	'LA':'<option value="" selected="selected">(All)</option><option value="ELT">Elastic tape/webbing</option><option value="FAP">Fabric Printed</option><option value="HET">Heat Transfers</option><option value="PLB">Printed Label</option><option value="WOT">Woven Tapes</option><option value="WOV">Woven</option>',
	'PA':'<option value="" selected="selected">(All)</option><option value="COB">Combo Material</option><option value="EMB">Embroidered</option><option value="HET">Heat transfer</option><option value="IML">Imitation leather</option><option value="LEA">Leather</option><option value="MIS">Misc</option><option value="PVC">PVC</option><option value="RUB">Rubber</option><option value="WOV">Woven Tapes</option>',
	'PI':'<option value="" selected="selected">(All)</option><option value="BAC">Backer Card</option><option value="BLC">Blister Card</option><option value="HAT">Hang Tag</option><option value="HEC">Header Card</option><option value="INS">Insert</option><option value="ITS">Instruction Sheet</option><option value="JOT">Jocker Tag</option><option value="MIS">Misc</option><option value="POF">Pocket Flasher</option><option value="PST">Paper Stock</option><option value="SHB">Shirt Band</option><option value="SOC">Sockband</option><option value="TIS">Tissue Paper</option><option value="WRA">Wrapper (Band)</option>',
	'PL':'<option value="" selected="selected">(All)</option><option value="BAG">PolyBag</option><option value="BUB">Bubble</option><option value="BUC">Buckle</option><option value="CLA">Clam</option><option value="HAG">Hanger</option><option value="HAT">Hang Tag</option><option value="HCL">Half Clam</option><option value="MIS">Misc</option><option value="OUB">Outer Blister</option>',
	'PN':'<option value="" selected="selected">(All)</option><option value="PIN">Pins</option>',
	'SF':'<option value="" selected="selected">(All)</option><option value="HOE">Hook & Eye</option><option value="RIV">Rivet</option><option value="SHA">Shank</option>',
	'SP':'<option value="" selected="selected">(All)</option><option value="BOW">Bows</option><option value="FAB">Fabric</option><option value="MCD">Merchandise</option><option value="MIS">Misc</option>',
	'ST':'<option value="" selected="selected">(All)</option><option value="CLB">Master Carton Label</option><option value="FST">Foil Sticker</option><option value="G&U">Graphic & UPC</option><option value="GRA">Graphic Only</option><option value="INT">Integrated (logo/graphic/UPC/Size)</option><option value="MIS">Misc</option><option value="PRI">Price Only</option><option value="SIZ">Size Only</option>',
	'TP':'<option value="" selected="selected">(All)</option><option value="ELT">Elastic</option><option value="MIS">Misc</option><option value="RUF">Ruffle Edge</option><option value="VEL">Velvet</option><option value="WOV">Woven</option>',
	'ZI':'<option value="" selected="selected">(All)</option><option value="MET">Metal</option><option value="PLA">Plastic</option><option value="POL">Polyester</option>',
	'ZP':'<option value="" selected="selected">(All)</option><option value="FAP">Fabric Printed</option><option value="LEA">Leather</option><option value="MET">Metal</option><option value="PLA">Plastic</option><option value="RUB">Rubber</option><option value="WOV">Woven</option>'

};


$(document).ready(function(){
		$('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });
		
		$("#dnDetail").change(function(){
			if($(this).val() == "no" ){
				$("#orderby").attr("disabled",false)
			}else if($(this).val() == "yes") {
				$("#orderby").attr("disabled",true);
			}
		});
		
		
		$(".ajaxSearchField").each(function(){
	        var jqObj = $(this);
	
	            var ac = jqObj.autocomplete("/kohlspo/getAjaxValues", {
	                    extraParams: {
	                       fieldName: jqObj.attr("id"),
						   ln_company_code : function(){return $("#ln_company_code").val();},
						   rowcount : 20
	                    },
	                    formatItem: function(item){
	                           return item[0]
	                    },
	                    matchCase : true,
	                    maxItemsToShow  : 20
	            });
	    });
		
		$("#in_item_cat").change(function(){
		if( $(this).val() == "" ){
            $("#in_sub_cat1").html("<option value=''></option>");
            return;
        }else{
			$("#in_sub_cat1").html(category[$(this).val()]);
		}

	});
	});

	

function toExport(){
	var flag = false;
	$("form :input").each(function(){
		var tmp = $(this);
		if(tmp.val()!=""){
			flag = true;
		}
	});
	
	if(flag){
		$("form").submit();
	}else{
		$.prompt("Please input at least one field to generate the report!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
		return false;
	}
}
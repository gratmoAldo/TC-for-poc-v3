var cur_edit=null;
function removeEdit() {
	if(cur_edit!=null) {
		e=$('#asset_edit').siblings('.view');
		$('#asset_edit').remove();
		e.find('.view-actions').hide();
		e.show();
		cur_edit=null;
	}
}
$(function() {

	$("#search-input").focus(function(e){
		var d = $("#search-input").attr("default");
		var v = $("#search-input").attr("value");
		if (d.toLowerCase() == v.toLowerCase()) {
			$("#search-input").attr("value", "");
			$("#search-input").removeClass("input_tip");
		}
		$("#search-input").select();
	});
	$("#search-input").blur(function(e){
		var d = $("#search-input").attr("default");
		var v = $("#search-input").attr("value");
		if (d.toLowerCase() == v.toLowerCase() || v == '') {
			$("#search-input").attr("value", "");
			$("#search-input").addClass("input_tip");
			$("#search-input").attr("value", d);
		}
	});
	if ($("#search-input").attr("value") == "") {
		$("#search-input").addClass("input_tip");
		$("#search-input").attr("value", $("#search-input").attr("default"));
	}

	$(".edit").live('click', function() {
		if(cur_edit==null) {
			cur_edit="asset_edit";
			// $(this).parents('.col4').hide();
			// setTimeout(function(){$("#effect:hidden").removeAttr('style').hide().fadeIn();}, 1000);

			$(this).parents('.asset').append('<div id="'+cur_edit+'" style="display: none;"></div>');
			$.get($(this).attr('rel'), null, null, "script");
		}
		return false;
	})
	if(admin==true) {
		$("li").hover(
			function () {
				if(cur_edit==null) $(this).find('.view-actions').show();
			}, 
			function () {
				$(this).find('.view-actions').hide();
			})
	}

	focus('search-input');
		
})

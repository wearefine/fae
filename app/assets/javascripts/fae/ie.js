$(function() {
	// this is done in modern browsers using :checked with CSS. needs JS in <= IE8
	$(".slider-wrapper-checkbox-area").each(function(){
		var $parent = $(this);
		var $checkbox = $parent.find("input[type=checkbox]");

		if($checkbox.is(":checked")) {
			$parent.addClass("slider-yes-selected");
		}
	});

	$('#main_content').on('click', ".slider-wrapper-checkbox-area", function(e){
		e.preventDefault();
		$(this).toggleClass("slider-yes-selected");
	});

	// for the dropdown select boxes. we are using nth-of-type for modern browsers
	$(".input.date").each(function(){
		$(this).find("select").each(function(index){
			$(this).addClass("ie-select-" + (index + 1));
		});
	});
});
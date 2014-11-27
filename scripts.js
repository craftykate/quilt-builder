// ============ HOVER COLORS ============
$(document).ready(function(){
	$(".colors").hover(function(){
		$(".colors").addClass("white");
		var thisClass = $('.'+$(this).attr('class').split(' ').join('.'));
		$(thisClass).removeClass("white");
	}, function(){
		$(".colors").removeClass("white");
	});
});
// ========== END HOVER COLORS ==========
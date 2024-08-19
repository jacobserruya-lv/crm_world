// table arrow VOICE 2
// All the function that we use in the scroll Y in the table
function tablePrev() {
	$table = $(".table-responsive.theOne");
	$table.scrollLeft(0);
	updateOnScroll();
};
function tableNext() {
	$table = $(".table-responsive.theOne");
	$table.scrollLeft($table.prop('scrollWidth'));
	updateOnScroll();
};
function updateOnScroll(){
	$btPrev = $(".tableArrow.arrowLeft");
	$btNext = $(".tableArrow.arrowRight");
	$table = $(".table-responsive.theOne");
	$scrollX = $table.scrollLeft();
	$scrollW = $table.prop('scrollWidth') - $table.width();
	//console.log($scrollX + " / "+$scrollW);
	////////
	if($scrollX <= 0){
		$btPrev.attr('disabled','disabled');
		$btNext.removeAttr('disabled');
	}else if($scrollX >= $scrollW){
		$btPrev.removeAttr('disabled');
		$btNext.attr('disabled','disabled');
	}else{
		$btPrev.removeAttr('disabled');
		$btNext.removeAttr('disabled');
	}
}
$( document ).ready(function() {
	$(".table-responsive.theOne").scroll(updateOnScroll);
});

/*
    <!-- createdBy          Haim Knokh, 18/08/2015 -->
    <!-- lastModifiedBy     Menashe Yamin, 17/02/2016 -->
	<!-- dependencies : jquery.blockUI.min.js -->

	set the blockUI library 
*/
function unblockUI(){
	if($('.blockUI.blockOverlay').length === 0) return;
	$.unblockUI();
}

function blockUI() {
	if($('.blockUI.blockOverlay').length > 0) return;
	$.blockUI({ 
		message: '<img src="http://cdnjs.cloudflare.com/ajax/libs/semantic-ui/0.16.1/images/loader-large.gif" />', 
		overlayCSS:  { 
			backgroundColor: '#F0F0F0',  
			opacity:         0.3, 
			cursor:          'wait' 
		},
		baseZ: 2000,
		css: {
		border: 'border:solid 1px #a0a0a0',
		padding: '8px',
		backgroundColor: 'transparent',
		'-webkit-border-radius': '10px',
		'-moz-border-radius': '10px',
		opacity: .5,
		color: '#000',
		'width': '300px'
	} } ); 
}
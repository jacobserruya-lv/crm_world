({
	onInit: function (component, event, helper) {
		// console.group('MIY_Files.onInit');
        // console.log('v.recordId',component.get('v.recordId'));
		helper.getFiles(component);
		component.addEventHandler('force:recordChange', component.getReference('c.handleRecordChange'));
		// console.groupEnd();
	},
	handleRecordChange : function(component, event, helper) {
		// console.group(component.getType() + '.handleRecordChange', event);
		helper.getFiles(component);
		// console.groupEnd();
	},
})
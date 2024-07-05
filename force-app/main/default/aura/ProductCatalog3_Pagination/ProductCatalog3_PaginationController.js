({
    changePage : function(component, event, helper) {
        // console.group(component.getType() + '.changePage');
        var pageNum = Number(event.getSource().get('v.value'));
        var pageCount = component.get('v.pageCount');
        if(pageNum <= pageCount){
            component.set('v.currentPage', pageNum);
            var myEvent = $A.get("e.c:ProductCatalog3_PaginationChangeCurrentPageEvent");
            myEvent.setParams({ "pageNumber": pageNum});
            myEvent.fire();
        }
        // console.groupEnd();
    },
    changeCountPerPage : function(component, event, helper) {
        // console.group(component.getType() + '.changeCountPerPage');
        var countPerPage = Number(event.getParam("value"));
        component.set('v.countPerPage', countPerPage);

        var myEvent = $A.get("e.c:ProductCatalog3_PaginationCountPerPageEvent");
        myEvent.setParams({ "countPerPage": countPerPage});
        myEvent.fire();

        // console.groupEnd();
    },

   
})
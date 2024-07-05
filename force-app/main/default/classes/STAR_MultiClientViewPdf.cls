public with sharing class STAR_MultiClientViewPdf {
		
    public list<String> idList {get;set;}
    public STAR_MultiClientViewPdf()
    {
        idList = (list<string>)JSON.deserialize (System.currentPagereference().getParameters().get('listid'),List<string>.class);
        
        
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=clientsprinted.pdf');
        
    }

}
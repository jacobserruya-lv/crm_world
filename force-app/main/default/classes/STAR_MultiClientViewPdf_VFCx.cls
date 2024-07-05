/*** File Name: STAR_MultiClientViewPdf_VFCx
* Description : Controller of STAR_MultiClientViewPdf
* @author : UNKNOWN
* Modification Log =============================================================== 
	MTOU 21/06/2016 retrievong Star_LVInterestsDetails__pc from query

***/
public with sharing class STAR_MultiClientViewPdf_VFCx {


    public list<String> idList {get;set;}
    
    public STAR_MultiClientViewPdf_VFCx()
    {   
        idList = (list<string>)JSON.deserialize (System.currentPagereference().getParameters().get('listid'),List<string>.class);
             
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=clientsprinted.pdf');
        

    }
    
    public List<Account> getClients()
    {
        List<Account> clients  =[Select Id, Gender__pc, Salutation,lastname, firstname, DREAMID__c, DreamSA__pc, Title__pc, ownerId, Segmentation__pc,
         Nationality__pc, Typology__pc, AttachedStore__pc, Star_CommentPhotoBook__pc, Spouse__pc, Anniversary__pc,Star_LVInterestsDetails__pc,
         PersonalInterest2__pc, PersonalInterest1__pc, PersonalInterest3__pc, HistoricalSpendEUR__pc, Occupation__pc, Company__pc, YTDSpendEUR__pc, IsPersonAccount,
         AccessoriesInterest__pc,JewelleryInterest__pc, LeatherGoodsInterest__pc, RTWInterest__pc, ShoesInterest__pc, WatchesInterest__pc, PerfumesInterest__pc, OtherInterest__pc, ServiceInterest__pc, EventInterest__pc,
        (Select ParentId, Name, Id, ContentType, BodyLength 
                From Attachments 
                where name = 'Contact Picture' limit 1)                          
         FROM Account WHERE id in: idList];
        
        system.debug('## MT returned clients: ' + clients);
        return clients;
    }

}
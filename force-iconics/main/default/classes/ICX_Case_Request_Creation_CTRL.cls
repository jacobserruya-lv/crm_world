public class ICX_Case_Request_Creation_CTRL {
    
    public Flow.Interview.ICX_CaseCreation myFlow {get; set;}
    public String newCaseId;
    public PageReference nextPage;
    
    //public Flow.Interview.ICX_Phoenix_MyCR_Creation phoenixFlow {get; set;}
    
    public ICX_Case_Request_Creation_CTRL(ApexPages.StandardController st) {
        
    }
        
    public PageReference getNextPage()
    {
        //System.debug('myFlow=' + myFlow);
        //System.debug('phoenixFlow=' + phoenixFlow);
        //System.debug('getVariableValue>VarCaseId=' + (phoenixFlow != null ? phoenixFlow.getVariableValue('VarCaseId') : null));
        String caseId = (myFlow != null ? myFlow.VarNewCaseID : null);//(phoenixFlow != null ? phoenixFlow.VarCaseId : null));
        //System.debug('CaseId=' + caseId);
        if (String.isNotBlank(caseId)) {
            return new PageReference('/' + caseId);
        } else {
            return null;
        }
       /*System.debug('myFlow=' + myFlow);
        if(myFlow == null)
        {
            return null;
        }
        else
        {
        System.debug('myFlow.VarNewCaseID=' + myFlow.VarNewCaseID);
            return new PageReference('/' + myFlow.VarNewCaseID);
        }*/
    }
}
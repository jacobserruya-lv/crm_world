public class ICX_CaseCreationFromTask_EXT {

    
    public Flow.Interview.ICONICS_Case_Creation_from_Task myFlow {get;set;}
	public id caseID;
    public id taskID {get; set;}
    public ICX_CaseCreationFromTask_EXT(ApexPages.StandardController controller)
    {
        taskID = controller.getRecord().id;
    }
    
    public id getCaseID()
    {
        return myFlow.VarCaseID;
    }
}
@isTest
class ICX_GenesysEmailDisconnectInvoc_TEST {
    
    @isTest
    static void genesysPickOut(){
        ICX_GenesysEmailDisconnectInvoc.Request req = new ICX_GenesysEmailDisconnectInvoc.Request();
        req.conversationId = 'conversationId';
        req.participantId = 'participantId';
        List<ICX_GenesysEmailDisconnectInvoc.Request> requests = new List<ICX_GenesysEmailDisconnectInvoc.Request>{req};
        List<ICX_GenesysEmailDisconnectInvoc.Result> res = ICX_GenesysEmailDisconnectInvoc.genesysPickOut(requests);
        Assert.isTrue(res.get(0).result);
    }
}
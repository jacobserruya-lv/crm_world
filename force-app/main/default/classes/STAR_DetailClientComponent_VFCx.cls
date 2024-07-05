public with sharing class STAR_DetailClientComponent_VFCx {

    
    public Account currClient {get;set;}
    public Attachment file {get;set;}
    public boolean hasPicture;
    
    public boolean getHasPicture()
    {
        system.Debug('## currClient: ' +currClient);
        hasPicture = false;
        if(currClient.Attachments.size() > 0)
        {
           hasPicture = true;
           file = currClient.Attachments[0];
           file.Body = Blob.valueOf('AuxString');
        }
        system.debug('## file: ' + file);
        system.Debug('## hasPicture: ' + hasPicture);
        
        return hasPicture;
    }

}
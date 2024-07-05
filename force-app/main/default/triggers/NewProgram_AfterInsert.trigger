/** * File Name: NewProgram_AfterInsert
* Description : trigger for after insert on program
* @author : UNKNOWN
* Modification Log =============================================================== 
	MTOU 13/06/2016 calling new method UpdateClients: update some client information
	MTOU 20/06/2016 removing the temporary gift creation 
* */
trigger NewProgram_AfterInsert on Program__c (after insert) {
	
	 If (IC_Utils.canTrigger('NEWPROGRAM_AFTER')) {
       System.debug('### in trigger Program');
       //STAR_NewProgram_TRG.NewProgam(Trigger.new);
       STAR_NewProgram_TRG.UpdateClients(Trigger.new);
    }

}
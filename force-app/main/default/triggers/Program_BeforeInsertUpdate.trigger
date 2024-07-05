trigger Program_BeforeInsertUpdate on Program__c (before insert, before update) 
{   
     If (IC_Utils.canTrigger('PROGRAM_BEFOREINSERTUPDATE'))
     {
        System.debug('### in trigger Program');
        STAR_ProgramBeforeInsertUpdate_TRG.ProgamInsertOrUpdate(Trigger.new);
     } 
     
}
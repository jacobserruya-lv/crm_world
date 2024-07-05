global Class STAR_ProgramWrapper
{
    public boolean isSelected {get;set;}
    public Program__c prg {get;set;}
    
    public STAR_ProgramWrapper(boolean isSelected, Program__c p)
    {
        this.isSelected = isSelected;
        this.prg = p;
    }
}
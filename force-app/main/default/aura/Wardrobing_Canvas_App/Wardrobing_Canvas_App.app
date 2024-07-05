<aura:application extends="force:slds">
    <aura:attribute name="wrdbParams" type="string" />
    <aura:attribute name="masterSku" type="string" />
    <aura:attribute name="dreamId" type="string" />
    <aura:attribute name="gender" type="string" />
    <aura:attribute name="is10k" type="string" />
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
  <c:Wardrobing_Canvas canvasParameters="{!v.wrdbParams}"/>
</aura:application>
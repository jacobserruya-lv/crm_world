<aura:application access="global" extensible="true" implements="force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId,forceCommunity:availableForAllPageTypes">
    <aura:handler value="{!this}" name="init" action="{!c.init}"/>
    <aura:attribute name="dev" type="String" />

    
    
          <lightning:container src="{!$Resource.appointmentsVue  + '/index.html'}" />
            
</aura:application>
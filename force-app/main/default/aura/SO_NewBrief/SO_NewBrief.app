<aura:application extends="force:slds" controller="SO_OpportunitySPAController">
    <!--, ltng:outApp
<aura:dependency resource="markup://c:SO_OpportunitySPA" /-->

    <!--meta name="apple-mobile-web-app-capable" content="yes"/-->

    <aura:attribute name="sku" type="String" />
    <aura:attribute name="product" type="ProductReferential__c" />
    <aura:attribute name="showToast" type="Boolean" default="false"/>
    <aura:attribute name="toastType" type="String"/>
    <aura:attribute name="toastTitle" type="String"/>
    <aura:attribute name="toastMessage" type="String" default="an error occurred"/>
    <aura:attribute name="orderSettings" type="OrderSettings__c" />

    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <!-- <aura:handler event="force:showToast" action="handleToastEvent"/> -->
    <aura:handler event="c:SO_CustomToastEvent" action="{! c.doCustomToast }"/>
    <aura:registerEvent name="opportunityEvent" type="c:SO_OpportunitySPAEvent"/>

    <div>
        <!-- Header from PERSO app -->
        <div class="lv-header">
            <div class="wrapper">
                <!--div id="backButton" class="back" onclick="{!c.redirect}">
                    <i class="fa fa-angle-left" aria-hidden="true"></i>
                    <p>back to Now Yours</p>
                </div-->
                <div class="logo slds-text-heading--small font-weight--bold" >
                    <!--lightning:input type="url" label="Website" name="website" value="">
                    </lightning:input-->

                    <a href="{!v.orderSettings.MakeItYoursAppUrl__c}">
                    {!$Label.c.LV_SO_LOUIS_VUITTON}
                        <p class="slds-text-body--small">{!$Label.c.LV_SO_Header_Creation}</p>
                    </a>
                </div>
                <!--nav class="nav-main">
                <ul>
                    <li id="nav-starred">
                        <a href="/favorites">
                            <i class="fa fa-star" aria-hidden="true"></i>
                        </a>
                    </li>
                    <li id="nav-cart">
                        <a href="/carts">
                            <i class="fa fa-suitcase"></i>
                        </a>
                    </li>
                </ul>
            </nav-->
            </div>
        </div>
    </div>


    <div style="margin-top:60px; margin-bottom:60px; height:100%;"> <!-- MIY-1783 -->
        <aura:if isTrue="{! v.showToast }">
            <div id="toastDiv" onclick="{! c.closeToast }" class="slds-transition-show">
                <ui:message title="{! v.toastTitle }" severity="{! v.toastType }" closable="true">
                        {! v.toastMessage }
                </ui:message>
            </div>
        </aura:if>
        <c:SO_OpportunitySPA aura:id="briefSPA"/>
    </div>
    <!--c:SO_BriefCreationSPA aura:id="briefSPA"/-->
    <!--c:SO_PictureGalleryCard aura:id="briefSPA"/-->

</aura:application>
<aura:application access="global" extends="ltng:outApp" implements="ltng:allowGuestAccess">
    <aura:dependency resource="c:twistLoginWrapper"/>
    <aura:dependency resource="c:twistForgotPasswordWrapper"/>
    <aura:dependency resource="c:twistResetPasswordWrapper"/>
    <aura:dependency resource="c:twistAccountCreationWrapper"/>
    <aura:dependency resource="c:twistAlternativeLoginWrapper"/>
    <aura:dependency resource="c:twistSocialMediaBounceWrapper"/>
    <aura:dependency resource="c:twistError404Wrapper"/>
</aura:application>
function showLineSocialLoginButton() {
    return showSocialMediaButton.call(this, 'LineLV', 'lineSocialLoginEnabled');
}

function showLineTaiwanSocialLoginButton() {
    return showSocialMediaButton.call(this, 'LineLVTW', 'lineSocialLoginEnabled');;
}

function showGoogleSocialLoginButton() {
    return showSocialMediaButton.call(this, 'GoogleLV', 'googleSocialLoginEnabled');;
}

function showSocialMediaButton(providerName, flagFeatureKey) {
    return this.socialMediaProviders[providerName] && this.componentConfig[flagFeatureKey] && !this.oQueryParams?.social_id;
}

function showOrSeparator() {
    return this.componentConfig['lineSocialLoginEnabled'] || this.componentConfig['googleSocialLoginEnabled'];
}

export {
    showLineSocialLoginButton,
    showLineTaiwanSocialLoginButton,
    showGoogleSocialLoginButton,
    showOrSeparator
}
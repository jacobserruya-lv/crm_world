function setup(isLoading) {

    if (settings.current_step == settings.static.KISSA_STEP) {
        enableKisaButton();
        setDynamicKisaLabels();
    } else if (settings.current_step == settings.static.LOGIN_STEP) {
        // Hide automattically login modal 
        $('#login_modal').hide();
        // enable the submit button 
        enableButton('[id$=":login_button"]', true);
        setDynamicLoginLabels();
    } else if (settings.current_step == settings.static.PERSONAL_STEP) {
        // autocomplete attribute not working on apex inputsecret
        onDisplayPasswordClick(true);
        // enable the submit button 
        enableButton('[id$=":personal_button"]', true);
        setDynamicPersonalLabels();

        // validation on pre-filled fields
        if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
            onPersonalSectionSubmit(true);
        }

        if (settings.mode == settings.static.ACTIVATION && settings.sub_mode == settings.static.PARTIAL) {
            setDynamicActivationLabels();
        }
    } else if (settings.current_step == settings.static.VERIFICATION_STEP) {
        $('[id$=":resent_done_message"]').hide();
        setDynamicVerificationLabels();
    }

    enableBackButton();


    handleSectionForm(isLoading);
};

/******************************  LOGGIN   **************************/

function logout() {
    // AUTO LOGOUT IF ALREADY HAVE SALESFORCE SESSION ID
    if (settings.isLoggin == 'true') {
        window.parent.location = settings.site_prefix;
    }
}

function login() {
    // Add loading style
    showLoader(true, '#popover-login-loader', 'popover-login');
    loginPasswordMethod();
}

/******************************  NAVIGATION   **************************/

function back() {
    if (!settings.remoting) {

        settings.index_step--;

        // Avoid 
        if (settings.index_step < 0) {
            settings.index_step = 0;
        }

        settings.current_step = settings.flow[settings.index_step];

        if (isTrackingAvailable()) {
            var page = (settings.current_step == 1 ? 'email' : (settings.current_step == 2 ? 'personal_infos' : (settings.current_step == 3 ? 'activation' : 'options')));
            page = 'step_' + page;
            autoData.sendEvent({
                'actionId': 'back_to_previous_step',
                'actionType': 'navigation',
                'actionPosition': 'top',
                'pageRank': page, 
                'categoryGa':'mylv', 
                'actionGa':'back_to_previous_step_form_sf'
            });
            autoData.sendPageView({
                'event': 'pageview',
                'pageRank': page
            });
        }
    }
}

function next() {
    if (!settings.remoting) {

        settings.index_step++;

        // Avoid 
        if (settings.index_step > 3) {
            settings.index_step = 3;
        }

        settings.current_step = settings.flow[settings.index_step];

        if (isTrackingAvailable()) {
            var page = (settings.current_step == settings.static.LOGIN_STEP ? 'email' : (settings.current_step == settings.static.PERSONAL_STEP ? 'personal_infos' : (settings.current_step == settings.static.VERIFICATION_STEP ? 'activation' : 'options')));
            page = 'step_' + page;
            autoData.sendPageView({
                'event': 'pageview',
                'pageRank': page
            });
        }
    }
}

function needNavigationToLVAPP(current_url, origin) {
    return ((navigator.userAgent.match(/Android/i) ||
            navigator.userAgent.match(/webOS/i) ||
            navigator.userAgent.match(/iPhone/i) ||
            navigator.userAgent.match(/iPad/i) ||
            navigator.userAgent.match(/iPod/i) ||
            navigator.userAgent.match(/BlackBerry/i) ||
            navigator.userAgent.match(/Windows Phone/i)
        ) &&
        !current_url.searchParams.get('skip') &&
        current_url.searchParams.get('cid') &&
        origin != 'lvapp'
    );
}

function navigateToLVAPP(current_url, new_url) {
    // CID Param
    var cidVal = current_url.searchParams.get('cid');
    new_url += '/' + cidVal;

    // Redirect
    var now = new Date().valueOf();
    setTimeout(function () {
        if (new Date().valueOf() - now > 100) return;
        current_url.searchParams.set('skip', true);
        window.location.href = current_url;
    }, 50);
    window.location.href = new_url;
}

function setFlow() {

    settings.flow = [settings.static.LOGIN_STEP, settings.static.PERSONAL_STEP, settings.static.VERIFICATION_STEP];

    if (settings.mode == settings.static.ACTIVATION) {
        if (settings.sub_mode == settings.static.PARTIAL) {
            settings.flow = [settings.static.PERSONAL_STEP];
        } else if (settings.sub_mode == settings.static.FULL) {
            settings.flow = [settings.static.LOGIN_STEP, settings.static.PERSONAL_STEP, settings.static.VERIFICATION_STEP];
        }
    }

    if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
        if (settings.sub_mode == settings.static.MATCHING) {
            settings.flow = [settings.static.LOGIN_STEP, settings.static.VERIFICATION_STEP];
        } else if (settings.sub_mode == settings.static.FULL) {
            settings.flow = [settings.static.LOGIN_STEP, settings.static.PERSONAL_STEP, settings.static.VERIFICATION_STEP];
        } else if (settings.sub_mode == settings.static.PARTIAL) {
            settings.flow = [settings.static.PERSONAL_STEP, settings.static.VERIFICATION_STEP];
        }
    }

    if (settings.country_local == 'kr') {
        settings.flow.unshift(settings.static.KISSA_STEP);
    }

    settings.total_step = settings.flow.length;
}

function setStep() {
    settings.index_step = 0;
    settings.current_step = settings.flow[settings.index_step];
    settings.initial_step = settings.current_step;
}

/******************************  EVENT   **************************/

function onKisaAgreementExpand(index, current_index) {
    if (parseInt(current_index) == index) {
        index = 0;
    } else {
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'actionId': 'options_details_popin',
                'pageRank': 'step_options', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'options_details_popin'
            });
        }
    }

    updateExpandedIndex(index);
}

function onAllKisaAgreementsChange() {
    var trigger = $('#kisa-agreement-all').prop('checked');

    [1, 2, 3].forEach(function (i) {
        $('#kisa-agreement-' + i).prop('checked', trigger)
    });

    enableKisaButton();
}

function onKisaAgreementChange() {
    enableKisaButton();
}

function handleCheckboxEnter(e, field) {
    var key = e.keyCode;
    var code = e.charCode;

    if (key == 13 || code == 13) {
        $('[id$=":' + field + '"]').click();
        return false;
    }
}

function onHandleKeyPress(e, type) {
    var key = e.keyCode;
    var code = e.charCode;
    //backspace, space and other special characters
    var special = keyIsSpecialCode(key) || keyIsSpecialCode(code);
    //english letters (plus accents and special chars)
    var english = (key > 64 && key < 91) || (key > 96 && key < 123) || keyIsAccent(key) || (code > 64 && code < 91) || (code > 96 && code < 123) || keyIsAccent(code);

    if (key == 13 || code == 13) {
        return false;
    }

    if (type == 'numeric') {
        return ((key >= 48 && key <= 57) || key == 8 || key == 45 || key == 32 || (code >= 48 && code <= 57) || code == 8 || code == 45 || code == 32);
    } else if (type == 'alpha') {
        /*ECO-17948: we should allow english + specific characteres for each context needed (Japan, Russia..)*/
        if (settings.country_local == "jp") {
            return isKanjiKanaCode(key) || isKanjiKanaCode(code) || english || special;
        } else if (settings.country_local == "ru") {
            return (key >= 1024 && key <= 1279) || (code >= 1024 && code <= 1279) || english || special;
        } else {
            return english || special;
        }
    } else if (type == 'kana') {
        /* allow katakana kana +english and special chars*/
        // Modified by Nicolas and Bernard - Add (key >= 12352 && key <= 12447)
        return (key >= 12352 && key <= 12447) || (key >= 12448 && key <= 12543) || (key >= 12784 && key <= 12799) || (code >= 12448 && code <= 12543) || (code >= 12784 && code <= 12799) || english || special;
    }
}

function isKanjiKanaCode(key) {
    return (key >= 12352 && key <= 12447) ||
        (key >= 12448 && key <= 12543) ||
        (key >= 12784 && key <= 12799) ||
        (key >= 13312 && key <= 19893) ||
        (key >= 19968 && key <= 40959) ||
        (key >= 12288 && key <= 12351);
    //12352-12447:Hiragana, 12448-12543:Katakana, 12784-12799:Katakana Phonetic Extensions
    //13312-19893:CJK Unified Ideographs Extension A, 19968-40959:CJK Unified Ideographs 
    //12288-12351: CJK Symbols and Punctuation 
}

function keyIsSpecialCode(k) {
    return (k == 46 || k == 45 || k == 39 || k == 8 || k == 32);
}

function keyIsAccent(k) {
    return ((k >= 224 && k <= 239) || (k >= 242 && k <= 246) || (k >= 249 && k <= 252));
}

function onInputCodeChange(isConfirmed) {
    if (isConfirmed == 'true') {
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'event': 'createAccountSuccess',
                'actionId': 'account_creation_succeeded',
                'actionType': 'submit_button',
                'pageRank': 'step_activation', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'account_creation_activation_succeeded'
            });
        }
        setup(true);
        register();
    } else {
        enableButton('[id$=":verification_button"]', true);
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'event': 'createAccountFailure',
                'actionId': 'account_creation_failed',
                'actionType': 'submit_button',
                'pageRank': 'step_activation', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'account_creation_activation_failed'
            });
        }
        handleInputCodeExceptions({
            hasError: true,
            error: settings.labels.Verification_Section_Error
        });
        setup();
    }
}

function onVerificationButtonSubmit() {
    enableButton('[id$=":verification_button"]', false);
    onVerificationSubmit();
}

function onKisaButtonSubmit() {
    enableButton('[id$=":kisa_button"]', false);
    next();
    setup();
}

function onLoginSectionSubmit(isPreValidation) {
    if (settings.remoting) {
        setTimeout(DOLoginSectionSubmit, 1000);
    } else {
        DOLoginSectionSubmit();
    }
}

function DOLoginSectionSubmit() {
    var isHidden, isValid, isChecked, isRequired;
    var submit = true;

    isHidden = parseBoolean(settings.fields.login_email.isHidden);
    isRequired = parseBoolean(settings.fields.login_email.isRequired);
    isNotEmpty = Boolean($('[id$=":login_email"]').val());
    isValid = $('[id$=":login_email"]').data('isValid');
    if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
        onLoginEmailChange();
        if (!$('[id$=":login_email"]').data('isValid')) {
            submit = false;
        }
    }

    isHidden = parseBoolean(settings.fields.login_email_confirmation.isHidden);
    isValid = $('[id$=":login_email_confirmation"]').data('isValid');
    if (!isHidden && !isValid) {
        onLoginEmailConfirmationChange();
        if (!$('[id$=":login_email_confirmation"]').data('isValid')) {
            submit = false;
        }
    }

    isHidden = parseBoolean(settings.fields.login_mobile_phone.isHidden);
    isRequired = parseBoolean(settings.fields.login_mobile_phone.isRequired);
    isNotEmpty = Boolean($('[id$=":login_mobile_phone"]').val());
    isValid = $('[id$=":login_mobile_phone"]').data('isValid');
    if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
        onLoginMobilePhoneChange();
        if (!$('[id$=":login_mobile_phone"]').data('isValid')) {
            submit = false;
        }
    }

    if (submit) {
        enableButton('[id$=":login_button"]', false);
        showLoader(true, '#login-section-loader', 'login_button');
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'event': 'createAccountSuccess',
                'actionId': 'account_creation_succeeded',
                'actionType': 'submit_button',
                'pageRank': 'step_email', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'account_creation_succeeded'
            });
        }
        onLoginSubmit();
        next();
    } else {
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'event': 'createAccountFailure',
                'actionId': 'account_creation_failed',
                'actionType': 'submit_button',
                'pageRank': 'step_email', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'account_creation_failed'
            });
        }
    }
}

function onPersonalSectionSubmit(isPreValidation) {
    var isHidden, isValid, isChecked, isRequired;
    var submit = true;
    var firstErrorField;
    var fieldsInError = '';

    isValid = $('[id$=":password"]').data('isValid');
    if (!isPreValidation) {
        if (!isLegalPassword()) { //#from email & name
            submit = false;
            firstErrorField = (!firstErrorField ? 'password_error' : firstErrorField);
            fieldsInError += 'password;';
        } else if (!isValid) { //respects all other rules
            onPasswordChange();
            if (!$('[id$=":password"]').data('isValid')) {
                submit = false;
                firstErrorField = (!firstErrorField ? 'password_error' : firstErrorField);
                fieldsInError += 'password;';
            }
        }
    }

    if ($('[id$=":title"]').length > 0) {
        isHidden = parseBoolean(settings.fields.title.isHidden);
        isRequired = parseBoolean(settings.fields.title.isRequired);
        isNotEmpty = Boolean($('[id$=":title"]').val());
        isValid = $('[id$=":title"]').val() != null;
        if (!isHidden && (!isPreValidation && (isRequired || isNotEmpty) && !isValid)) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'title_error' : firstErrorField);
            fieldsInError += 'title;';
            onTitleChange();
        }
    }

    if ($('[id$=":firstname"]').length > 0) {
        isHidden = parseBoolean(settings.fields.firstname.isHidden);
        isRequired = parseBoolean(settings.fields.firstname.isRequired);
        isNotEmpty = Boolean($('[id$=":firstname"]').val());
        isValid = $('[id$=":firstname"]').data('isValid');
        if (!isHidden &&
            ((!isPreValidation && (isRequired || isNotEmpty)) || (isPreValidation && isNotEmpty)) &&
            !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'firstname_error' : firstErrorField);
            fieldsInError += 'firstname;';
            onFirstnameChange();
        }
    }

    if ($('[id$=":lastname"]').length > 0) {
        isHidden = parseBoolean(settings.fields.lastname.isHidden);
        isRequired = parseBoolean(settings.fields.lastname.isRequired);
        isNotEmpty = Boolean($('[id$=":lastname"]').val());
        isValid = $('[id$=":lastname"]').data('isValid');
        if (!isHidden &&
            ((!isPreValidation && (isRequired || isNotEmpty)) || (isPreValidation && isNotEmpty)) &&
            !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'lastname_error' : firstErrorField);
            fieldsInError += 'lastname;';
            onLastnameChange();
        }
    }

    if ($('[id$=":firstname2"]').length > 0) {
        isHidden = parseBoolean(settings.fields.firstname2.isHidden);
        isRequired = parseBoolean(settings.fields.firstname2.isRequired);
        isNotEmpty = Boolean($('[id$=":firstname2"]').val());
        isValid = $('[id$=":firstname2"]').data('isValid');
        if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'firstname2_error' : firstErrorField);
            fieldsInError += 'firstname2;';
            onFirstname2Change();
        }
    }

    if ($('[id$=":lastname2"]').length > 0) {
        isHidden = parseBoolean(settings.fields.lastname2.isHidden);
        isRequired = parseBoolean(settings.fields.lastname2.isRequired);
        isNotEmpty = Boolean($('[id$=":lastname2"]').val());
        isValid = $('[id$=":lastname2"]').data('isValid');
        if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'lastname2_error' : firstErrorField);
            fieldsInError += 'lastname2;';
            onLastname2Change();
        }
    }

    if ($('[id$="country"]').length > 0) {
        isHidden = parseBoolean(settings.fields.country.isHidden);
        isRequired = parseBoolean(settings.fields.country.isRequired);
        isNotEmpty = Boolean($('[id$="country"]').val());
        isValid = $('[id$="country"]').val() != null;
        if (!isHidden && (!isPreValidation && (isRequired || isNotEmpty) && !isValid)) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'country_error' : firstErrorField);
            fieldsInError += 'country;';
            onCountryChange();
        }
    }

    if ($('[id$=":email"]').length > 0) {
        isHidden = parseBoolean(settings.fields.email.isHidden);
        isRequired = parseBoolean(settings.fields.email.isRequired);
        isNotEmpty = Boolean($('[id$=":email"]').val());
        isValid = $('[id$=":email"]').data('isValid');
        if (!isHidden &&
            ((!isPreValidation && (isRequired || isNotEmpty)) || (isPreValidation && isNotEmpty)) &&
            !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'email_error' : firstErrorField);
            fieldsInError += 'email;';
            onEmailChange();
        }
    }

    if ($('[id$=":mobile_phone"]').length > 0) {
        isHidden = parseBoolean(settings.fields.mobile_phone.isHidden);
        isRequired = parseBoolean(settings.fields.mobile_phone.isRequired);
        isNotEmpty = Boolean($('[id$=":mobile_phone"]').val());
        isValid = $('[id$=":mobile_phone"]').data('isValid');
        if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'mobile_phone_error' : firstErrorField);
            fieldsInError += 'mobile_phone;';
            onMobilePhoneChange();
        }
    }

    isHidden = parseBoolean(settings.fields.newsletter_agreement.isHidden);
    isChecked = $('[id$=":newsletter_agreement"]').prop('checked');
    isRequired = parseBoolean(settings.fields.newsletter_agreement.isRequired);
    isValid = (isRequired && isChecked) || !isRequired;
    if (!isHidden && !isValid && !isPreValidation) {
        submit = false;
        firstErrorField = (!firstErrorField ? 'newsletter_agreement_error' : firstErrorField);
        fieldsInError += 'newsletter_agreement;';
        onNewsletterAgreementChange();
    }

    isHidden = parseBoolean(settings.fields.privacy_agreement.isHidden);
    isChecked = $('[id$=":privacy_agreement"]').prop('checked');
    isRequired = parseBoolean(settings.fields.privacy_agreement.isRequired);
    isValid = (isRequired && isChecked) || !isRequired;
    if (!isHidden && !isValid && !isPreValidation) {
        submit = false;
        firstErrorField = (!firstErrorField ? 'privacy_agreement_error' : firstErrorField);
        fieldsInError += 'privacy_agreement;';
        onPrivacyAgreementChange();
    }

    if (!isPreValidation) {
        if (submit) {
            enableButton('[id$=":personal_button"]', false);
            showLoader(true, '#personal-section-loader', 'personal_button');
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountSuccess',
                    'actionId': 'account_creation_succeeded',
                    'actionType': 'submit_button',
                    'pageRank': 'step_personal_infos', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_personal_infos_succeeded'
                });
            }
            next();
            if (settings.mode == settings.static.ACTIVATION && settings.sub_mode == settings.static.PARTIAL) {
                register();
            } else {
                onPersonalSubmit();
            }
        } else {
            $('#div_' + firstErrorField).focus();
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountFailure',
                    'actionId': 'account_creation_failed',
                    'actionType': 'submit_button',
                    'errorId': fieldsInError,
                    'pageRank': 'step_personal_infos', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_personal_infos_failed'
                });
            }
        }
    }
}

function afterSubmit(buttonId, loaderId) {
    showLoader(false, loaderId, buttonId, settings.labels.Next_Button);
    setup();
}

/******************************  MANAGE STYLE   **************************/

function setDefaultStyle() {
    // TITLE
    $('.id-page-form__select-title option:first-child').attr("disabled", "disabled").siblings().removeAttr('disabled');
    $('.id-page-form__select-title option:first-child').prop('selected', true);

    // COUNTRY
    if (settings.country_local == 'e1') {
        // DISABLE FIRST OPTION
        $('.id-page-form__select-country option:first-child').attr("disabled", "disabled").siblings().removeAttr('disabled');
        $('.id-page-form__select-country option:first-child').prop('selected', true);
    }
    if (settings.client.country) {
        $('[id$="country"]').val(settings.client.country);
        $('[id$="country"]').addClass('id-page-form__select_is-valid');
        $(".id-page-form__select-country option[value='" + settings.client.country + "']").prop('selected', true);
    }

    // DISABLE COPY PASTE FOR EMAIL CONFIRMATION
    $('[id$=":login_email_confirmation"]').on("cut copy paste", function (e) {
        e.preventDefault();
    });

    if (settings.country_local == 'cn') {
        // DISABLE CALLING CODE
        $('[id$=":login_calling_code"]').prop('disabled', 'disabled');
    }

    // DYNAMIC PLACEHOLDER ACCORDING THE COUNTRY CODE
    $('[id$=":mobile_phone"]').intlTelInput({
        autoHideDialCode: true,
        autoPlaceholder: true,
        defaultCountry: settings.client.country
    });
    $('[id$=":login_mobile_phone"]').intlTelInput({
        autoHideDialCode: true,
        autoPlaceholder: true,
        defaultCountry: settings.client.country
    });

    // FOR MAC STYLE
    if (navigator.userAgent.indexOf('Mac OS X') != -1) {
        $("body").addClass("mac");
    } else {
        $("body").addClass("pc");
    }

    //FOR LVAPP WEBVIEW
    if (settings.origin == 'lvapp') {
        $("body").addClass("lvapp");
    }

    // DISABLE DOUBLE CLICK EVENT
    $('[id$=":kisa_button"]').dblclick(function () {});
    $('[id$=":login_button"]').dblclick(function () {});
    $('[id$=":personal_button"]').dblclick(function () {});
    $('[id$=":verification_button"]').dblclick(function () {});
}

function handleSectionForm(isLoading) {
    if (isLoading || settings.current_step == settings.static.LOADING_STEP) {
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').hide();
        $('[id$=":loader_section"]').show();
    } else if (settings.current_step == settings.static.KISSA_STEP) {
        $('[id$=":kisa_section"]').show();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').hide();
        $('[id$=":loader_section"]').hide();
    } else if (settings.current_step == settings.static.LOGIN_STEP) {
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').show();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').hide();
        $('[id$=":loader_section"]').hide();
        setFocus();
    } else if (settings.current_step == settings.static.PERSONAL_STEP) {
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').show();
        $('[id$=":verification_section"]').hide();
        $('[id$=":loader_section"]').hide();
        setFocus();
    } else if (settings.current_step == settings.static.VERIFICATION_STEP) {
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').show();
        $('[id$=":loader_section"]').hide();
        setFocus();
    }
}

function setFocus() {
    //setFocus after navigation.
    if (settings.current_step == settings.static.LOGIN_STEP) {
        $('#h2_login').focus();
    } else if (settings.current_step == settings.static.PERSONAL_STEP) {
        $('#h2_personal').focus();
    } else if (settings.current_step == settings.static.VERIFICATION_STEP) {
        $('#h2_activation').focus();
    }
}

function handleExceptions({input, error, message, isValid, hasError}) {

    console.log(input)
    console.log(error)

    // Style Class for valid field
    var class_name = 'id-page-form__field_is-valid';
    if (input.hasClass('id-page-form__select')) {
        class_name = 'id-page-form__select_is-valid';
    } else if (input.parent().parent().hasClass('id-page-form__checkbox-field')) {
        class_name = '';
    }

    if (hasError) {
        if (error) {
            error.html(message ? message : '');
        }
        input.addClass('id-page-form__field_has-error');
        input.removeClass(class_name);
        input.data('isValid', false);
    } 
    else if (isValid) {
        if (error) {
            error.html('');
        }
        input.removeClass('id-page-form__field_has-error');
        input.addClass(class_name);
        input.data('isValid', true);
    }
    else {
        if (error) {
            error.html('');
        }
        input.removeClass('id-page-form__field_has-error');
        input.removeClass(class_name);
        input.data('isValid', false);
    }
}

function handleInputCodeExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":input_code"]',
        id_error: '[id$=":input_code_error"]',
        error: field.error
    });
}

function handlePasswordRule(id, isValid) {
    if (isValid) {
        $(id).addClass('id-page-form__password-rule_is-valid');
    } else {
        $(id).removeClass('id-page-form__password-rule_is-valid');
    }
}

function enableButton(id, enabled) {
    $(id).attr('disabled', !enabled);
}

function showLoader(show, idLoader, idButton, textButton) {
    if (show) {
        $('[id$=":' + idButton + '"]').val('');
        $(idLoader).show();
    } else {
        $(idLoader).hide();
        $('[id$=":' + idButton + '"]').val(textButton);
    }
}

function enableKisaButton() {
    var isValid = $('#kisa-agreement-1').prop('checked') &&
        $('#kisa-agreement-2').prop('checked') &&
        $('#kisa-agreement-3').prop('checked') &&
        $('#kisa-agreement-4').prop('checked');

    enableButton('[id$=":kisa_button"]', isValid);
}

function enableBackButton() {
    if (settings.current_step == settings.initial_step) {
        $('[id$=":back_button"]').hide();
    } else {
        $('[id$=":back_button"]').show();
    }
}

function openLoginModal(username, offset, hasError) {
    var modal = $('#login_modal');

    if (username) {
        $('[id$=":username"]').val(username);
        $('[id$=":username"]').trigger('change');
    }

    if (hasError) {
        showLoader(false, '#popover-login-loader', 'popover-login', settings.labels.Sign_In_Button);
        $('[id$=":password_login_error"]').html(settings.labels.Incorrect_Password);
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'event': 'logInFailure',
                'actionId': 'sign_in_failed',
                'actionType': 'submit_button',
                'actionPosition': 'existing_email',
                'pageRank': 'step_email', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'sign_in_failed'
            });
        }
    } else {
        $('[id$=":password_login_error"]').html('');
    }

    // SHOW   
    if ($('#login_modal').is(":visible") == false) {
        modal.css(offset);
        modal.show();
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'actionId': 'show_popin_existing_email',
                'actionPosition': 'existing_email',
                'pageRank': 'step_email', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'show_popin_existing_email'
            });
        }
    }
}

function onclickCloseLoginModal() {
    $('[id$=":login_email"]').val('');
    $('[id$=":login_email"]').removeClass('id-page-form__field_has-error');
    closeLoginModal();
}

function closeLoginModal() {
    $('[id$=":password_login_error"]').html('');
    if ($('#login_modal').is(":visible") == true) {
        $('#login_modal').hide();
        if (isTrackingAvailable()) {
            autoData.sendEvent({
                'actionId': 'close_popin_existing_email',
                'actionPosition': 'existing_email',
                'pageRank': 'step_email', 
                'categoryGa':'mylv', 
                'actionGa':'create_an_account_form_sf', 
                'labelGa':'close_popin_existing_email'
            });
        }
    }
}

function setDynamicKisaLabels() {
    setStepCounter();
}

function setDynamicLoginLabels() {
    setStepCounter();
}

function setDynamicPersonalLabels() {
    setStepCounter();
}

function setDynamicActivationLabels() {

    var label;

    if (parseBoolean(settings.fields.login_mobile_phone.isHidden)) {
        label = settings.labels.Email_Repairs_Section_Description;
        label = label.replace('xx@xx.com', settings.client.login_email);
    } else {
        label = settings.labels.Mobile_Repairs_Section_Description;
        label = label.replace('+XXX', settings.client.login_international_mobile_phone);
    }

    $('[id$=":section_description"]').html(label);
}

function setDynamicVerificationLabels() {
    if (settings.fields.login_mobile_phone.isHidden == 'false') {
        var label = settings.labels.SMS_Verification_Section_Description;

        if (settings.mode == settings.static.SOCIAL_REGISTRATION && settings.client.login_international_mobile_phone != null && settings.client.login_international_mobile_phone != '') {
            label = label.replace('XXX', settings.client.login_international_mobile_phone);
        } else {
            label = label.replace('XXX', $('[id$=":login_international_mobile_phone"]').val());
        }

        $('[id$=":verification_description"]').html(label);
    } else {
        var label = settings.labels.Email_Verification_Section_Description;

        if (settings.mode == settings.static.SOCIAL_REGISTRATION && settings.client.login_email != null && settings.client.login_email != '') {
            label = label.replace('xx@xx.com', settings.client.login_email);
        } else {
            label = label.replace('xx@xx.com', $('[id$=":login_email_confirmation"]').val());
        }

        $('[id$=":verification_description"]').html(label);
    }

    setStepCounter();
}

function setStepCounter() {
    $('.id-page-form__section-count').html('(' + (Number(settings.index_step) + 1) + '/' + settings.total_step + ')');
}

function displayStatus(success, isLimitReached) {
    //display status after send again verification code

    if (isLimitReached == 'true') {
        var label = settings.labels.Verification_Code_Limit;
        $('[id$=":resent_done_message"]').removeClass('resent_done');
        $('[id$=":resent_done_message"]').addClass('resent_error');
    } else if (success == 'true') {
        var label = settings.labels.Verification_Code_Resent;
        $('[id$=":resent_done_message"]').removeClass('resent_error');
        $('[id$=":resent_done_message"]').addClass('resent_done');

    } else {
        var label = settings.labels.Verification_Code_Failed;
        $('[id$=":resent_done_message"]').removeClass('resent_done');
        $('[id$=":resent_done_message"]').addClass('resent_error');
    }
    $('[id$=":resent_done_message"]').html(label);
    $('[id$=":resent_done_message"]').show();
}

/******************************  VARIABLES   **************************/

function setVariable(key, value) {
    settings[key] = value;
}

function setAttributes() {

    var myMap = new Map();

    $('.id-page-form__field-error').each(function (i) {

        var value = $(this).attr('id');
        var key = value.split(':').pop();
        myMap.set(key, value);
    });
    myMap.set('password_error', 'password_rules ' + myMap.get('password_error'));

    $('[aria-describedby]').each(function (i) {
        var field_name = $(this).attr('aria-describedby');
        $(this).attr('aria-describedby', myMap.get(field_name));
    });

    $('#body').each(function (i) {
        var field_name = $(this).attr('data-pv-page-rank');
        $(this).attr('data-pv-page-rank', 'step_' + (settings.initial_step == settings.static.LOGIN_STEP ? 'email' : 'options'));
    });
}

/******************************  TRACKING   **************************/

function isTrackingAvailable() {
    if (autoDataLoaded == true) { //autoData.instance != undefined
        return true;
    } else {
        return false;
    }
}

/******************************  VALIDATION   **************************/

function hasSixOrMoreCharacters(password) {
    var isValid = password.length >= 6;
    handlePasswordRule('#password-rule-1', isValid)

    return isValid;
}

function hasUpperCharacter(password) {
    var regex = new RegExp('(?=.*[A-Z])');

    var isValid = password.match(regex);
    handlePasswordRule('#password-rule-3', isValid)

    return isValid;
}

function hasLowerCharacter(password) {
    var regex = new RegExp('(?=.*[a-z])');

    var isValid = password.match(regex);
    handlePasswordRule('#password-rule-4', isValid)

    return isValid;
}

function hasNumberCharacter(password) {
    var regex = new RegExp('(?=.*[0-9])');

    var isValid = password.match(regex);
    handlePasswordRule('#password-rule-2', isValid)

    return isValid;
}

function isDifferentFromEmail(password) {

    password = password.toLowerCase();
    var email = $('[id$=":login_email"]').val() || settings.client.login_email;
    var international_mobile_phone = $('[id$=":login_international_mobile_phone"]').val() || settings.client.login_international_mobile_phone;
    if (Boolean(email)) {
        email = email.toLowerCase();
        var prefix = email.split("@")[0];
        var isValid = !password.includes(email) && !password.includes(prefix);
        return isValid;
    }

    if (Boolean(international_mobile_phone)) {
        var suffix = international_mobile_phone.split("+")[1];
        var isValid = !password.includes(international_mobile_phone) && !password.includes(suffix);
        return isValid;
    }

    return true;
}

function isDifferentFromName(password) {
    password = password.toLowerCase();
    var firstname = settings.client.firstname || $('[id$=":firstname"]').val().toLowerCase();
    var lastname = settings.client.lastname || $('[id$=":lastname"]').val().toLowerCase();

    if(Boolean(firstname) && Boolean(lastname)){
        var isValid = !password.includes(firstname) && !password.includes(lastname);
        handlePasswordRule('#password-rule-5', isValid);
    }

    return true;
}

function isKana(str) {
    return Array.prototype.every.call(str, isKanaChar);
}

function isKanji_Kana(str) {
    return Array.prototype.every.call(str, isKanjiKanaChar);
}

function isCyrillic(str) {
    return Array.prototype.every.call(str, isCyrillicChar);
}

function isEnglish(str) {
    return Array.prototype.every.call(str, isEnglishChar);
}

function isKanaChar(ch) {
    return (ch >= '\u30a0' && ch <= '\u30ff') ||
        (ch >= "\u31f0" && ch <= "\u31ff") ||
        keyIsSpecialChar(ch);
    //allow katakana kana
}

function isKanjiKanaChar(ch) {
    return (ch >= "\u3000" && ch <= "\u303F") ||
        (ch >= "\u3040" && ch <= "\u309f") ||
        (ch >= "\u30a0" && ch <= "\u30ff") ||
        (ch >= "\u31f0" && ch <= "\u31ff") ||
        (ch >= "\u3400" && ch <= "\u4dbf") ||
        (ch >= "\u4e00" && ch <= "\u9faf") ||
        keyIsSpecialChar(ch);
    //3000-303F: CJK Symbols and Punctuation
    //3040-309F:Hiragana, 30A0-30FF:Katakana, 31F0-31FF:Katakana Phonetic Extensions
    //3400-4DBF:CJK Unified Ideographs Extension A, 4E00-9FFF:CJK Unified Ideographs        
}

function isCyrillicChar(ch) {
    return (ch >= "\u0400" && ch <= "\u04ff") ||
        keyIsSpecialChar(ch);
}

function isEnglishChar(ch) {
    return (ch >= "\u0041" && ch <= "\u005A") ||
        (ch >= "\u0061" && ch <= "\u007A") ||
        (ch >= "\u00E0" && ch <= "\u00EF") ||
        (ch >= "\u00F2" && ch <= "\u00F6") ||
        (ch >= "\u00F9" && ch <= "\u00FC") ||
        keyIsSpecialChar(ch);
}

function keyIsSpecialChar(ch) {
    return ch == "\u002E" || ch == "\u002D" || ch == "\u0027" || ch == "\u0008" || ch == "\u0020";
}

function isMultiIdentifier(){
    return !parseBoolean(settings.fields.login_mobile_phone.isHidden) && !parseBoolean(settings.fields.login_email.isHidden);
}

function parseBoolean(val){
    return val === 'true';
}

function form (){
    form = {};

    form.steps = {};
    form.steps[settings.static.LOGIN_STEP] = {
        focus_id: null,
        elements: {
            button: $('[id$=":login_button"]'),
        },
        fields: [
            {
                name: 'email',
                elements: {
                    input: $('[id$=":login_email"]'),
                    error: $('[id$=":login_email_error"]'),
                },
                isRequired: parseBoolean(settings.fields.login_email.isRequired),
                isHidden: parseBoolean(settings.fields.login_email.isHidden),
                pattern(value){
                    var regex = new RegExp(patterns.email);
                    return value.match(regex);
                },
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    closeLoginModal();
                    this.isValid = true;
                    return true;
                },
                reject({value, message, modal, tracking}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    if(modal){
                        openLoginModal(value, this.elements.input.parent().offset());
                    }
                    else{
                        closeLoginModal();
                    }
                    
                    if (tracking && isTrackingAvailable()) {
                        autoData.sendEvent({
                            'actionId': 'email_not_valid',
                            'pageRank': 'step_email', 
                            'categoryGa':'mylv', 
                            'actionGa':'create_an_account_form_sf', 
                            'labelGa':'email_not_valid'
                        });
                    }
                    
                    this.isValid = false;
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({value, message: settings.labels.Required_Field, modal: false, tracking: false});
                    }

                    if (value){
                        // REGEX
                        if (!this.pattern(value)) {
                            return this.reject({value, message: settings.labels.Validation_Format_Email_Message, modal: false, tracking: true});
                        }

                        // DUPLICATA
                        var isValid = await remoteFunction('IDENTITY_Registration_CTRL.onLoginEmailChange', value);
                        if (settings.mode == settings.static.REGISTRATION || settings.mode == settings.static.ACTIVATION) {
                            if (!isValid) {
                                return this.reject({value, message: '', modal: true, tracking: false});
                            } else {
                                return this.resolve();
                            }
                        } else if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
                            if ((isValid && settings.sub_mode == settings.static.MATCHING) || (!isValid && settings.sub_mode == settings.static.FULL)) {
                                updateSubMode(isValid);
                            }

                            return this.resolve();
                        }
                    }

                    return this.reset();
                },
                events(){
                    this.elements.input.on("blur", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event)});
                }
            },
            {
                name: 'email_confirmation',
                elements: {
                    input: $('[id$=":login_email_confirmation"]'),
                    error: $('[id$=":login_email_confirmation_error"]'),
                    compared: $('[id$=":login_email"]'), 
                },
                isHidden: parseBoolean(settings.fields.login_email_confirmation.isHidden),
                isRequired: parseBoolean(settings.fields.login_email_confirmation.isRequired),
                pattern(value, compared){
                    var compared = this.elements.compared.val();
                    return !Boolean(compared) || (compared !== value);
                },
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message, tracking}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    if (tracking && isTrackingAvailable()) {
                        autoData.sendEvent({
                            'actionId': 'emails_dont_match',
                            'pageRank': 'step_email', 
                            'categoryGa':'mylv', 
                            'actionGa':'create_an_account_form_sf', 
                            'labelGa':'emails_dont_match'
                        });
                    }

                    this.isValid = false;
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field, tracking: false});
                    }

                    if(value){
                        // PATTERN
                        if (!this.pattern(value)) {
                            return this.reject({message: settings.labels.Email_Confirmation_Doesn_t_Match, tracking: true});
                        }

                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elements.input.on("keyup", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event)});
                }
            },
            {
                name: 'mobile_phone',
                isHidden: parseBoolean(settings.fields.login_mobile_phone.isHidden),
                isRequired: parseBoolean(settings.fields.login_mobile_phone.isRequired),
                elements: {
                    input: $('[id$=":login_mobile_phone"]'),
                    input_code: $('[id$=":login_calling_code"]'),
                    error: $('[id$=":login_mobile_phone_error"]'),
                    hidden: $('[id$=":login_international_mobile_phone"]'),
                },
                pattern(phone, code){
                    return !intlTelInputUtils.isValidNumber(phone, code) || intlTelInputUtils.getNumberType(phone, code) != 1;
                },
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    closeLoginModal();
                    this.isValid = true;
                    return true;
                },
                reject({value, message, modal}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    if(modal){
                        openLoginModal(value, this.elements.input.parent().offset());
                    }
                    else{
                        closeLoginModal();
                    }

                    this.isValid = false;
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var mobile_phone = this.elements.input.val();
                    var calling_code = this.elements.input_code.val();
                    var login_international_mobile_phone = intlTelInputUtils.formatNumber(mobile_phone, calling_code);

                    this.elements.input.intlTelInput("setCountry", calling_code.toLowerCase());

                    // REQUIRED 
                    if (isRequired && (!mobile_phone || !calling_code)) {
                        return this.reject({value, message: settings.labels.Required_Field, modal: false});
                    }

                    if (mobile_phone) {
                        // REGEX
                        if (this.pattern(mobile_phone, calling_code)) {
                            return this.reject({value, message: settings.labels.Validation_Format_Mobile_Phone_Message, modal: false});
                        }

                        this.elements.hidden.val(login_international_mobile_phone);

                        // DUPLICATA
                        var isValid = await remoteFunction('IDENTITY_Registration_CTRL.onLoginMobilePhoneChange', login_international_mobile_phone);
                        if (settings.mode == settings.static.REGISTRATION || settings.mode == settings.static.ACTIVATION) {
                            if (!isValid) {
                                return this.reject({value: login_international_mobile_phone, message: '', modal: true});
                            } else {
                                return this.resolve();
                            }
                        } 
                        else if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
                            if ((isValid && settings.sub_mode == settings.static.MATCHING) || (!isValid && settings.sub_mode == settings.static.FULL)) {
                                updateSubMode(isValid);
                            }

                            return this.resolve();
                        }
                    }
                    
                    return this.reset();
                },
                events(){
                    this.elements.input.on("blur", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'numeric')});

                    this.elements.input_code.on("blur", () => this.validator());
                }
            }
        ],
        resolve: () => {
            enableButton('[id$=":login_button"]', false);
            showLoader(true, '#login-section-loader', 'login_button');
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountSuccess',
                    'actionId': 'account_creation_succeeded',
                    'actionType': 'submit_button',
                    'pageRank': 'step_email', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_succeeded'
                });
            }
            onLoginSubmit();
            next();
        },
        reject: () => {
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountFailure',
                    'actionId': 'account_creation_failed',
                    'actionType': 'submit_button',
                    'pageRank': 'step_email', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_failed'
                });
            }
        },
        events(){
            this.elements.button.on("click", () => form.validate());
        }
    };

    form.steps[settings.static.PERSONAL_STEP] = {
        focus_id: null,
        elements: {
            button: $('[id$=":personal_button"]'),
        },
        fields: [
            {
                name: 'password',
                elements: {
                    input: $('[id$=":password"]'),
                    error: $('[id$=":password_error"]'),
                    button: $('button#password_btn'),
                    desc: $('#password_rules'),
                    label: $('#idPpasswordLabel'),
                },
                isRequired: true,
                isHidden: false,
                resolve(){
                    this.isValid = true;

                    handleExceptions({
                        isValid: true,
                    });
                    
                    return this.isValid;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    
                    this.isValid = false;
                    
                    return this.isValid;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                pattern(){
                    var value = this.elements.input.val();

                    var rule1 = hasSixOrMoreCharacters(value);
                    var rule2 = hasNumberCharacter(value);
                    var rule3 = hasUpperCharacter(value);
                    var rule4 = hasLowerCharacter(value);

                    return rule1 && rule2 && rule3 && rule4;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // hide password rules
                    this.elements.desc.hide();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){
                        // REGEX
                        if (!this.pattern()) {
                            return this.reject({message: settings.labels.Password_Error});
                        }

                        // DUPLICATA
                        var isValid = isDifferentFromEmail(value) && isDifferentFromName(value);
                        if (!isValid) {
                            return this.reject({message: settings.labels.Password_UsernameError});
                        }

                        return this.resolve();
                    }

                    return this.reset();
                },
                focus(){
                    this.elements.desc.show();
                    if (/Mobi|Android/i.test(navigator.userAgent)) {
                        $('html, body').animate({
                            scrollTop: this.elements.label.offset().top
                        }, 800);
                    }
                },
                blur(){
                    if ($('button#password_btn:hover').length == 0) {
                        this.elements.desc.hide();
                    }
                },
                click(isSetup){
                    if (!isSetup) {
                        this.focus();
                        if (this.elements.input.attr('type') == 'text') {
                            this.elements.input.attr('type', 'password');
                            if (isTrackingAvailable()) {
                                autoData.sendEvent({
                                    'actionId': 'hide_password',
                                    'pageRank': 'step_personal_infos', 
                                    'categoryGa':'mylv', 
                                    'actionGa':'create_an_account_form_sf', 
                                    'labelGa':'hide_password'
                                });
                            }
                        } else {
                            this.elements.input.attr('type', 'text');
                            if (isTrackingAvailable()) {
                                autoData.sendEvent({
                                    'actionId': 'show_password',
                                    'pageRank': 'step_personal_infos', 
                                    'categoryGa':'mylv', 
                                    'actionGa':'create_an_account_form_sf', 
                                    'labelGa':'show_password'
                                });
                            }
                        }
                    } else {
                        this.elements.input.attr('type', 'password');
                    }
                },
                events(){
                    this.elements.input.on("focus", () => this.focus());
                    this.elements.input.on("change", () => this.validator());
                    this.elements.input.on("blur", () => this.blur());
                    this.elements.input.on("keyup", (event) => {return this.pattern()});
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event)});
                    
                    this.elements.button.on("click", () => this.click());
                    this.elements.button.on("blur", () => this.blur());
                }
            },
            {
                name: 'title',
                elements: {
                    input: $('[id$=":title"]'),
                    error: $('[id$=":title_error"]'),
                },
                isHidden: parseBoolean(settings.fields.title.isHidden),
                isRequired: parseBoolean(settings.fields.title.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // add select prop
                    $(".id-page-form__select-title option[value='" + value + "']").prop('selected', true);

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){
                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elem.on("blur", () => this.validator());
                }
            },
            {
                name: 'firstname',
                elements: {
                    input: $('[id$=":firstname"]'),
                    error: $('[id$=":firstname_error"]'),
                },
                isHidden: parseBoolean(settings.fields.firstname.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.firstname == ''),
                isRequired: parseBoolean(settings.fields.firstname.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){
                        // JAPANESE CHARS
                        if (settings.country_local == "jp" && !isKanji_Kana(value) && !isEnglish(value)) {
                            return this.reject({message: settings.labels.Kanji_Error_Validation});
                        }

                        // RUSSIAN CHARS
                        if (settings.country_local == "ru" && !isCyrillic(value) && !isEnglish(value)) {
                            return this.reject({message: settings.labels.Cyrillic_Error_Validation});
                        }

                        return this.resolve();
                    }

                    return this.reset();  
                },
                events(){
                    this.elem.on("change", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'alpha')});
                }
            },
            {
                name: 'lastname',
                elements: {
                    input: $('[id$=":lastname"]'),
                    error: $('[id$=":lastname_error"]'),
                },
                isHidden: parseBoolean(settings.fields.lastname.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.lastname == ''),
                isRequired: parseBoolean(settings.fields.lastname.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    // JAPANESE CHARS
                    if (settings.country_local == "jp" && !isKanji_Kana(value) && !isEnglish(value)) {
                        return this.reject({message: settings.labels.Kanji_Error_Validation});
                    }

                    // RUSSIAN CHARS
                    if (settings.country_local == "ru" && !isCyrillic(value) && !isEnglish(value)) {
                        return this.reject({message: settings.labels.Cyrillic_Error_Validation});
                    }

                    return this.resolve();
                },
                events(){
                    this.elem.on("change", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'alpha')});
                }
            },
            {
                name: 'lastname2',
                elements: {
                    input: $('[id$=":lastname2"]'),
                    error: $('[id$=":lastname2_error"]'),
                },
                isHidden: parseBoolean(settings.fields.lastname2.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.lastname2 == ''),
                isRequired: parseBoolean(settings.fields.lastname2.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){

                        // KANA CHARS
                        if (!isKana(value) && !isEnglish(value)) {
                            return this.reject({message: settings.labels.Kana_Error_Validation});
                        }
                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elem.on("change", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'kana')});
                }
            },
            {
                name: 'firstname2',
                elements: {
                    input: $('[id$=":firstname2"]'),
                    error: $('[id$=":firstname2_error"]'),
                },
                isHidden: parseBoolean(settings.fields.firstname2.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.firstname2 == ''),
                isRequired: parseBoolean(settings.fields.firstname2.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){

                        // KANA CHARS
                        if (!isKana(value) && !isEnglish(value)) {
                            return this.reject({message: settings.labels.Kana_Error_Validation});
                        }
                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elem.on("change", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'kana')});
                }
            },
            {
                name: 'email',
                elements: {
                    input: $('[id$=":email"]'),
                    error: $('[id$=":email_error"]'),
                },
                isRequired: parseBoolean(settings.fields.email.isRequired),
                isHidden: parseBoolean(settings.fields.email.isHidden),
                pattern(value){
                    var regex = new RegExp(patterns.email);
                    return value.match(regex);
                },
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    closeLoginModal();
                    this.isValid = true;
                    return true;
                },
                reject({value, message, modal, tracking}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    if(modal){
                        openLoginModal(value, this.elements.input.parent().offset());
                    }
                    else{
                        closeLoginModal();
                    }
                    
                    if (tracking && isTrackingAvailable()) {
                        autoData.sendEvent({
                            'actionId': 'email_not_valid',
                            'pageRank': 'step_email', 
                            'categoryGa':'mylv', 
                            'actionGa':'create_an_account_form_sf', 
                            'labelGa':'email_not_valid'
                        });
                    }
                    
                    this.isValid = false;
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({value, message: settings.labels.Required_Field, modal: false, tracking: false});
                    }
                    
                    if(value){
                        // REGEX
                        if (!this.pattern(value)) {
                            return this.reject({value, message: settings.labels.Validation_Format_Email_Message, modal: false, tracking: true});
                        }

                        // DUPLICATA
                        var isValid = await remoteFunction('IDENTITY_Registration_CTRL.onLoginEmailChange', value);
                        if (!isValid) {
                            return this.reject({value, message: '', modal: true, tracking: false});
                        } else {
                            return this.resolve();
                        }
                    }

                    return this.reset();
                },
                events(){
                    this.elements.input.on("blur", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event)});
                }
            },
            {
                name: 'country',
                elements: {
                    input: $('[id$=":country"]'),
                    error: $('[id$=":country_error"]'),
                    hidden: $('[id$="client_country"]'),
                },
                isHidden: parseBoolean(settings.fields.country.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.country == ''),
                isRequired: parseBoolean(settings.fields.country.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var value = this.elements.input.val();

                    // DEPENDENCIES
                    this.elements.hidden[0].value = value;
                    // UPDATE THE CALLING CODE ACCORDING THE COUNTRY ONLY IF THE MOVBILE PHONE IS NOT FILLED IN
                    var international_mobile_phone = $('[id$=":international_mobile_phone"]').val();
                    if (value && !international_mobile_phone) {
                        $('[id$=":calling_code"]').val(value);
                        $('[id$=":mobile_phone"]').intlTelInput("setCountry", value.toLowerCase());
                    }

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }
                   
                    if(value){
                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elem.on("blur", () => this.validator());
                }
            },
            {
                name: 'newsletter_agreement',
                elements: {
                    input: $('[id$=":newsletter_agreement"]'),
                    error: $('[id$=":newsletter_agreement_error"]'),
                },
                isHidden: parseBoolean(settings.fields.newsletter_agreement.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.newsletter_agreement == ''),
                isRequired: parseBoolean(settings.fields.newsletter_agreement.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator(event) {
                    var value = this.elements.input.prop('checked');

                    if (event && isTrackingAvailable()) {
                        autoData.sendEvent({
                            'contentId': 'newsletter_subscription',
                            'actionId': (value ? 'tick_checkbox' : 'untick_checkbox'),
                            'actionType': 'newsletter_subscription', 
                            'categoryGa':'mylv', 
                            'actionGa':'create_an_account', 
                            'labelGa':(value ? 'news_tick_checkbox' : 'news_untick_checkbox')
                        });
                    }

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    if(value){
                        return this.resolve();
                    }

                    return this.reset();
                },
                events(){
                    this.elem.on("click", (event) => this.validator(event));
                    this.elements.input.on("keypress", (event) => {return handleCheckboxEnter(event, this.name)});
                }
            },
            {
                name: 'privacy_agreement',
                elements: {
                    input: $('[id$=":privacy_agreement"]'),
                    error: $('[id$=":privacy_agreement_error"]'),
                },
                isHidden: parseBoolean(settings.fields.privacy_agreement.isHidden) || (settings.mode == 'ACTIVATION' && settings.client.privacy_agreement == ''),
                isRequired: parseBoolean(settings.fields.privacy_agreement.isRequired),
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    
                    return false;
                },
                async validator() {
                    var value = this.elements.input.prop('checked');

                    // REQUIRED 
                    if (this.isRequired && !value) {
                        return this.reject({message: settings.labels.Required_Field});
                    }

                    return this.resolve();
                },
                events(){
                    this.elem.on("click", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return handleCheckboxEnter(event, this.name)});
                }
            },
            {
                name: 'mobile_phone',
                isHidden: parseBoolean(settings.fields.mobile_phone.isHidden),
                isRequired: parseBoolean(settings.fields.mobile_phone.isRequired),
                elements: {
                    input: $('[id$=":mobile_phone"]'),
                    input_code: $('[id$=":calling_code"]'),
                    error: $('[id$=":mobile_phone_error"]'),
                    hidden: $('[id$=":international_mobile_phone"]'),
                },
                pattern(phone, code){
                    return !intlTelInputUtils.isValidNumber(phone, code) || intlTelInputUtils.getNumberType(phone, code) != 1;
                },
                resolve(){
                    handleExceptions({
                        isValid: true,
                    });
                    this.isValid = true;
                    return true;
                },
                reject({message}){
                    handleExceptions({
                        isValid: false,
                        hasError: true,
                        error: message,
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });

                    this.isValid = false;
                    return false;
                },
                reset(){
                    handleExceptions({
                        id_field: this.elements.input,
                        id_error: this.elements.error,
                    });
                    return true;
                },
                async validator() {
                    var mobile_phone = this.elements.input.val();
                    var calling_code = this.elements.input_code.val();
                    var international_mobile_phone = intlTelInputUtils.formatNumber(mobile_phone, calling_code);

                    this.elements.input.intlTelInput("setCountry", calling_code.toLowerCase());

                    // REQUIRED 
                    if (isRequired && (!mobile_phone || !calling_code)) {
                        return this.reject({value, message: settings.labels.Required_Field, modal: false});
                    }

                    if (mobile_phone) {
                        // REGEX
                        if (this.pattern(mobile_phone, calling_code)) {
                            return this.reject({value, message: settings.labels.Validation_Format_Mobile_Phone_Message, modal: false});
                        }

                        this.elements.hidden.val(international_mobile_phone);

                        return this.resolve();
                    }
                    
                    return this.reset();
                },
                events(){
                    this.elements.input.on("change", () => this.validator());
                    this.elements.input.on("keypress", (event) => {return onHandleKeyPress(event, 'numeric')});

                    this.elements.input_code.on("blur", () => this.validator());
                }
            }
        ],
        resolve: () => {
            enableButton('[id$=":personal_button"]', false);
            showLoader(true, '#personal-section-loader', 'personal_button');
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountSuccess',
                    'actionId': 'account_creation_succeeded',
                    'actionType': 'submit_button',
                    'pageRank': 'step_personal_infos', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_personal_infos_succeeded'
                });
            }
            next();
            if (settings.mode == settings.static.ACTIVATION && settings.sub_mode == settings.static.PARTIAL) {
                register();
            } else {
                onPersonalSubmit();
            }
        },
        reject: () => {
            // focus on the first error occurrence
            this.focus_id.focus();

            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'event': 'createAccountFailure',
                    'actionId': 'account_creation_failed',
                    'actionType': 'submit_button',
                    'errorId': fieldsInError,
                    'pageRank': 'step_personal_infos', 
                    'categoryGa':'mylv', 
                    'actionGa':'create_an_account_form_sf', 
                    'labelGa':'account_creation_personal_infos_failed'
                });
            }
        },
        events(){
            this.elements.button.on("click", () => form.validate());
        }
    };

    form.init = () => {

        // remove hidden fields
        form.steps[settings.current_step].fields = form.steps[settings.current_step].fields.filter((field) => !field.isHidden);

        // add event handler for submit button
        Object.values(form.steps).forEach(step => {
            step.events();
        });

        // add event handler for fields 
        form.steps[settings.current_step].fields.forEach(field => {
            field.events();
        });
    };
    
    form.validate = async () => {
        
        var validators = [];
        form.steps[settings.current_step].fields.forEach(field => {
            if(field.isValid){
                validators.push(() => true);
            }
            else{   
                validators.push(field.validator());
            }
        });

        var result = await Promise.all(validators);
        var isValidStep = result.reduce((isValid, next, index) => {
            if(!next && !form.steps[settings.current_step].focus_id){
                form.steps[settings.current_step].focus_id = form.steps[settings.current_step].fields[index].element.error;
            }
            return isValid && next;
        }, true);

        if (isValidStep) {
            form.steps[settings.current_step].resolve();
        } else {
            form.steps[settings.current_step].reject();
        }
    }
}

function remoteFunction(...args){
    var myPromise = new Promise(function(resolve, reject){
        Visualforce.remoting.Manager.invokeAction(
            ...args,
            function(result, event) {
                if (event.status)
                    resolve(result);
                else
                    reject(event);
            },
            { 
                buffer: false, 
                escape: false, 
                timeout: 120000 
            }
        );
    });
    return myPromise;
}

var patterns = {
    email: '^[a-zA-Z0-9!#$%&\'\/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&\'*+\/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-z0-9-]*[a-zA-Z0-9])?\\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
};
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
        enableButton('[id$=":personal_button2"]', true);
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

        // Captcha style
        if(settings.country_local == 'cn'){
            $('[id$="loading_animation"]').css('width', '100%');
            $('[id$="loading_animation"]').children().css('width', '100%');
        }
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
    
    if(isTrackingAvailable()) {
        autoData.sendEvent({'actionId':'sign_in_intention', 
                            'actionType':'submit_button', 
                            'actionPosition':'existing_email', 
                            'pageRank':'step_email', 
                            'categoryGa':'mylv', 
                            'actionGa':'create_an_account_form_sf', 
                            'labelGa':'sign_in_intention'});
    }
    
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

function needNavigationToLVAPP(current_url, origin, redirectToLvApp) {
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
        redirectToLvApp == 'true' && 
        origin != 'lvapp'
    );
}

function navigateToLVAPP(current_url, new_url) {
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
            if(settings.isTrustOrigin == 'false'){
                settings.flow = [settings.static.PERSONAL_STEP, settings.static.VERIFICATION_STEP];
            }
            else{
                settings.flow = [settings.static.PERSONAL_STEP];
            }
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
        }else if (settings.sub_mode == settings.static.AUTO) {
            //settings.flow = [settings.static.LOADING_STEP];
            settings.flow = [settings.static.AUTO_REG_STEP];
        }
    }

    if (settings.country_local == 'kr' && settings.sub_mode != settings.static.AUTO) {
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

function onKisaAgreementExpand(index, current_index , lvConnectOrigine = false) {
    console.log('voici ', index ,'curent ', current_index)
    if(lvConnectOrigine){
        return lvConnectUpdateExpandedIndex(index)
    }
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
/**
 * -------------   fct for lv connect  --------------------
 */
let myIndex;

function lvConnectUpdateExpandedIndex(index){
    if (isTrackingAvailable()) {
        autoData.sendEvent({
            'actionId': 'options_details_popin',
            'pageRank': 'step_options',
            'categoryGa':'mylv',
            'actionGa':'create_an_account_form_sf',
            'labelGa':'options_details_popin'
        });
    }
    myIndex = index;
    $('.identity-reg-kisa_details-pop-up-container').addClass('isShow') 
    updateExpandedIndex(index);
}

function toogleKisaAgreementExpand(){
    $('.identity-reg-kisa_details-pop-up-container').toggleClass('isShow') 
    updateExpandedIndex(0);
}

function kisaAgreementPopUp(){
    let id = `#kisa-agreement-${myIndex}`
    $( id ).prop( "checked", true );
    toogleKisaAgreementExpand()
}

// ------------ end fct lvconnect ------------------

function onAllKisaAgreementsChange() {
    var trigger = $('#kisa-agreement-all').prop('checked');

    [1, 2, 3, 4, 5].forEach(function (i) {
        $('#kisa-agreement-' + i).prop('checked', trigger)
    });

    enableKisaButton();
}

function onKisaAgreementChange() {
    enableKisaButton();
}

function onLoginEmailChange() {
    var email = $('[id$=":login_email"]').val();
    var isRequired = settings.fields.login_email.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !email) {
        handleLoginEmailExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        closeLoginModal();
        return;
    } else {
        // REGEX
        var regex = new RegExp('^[a-zA-Z0-9!#$%&\'\/=?^_`{|}~-]+(?:[a-zA-Z0-9!#$.%+&\'*\/=?^_`{|}~-]+)*@[a-zA-Z0-9.-]{2,}\\\.[a-zA-Z]{2,}$');

        if (!email.match(regex)) {
            handleLoginEmailExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Email_Message,
            });
            closeLoginModal();
            if (isTrackingAvailable()) {
                autoData.sendEvent({
                    'actionId': 'email_not_valid',
                    'pageRank': 'step_email',
                    'categoryGa':'mylv',
                    'actionGa':'create_an_account_form_sf',
                    'labelGa':'email_not_valid'
                });
            }
            return;
        } else {
            // DUPLICATA
            settings.remoting = true;
            Visualforce.remoting.Manager.invokeAction(
                'IDENTITY_Registration_CTRL.onLoginEmailChange',
                email,
                function (isValid) {

                    if (settings.mode == settings.static.REGISTRATION || settings.mode == settings.static.ACTIVATION) {
                        handleLoginEmailExceptions({
                            isValid: isValid,
                            hasError: !isValid,
                        });

                        settings.remoting = false;

                        if (!isValid) {
                            openLoginModal(email, $('[id$=":login_email"]').parent().offset());
                        } else {
                            closeLoginModal();
                        }
                    } else if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
                        handleLoginEmailExceptions({
                            isValid: true,
                        });

                        if ((isValid && settings.sub_mode == settings.static.MATCHING) || (!isValid && settings.sub_mode == settings.static.FULL)) {
                            updateSubMode(isValid);
                            // SET remoting to false oncomplete
                        } else {
                            settings.remoting = false;
                        }
                    }
                }
            );
        }
    }

}

function onLoginEmailConfirmationChange(event, isTriggeredManually) {
    var email_confirmation = $('[id$=":login_email_confirmation"]').val();
    var isRequired = settings.fields.login_email_confirmation.isRequired == 'true';
    var error;

    // REQUIRED 
    if ((isTriggeredManually && email_confirmation) || (!isTriggeredManually && event && event.keyCode != 9) || (!isTriggeredManually && !event)) {
        if (isRequired && !email_confirmation) {
            handleLoginEmailConfirmationExceptions({
                hasError: true,
                error: settings.labels.Required_Field,
            });
            return;
        }
        // MATCH
        else {
            var email = $('[id$=":login_email"]').val();
            if (email != email_confirmation) {
                handleLoginEmailConfirmationExceptions({
                    hasError: true,
                    error: settings.labels.Email_Confirmation_Doesn_t_Match,
                });
                //tracking. not on keyup event (on submit, function is called without event) 
                if ((event == null) && (isTrackingAvailable())) {
                    autoData.sendEvent({
                        'actionId': 'emails_dont_match',
                        'pageRank': 'step_email',
                        'categoryGa':'mylv',
                        'actionGa':'create_an_account_form_sf',
                        'labelGa':'emails_dont_match'
                    });
                }
                return;
            }
        }

        handleLoginEmailConfirmationExceptions({
            isValid: true,
        });
    }
}

function onLoginCallingCodeChange() {
    var mobile_phone = $('[id$=":login_mobile_phone"]').val();
    var calling_code = $('[id$=":login_calling_code"]').val();

    setMobilePlaceholder('[id$=":login_mobile_phone"]', calling_code);

    if (mobile_phone) {
        onLoginMobilePhoneChange();
        return;
    }
    //else, do nothing. user has only changed code and did not entered number yet.
    return;
}

function onLoginMobilePhoneChange() {
    var mobile_phone = $('[id$=":login_mobile_phone"]').val();
    var calling_code = $('[id$=":login_calling_code"]').val();
    var login_international_mobile_phone = intlTelInputUtils.formatNumber(mobile_phone, calling_code);

    var isRequired = settings.fields.login_mobile_phone.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && (!mobile_phone || !calling_code)) {
        handleLoginMobilePhoneExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }
    // REGEX
    else if (mobile_phone) {
        if (!intlTelInputUtils.isValidNumber(mobile_phone, calling_code) || intlTelInputUtils.getNumberType(mobile_phone, calling_code) != 1) {
            handleLoginMobilePhoneExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Mobile_Phone_Message,
            });
            return;
        } else {
            // DUPLICATA
            settings.remoting = true;
            Visualforce.remoting.Manager.invokeAction(
                'IDENTITY_Registration_CTRL.onLoginMobilePhoneChange',
                login_international_mobile_phone,
                function (isValid) {

                    $('[id$=":login_international_mobile_phone"]').val(login_international_mobile_phone);

                    if (settings.mode == settings.static.REGISTRATION || settings.mode == settings.static.ACTIVATION) {
                        handleLoginMobilePhoneExceptions({
                            isValid: isValid,
                            hasError: !isValid,
                        });

                        settings.remoting = false;

                        if (!isValid) {
                            openLoginModal(login_international_mobile_phone, $('[id$=":id-page-form__mobile-phone"]').parent().offset());
                        } else {
                            closeLoginModal();
                        }
                    } else if (settings.mode == settings.static.SOCIAL_REGISTRATION) {
                        handleLoginMobilePhoneExceptions({
                            isValid: true,
                        });

                        if ((isValid && settings.sub_mode == settings.static.MATCHING) || (!isValid && settings.sub_mode == settings.static.FULL)) {
                            updateSubMode(isValid);
                            // SET remoting to false oncomplete
                        } else {
                            settings.remoting = false;
                        }
                    }
                }
            );
            return;
        }
    }

    setMobilePlaceholder('[id$=":login_mobile_phone"]', calling_code);
    handleLoginMobilePhoneExceptions({});
}

function onPasswordFocus() {
    $('#password_rules').show();
    if (/Mobi|Android/i.test(navigator.userAgent)) {
        $('html, body').animate({
            scrollTop: $('#idPpasswordLabel').offset().top
        }, 800);
    }
}

function onPasswordBlur() {
    if ($('button#password_btn:hover').length == 0) {
        $('#password_rules').hide();
    }
}

function onPasswordKeyup() {
    var password = $('[id$=":password"]').val();

    var rule1 = hasEightOrMoreCharacters(password);
    var rule2 = hasNumberCharacter(password);
    var rule3 = hasUpperCharacter(password);
    var rule4 = hasLowerCharacter(password);
    var rule6 = hasSpecialCharacter(password);

    return rule1 && rule2 && rule3 && rule4 && rule6;
}

function onPasswordChange() {
    var password = $('[id$=":password"]').val();
    $('[id$=":password_rules"]').hide();

    // REQUIRED
    if (isNullOrWhiteSpace(password)) {
        handlePasswordExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }
    // RULES
    var isValid = onPasswordKeyup();

    if (!isValid) {
        handlePasswordExceptions({
            isValid: isValid,
            hasError: !isValid,
            error: settings.labels.Password_Error
        });
    } else {
        isValid = isLegalPassword();
        handlePasswordExceptions({
            isValid: isValid,
            hasError: !isValid,
            error: settings.labels.Password_UsernameError
        });
    }
}

function isLegalPassword() {
    var password = $('[id$=":password"]').val();
    if (isNullOrWhiteSpace(password)) {
        return true; //this problem will be tracked in another place
    }

    var isValid = true;

    if(settings.mode != settings.static.ACTIVATION){
        isValid = isDifferentFromEmail(password) && isDifferentFromName(password);
        if (!isValid) {
            handlePasswordExceptions({
                isValid: isValid,
                hasError: !isValid,
                error: settings.labels.Password_UsernameError
            });
        }
    }
    else{
        var activation_client_encrypted = $('[id$=":activation_client_encrypted"]').val();
        var firstname = $('[id$=":firstname"]').val()?? "";
        var lastname = $('[id$=":lastname"]').val()?? "";
        var email = $('[id$=":login_email"]').val()?? "";
        var mobilephone = $('[id$=":login_international_mobile_phone"]').val()?? "";
        isValid = checkValidityPasswordFromBackend(password,activation_client_encrypted,firstname,lastname,email,mobilephone)
        
    }
    return  isValid; 
}

async function checkValidityPasswordFromBackend(password,activation_client_encrypted,firstname,lastname,email,mobilephone){
    var invalidPassword = await remoteFunction('IDENTITY_Registration_CTRL.onCheckValidationPasswordWhenActivation', password,activation_client_encrypted,firstname,lastname,email,mobilephone);
    isValid = !invalidPassword;
    if (!isValid) {
        handlePasswordExceptions({
            isValid: isValid,
            hasError: !isValid,
            error: settings.labels.Password_UsernameError
        });
        return false;
    } else {
        return true;
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

function onDisplayPasswordClick(isSetup) {
    if (!isSetup) {
        onPasswordFocus();
        hidePassword('password');
    } else {
        $('[id$=":password"]').attr('type', 'password');
    }
}

function hidePassword(id) {
    if ($('[id$=":' + id + '"]').attr('type') == 'text') {
        $('[id$=":' + id + '"]').attr('type', 'password');
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
        $('[id$=":' + id + '"]').attr('type', 'text');
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
}

function onTitleChange() {
    var title = $('[id$=":title"]').val();
    $(".id-page-form__select-title option[value='" + title + "']").prop('selected', true);
    var isRequired = settings.fields.title.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !title) {
        handleTitleExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }

    handleTitleExceptions({
        isValid: true,
    });
}

function onFirstnameChange() {
    var firstname = $('[id$=":firstname"]').val();
    var isRequired = settings.fields.firstname.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && isNullOrWhiteSpace(firstname)) {
        handleFirstnameExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    }
    // Japanase Characters
    else if (settings.country_local == "jp" && !isKanji_Kana(firstname) && !isEnglish(firstname)) {
        handleFirstnameExceptions({
            hasError: true,
            error: settings.labels.Kanji_Error_Validation
        });
        return;
    }
    // Russian Characters
    else if (settings.country_local == "ru" && !isCyrillic(firstname) && !isEnglish(firstname)) {
        handleFirstnameExceptions({
            hasError: true,
            error: settings.labels.Cyrillic_Error_Validation
        });
        return;
    }

    handleFirstnameExceptions({
        isValid: true,
    });
}

function onFirstname2Change() {
    var firstname_kana = $('[id$=":firstname2"]').val();
    var isRequired = settings.fields.firstname2.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && isNullOrWhiteSpace(firstname_kana)) {
        handleFirstname2Exceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    } else if (!isKana(firstname_kana) && !isEnglish(firstname_kana)) {
        handleFirstname2Exceptions({
            hasError: true,
            error: settings.labels.Kana_Error_Validation,
        });
        return;
    }

    handleFirstname2Exceptions({
        isValid: true,
    });
}

function onLastnameChange() {
    var lastname = $('[id$=":lastname"]').val();
    var isRequired = settings.fields.lastname.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && isNullOrWhiteSpace(lastname)) {
        handleLastnameExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }
    // Japanase Characters
    else if (settings.country_local == "jp" && !isKanji_Kana(lastname) && !isEnglish(lastname)) {
        handleLastnameExceptions({
            hasError: true,
            error: settings.labels.Kanji_Error_Validation
        });
        return;
    }
    // Russian Characters
    else if (settings.country_local == "ru" && !isCyrillic(lastname) && !isEnglish(lastname)) {
        handleLastnameExceptions({
            hasError: true,
            error: settings.labels.Cyrillic_Error_Validation
        });
        return;
    }

    handleLastnameExceptions({
        isValid: true,
    });
}

function onBirthdateChange() {
    var birthdate = $('[id$=":birthdate"]').val();
    var isRequired = settings.fields.birthdate.isRequired == 'true';
    
    if (isRequired && isNullOrWhiteSpace(birthdate)) {
        handleBirthdateExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }

    // FUTURE DATE CHECK
    var currentDate = new Date();
    var selectedDate = new Date(birthdate);

    if (selectedDate > currentDate || (selectedDate.getFullYear() < 1922 || selectedDate.getFullYear() > 2023)) { 
        handleBirthdateExceptions({
            hasError: true,
            error: settings.labels.Birthdate_Error,
        });
        return;
    }

    handleBirthdateExceptions({
        isValid: true,
    });
}

//1. POSTAL CODE
function onPostalCodeChange() {
    var postal_code = $('[id$=":postal_code"]').val();
    var regex = new RegExp('^[a-zA-Z0-9!@#$%^&*()_+-=]{5,10}$');
        if (!postal_code.match(regex)) {
            handlePostalCodeExceptions({
                hasError: true,
                error: settings.labels.Invalid_Field_Error
            });
            return;
        }
        handlePostalCodeExceptions({
            isValid: true,
        });
}

//2. STATE
function onStateChange() {
    var state = $('[id$=":state"]').val();
    var regex = new RegExp('.+');
    if (!state.match(regex)) {
        handleStateExceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });
        return;
    }
    handleStateExceptions({
        isValid: true,
    });
}

//3. CITY
function onCityChange() {
    var city = $('[id$=":city"]').val();
    var regex = new RegExp('^[^\\d]+$');
    if (!city.match(regex)) {
        handleCityExceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });        
        return;
    }
    handleCityExceptions({
        isValid: true,
    });
   
}

//4. ADDRESS-1
function onAddress1Change() {
    var address1 = $('[id$=":address1"]').val();
    var regex = new RegExp('^[\\u0020-\\u007E\\u0080-\\uFFFF]{1,40}$');
    if (!address1.match(regex)) {
        handleAddress1Exceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });
        return;
    }
    handleAddress1Exceptions({
        isValid: true,
    });
}

//5. ADDRESS-2
function onAddress2Change() {
    var address2 = $('[id$=":address2"]').val();
    var regex = new RegExp('^[\\u0020-\\u007E\\u0080-\\uFFFF]{1,40}$');
    if (!address2.match(regex)) {
        handleAddress2Exceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });
        return;
    } 
    handleAddress2Exceptions({
        isValid: true,
    });
}

//6. ADDRESS-3
function onAddress3Change() {
    var address3 = $('[id$=":address3"]').val();
    var regex = new RegExp('^[\\u0020-\\u007E\\u0080-\\uFFFF]{1,40}$');
    if (!address3.match(regex)) {
        handleAddress3Exceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });
        return;
    }
    handleAddress3Exceptions({
        isValid: true,
    });
}

//7. MOBILE PHONE
function onMobilePhoneChange() {
    var mobile_phone = $('[id$=":mobile_phone"]').val();
    var calling_code = $('[id$=":calling_code"]').val();
    var international_mobile_phone = intlTelInputUtils.formatNumber(mobile_phone, calling_code);

    // REQUIRED 
    if ((!mobile_phone || !calling_code)) {
        handleMobilePhoneExceptions({
            hasError: true,
            error: settings.labels.Invalid_Field_Error
        });
        return;
    }
    // REGEX
    else if (mobile_phone) {
        if (!intlTelInputUtils.isValidNumber(mobile_phone, calling_code)) {
            handleMobilePhoneExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Mobile_Phone_Message
            });
            return;
        } else {
            $('[id$=":international_mobile_phone"]').val(international_mobile_phone);
            handleMobilePhoneExceptions({
                isValid: true,
            });
            return;
        }
    }
    setMobilePlaceholder('[id$=":mobile_phone"]', calling_code);
    handleMobilePhoneExceptions({});
}

function onLastname2Change() {
    var lastname_kana = $('[id$=":lastname2"]').val();
    var isRequired = settings.fields.lastname2.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && isNullOrWhiteSpace(lastname_kana)) {
        handleLastname2Exceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    } else if (!isKana(lastname_kana) && !isEnglish(lastname_kana)) {
        handleLastname2Exceptions({
            hasError: true,
            error: settings.labels.Kana_Error_Validation,
        });
        return;
    }

    handleLastname2Exceptions({
        isValid: true,
    });
}

function onEmailChange() {
    var email = $('[id$=":email"]').val();
    var isRequired = settings.fields.email.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !email) {
        handleEmailExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    } else if (email) {
        // REGEX
        var regex = new RegExp('^[a-zA-Z0-9!#$%&\'\/=?^_`{|}~-]+(?:[a-zA-Z0-9!#$.%+&\'*\/=?^_`{|}~-]+)*@[a-zA-Z0-9.-]{2,}\\\.[a-zA-Z]{2,}$');

        if (!email.match(regex)) {
            handleEmailExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Email_Message
            });

            return;
        } else {
            // DUPLICATA
            settings.remoting = true;
            Visualforce.remoting.Manager.invokeAction(
                'IDENTITY_Registration_CTRL.onLoginEmailChange',
                email,
                function (isValid) {

                    settings.remoting = false;

                    handleEmailExceptions({
                        isValid: isValid,
                        hasError: !isValid,
                    });

                    if (!isValid) {
                        openLoginModal(email, $('[id$=":email"]').parent().offset());
                    } else {
                        closeLoginModal();
                    }
                }
            );
        }
    }

    handleEmailExceptions({});
}

function onCountryChange() {
    var country = $('[id$="country"]').val();
    $('[id$="client_country"]')[0].value = country;

    // UPDATE THE CALLING CODE ACCORDING THE COUNTRY 
    // ONLY IF THE MOVBILE PHONE IS NOT FILLED IN
    var international_mobile_phone = $('[id$=":international_mobile_phone"]').val();
    if (country && !international_mobile_phone) {
        $('[id$=":calling_code"]').val(country);
        setMobilePlaceholder('[id$=":mobile_phone"]', country);
    }

    var isRequired = settings.fields.country.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !country) {
        handleCountryExceptions({
            hasError: true,
            error: settings.labels.Required_Field,
        });
        return;
    }

    handleCountryExceptions({
        isValid: true,
    });
}

function onCallingCodeChange() {
    var mobile_phone = $('[id$=":mobile_phone"]').val();
    var calling_code = $('[id$=":calling_code"]').val();

    setMobilePlaceholder('[id$=":mobile_phone"]', calling_code);

    if (mobile_phone) {
        onMobilePhoneChange();
        return;
    }
    //else, do nothing. user has only changed code and did not entered number yet.
    return;
}

function onNewsletterAgreementChange(doTracking) {
    var agreement = $('[id$=":newsletter_agreement"]').prop('checked');
    var isRequired = settings.fields.newsletter_agreement.isRequired == 'true';
    var error;

    if (doTracking && isTrackingAvailable()) {
        autoData.sendEvent({
            'contentId': 'newsletter_subscription',
            'actionId': (agreement ? 'tick_checkbox' : 'untick_checkbox'),
            'actionType': 'newsletter_subscription',
            'categoryGa':'mylv',
            'actionGa':'create_an_account_form_sf',
            'labelGa':(agreement ? 'news_tick_checkbox' : 'news_untick_checkbox')
        });
    }

    // REQUIRED 
    if (isRequired && !agreement) {
        handleNewsletterAgreementExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    }

    handleNewsletterAgreementExceptions({
        isValid: true
    });
}

function onPrivacyAgreementChange() {
    var agreement = $('[id$=":privacy_agreement"]').prop('checked');
    var isRequired = settings.fields.privacy_agreement.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !agreement) {
        handlePrivacyAgreementExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    }

    handlePrivacyAgreementExceptions({
        isValid: true
    });
}

function onCbdtAgreementChange() {
    var agreement = $('[id$=":cbdt_agreement"]').prop('checked');
    var isRequired = settings.fields.cbdt_agreement.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !agreement) {
        handleCbdtAgreementExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    }

    handleCbdtAgreementExceptions({
        isValid: true
    });
}

function onAgeConfirmationChange() {
    var agreement = $('[id$=":age_confirmation"]').prop('checked');
    var isRequired = settings.fields.age_confirmation.isRequired == 'true';
    var error;

    // REQUIRED 
    if (isRequired && !agreement) {
        handleAgeConfirmationExceptions({
            hasError: true,
            error: settings.labels.Required_Field
        });
        return;
    }

    handleAgeConfirmationExceptions({
        isValid: true
    });
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

    if (type == 'numeric') 
    {
        return ((key >= 48 && key <= 57) || key == 8 || key == 45 || key == 32 || (code >= 48 && code <= 57) || code == 8 || code == 45 || code == 32);
    } 
    else if (type == 'alpha') 
    {
        /*ECO-17948: we should allow english + specific characteres for each context needed (Japan, Russia..)*/
        if (settings.country_local == "jp") 
        {
            return isKanjiKanaCode(key) || isKanjiKanaCode(code) || english || special;
        }
        else if (settings.country_local == "ru") 
        {
            return (key >= 1024 && key <= 1279) || (code >= 1024 && code <= 1279) || english || special;
        }
        /*ECO-25892: enable korean & arabic characters*/
        else if (settings.country_local == "kr")
        {
            return     (key >= 44032 && key <= 55215) || (code >= 44032 && code <= 55215)
                    || (key >= 4352  && key <= 4607)  || (code >= 4352  && code <= 4607)
                    || (key >= 12592 && key <= 12687) || (code >= 12592 && code <= 12687)
                    || (key >= 43360 && key <= 43391) || (code >= 43360 && code <= 43391)
                    || (key >= 55216 && key <= 55295) || (code >= 55216 && code <= 55295) 
                    || english 
                    || special;
        }
        else if (settings.country_local == "ae")
        {
            return     (key >= 1536 && key <= 1791) || (code >= 1536 && code <= 1791)
                    || english 
                    || special;
        }
        /*ECO-30898: enable thai characters*/
        else if (settings.country_local == "th")
        {
            return     (key >= 3585 && key <= 3675) || (code >= 3585 && code <= 3675)
                    || english 
                    || special;
        }
        else 
        {
            return english || special;
        }
    } 
    else if (type == 'kana') {
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
    return (k == 45 || k == 39 || k == 8 || k == 32);
}

function keyIsAccent(k) {
    return ((k >= 224 && k <= 239) || (k >= 242 && k <= 246) || (k >= 249 && k <= 252));
}

function onInputCodeChange(isConfirmed) {
    enableButton('[id$=":verification_button"]', true);
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

function onAutoRegistrationButtonSubmit() {
    setup(true);
    $('[id$=":auto_registration_error"]').html('');
    register();
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

//If all are empty OR all are not empty
function isKoreaFieldsRequired() {
    if(settings.country_local != "kr") {
        return false;
    }
    var postal_code_val = $('[id$=":postal_code"]').val() != '';
    var state_val = $('[id$=":state"]').val() != '';
    var city_val = $('[id$=":city"]').val() != '';
    var address1_val = $('[id$=":address1"]').val() != '';
    var address2_val = $('[id$=":address2"]').val() != '';
    var address3_val = $('[id$=":address3"]').val() != '';
    var mobile_phone_val = $('[id$=":mobile_phone"]').val() != '';

    //if all are empty
    if(!postal_code_val && !state_val && !city_val && !address1_val && !address2_val && !address3_val && !mobile_phone_val) {
        return false;
    }
    return true;
}

function clearKRFieldsData() {
    showLoader(true, '#popover-kr-loader', 'korea_address_button');
    showLoader(true, '#popover-kor-loader', 'korea_address_cancel_button');

    $('[id$=":postal_code"]').val('');
    $('[id$=":state"]').val('');
    $('[id$=":city"]').val('');
    $('[id$=":address1"]').val('');
    $('[id$=":address2"]').val('');
    $('[id$=":address3"]').val('');
    $('[id$=":mobile_phone"]').val('');
}

function focusKRFields() {
    $('#div_postal_code_error').focus();
}

function openSearchAdressPopup() {
    document.querySelector(".popup-wrapper").style.display = "block";
}

async function onPersonalSectionSubmit(isPreValidation) {
    var isHidden, isValid, isChecked, isRequired;
    var submit = true;
    var firstErrorField;
    var fieldsInError = '';

    isValid = $('[id$=":password"]').data('isValid');
    if (!isPreValidation) {
        var legalPassword = await this.isLegalPassword();
        if (!legalPassword) { //#from email & name
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
    
    if(isKoreaFieldsRequired()) { //(Korea) if ALL fields OR some of the fields are filled
        //1. POSTAL CODE
        isNotEmpty = Boolean($('[id$=":postal_code"]').val());
        isValid = $('[id$=":postal_code"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'postal_code_error' : firstErrorField);
            fieldsInError += 'postal_code;';
            onPostalCodeChange();
        }
        if(!isNotEmpty) { //Required error if empty
            handlePostalCodeExceptions({ hasError: true, error: settings.labels.Required_Field });
        }
        
        //2. STATE
        isNotEmpty = Boolean($('[id$=":state"]').val());
        isValid = $('[id$=":state"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'state_error' : firstErrorField);
            fieldsInError += 'state;';
            onStateChange();
        }
        if(!isNotEmpty) { //Required error if empty
            handleStateExceptions({ hasError: true, error: settings.labels.Required_Field });
        }

        //3. CITY
        isNotEmpty = Boolean($('[id$=":city"]').val());
        isValid = $('[id$=":city"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'city_error' : firstErrorField);
            fieldsInError += 'city;';
            onCityChange();
        }
        if(!isNotEmpty) { //Required error if empty
            handleCityExceptions({ hasError: true, error: settings.labels.Required_Field });
        }

        //4. ADDRESS-1
        isNotEmpty = Boolean($('[id$=":address1"]').val());
        isValid = $('[id$=":address1"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'address1_error' : firstErrorField);
            fieldsInError += 'address1;';
            onAddress1Change();
        }
        if(!isNotEmpty) { //Required error if empty
            handleAddress1Exceptions({ hasError: true, error: settings.labels.Required_Field });
        }

        //5. ADDRESS-2
        isNotEmpty = Boolean($('[id$=":address2"]').val());
        isValid = $('[id$=":address2"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'address2_error' : firstErrorField);
            fieldsInError += 'address2;';
            onAddress2Change();
        }
        if(!isNotEmpty) { //Required error if empty
            handleAddress2Exceptions({ hasError: true, error: settings.labels.Required_Field });
        }

        //6. ADDRESS-3
        isNotEmpty = Boolean($('[id$=":address3"]').val());
        isValid = $('[id$=":address3"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'address3_error' : firstErrorField);
            fieldsInError += 'address3;';
            onAddress3Change();
        }
        if(!isNotEmpty) { //Required error if empty
            handleAddress3Exceptions({ hasError: true, error: settings.labels.Required_Field });
        }

        //7. MOBILE PHONE
        isNotEmpty = Boolean($('[id$=":mobile_phone"]').val());
        isValid = $('[id$=":mobile_phone"]').data('isValid');
        if (!isNotEmpty || !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'mobile_phone_error' : firstErrorField);
            fieldsInError += 'mobile_phone;';
            onMobilePhoneChange();
        }
        if(!isNotEmpty) { //Required error if empty
            handleMobilePhoneExceptions({ hasError: true, error: settings.labels.Required_Field });
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
        isNotEmpty = Boolean($.trim($('[id$=":firstname"]').val()));
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

    if ($('[id$=":birthdate"]').val() != '') {
        isHidden = parseBoolean(settings.fields.birthdate.isHidden);
        isRequired = parseBoolean(settings.fields.birthdate.isRequired);
        isNotEmpty = Boolean($('[id$=":birthdate"]').val());
        isValid = $('[id$=":birthdate"]').data('isValid');

        if (!isHidden && (isRequired || isNotEmpty) && !isValid) {
            submit = false;
            firstErrorField = (!firstErrorField ? 'birthdate_error' : firstErrorField);
            fieldsInError += 'birthdate;';
            onBirthdateChange();
        }
    }

    if ($('[id$=":lastname"]').length > 0) {
        isHidden = parseBoolean(settings.fields.lastname.isHidden);
        isRequired = parseBoolean(settings.fields.lastname.isRequired);
        isNotEmpty = Boolean($.trim($('[id$=":lastname"]').val()));
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
        isNotEmpty = Boolean($.trim($('[id$=":firstname2"]').val()));
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
        isNotEmpty = Boolean($.trim($('[id$=":lastname2"]').val()));
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

    isHidden = parseBoolean(settings.fields.cbdt_agreement.isHidden);
    isChecked = $('[id$=":cbdt_agreement"]').prop('checked');
    isRequired = parseBoolean(settings.fields.cbdt_agreement.isRequired);
    isValid = (isRequired && isChecked) || !isRequired;
    if (!isHidden && !isValid && !isPreValidation) {
        submit = false;
        firstErrorField = (!firstErrorField ? 'cbdt_agreement_error' : firstErrorField);
        fieldsInError += 'cbdt_agreement;';
        onCbdtAgreementChange();
    }

    isHidden = parseBoolean(settings.fields.age_confirmation.isHidden);
    isChecked = $('[id$=":age_confirmation"]').prop('checked');
    isRequired = parseBoolean(settings.fields.age_confirmation.isRequired);
    isValid = (isRequired && isChecked) || !isRequired;
    if (!isHidden && !isValid && !isPreValidation) {
        submit = false;
        firstErrorField = (!firstErrorField ? 'age_confirmation_error' : firstErrorField);
        fieldsInError += 'age_confirmation;';
        onAgeConfirmationChange();
    }

    if (!isPreValidation) {
        if (submit) {
            enableButton('[id$=":personal_button"]', false);
            enableButton('[id$=":personal_button2"]', false);
            showLoader(true, '#personal-section-loader', 'personal_button');
            showLoader(true, '#personal-section-loader', 'personal_button2');
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
           if (settings.mode == settings.static.ACTIVATION && settings.sub_mode == settings.static.PARTIAL && settings.isTrustOrigin == 'true') {
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

function onSendVerificationCodeClick() {
    enableButton('[id$=":send_verification_code_link"]', false);
    $('[id$=":send_verification_code_link"]').addClass( 'disabled-link');
    $('[id$=":resent_done_message"]').hide();
    setTimeout(function(){  
        enableButton('[id$=":send_verification_code_link"]', true);
        $('[id$=":send_verification_code_link"]').removeClass( 'disabled-link');
    }, 60000);
    sendVerificationCodeByLinkClick();
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
    if (settings.client_country) {
        $('[id$="country"]').val(settings.client_country);
        $('[id$="country"]').addClass('id-page-form__select_is-valid');
        $(".id-page-form__select-country option[value='" + settings.client_country + "']").prop('selected', true);
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
        defaultCountry: settings.client_country
    });
    $('[id$=":login_mobile_phone"]').intlTelInput({
        autoHideDialCode: true,
        autoPlaceholder: true,
        defaultCountry: settings.client_country
    });

    // FOR MAC STYLE
    if (navigator.userAgent.indexOf('Mac OS X') != -1) {
        $("body").addClass("mac");
    } else {
        $("body").addClass("pc");
    }

    //FOR LVAPP WEBVIEW
    if (settings.origin == 'lvapp' || settings.origin == 'lvconnect' || settings.origin == 'checkout') {
        $("body").addClass("lvapp");
        settings.webviewInterval = setInterval(webViewStyle, 1);
    }

    // DISABLE DOUBLE CLICK EVENT
    $('[id$=":kisa_button"]').dblclick(function () {});
    $('[id$=":login_button"]').dblclick(function () {});
    $('[id$=":personal_button"]').dblclick(function () {});
    $('[id$=":personal_button2"]').dblclick(function () {});
    $('[id$=":verification_button"]').dblclick(function () {});
}

function webViewStyle() {
    var elem = $("#footer");
    if(elem != null && elem.length != null && elem.length > 0){
        elem.hide();
        clearInterval(settings.webviewInterval);
    }
}

function handleSectionForm(isLoading) {
    if (isLoading || settings.current_step == settings.static.LOADING_STEP) {
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').hide();
        $('[id$=":auto_registration_section"]').hide();
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

        // Display error messageon step3 if step2 has been skipped because double click on step1 submit
        if( (settings.sub_mode === "" || settings.sub_mode !== settings.static.MATCHING) && !(isStep2Valid()) && settings.sub_mode!== settings.static.PARTIAL)
            $('[id$=":skip_step2_error"]').show();
        else
            $('[id$=":skip_step2_error"]').hide();            
        
        setFocus();
    } else if (settings.current_step == settings.static.AUTO_REG_STEP) {//ADDED FOR AUTO REG SECTION WITH BUTTON
        $('[id$=":kisa_section"]').hide();
        $('[id$=":login_section"]').hide();
        $('[id$=":personal_section"]').hide();
        $('[id$=":verification_section"]').hide();
        $('[id$=":auto_registration_section"]').show();
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
    else if (settings.current_step == settings.static.AUTO_REG_STEP) {
        $('#h2_auto_registration').focus();
    }
}

function setRegistrationException(message) {
    // Set message
    if(message.includes('INVALID_NEW_PASSWORD_TOO_EASY')){
        message = settings.labels.Password_Error; 
    }
    else {
        message = settings.labels.Verification_Code_Failed;
    }
    settings.registration_exception = message; 

    if(settings.sub_mode == settings.static.AUTO){
        // Display current step - remove if solution without button
        setup();

        // Display error
        handleAutoRegistrationExceptions(message);
    }
    else{
        // Display current step
        setup();  
    
        // Display error
        handleInputCodeExceptions({
            hasError: true,
            error: message
        });        
    }
}

function handleExceptions(field) {

    var classForIsValid = 'id-page-form__field_is-valid';
    //for picklists and checkboxes the style of valid is different
    if ($(field.id_field).hasClass('id-page-form__select')) {
        classForIsValid = 'id-page-form__select_is-valid';
    } else if ($(field.id_field).parent().parent().hasClass('id-page-form__checkbox-field')) {
        classForIsValid = '';
    }

    if (field.hasError) {
        if (field.id_error) {
            $(field.id_error).html(field.error ? field.error : '');
        }
        $(field.id_field).addClass('id-page-form__field_has-error');
        $(field.id_field).removeClass(classForIsValid);
        $(field.id_field).data('isValid', false);
    } else if (field.isValid) {
        if (field.id_error) {
            $(field.id_error).html('');
        }
        $(field.id_field).removeClass('id-page-form__field_has-error');
        $(field.id_field).addClass(classForIsValid);
        $(field.id_field).data('isValid', true);
    } else {
        if (field.id_error) {
            $(field.id_error).html('');
        }
        $(field.id_field).removeClass('id-page-form__field_has-error');
        $(field.id_field).removeClass(classForIsValid);
        $(field.id_field).data('isValid', false);
    }
}

function handleLoginEmailExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":login_email"]',
        id_error: '[id$=":login_email_error"]',
        error: field.error
    });

    onLoginEmailConfirmationChange(null, true);
}

function handleLoginEmailConfirmationExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":login_email_confirmation"]',
        id_error: '[id$=":login_email_confirmation_error"]',
        error: field.error
    });
}

function handleLoginMobilePhoneExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":login_mobile_phone"]',
        id_error: '[id$=":login_mobile_phone_error"]',
        error: field.error
    });
}

function handlePasswordExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        error: field.error,
        id_field: '[id$=":password"]',
        id_error: '[id$=":password_error"]',
    });
}

function handleTitleExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":title"]',
        id_error: '[id$=":title_error"]',
        error: field.error
    });
}

function handleFirstnameExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":firstname"]',
        id_error: '[id$=":firstname_error"]',
        error: field.error
    });
}

function handleFirstname2Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":firstname2"]',
        id_error: '[id$=":firstname2_error"]',
        error: field.error
    });
}

function handleLastnameExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":lastname"]',
        id_error: '[id$=":lastname_error"]',
        error: field.error
    });
}

function handleLastname2Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":lastname2"]',
        id_error: '[id$=":lastname2_error"]',
        error: field.error
    });
}

function handleFirstname2Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":firstname2"]',
        id_error: '[id$=":firstname2_error"]',
        error: field.error
    });
}

function handleLastname2Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":lastname2"]',
        id_error: '[id$=":lastname2_error"]',
        error: field.error
    });
}

function handleCountryExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$="country"]',
        id_error: '[id$=":country_error"]',
        error: field.error
    });
}

function handleEmailExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":email"]',
        id_error: '[id$=":email_error"]',
        error: field.error
    });
}

function handlePostalCodeExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":postal_code"]',
        id_error: '[id$=":postal_code_error"]',
        error: field.error
    });
}

function handleCityExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":city"]',
        id_error: '[id$=":city_error"]',
        error: field.error
    });
}

function handleAddress1Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":address1"]',
        id_error: '[id$=":address1_error"]',
        error: field.error
    });
}

function handleAddress2Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":address2"]',
        id_error: '[id$=":address2_error"]',
        error: field.error
    });
}

function handleAddress3Exceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":address3"]',
        id_error: '[id$=":address3_error"]',
        error: field.error
    });
}

function handleStateExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":state"]',
        id_error: '[id$=":state_error"]',
        error: field.error
    });
}
function handleMobilePhoneExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":mobile_phone"]',
        id_error: '[id$=":mobile_phone_error"]',
        error: field.error
    });
}

function handleBirthdateExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":birthdate"]',
        id_error: '[id$=":birthdate_error"]',
        error: field.error
    });
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

function handleNewsletterAgreementExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":newsletter_agreement"]',
        id_error: '[id$=":newsletter_agreement_error"]',
        error: field.error
    });
}

function handlePrivacyAgreementExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":privacy_agreement"]',
        id_error: '[id$=":privacy_agreement_error"]',
        error: field.error
    });
}

function handleCbdtAgreementExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":cbdt_agreement"]',
        id_error: '[id$=":cbdt_agreement_error"]',
        error: field.error
    });
}

function handleAgeConfirmationExceptions(field) {
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":age_confirmation"]',
        id_error: '[id$=":age_confirmation_error"]',
        error: field.error
    });
}

function handleAutoRegistrationExceptions(message) {
    //$('[id$=":loader_section"] label').css('color','red');
    //$('[id$=":loader_section"] label').html(message);
    $('[id$=":auto_registration_error"]').html(message);
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
        $('[id$=":' + idButton + '"]').val('').addClass('personal-loader');
        if(idButton == 'personal_button'){
            $('[id$=":' + idButton + '"]').addClass('personal-loader');
        }
        else{
            $(idLoader).show();
        }        
    } else {
        $(idLoader).hide();
        $('[id$=":' + idButton + '"]').val(textButton).removeClass('personal-loader');
    }
}

function enableKisaButton() {
    var isValid =   $('#kisa-agreement-1').prop('checked') &&
                    $('#kisa-agreement-2').prop('checked') &&
                    $('#kisa-agreement-4').prop('checked') &&
                    $('#kisa-agreement-5').prop('checked');   

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
    $('[id$=":login_email_confirmation"]').val('');
    $('[id$=":login_email"]').removeClass('id-page-form__field_has-error');
    closeLoginModal();
}

function closeLoginModal() {
    $('[id$=":username"]').val('');
    $('[id$=":password_login"]').val('');
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
        label = label.replace('xx@xx.com', settings.client_login_email);
    } else {
        label = settings.labels.Mobile_Repairs_Section_Description;
        label = label.replace('+XXX', settings.client_login_international_mobile_phone);
    }

    $('[id$=":section_description"]').html(label);
}

function setDynamicVerificationLabels() {
    if (settings.fields.login_mobile_phone.isHidden == 'false') {
        var label = settings.labels.SMS_Verification_Section_Description;

        if ((settings.mode == settings.static.SOCIAL_REGISTRATION || settings.isTrustOrigin == 'false') && settings.client_login_international_mobile_phone != null && settings.client_login_international_mobile_phone != '') {
            label = label.replace('XXX', settings.client_login_international_mobile_phone)
        } else {
            label = label.replace('XXX', $('[id$=":login_international_mobile_phone"]').val());
        }

        $('[id$=":verification_description"]').html(label);
    } else {
        var label = settings.labels.Email_Verification_Section_Description;

        if ((settings.mode == settings.static.SOCIAL_REGISTRATION || settings.isTrustOrigin == 'false') && settings.client_login_email != null && settings.client_login_email != '') {
            label = label.replace('xx@xx.com', settings.client_login_email);
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

function setMobilePlaceholder(id, country) {
    $(id).intlTelInput("setCountry", country.toLowerCase());
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
    $('[id$=":resent_done_message"]').css('margin-bottom', '0');
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
    if (document.readyState === "complete" && autoDataLoaded == true) { //autoData.instance != undefined
        return true;
    } else {
        return false;
    }
}

/******************************  VALIDATION   **************************/

function hasEightOrMoreCharacters(password) {
    var isValid = password.length >= 8;
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

function hasSpecialCharacter(password) {
    var regex = new RegExp('(?=.*[!#$&()*+,\\-.:;<=>?@\\[\\]^_{|}~])');

    var isValid = password.match(regex);
    handlePasswordRule('#password-rule-6', isValid)

    return isValid;
}

function isDifferentFromEmail(password) {

    password = password.toLowerCase();
    var email = $('[id$=":login_email"]').val() ||  settings.client_login_email;
    var international_mobile_phone = $('[id$=":login_international_mobile_phone"]').val() || settings.client_login_international_mobile_phone;
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
    var firstname = $('[id$=":firstname"]').val().toLowerCase();
    var lastname = $('[id$=":lastname"]').val().toLowerCase();

    if(Boolean(firstname) && Boolean(lastname)){
        var isValid = !password.includes(firstname) && !password.includes(lastname);
        handlePasswordRule('#password-rule-5', isValid);

        return isValid;
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

function isNullOrWhiteSpace(str) {
    return (!str || str.length === 0 || /^\s*$/.test(str))
}

function isStep2Valid()
{
    // lastname
    var lastname = $('[id$=":lastname"]').val();
    var isRequired = settings.fields.lastname.isRequired == 'true';
    if(isRequired && isNullOrWhiteSpace(lastname)){
        return false;
    }        

    // firstname
    var firstname = $('[id$=":firstname"]').val();
    var isRequired = settings.fields.firstname.isRequired == 'true';
    if(isRequired && isNullOrWhiteSpace(firstname)){
        return false;
    }

    // lastname2
    var lastname2 = $('[id$=":lastname2"]').val();
    var isRequired = settings.fields.lastname2.isRequired == 'true';
    if(isRequired && isNullOrWhiteSpace(lastname2)){
        return false;
    }

    // firstname2
    var firstname2 = $('[id$=":firstname2"]').val();
    var isRequired = settings.fields.firstname2.isRequired == 'true';
    if(isRequired && isNullOrWhiteSpace(firstname2)){
        return false;
    }

    // country
    var country = $('[id$="country"]').val();
    var isRequired = settings.fields.country.isRequired == 'true';
    if(isRequired && isNullOrWhiteSpace(country)){
        return false;
    }

    return true;
}

// GG ANALYTICS CLIENT_ID COOKIE
function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
        c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
        }
    }
    return "";
}

function setAnalyticsCookies()
{
    var clientId = getCookie('_ga');
    clientId = clientId.slice(-20);
    setCookie('apex__clientId', clientId, 365);
}

$( document ).ready(function() {
    setAnalyticsCookies();
});

function manageAutoRegistration(){
    if(settings.sub_mode == settings.static.AUTO){
        register();
    }
}

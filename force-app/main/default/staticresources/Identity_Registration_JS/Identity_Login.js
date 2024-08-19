function onLoginEmailChange() {
    var email = $('[id$=":login_email"]').val();

    if(Boolean(email)){

        // REGEX
        var regex = new RegExp('^[a-zA-Z0-9!#$%&\'\/=?^_`{|}~-]+(?:[a-zA-Z0-9!#$.%+&\'*\/=?^_`{|}~-]+)*@[a-zA-Z0-9.-]{2,}\\\.[a-zA-Z]{2,}$');

        if(!email.match(regex)){
            handleLoginEmailExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Email_Message,
            });
            
            return;
        }
        else{
            handleLoginEmailExceptions({
                isValid: true,
            });

            settings.remoting = true;
            console.log(true)
            Visualforce.remoting.Manager.invokeAction(
                'IDENTITY_Login_CTRL.onLoginEmailChange',
                email,
                function () {
                    console.log(false)
                    settings.remoting = false;
                }
            );
        }

        $('[id$=":username"]').val(email);
        $('[id$=":username"]').trigger('change');
    }
    else {
        handleLoginEmailExceptions({});
    }
}

function handleLoginEmailExceptions(field){
    handleExceptions({
        isValid: field.isValid,
        hasError: field.hasError,
        id_field: '[id$=":login_email"]',
        id_error: '[id$=":login_email_error"]',
        error: field.error
    });
}

function onLoginMobilePhoneChange(){
    var mobile_phone = $('[id$=":login_mobile_phone"]').val();
    var calling_code = $('[id$=":login_calling_code"]').val();
    var login_international_mobile_phone = intlTelInputUtils.formatNumber(mobile_phone, calling_code);

    if(Boolean(mobile_phone)){
        if( !intlTelInputUtils.isValidNumber(mobile_phone, calling_code) || intlTelInputUtils.getNumberType(mobile_phone, calling_code) != 1){
            handleLoginMobilePhoneExceptions({
                hasError: true,
                error: settings.labels.Validation_Format_Mobile_Phone_Message,
            });
            return;
        }
        else {
            handleLoginMobilePhoneExceptions({
                isValid: true,
            });

            settings.remoting = true;
            Visualforce.remoting.Manager.invokeAction(
                'IDENTITY_Login_CTRL.onLoginMobilePhoneChange',
                login_international_mobile_phone,
                function () {
                    settings.remoting = false;
                }
            );
        }
    
        $('[id$=":username"]').val(login_international_mobile_phone);
        $('[id$=":username"]').trigger('change');
        
    }
    else {
        handleLoginMobilePhoneExceptions({});
    }
}

function handleLogin(){
    showLoader(false, '#popover-login-loader', 'popover-login', settings.labels.Sign_In_Button);
    $('[id$=":password_login_error"]').html(settings.labels.Incorrect_Password);
    if(isTrackingAvailable()) {
        autoData.sendEvent({'event':'logInFailure', 
                            'actionId':'sign_in_failed', 
                            'actionType':'submit_button', 
                            'actionPosition':'existing_email', 
                            'pageRank':'step_email', 
                            'categoryGa':'mylv', 
                            'actionGa':'i_already_have_an_account', 
                            'labelGa':'sign_in_failed'});
    }
}

function onLoginPasswordClick(isSetup){
    if($('[id$=":password_login"]').attr('type') == 'text') {
        $('[id$=":password_login"]').attr('type','password');
        
    } else {
        $('[id$=":password_login"]').attr('type','text');        
    }
}

function login() {
     
    //bug username autofill when using password manager (only in LOGIN mode, not KNOWN_LOGIN)
    if($('[id$=":username"]').length && $('[id$=":username"]').val().trim() == ''){
        if($('[id$=":login_email"]').length && $('[id$=":login_email"]').val().trim() !== ''){
            onLoginEmailChange();
        }
        else if($('[id$=":login_mobile_phone"]').length && $('[id$=":login_mobile_phone"]').val().trim() !== ''){
            onLoginMobilePhoneChange();
        }
    }

    if(isTrackingAvailable()) {
        autoData.sendEvent({'actionId':'sign_in_intention', 
                            'actionType':'submit_button', 
                            'actionPosition':'i_already_have_an_account', 
                            'pageRank':'connexion_module', 
                            'categoryGa':'mylv', 
                            'actionGa':'i_already_have_an_account', 
                            'labelGa':'sign_in_intention'});
    }
    
    if (settings.remoting) {
        setTimeout(() => {
            // Add loading style
            showLoader(true, '#popover-login-loader', 'popover-login');
            loginPasswordMethod();
        }, 1000);
    } else {
        // Add loading style
        showLoader(true, '#popover-login-loader', 'popover-login');
        loginPasswordMethod();
    }    
}
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


/*
* 
*/
const copyToClipboard = async (valueToCopy, messageToDisplay, component) =>
    {    
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(valueToCopy);
        } else {
            let textArea = document.createElement("textarea");
            textArea.value = valueToCopy;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            // return new Promise((res, rej) => {
            //     document.execCommand("copy") ? res() : rej();
                
            // }); 
            var result = document.execCommand("copy");
            textArea.remove();

            let evt = new ShowToastEvent({
                title: 'Copy to clipboard',
                message: messageToDisplay,
                variant: 'success',
                mode: 'pester'
                });
            component.dispatchEvent(evt);
        }
    }

    export {
        copyToClipboard
    }
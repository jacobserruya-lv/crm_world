import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const showMessage = (page, message, title = 'Error', variant = 'error') => {
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode: 'dismissable'
    });
    page.dispatchEvent(evt);
}

const getFileDimensions = async (url) => {
    return new Promise((resolve, reject) => {
        try {
            const isVideo = url.match('.mp4');
            const loadedFile = isVideo ? document.createElement('video') : new Image;
            loadedFile.src = url;
            const eventToListen = isVideo ? "loadedmetadata" : "load";

            loadedFile.addEventListener(eventToListen, () => {
                const { width, height, videoWidth, videoHeight } = loadedFile;
                
                resolve({
                    width: videoWidth || width,
                    height: videoHeight || height
                });
            });
        } catch(e) {
            reject(e);
        }
    });
}

const removeEmpty = (obj) => {
    return Object.fromEntries(Object.entries(obj).filter(([_, v]) => !!v));
}

export { 
    showMessage,
    getFileDimensions,
    removeEmpty
}
function showPageLoader() {
    window.postMessage('showPageLoader', '*');
}

function hidePageLoader() {
    window.postMessage('hidePageLoader', '*');
}

/**
 * @param {String} renderedLwcName
 */
function hidePageLoaderIfAllChildLwcRendered(renderedLwcName) {
    if (!this.lwcRenderStatus[renderedLwcName]) {
        this.lwcRenderStatus[renderedLwcName] = true;
        const notRendered = Object.values(this.lwcRenderStatus).filter(isRendered => isRendered === false);
        if (!notRendered.length) {
            hidePageLoader();
        }
    }
}

export {
    showPageLoader,
    hidePageLoader,
    hidePageLoaderIfAllChildLwcRendered
};
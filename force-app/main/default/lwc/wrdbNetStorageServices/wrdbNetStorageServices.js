import createAkamaiHeaders from '@salesforce/apex/WRDB_CreateAsset_Controller.createAkamaiHeaders';

const uploadFileToAkamaiNS = async (file) => {
    const akamaiHeaders = await createAkamaiHeaders({ originalFileName: file.name, method: 'upload' });
    console.log(akamaiHeaders);
    const { endPoint, fileAddress, accessUrl, action, authData, authSign } = akamaiHeaders;
    const akamaiResponse = await fetch(endPoint + fileAddress, {
        method: "PUT",
        mode: 'cors',
        body: file,
        headers: {
            'X-Akamai-ACS-Action': action,
            'X-Akamai-ACS-Auth-Data': authData,
            'X-Akamai-ACS-Auth-Sign':authSign
        }
    });

    if (!akamaiResponse.ok) {
        throw akamaiResponse.statusText;
    }

    return { accessUrl, fileAddress };
}

const deleteFileFromAkamaiNS = async (fileAddress) => {
    const akamaiHeaders = await createAkamaiHeaders({ originalFileName: fileAddress, method: 'delete' });
    const { endPoint, action, authData, authSign } = akamaiHeaders;
    const akamaiResponse = await fetch(endPoint + fileAddress, {
        method: "PUT",
        mode: 'cors',
        headers: {
            'X-Akamai-ACS-Action': action,
            'X-Akamai-ACS-Auth-Data': authData,
            'X-Akamai-ACS-Auth-Sign': authSign
        }
    });
    return akamaiResponse;
}

export {
    deleteFileFromAkamaiNS,
    uploadFileToAkamaiNS
}
public class SO_WS_RMS_ClientCreationUpdate_Mock implements WebServiceMock {
    private SO_WS_RMS_ClientCreationUpdate_v5.mainServiceResponse mockResponse;
    
    public SO_WS_RMS_ClientCreationUpdate_Mock(SO_WS_RMS_ClientCreationUpdate_v5.mainServiceResponse mockResponse) {
        this.mockResponse = mockResponse;
    }
    
    public void doInvoke(
        Object stub, Object request, Map<String, Object> response,
        String endpoint, String soapAction, String requestName,
        String responseNS, String responseName, String responseType
    ) {
        response.put('response_x', mockResponse);
    }
}
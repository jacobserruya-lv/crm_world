public with sharing class BL_ICON_OneData_Helper {
    public static final String GET_COUNT_PATH = '/get-count';
    public static final String GET_DREAMIDS_PATH = '/get-dream-ids';

    public static Integer getCount(String filters){
        String response = perform(GET_COUNT_PATH, filters);
        return Integer.valueOf(response);
    }

    public static List<String> getDreamIds(String filters){
        String response = perform(GET_DREAMIDS_PATH, filters);
        return (List<String>) JSON.deserialize(response, List<String>.class);
    }

    public static String perform(String path, String filters){
        BL_HTTP_Utils request = new BL_HTTP_Utils()
        .post('callout:MULESOFT_ONEDATA'+path)
        .header('client_id',  '{!$Credential.UserName}')
        .header('client_secret', '{!$Credential.Password}')
        .header('Content-Type', 'application/json')
        .body(filters)
        .timeout(60000)
        .call();

        if(request.statusCode() == 200){
            return request.responseBody();
        }
        System.debug(request.responseBody());
        throw new BL_Exceptions.QueryException('ERROR_DURING_ONEDATA_REQUEST', 'An error occurred during the onedata query');

    }
}
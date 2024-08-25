global class BL_JOURNEY_Appointment extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {

    global Object executeGET(){

        List<String> validParams =  new List<String> {'storeCode', 'from', 'to', 'caUniqueId','pageIndex' ,'pageSize'};
        checkRequiredParams(new List<String> {'storeCode', 'from', 'to'});
        Map<String,String> params = getValidParams(validParams);

        return BL_JOURNEY_Appointment_Helper.getAppointments(params);
    }

    public Map<String,String> getValidParams(List<String> validParams ){
        Map<String,String> params = new Map<String,String>();

        for(String param: this.queryParams.keySet()){

            if(validParams.contains(param) ) params.put(param, getQueryParameter(param));
        }
        return params;
    }

    public void checkRequiredParams(List<String> requiredParams){

        List<String> missingParams = new List<String>();
       
        for(String param: requiredParams){

            if(requiredParams.contains(param) && (getQueryParameter(param) == null || String.isEmpty(getQueryParameter(param))))  missingParams.add(param);
        }
        if(!missingParams.isEmpty()) throw new BL_Exceptions.RouterException('Required Params Missing: ' + missingParams.toString());
    }
}
public with sharing class StringUtils {
    
    public static Boolean isValidBase64(String s) {
        try {
            EncodingUtil.base64Decode(s).toString();
            return true;
        }
        catch(Exception e) {
            return false;
        }
    }

    public static String camelCaseToKebabCase(String input) {
        if (input == null) {
            return null;
        }
        String output = '';
        for (String c : input.split('')) {
            output += !c.toLowerCase().equals(c) ? '-' + c.toLowerCase() : c;
        }
        return output.startsWith('-') ? output.substring(1) : output;
    }

    /*
    * @description Generate Random String
    * @param {Integer} length
    * @param {String} chars
    * @returns {String}
    */
    public static String generateRandomString(Integer length, String chars) {
        try{
            String randomVal = '';
            while (randomVal.length() < length) {
                Integer idVal = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                randomVal += chars.substring(idVal, idVal+1);
            }
            return randomVal;
        } catch(Exception e) {
            System.debug('> Error in method StringUtils.generateRandomString(): ' + e.getMessage());
        }
        return null;
    }

}
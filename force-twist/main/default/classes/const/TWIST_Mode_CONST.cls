public with sharing class TWIST_Mode_CONST {
    
    public static final String LOGIN = 'LOGIN';
    public static final String ACTIVATION = 'ACTIVATION';
    public static final String REGISTRATION = 'REGISTRATION';
    public static final String SOCIAL_REGISTRATION = 'SOCIAL_REGISTRATION';
    
    // SUB MODE
    public static final String MATCHING = 'MATCHING';
    public static final String FULL = 'FULL';
    public static final String PARTIAL = 'PARTIAL';
    
    /**
    * @description this method is only used for unit testing
    */
    public static List<String> getConstants() {
        return new List<String> {LOGIN,
            ACTIVATION,
            REGISTRATION,
            SOCIAL_REGISTRATION,
            MATCHING,
            FULL,
            PARTIAL
        };
    }
    
}

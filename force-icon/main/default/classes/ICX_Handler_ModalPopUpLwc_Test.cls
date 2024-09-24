@isTest
public with sharing class ICX_Handler_ModalPopUpLwc_Test {
    
    // Cette méthode sert de constructeur pour initialiser les données de test
    public ICX_Handler_ModalPopUpLwc_Test() {
    }

    @isTest
    private static void getUSerValueTest() {
        // Créer un utilisateur de test
        Long milliSeconds = System.currentTimeMillis();
        String email = 'test' + milliSeconds + '@tsertest.com';
        User usr = IC_TestFactory.createUser(email);
        usr.profileId = IC_UTILS.getSysAdminProfile();
        
        // Insérer l'utilisateur dans la base de données
        insert usr;
        
        // Récupérer l'utilisateur via la méthode à tester
        Test.startTest();
        User result = ICX_Handler_ModalPopUpLwc.getUSerValue(usr.Id);
        Test.stopTest();
        
        // Vérifier que les informations récupérées sont correctes
        System.assertEquals(usr.Id, result.Id, 'L\'utilisateur récupéré doit correspondre à l\'utilisateur créé');
    }

    
    @isTest
    private static void UpdateEmailTest() {
    // Créer un utilisateur et un compte de test
    Long milliSeconds = System.currentTimeMillis();
    String email = 'test' + milliSeconds + '@UserTest.com';
    Account acc = IC_TestFactory.createAccount();
    Account acc1 = IC_TestFactory.createAccount();
   	acc1.personEmail = null;
    
    // Insérer le compte avant de travailler avec l'utilisateur
    insert acc;
    insert acc1;
    
    // Créer un utilisateur de test
    User usr = IC_TestFactory.createUser(email);
      usr.profileId = IC_UTILS.getSysAdminProfile();
         String newEmail = 'updated' + milliSeconds + '@usertest.com';
    
    // Pour éviter l'erreur MIXED_DML_OPERATION, encapsuler l'opération sur l'utilisateur dans un bloc runAs
    System.runAs(new User(Id = UserInfo.getUserId())) {
        insert usr;
        
        // Nouvelle adresse e-mail pour la mise à jour
       

        // Tester la méthode de mise à jour
        Test.startTest();
        ICX_Handler_ModalPopUpLwc.UpdateEmail(newEmail, usr.Id, acc.Id);
        ICX_Handler_ModalPopUpLwc.UpdateEmail(newEmail, usr.Id, acc1.Id);

        Test.stopTest();
    }

    // Récupérer l'utilisateur mis à jour
    User updatedUser = [SELECT Email, Username, TECH_Email__c FROM User WHERE Id = :usr.Id];
    
    // Vérifier que l'email a bien été mis à jour
    System.assertEquals(newEmail, updatedUser.Email, 'L\'email doit être mis à jour');
    System.assertEquals(newEmail, updatedUser.Username, 'Le username doit être mis à jour');
    System.assertEquals(newEmail, updatedUser.TECH_Email__c, 'Le champ TECH_Email__c doit être mis à jour');
}

    
    

    
}
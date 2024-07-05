/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_Exceptions
*/

@isTest
public class BL_Exceptions_Test {
    
      @isTest
      static void testBL_Exception(){ 
        Test.startTest();        
          try{ 
            throw new BL_Exceptions.BL_Exception('test','test');
          }
          catch(Exception e){}
           try{ 
            throw new BL_Exceptions.BL_Exception('test','test','test');
          }
          catch(Exception e){}
        Test.stopTest();
      }
    
      @isTest
      static void testCLTException(){ 
        
        Test.startTest();        
          try{ 
            throw new BL_Exceptions.CLTException('test','test');
          }
          catch(Exception e){}
           try{ 
            throw new BL_Exceptions.CLTException('test','test','test');
          }
          catch(Exception e){}
        Test.stopTest();
      }
    
      @isTest
      static void testRouterException(){ 
        
        Test.startTest();        
          try{ 
            throw new BL_Exceptions.RouterException('test','test');
          }
          catch(Exception e){}
           try{ 
            throw new BL_Exceptions.RouterException('test','test','test');
          }
          catch(Exception e){}
        Test.stopTest();
     }
    
      @isTest
      static void testQueryException(){ 
        
        Test.startTest();        
          try{ 
            throw new BL_Exceptions.QueryException('test','test');
          }
          catch(Exception e){}
           try{ 
            throw new BL_Exceptions.QueryException('test','test','test');
          }
          catch(Exception e){}
        Test.stopTest();
      }
}
/* ****************************************************************************
Class Name      : SolutionHelperPORPermissionChkTest
* Author        : Laxmi Rahate : EDGE-142321
* Date          : 29-Apr-2020
* Description   : Test class for SolutionHelperPORPermissionChk
1.  Laxmi Rahate - New class for Port Out reversal
* *****************************************************************************/

@isTest(SeeAllData=FALSE)
public class SolutionHelperPORPermissionChkTest {
    @TestSetup static void CreateData()
    {
        Profile testProfile = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];  
        List <User> userList = new List <User>();
        User sales ;
        sales = new User(alias = 'standt',email='salesuser@testsales1.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='SolnHelperTest', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuserNeg@testsales.com',phone='+121231231234');     
        
        
        userList.add (sales);
        
                
        user salesPos = new User(alias = 'standt1',email='salesuser@testsales2.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='SolnHelperTestPos', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuserPos@testsales.com',phone='+121231231234');    
        userList.add (salesPos);

        insert userList;  
        
                
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Port_Out_Reversal'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = salesPos.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        
    }
    
    
    
    /******************************************************************************************************
* Method Name : getDataTest
* Parameters  : NA
* Return      : NA                      
******************************************************************************************************/
    
    
    @isTest static void getDataTestNegative(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
        
        User sales = [ select name,id, lastname from  User where lastname = 'SolnHelperTest' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            SolutionHelperPORPermissionChk solnHelper  =  new SolutionHelperPORPermissionChk();        
            returnMap = solnHelper.getData(inputMap);
            
            test.stopTest();
            System.assertEquals(false,returnMap.get('hasPortOutReversalPermission')); 
        }
        
    }
    
     
    /******************************************************************************************************
* Method Name : getDataTestPos
* Parameters  : NA
* Return      : NA                      
******************************************************************************************************/
    
    
    @isTest static void getDataTestPos(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
        
        User sales = [ select name,id, lastname from  User where lastname = 'SolnHelperTestPos' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            SolutionHelperPORPermissionChk solnHelper  =  new SolutionHelperPORPermissionChk();        
            returnMap = solnHelper.getData(inputMap);
            
            test.stopTest();
            System.assertEquals(true,returnMap.get('hasPortOutReversalPermission')); 
        }
        
    }  
    
}
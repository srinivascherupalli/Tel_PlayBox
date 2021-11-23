/*
 * Modified By : Team Hawaii
 * Description : Get role instead of new creation.
*/
@isTest
public with sharing class ContinuationControllerTest {

@testSetup static void setup() {

  		//Create New Role Map to avoid maximum role limit reached
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops']){
            rolesMap.put(role.DeveloperName, role);
        }
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
		 
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName = orgId + dateString + randomInt;

    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username=uniqueName+'Cont987657awqas@noemail.com', userroleid=rolesMap.get('Sales_Ops').Id);
          
        insert uSysAdmin;
        }
    @isTest 
    public  static void testContinuation(){
     User uSysAdmin = [Select id from User where email='ContactTr8wrw98@noemail.com'];
        System.runAs(uSysAdmin){  
        ContinuationController controller = new ContinuationController();
        String methodName = 'callPIMS';
        /*
         String params = '{'+
        '  \"userPid\": \"\",'+
        '  \"userFirstName\": \"Nikita\",'+
        '  \"userLastName\": \"Tiwa\",'+
        '  \"userEmail\": \"abc@telstra.com\",'+
        '  \"orgName\": \"abc\",'+
        '  \"isPDUA\": \"false\",'+
        '  \"isDeactivate\": \"false\",'+
        ' \"pimsAPIType\": \"MANAGEORG\",'+
        '  \"mobileNumber\": \"0419111000\"'+
        '}';
    */
        String params2 = '{'+
        '  \"userPid\": \"\",'+
        '  \"userFirstName\": \"Nikita\",'+
        '  \"userLastName\": \"Tiwa\",'+
        '  \"userEmail\": \"abc@telstra.com\",'+
        '  \"orgName\": \"abc\",'+
        '  \"isPDUA\": \"false\",'+
        '  \"isDeactivate\": \"false\",'+
        ' \"pimsAPIType\": \"MANAGEUSER\",'+
        '  \"mobileNumber\": \"0419111000\"'+
        '}';
        
          

        
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        Account ac = new Account(name ='Telecom') ;
        insert ac; 
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active');
        insert con; 
		
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName = orgId + dateString + randomInt;

        User u1 = new User(alias = 'test123', email='test12345@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12345@noemail.com');
        
        insert u1;
        System.assertNotEquals(null,u1);
        
        String params = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'createorg'
        });
        
        
        test.starttest();
        ContinuationController.getVFBaseURL();
        ContinuationController.invoke(methodName, params);
        ContinuationController.invoke(methodName, params2);
        
        ContinuationController.WrapperState state= new ContinuationController.WrapperState();
         //ManagePIMSController.WrapperPageParameters pageParams =  (ManagePIMSController.WrapperPageParameters)JSON.deserialize((String)params, ManagePIMSController.WrapperPageParameters.class);
        WrapperMSPIMSParams.WrapperPageParameters pageParams = (WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String)params,
                                                                           WrapperMSPIMSParams.WrapperPageParameters.class);
        state.pageParams=pageParams;
        state.requestTime=DateTime.now(); //EDGE-127154 - CLF Changes
        ContinuationController.callbackPIMS(state);
       
        test.stoptest();
 

        
 
}
    }
}
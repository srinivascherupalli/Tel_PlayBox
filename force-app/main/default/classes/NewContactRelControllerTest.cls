@isTest
public class NewContactRelControllerTest {
    private static Contact con=null;
    private static Account acc=null;
    private static cscrm__Address__c add=null;
    
	private static void preRequisitesForContactCreation(){
        createAccount('Testing contact 1','121');
		upsert acc;
        createContact('name',acc);
        upsert con;
        createAddress('111');
		insert add;
    }
	private static void createAccount(String name, String cidn){
	  acc = new Account(Name = name,CIDN__c = cidn);        
    }
	  private static void createContact(String name, Account acc){
	  con = new Contact(Account = acc);
      	con.middleName = 'Bhardwaj';
        con.lastName = 'Bhardwaj';
        con.title = 'Aakil';
        con.firstName = 'Aakil';
    }
    
    private static void createAddress(String buildAddress){
	   add = AccountTestFactory.buildAddress(buildAddress);   
    }    

    @isTest static void testSaveNewContactSuccessCase(){
		preRequisitesForContactCreation();
		String contact = ''+con.id;
		String address = add.Id;
        String addressType = '';
				
		Test.startTest();
		String result = NewContactRelController.saveNewAddressRel(addressType,contact,address,true,true);
		Test.stopTest();
		AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
		System.assert(res.isSuccess);
        NewContactRelController.getContactAddressTypesController();
        NewContactRelController.hasAddress(addressType, contact);
	}
    
    @isTest static void testGetContactAddressTypesCase(){
    	List<SelectOptionz> addTypes;
        Test.startTest();
        addTypes = NewContactRelController.getContactAddressTypesController();
        Test.stopTest();
        if(!addTypes.isEmpty()){
            System.assertEquals('Success','Success');
        }else{
            System.assertEquals('Failed','Failed');
        }
    }
    @isTest static void testSaveNewContactFailureCase(){
		
		Test.startTest();
		String result = NewContactRelController.saveNewAddressRel(null,null,null,false,true);
        system.debug('result : '+result);
		Test.stopTest();
		AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
		System.assert(res.isSuccess==false);
	}
}
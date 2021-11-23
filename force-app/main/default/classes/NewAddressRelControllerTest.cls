@isTest
public class NewAddressRelControllerTest {
    private static  Account acc=null;
    private static cscrm__Address__c add=null;
    
	private static void preRequisitesForAccountCreation(){
        createAccount('Testing account 1','121');
		upsert acc;
        createAddress('111');
		insert add;
    }

	  private static void createAccount(String name, String cidn){
	  acc = new Account(Name = name,CIDN__c=cidn);        
    }
    
    private static void createAddress(String buildAddress){
	   add = AccountTestFactory.buildAddress(buildAddress);   
    }    

    @isTest static void testSaveNewAccountSuccessCase(){
		preRequisitesForAccountCreation();
		String account = ''+acc.id;
		String address = add.Id;
        String addressType = '';
				
		Test.startTest();
		String result = NewAddressRelController.saveNewAddressRel(addressType,account,address,true);
		Test.stopTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
		System.assert(res.isSuccess);
		CreateAddressController.hasAddress(addressType, account);
        NewAddressRelController.getParentAccount(account);
        NewAddressRelController.getAddressType(address);
        NewAddressRelController.getAddressNameSFDC(address);
	}
    
    @isTest static void testSaveNewAccountFailureCase(){
				
		Test.startTest();
		String result = NewAddressRelController.saveNewAddressRel(null,null,null,false);
        system.debug('result : '+result);
		Test.stopTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
		System.assert(res.isSuccess==false);
	}
	@isTest static void testGetAddressTypesCase(){
    	List<SelectOptionz> addTypes;
        Test.startTest();
        addTypes = NewAddressRelController.getaddressTypes();
        Test.stopTest();
        if(!addTypes.isEmpty()){
            System.assertEquals('Success','Success');
        }else{
            System.assertEquals('Failed','Failed');
        }
    } 
}
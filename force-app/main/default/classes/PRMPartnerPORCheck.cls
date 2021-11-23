//EDGE-151597
public class PRMPartnerPORCheck {
	@AuraEnabled
	public static Boolean checkActivePOR(String accountId) {
		try{
			Id usrId = userinfo.getUserId();
			Id partnerId;
			list<Partner_of_Record__c> lstPOR;
			list<User> usrLst = [SELECT Id, Contact.AccountId FROM User WHERE Id = :usrId];
			partnerId = usrLst[0].Contact.AccountId;
			lstPOR = [SELECT Id,Customer__c,Partner__c FROM Partner_of_Record__c WHERE 
                                    Customer__c = :accountId AND Partner__c = :partnerId AND Status__c = 'Active'];
			if(lstPOR.size() > 0){
				return true;
			}
			else{
				return false;
			}
		}
		catch(Exception e){
            system.debug('prmPartnerPORCheck'+e.getMessage());
			throw new AuraHandledException('Error Retrieving Data: '+ e.getMessage());
		}
	}
}
/*************************************************************************************************
Name : NonCommercialOrder
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             28-Oct-2020   EDGE-182452(new)
2. 		   Gnana			  30-Oct-2020	EDGE-182454 - Added logic to check eligible User for Non-Commercial Order
===============================================================================================================================
***************************************************************************************************/
public with sharing class NonCommercialOrder {
    
    //method to populate basket fields
     @AuraEnabled(cacheable=false)
    public static cscfga__Product_Basket__c getBasket(Id accountId){
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.BasketType__c=Label.Non_Commercial;
        if(accountId!=null){ 
            basket.csordtelcoa__Account__c=accountId;
        }
        return basket;
    }
     //method to create basket invoked from lwc noncommercialbasket
    @AuraEnabled(cacheable=false)
    public static String  CreateNonCommercialBasket (Id accountId){
        String basketId='';
        try{
            if(accountId!=null){    // create basket only when acc is not empty
                Sobject baskt = NonCommercialOrder.getBasket(accountId);
                basketId=sobjectFactory.insertSobject(baskt); 
         	}
        }catch(Exception e){
            system.debug('CreateNonCommercialBasket'+e.getMessage());
            throw new AuraHandledException('Error while CreateNonCommercialBasket: '+ e.getMessage());
        }
        return basketId;
    }
    

    // Logic to check eligible User for Non-Commercial Order - EDGE-182454

    @AuraEnabled
    public static Boolean checkEligibleUser(String accountId){
        try{
            Id usrId = userinfo.getUserId();
            Id profileId = UserInfo.getProfileId();
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
            if(profile.name == 'PRM Admin - Australia' || profile.name == 'PRM Community User - Australia'){
                Boolean checkActivePOR = checkActivePOR(usrId,accountId);
                return checkActivePOR;
            }
            else{
                return true;
            }
        }
        catch(Exception e){
            system.debug('prmPartnerPORCheck'+e.getMessage());
            throw new AuraHandledException('Error Retrieving Data: '+ e.getMessage());
        }
    }
    

    // Check ActivePOR for the Logged-In PRM User - EDGE-182454

	public static Boolean checkActivePOR(Id usrId, String accountId) {
		try{
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
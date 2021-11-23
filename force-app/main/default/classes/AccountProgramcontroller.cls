/* EDGE-201628 -Alexandria - 26/02/2021 
- Controller to display the Account Program Banner */

public with sharing class AccountProgramcontroller {
    
    @AuraEnabled 
    //START: Modified for EDGE-213096
    public Static Program_Account__c accountProgramlwc(String accId)
    {
        Program_Account__c programRec; 
        //END: EDGE-213096
        Account AccountRecord = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id=: accId];
        if(AccountRecord != null)
        {
            if(AccountRecord.RecordType.DeveloperName =='Enterprise')
            {
                //START: Modified for EDGE-213096
                programRec= AccountProgramHelper.checkaccountProgramdetails(accId);
                //END: EDGE-213096
            }
        }
        //START: Modified for EDGE-213096
        return programRec;
        //END: EDGE-213096
    }
    
    @AuraEnabled
    //START : DIGI-1520  
    public Static boolean getLoggedInUserLicense(){
        
        Boolean isInternalUser = true;
        string userLicense = [Select id,Profile.UserLicense.Name from User where Id =: userinfo.getUserId()].Profile.UserLicense.Name;
        if(userLicense == 'Partner Community'){
        	isInternalUser = false;    
        }
        return isInternalUser;   
    }
	//END : DIGI-1520 
	 
	@AuraEnabled//(cacheable=true) 
    public Static Map<string,Sobject> getCustomMetaDataValues()
    {
     	Map<string,Sobject> customMetadataRecordsMap = new Map<string,Sobject>();
        customMetadataRecordsMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');
        
        return customMetadataRecordsMap;
    }
}
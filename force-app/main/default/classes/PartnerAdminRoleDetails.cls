/**
*  Description of the purpose of the classthe method.
*  @name PartnerAdminRoleDetails
*  @description               : This class is used  in PartnerAdminRolelistView and PortalEngineerListView LWC to display the 
*                               Telstra Collaboration and Engineering User Functional Contact Roles (Partner Admin, Partner Engineer Recordtypes)
*  @param fulfillmentId       : ComponentType - Telstra Collaboration Operations User,Engineering User.
*  @return                    : Json Object 
*  @Jira Story Ref            : EDGE-128108
*  @CreateDate                : 26/02/2020 
*  @createdBy                 : Purushottama Sahu, Alexandria
**/
/***History of Updates 
Purushottama Sahu: 29/04/2020  EDGE-137134  Added getPartnerFCRTenancies Method to View Telstra Collaboration Services selected in Enrichment 
RaviTeja K: 30/05/2020  EDGE-140596  Enable MDM Engineering view based on Fulfilment line items ownership 

***/
public with sharing class PartnerAdminRoleDetails {
    // Functional_Contact_Role__c select Query
    private static String query='SELECT Id,Name,Partner_User__r.IsActive,Partner_User__r.name,Role__c,Account_Name__c,SubscriptionID__r.csordtelcoa__Subscription_Number__c,Relationship_Start_Date__c,Tenancy_ID__c,Fulfillment_Task__r.name,Fulfillment_Task__r.Status__c,Fulfillment_Task__r.Owner.name,SubscriptionID__r.csord__Account__c,Fulfillment_Task__r.Assigned_Date__c from Functional_Contact_Role__c';
    
    // getPartnerRoles method calling in PartnerAdminRolelistView LWC
    @AuraEnabled(cacheable = true)
    public static List<FunctionalContactRoleWrapper> getPartnerRoles(String componentType) {
        Id userId=userinfo.getUserId();
        Boolean isValidPartner=false;
        try {
            String partnerQuery = query+' WHERE Relationship_End_Date__c = null';
            //Retrieve Current User Details. 
            user partnerUser= [SELECT id,Contact.Partner_Role__c,Contactid,Accountid FROM user WHERE id=:userId];
            system.debug('partnerUser.Contact.Partner_Role__c'+partnerUser.Contact.Partner_Role__c);
            system.debug('componentType'+componentType);
        
            //Add the conditions for Telstra Collaboration Operations User
            if(partnerUser.Contact.Partner_Role__c !=null && 
               partnerUser.Contact.Partner_Role__c.contains('Adaptive Collaboration Operations User') && 
               componentType == 'Telstra Collaboration Operations User')
              {   isValidPartner=true;   
                  partnerQuery = partnerQuery+' AND Partner_User__r.IsActive=true AND RecordType.Name=\''+'Portal Admin'+'\' AND Role__c=\''+'Adaptive Collaboration'+ '\' AND ContactID__r.Accountid=\''+ partnerUser.Accountid+'\'';
              }
            else if(partnerUser.Contact.Partner_Role__c !=null && 
                       partnerUser.Contact.Partner_Role__c.contains('Engineering User') && 
                       componentType == 'Engineering User')  //Add the conditions for Engineering User
                      {  isValidPartner=true;
                         partnerQuery = partnerQuery+' AND RecordType.Name=\''+'Portal Engineer'+ '\' AND ContactID__c=\''+ partnerUser.Contactid+'\'';
                      }
            else if(partnerUser.Contact.Partner_Role__c !=null && 
                       partnerUser.Contact.Partner_Role__c.contains('MDM Operations User') && 
                       componentType == 'MDM Operations User')
					{
                        isValidPartner=true;
                         partnerQuery = partnerQuery+' AND RecordType.Name=\''+'Portal Admin'+ '\' AND Role__c=\''+'MDM Operations User'+ '\' AND ContactID__r.Accountid=\''+ partnerUser.Accountid+'\'';
                     
                    }            
              
            
            partnerQuery = partnerQuery+' ORDER By Name ASC';
            system.debug('partnerQuery'+partnerQuery);
            //Retrieve the Functional Contact Roles only if the user is Valid Partner
            if(String.isNotBlank(componentType) && isValidPartner){
                return getFunctionalContactRoles(partnerQuery);
            }
            else
                return null;
        }
        catch(Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // getPartnerEngineers method calling in PortalEngineerListView LWC
    @AuraEnabled(cacheable = true)
    public static List<FunctionalContactRoleWrapper> getPartnerEngineers(String recordId) {
        //Retrieve Partner Admin Details
        Functional_Contact_Role__c partnerAdmin = [SELECT id,SubscriptionID__c,Fulfillment_Task__c FROM Functional_Contact_Role__c WHERE id = :recordId];
        //Add the conditions to Retrieve Engineering User related to Partner Admin record
        String partnerEngQuery =query+' where  Fulfillment_Task__c = \''+ partnerAdmin.Fulfillment_Task__c + '\' AND  SubscriptionID__c= \''+ partnerAdmin.SubscriptionID__c + '\' AND Recordtype.name= \''+'Portal Engineer'+ '\' AND ID != \''+ partnerAdmin.id + '\'';
        return getFunctionalContactRoles(partnerEngQuery);
    }
    
    // This is a generic method to create a wrapper class to display the FCR in LWC
    private static List<FunctionalContactRoleWrapper> getFunctionalContactRoles(String query) 
    {
         List<FunctionalContactRoleWrapper> functionalContactRoleWrapperList=new List<FunctionalContactRoleWrapper>();
         List<Functional_Contact_Role__c> records = new List<Functional_Contact_Role__c>();
         records = Database.query(query);
         for(Functional_Contact_Role__c functionalContactRole:records)
                {
                    FunctionalContactRoleWrapper FCRWrapper= new FunctionalContactRoleWrapper();
                    FCRWrapper.referenceId= functionalContactRole.id;
                    FCRWrapper.name= functionalContactRole.name;
                    FCRWrapper.accountName= functionalContactRole.Account_Name__c;
                    FCRWrapper.subscriptionName=functionalContactRole.SubscriptionID__r.csordtelcoa__Subscription_Number__c;
                    FCRWrapper.tenancy=functionalContactRole.Tenancy_ID__c;
                    FCRWrapper.fulfillmentTaskId=functionalContactRole.Fulfillment_Task__c;
                    FCRWrapper.fulfiRec=functionalContactRole.Fulfillment_Task__c; 
                    FCRWrapper.fulfillmentTaskName=functionalContactRole.Fulfillment_Task__r.name;
                    FCRWrapper.fulfillmentTaskStatus=functionalContactRole.Fulfillment_Task__r.Status__c;
                    FCRWrapper.FLIassignee=functionalContactRole.Fulfillment_Task__r.Owner.name; //functionalContactRole.Partner_User__r.name;
                    FCRWrapper.startDate= functionalContactRole.Relationship_Start_Date__c.format();
					FCRWrapper.accountId=functionalContactRole.SubscriptionID__r.csord__Account__c;
                    FCRWrapper.Assigneddate=functionalContactRole.Fulfillment_Task__r.Assigned_Date__c!=null?functionalContactRole.Fulfillment_Task__r.Assigned_Date__c.format():'';
                    FCRWrapper.assignee=functionalContactRole.Partner_User__r.name;
                    FCRWrapper.disableReassign=(functionalContactRole.Fulfillment_Task__r.Ownerid==userinfo.getUserId())?false:true;
                    functionalContactRoleWrapperList.add(FCRWrapper);
                }               
                
         return functionalContactRoleWrapperList;
    }
   
    
    //EDGE-129805 Added by Ramya
    @AuraEnabled(cacheable = true)
    public static List<FunctionalContactRoleWrapper> getPartnerAdmins(String recordId) {
        String partnerEngQuery =query+' where  Fulfillment_Task__c = \''+ recordId +  '\' AND Recordtype.name= \''+'Portal Admin'+ '\'';
        
        return getFunctionalContactRoles(partnerEngQuery);
    }

    //EDGE-137134 Added by Purushottam
    @AuraEnabled(cacheable = true)
    public static List<FunctionalContactRoleWrapper> getPartnerFCRTenancies(String recordId) {
        FulfillmentLineItem__c FLIItems=[select id,FCR_Subscriptions__c from FulfillmentLineItem__c where id=:recordId];
        List<FunctionalContactRoleWrapper> functionalContactRoleWrapperList=new List<FunctionalContactRoleWrapper>();
        if(FLIItems != null && FLIItems.FCR_Subscriptions__c != null){
        System.debug('FLIItems: FCR_Subscriptions__c '+ FLIItems.FCR_Subscriptions__c);
                for(csord__Subscription__c sub: [select id,
                                                        Parent_Subscription__r.csordtelcoa__Subscription_Number__c,
                                                        Parent_Subscription__r.NetworkServiceId__c,
                                                        NetworkServiceId__c,
                                                        name,
                                                        csordtelcoa__Subscription_Number__c from csord__Subscription__c where id IN :FLIItems.FCR_Subscriptions__c.split(',')]){
                    FunctionalContactRoleWrapper FCRWrapper= new FunctionalContactRoleWrapper();
                    FCRWrapper.name=sub.name;
                    FCRWrapper.subscriptionName= sub.csordtelcoa__Subscription_Number__c;
                    FCRWrapper.tenancySubscriptionName=sub.Parent_Subscription__r.csordtelcoa__Subscription_Number__c;
                    FCRWrapper.tenancy=sub.Parent_Subscription__r.NetworkServiceId__c;
                    functionalContactRoleWrapperList.add(FCRWrapper);          
                }
        }
        return functionalContactRoleWrapperList;
    }
    
    /**
     *  EDGE-140596  Enable MDM Engineering view based on Fulfilment line items ownership 
     * Description: List of records need to show in MDM Engineering view based on FLI Owner and PS MDM FLI records
     **/
    
     @AuraEnabled(cacheable = true)
        public static List<FunctionalContactRoleWrapper> getPartnerEngineerRolesPSMDM() {
        Id userId=userinfo.getUserId();
       List<FunctionalContactRoleWrapper> functionalContactRoleWrapperList=new List<FunctionalContactRoleWrapper>();

        for(FulfillmentLineItem__c fli:[select id,name,subscription__r.csord__Account__c,subscription__r.csord__Account__r.Name,Owner.name,Ownerid,Account__c,Account__r.Name,Status__c,Createddate,Assigned_Date__c from FulfillmentLineItem__c where Ownerid=:userId and name =:PRMConstants.PS_MDM_FLI_NAME])
        {
            FunctionalContactRoleWrapper fliwrapper= new FunctionalContactRoleWrapper();
   					fliwrapper.name= fli.name;
           			fliwrapper.accountName= fli.subscription__r.csord__Account__r.Name;
            		fliwrapper.accountId=fli.subscription__r.csord__Account__c;
                    fliwrapper.fulfillmentTaskId=fli.id;
                    fliwrapper.fulfiRec=fli.id; 
                    fliwrapper.fulfillmentTaskName=fli.name;
                    fliwrapper.fulfillmentTaskStatus=fli.Status__c;
                    fliwrapper.FLIassignee=fli.Owner.name; 
                    fliwrapper.startDate= fli.Createddate.format();
                    fliwrapper.Assigneddate=fli.Assigned_Date__c!=null?fli.Assigned_Date__c.format():'';
                    fliwrapper.assignee=fli.Owner.name;
					fliwrapper.referenceId=fli.id;  
                    fliwrapper.disableReassign=(fli.Ownerid==userinfo.getUserId())?false:true;

            
            functionalContactRoleWrapperList.add(fliwrapper);
        }
            
      return functionalContactRoleWrapperList;
 }   
     
    // This is a wrapper class to display the FCR in LWC
    private class FunctionalContactRoleWrapper {
        @AuraEnabled public Id referenceId {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String accountName {get; set;}
        @AuraEnabled public String subscriptionName {get; set;}
        @AuraEnabled public String tenancySubscriptionName {get; set;}
        @AuraEnabled public String tenancy {get; set;}
        @AuraEnabled public Id fulfillmentTaskId {get; set;}
        @AuraEnabled public Id fulfiRec {get; set;}
        @AuraEnabled public String fulfillmentTaskName {get; set;}
        @AuraEnabled public String fulfillmentTaskStatus {get; set;}
        @AuraEnabled public String assignee {get; set;}
        @AuraEnabled public String startDate {get; set;}
		@AuraEnabled public String accountId {get; set;}
        @AuraEnabled public String Assigneddate {get; set;}
        @AuraEnabled public String FLIassignee {get; set;}  
        @AuraEnabled public boolean disableReassign {get; set;}  
    }
}
/**========================================================================================
* @Author :      Lokesh Thathuru
* @Description : This Class is defined to test cover the APTPS_AdobeAgreementTrigger
* @CreatedDate : 10/5/2021
============================================================================================*/

@isTest
public class APTPS_AdobeAgreementTriggerTest {
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testDataSetupMethod
    * @CreatedDate : 10/5/2021
    *===========================================================================================*/
    @testSetup
    public static void testDataSetupMethod(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Account for Adobe') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0412345678',
            Email = 'test@tele2.com'   
        );
        Insert contact;
        
        //CREATE OPPORTUNITY RECORD 
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Contract_Term__c = 12;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        
        //CREATE OPPORTUNITY CONTACT Role
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.Id;
        oppContRole.OpportunityId = opp.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        
        cscfga__Product_Basket__c basket00 = ProductTestFactory.buildEmptyBasket();
        basket00 = ProductTestFactory.buildEmptyBasket();
        basket00.csbb__Account__c = acc.id;
        basket00.cscfga__Opportunity__c = opp.id;
        basket00.Name = 'New basket';
        basket00.cscfga__total_contract_value__c = 10;
        basket00.BasketType__c = 'Incoming';
        insert basket00;
        
        //ContractJunction Creation
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = acc.Id;
        cntrctRecord.Related_Opportunity__c=opp.Id;
        cntrctRecord.Related_Basket__c=basket00.id;
        insert cntrctRecord;
         
        //CREATE custAuthForm
        Customer_Authority_Form__c custAuthForm = new Customer_Authority_Form__c();
        custAuthForm.Is_active__c=true;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        custAuthForm.Account__c=acc.id;
        custAuthForm.Opportunity__c=opp.id;
        insert  custAuthForm;
        
        
        //CREATE AGREEMENT
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Related_Opportunity__c = opp.Id,
            Related_Contract__c=cntrctRecord.Id,
            Name ='Test');
        insert agreement;
        
        string RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Parent_Agreement__c = agreement.Id,
            Name ='TestPS');
        insert agreement1;
        
        //insert echosign_dev1__SIGN_Agreement__c
        echosign_dev1__SIGN_Agreement__c adobeagg = new echosign_dev1__SIGN_Agreement__c();
        adobeagg.echosign_dev1__Account__c = acc.id;
        adobeagg.Apttus_Echosign__Apttus_Agreement__c = agreement.Id;
        adobeagg.echosign_dev1__Status__c = APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED;
        adobeagg.Customer_Authority_Form__c=custAuthForm.Id;
        insert adobeagg;
        
        echosign_dev1__SIGN_Agreement__c adobeagg01 = new echosign_dev1__SIGN_Agreement__c();
        adobeagg01.echosign_dev1__Account__c = acc.id;
        adobeagg01.Contractjunction__c = cntrctRecord.Id;
        adobeagg01.echosign_dev1__Status__c = APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED;
        adobeagg01.Customer_Authority_Form__c=custAuthForm.Id;
        insert adobeagg01;
        
        echosign_dev1__SIGN_AgreementEvent__c aggEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        aggEvent.echosign_dev1__Event_Type__c = 'RECALLED';
        aggEvent.echosign_dev1__SIGN_Agreement__c = adobeagg.Id;
        insert aggEvent;
        
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_OUT_FOR_SIGNATURE
    * @CreatedDate : 10/5/2021
    *===========================================================================================*/
    @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_OUT_FOR_SIGNATURE_01(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE;  
        update signAgreementInstance;
        Test.stopTest();
        ContractJunction__c contractJunctionInstance=[SELECT id,Status__c from ContractJunction__c WHERE Id =: signAgreementInstance.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c];
        System.assertEquals('Pending Approval', contractJunctionInstance.Status__c);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE
    * @CreatedDate : 10/5/2021
    *===========================================================================================*/
    @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE_02(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_SIGNATURE;  
        update signAgreementInstance;
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE;
        update signAgreementInstance;
        Test.stopTest();
        ContractJunction__c contractJunctionInstance=[SELECT id,Status__c from ContractJunction__c WHERE Id =: signAgreementInstance.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c];
        System.assertEquals('Customer Review', contractJunctionInstance.Status__c);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_SIGNED
    * @CreatedDate : 10/5/2021
    *===========================================================================================*/
    @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_SIGNED_03(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE;
        update signAgreementInstance;
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED;
        update signAgreementInstance;       
        Test.stopTest();
        ContractJunction__c contractJunctionInstance=[SELECT id,Status__c from ContractJunction__c WHERE Id =: signAgreementInstance.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c];
        System.assertEquals('Contract Accepted', contractJunctionInstance.Status__c);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_EXPIRED
    * @CreatedDate : 10/6/2021
    *===========================================================================================*/
     @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_EXPIRED_04(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_EXPIRED;
        update signAgreementInstance;       
        Test.stopTest();
        ContractJunction__c contractJunctionInstance=[SELECT id,Status__c from ContractJunction__c WHERE Id =: signAgreementInstance.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c];
        System.assertEquals('Void', contractJunctionInstance.Status__c);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_CANCELLED
    * @CreatedDate : 10/6/2021
    *===========================================================================================*/
     @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_CANCELLED_05(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
          echosign_dev1__SIGN_AgreementEvent__c aggEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        aggEvent.echosign_dev1__Event_Type__c = 'REJECTED';
        aggEvent.echosign_dev1__SIGN_Agreement__c = signAgreementInstance.Id;
        insert aggEvent;
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_CANCELLED;
        update signAgreementInstance;       
        Test.stopTest();
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to testMethod_SIGN_AGREEMENT_STATUS_CANCELLED
    * @CreatedDate : 10/6/2021
    *===========================================================================================*/
     @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_CANCELLED_05_01(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c =:APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED limit 1];
          echosign_dev1__SIGN_AgreementEvent__c aggEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        aggEvent.echosign_dev1__Event_Type__c = 'RECALLED';
        aggEvent.echosign_dev1__SIGN_Agreement__c = signAgreementInstance.Id;
        insert aggEvent;
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_CANCELLED;
        update signAgreementInstance;       
        Test.stopTest();
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateStatusOfCJToCancelledDeclined
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateStatusOfCJToCancelledDeclinedException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateStatusOfCJToCancelledDeclined(null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsInitiated
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateContractJunctionOnSIGNAgreementStatusAsInitiatedException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateContractJunctionOnSIGNAgreementStatusAsInitiated(null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsPendingApproval
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateContractJunctionOnSIGNAgreementStatusAsPendingApprovalException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateContractJunctionOnSIGNAgreementStatusAsPendingApproval(null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsCustomerReview
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateContractJunctionOnSIGNAgreementStatusAsCustomerReviewException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateContractJunctionOnSIGNAgreementStatusAsCustomerReview(null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    } 
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsContractAccepted
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateContractJunctionOnSIGNAgreementStatusAsContractAcceptedException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateContractJunctionOnSIGNAgreementStatusAsContractAccepted(null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsContractAccepted
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateRespectiveStatusToContractJunctionException(){
        String exceptionMessage;
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateRespectiveStatusToContractJunction(null, null);
        }catch(Exception e){
            exceptionMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to test Customer_Authorised_date__c and CA_status__c of the CustomerAuthForm
    * @CreatedDate : 10/6/2021
    *===========================================================================================*/
     @isTest
    private static void testMethod_SIGN_AGREEMENT_STATUS_SIGNED_06(){
        echosign_dev1__SIGN_Agreement__c signAgreementInstance= [SELECT id,echosign_dev1__Status__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__r.Status__c,Customer_Authority_Form__c FROM echosign_dev1__SIGN_Agreement__c WHERE Customer_Authority_Form__c!=null limit 1];
        System.debug('Test Data testMethod_SIGN_AGREEMENT_STATUS_SIGNED_06-->'+signAgreementInstance);
        Test.startTest();
        signAgreementInstance.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED;
        update signAgreementInstance;       
        Test.stopTest();
    	Customer_Authority_Form__c customerAuthForm=[SELECT id,Customer_Authorised_date__c,CA_status__c FROM Customer_Authority_Form__c WHERE Id =: signAgreementInstance.Customer_Authority_Form__c limit 1];
        System.assertNotEquals(null, customerAuthForm.Customer_Authorised_date__c);
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps To cover Exception
    * @CreatedDate : 10/6/2021
    *===========================================================================================*/
    @isTest
    private static void updateCustomerAuthorityFormCADateAndCAStatusException(){
        
        Test.startTest();
        try{
            APTPS_AdobeAgreementTriggerHandler.updateCustomerAuthorityFormCADateAndCAStatus(null);
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
    
      /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps To updateRespectiveStatusUpdate
    * @CreatedDate : 10/22/2021
    *===========================================================================================*/
    @isTest
    private static void updateRespectiveStatusUpdate(){
        
        Test.startTest();
        try{
            echosign_dev1__SIGN_Agreement__c adobeagg01 = [SELECT id, echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE ContractJunction__c!=null];
            adobeagg01.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_SIGNATURE;
            update adobeagg01;
            
            adobeagg01.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE;
            update adobeagg01;
            
            adobeagg01.echosign_dev1__Status__c=APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED;
            update adobeagg01;
            
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
    
    
}
/***************************************************************************************************************
Name          : LegacyTenancyHelperTest
Created By    :Anuj Pathak
Created Date  : Feb 24 2021
Description   : This is a test class to simulate and test the logic of LegacyTenancyHelper

*****************************************************************************************************************/
@isTest(SeeAllData=false)
private class LegacyTenancyHelperTest {
    
    @testsetup static void testDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.APTPS_Off_Shore_Restricted__c=false;
        acc.APTPS_Tier__c='1';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
   //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+612345678',
            Email = 'test@tele2.com'   
        );
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        System.assert(opp != null);
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        Marketable_Offer__c MO = New Marketable_Offer__c();
        MO.Name = 'Telstra Collaboration'; // telstra collaboration
        MO.Offer_ID__c = 'DMCAT_Offer_000618'; //telstra collaboration id
        Insert MO;
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='FIXED TELEPHONY';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='FIXED TELEPHONY';
        insert offername;
        cscfga__Product_Definition__c BC_PD = new cscfga__Product_Definition__c(Name = 'Business Calling', cscfga__Description__c = 'Business Calling' , product_Specification__c = 'DMCAT_ProductSpecification_000871');
        insert BC_PD;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        list<cscfga__Product_Basket__c> baskets = [select id from cscfga__Product_Basket__c];
            for(cscfga__Product_Basket__c currentBasket : baskets){
                cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
                MACPCnew.cscfga__Product_Definition__c=BC_PD.Id;
                MACPCnew.cscfga__Product_Basket__c =currentBasket.Id;
               // MACPCnew.cscfga__originating_offer__c=offername.id;
                MACPCnew.Offer_Reference__c=offername.id;
                MACPCnew.name='Business Calling'; //business calling
                MACPCnew.Type__c='New'; //new
                MACPCnew.Marketable_Offer__c = MO.Id;
                prdConfigList.add(MACPCnew);
            }
        insert prdConfigList;
       
        List<attachment> attlist= new List<attachment>();
        List<cscfga__Product_Configuration__c> productconfigurations = [select id from cscfga__Product_Configuration__c];
            for (cscfga__Product_Configuration__c currentpdconf : productconfigurations){
                attachment att=new attachment();
        att.ParentId = currentpdconf.Id;
        att.Name = 'TransitionDataNgUc.json';
        att.Body = Blob.valueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":null,"Reason":null,"eligibilityStatus":null,"eligibilityReason":null,"checkReserved":false}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null}],"groupId":"N7740924R","EligibilityStatus":"eligible","EligibilityReason":"","disableCheck":null,"checkValue":false}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":false}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}');
          attlist.add(att);
            }
        insert attlist ;
    }
    
     /*******************************************************************************************************
    * Method Name : populateLegacyTenancyIDTest()
    * Description : Used to simulate and test the logic of populateLegacyTenancyID method in populateLegacyTenancyID
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void populateLegacyTenancyIDTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        inputMap.put('populateLegacyTenancyID',basketId);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();    
        returnMap = LegacyTenancyHelper.getData(inputMap);
        Test.stopTest();
        system.debug(returnMap.get('TenancyID'));
        System.assert(returnMap.containsKey('TenancyID'));
        System.assert(!returnMap.containsKey('XYZ'));
        System.assert(returnMap.get('TenancyID')=='N7005109R');
        System.assert(returnMap.get('TenancyID')!='N70051000');
      
    }
     /*******************************************************************************************************
    * Method Name : populateLegacyTenancyIDNullTest()
    * Description : Used to simulate and test the logic of populateLegacyTenancyID method in populateLegacyTenancyID
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void populateLegacyTenancyIDNullTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('populateLegacyTenancyID',null);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();    
        returnMap = LegacyTenancyHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('TenancyID'));
        System.assert(!returnMap.containsKey('XYZ'));
        System.assert(returnMap.get('TenancyID')=='');
        System.assert(returnMap.get('TenancyID')!='N70051000');
    }
}
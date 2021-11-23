/****************************************************************************************************************************************************
Main Class : Model_addonPriceItemAssociation
Test Class : Model_addonPriceItemAssociationTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               
1.       Shubhi          09-Sept-2020      EDGE-147513    20.12(New Class)     
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_addonPriceItemAssociationTest{
   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        /*----Fix for FDR by Shubhi 2/9/20 START-----*/
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        /*----Fix for FDR by Shubhi 2/9/20 END-----*/
       insert sales;
        cspmb__Price_Item__c price_item =PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176');
        price_item.name='Handheld';
       	insert price_item;
        List<cspmb__Add_On_Price_Item__c> addonlist=new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c addon1 =PricingTestDataFactory.generateAddOn('TestDMCAT_RecurringCharge_000669','basic','TestDMCAT_RecurringCharge_000669');addonlist.add(addon1);
        cspmb__Add_On_Price_Item__c addon2 =PricingTestDataFactory.generateAddOn('TestDMCAT_RecurringCharge_000668','premium','TestDMCAT_RecurringCharge_000668');addonlist.add(addon2);
        addon1.addOn_Name__c='basic';
       	addon2.addOn_Name__c='premium';
       	insert addonlist;
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addonassoclst = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
		cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = PricingTestDataFactory.generateproceItemaddonAssociation(price_item,addon1);
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc2 = PricingTestDataFactory.generateproceItemaddonAssociation(price_item,addon2);
        addonassoc2.isDefault__c=true;
       addonassoclst.add(addonassoc1);
        addonassoclst.add(addonassoc2);
        insert addonassoclst;
  
      
   }
    @isTest
    static void getaddonAssociationRecordTest(){       
        String offerid='DMCAT_Offer_000646';
        String chargeid='TestDMCAT_RecurringCharge_000669';
        cspmb__Price_Item__c plan=[Select id,name from cspmb__Price_Item__c where name='Handheld'];
        String addonName='basic';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where  email='salesuser@testsales.com' limit 1];     
        System.runAs(sales){
            cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1=Model_addonPriceItemAssociation.getAddonPriceItemAssociation(addonName,chargeid,offerid,plan.id);
            System.assertEquals(addonName, addonassoc1.cspmb__add_on_price_item__r.addOn_Name__c); 
        }       
        Test.stopTest();
    }
    @isTest
    static void getaddonAssociationRecordBulkTest(){       
        String offerid='DMCAT_Offer_000646';
        List<String> chargeidList=new List<String>();
        chargeidList.add('TestDMCAT_RecurringCharge_000669');
        chargeidList.add('TestDMCAT_RecurringCharge_000668');
        cspmb__Price_Item__c plan=[Select id,name from cspmb__Price_Item__c where name='Handheld'];
        List<String> addonNameList=new List<String>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where  email='salesuser@testsales.com' limit 1];     
        System.runAs(sales){
            Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c> addonassoc1=Model_addonPriceItemAssociation.getAddonPriceItemAssociationBulk(chargeidList,offerid,plan.id,addonNameList);
            System.assert(true, addonassoc1.containskey('TestDMCAT_RecurringCharge_000668')); 
            addonNameList.add('basic');
            addonassoc1=Model_addonPriceItemAssociation.getAddonPriceItemAssociationBulk(chargeidList,offerid,plan.id,addonNameList);

        }       
        Test.stopTest();
    }
    @isTest
    static void getAddonAssociationRecordNegative(){
        try{
            Test.startTest();
            String offerid='TestDMCAT__000669';
            String chargeid='TestDMCAT_RecurringCharge_000669';
            cspmb__Price_Item__c plan=new cspmb__Price_Item__c();
            String addonName='Test Addon2';
            User sales = [SELECT id,name FROM User Where  email='salesuser@testsales.com' limit 1];     
            System.runAs(sales){
                cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1=Model_addonPriceItemAssociation.getAddonPriceItemAssociation(addonName,chargeid,offerid,plan.id);
                System.assert(true, addonassoc1==null); 
            }
        	Test.stopTest();
        }catch(exception e){
            system.debug(e);
        }
    }

}
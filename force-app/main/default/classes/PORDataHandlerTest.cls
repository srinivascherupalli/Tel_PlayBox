@isTest
public class PORDataHandlerTest {
    @testSetup static void createTestData() {
        PRMTestUtility.createPartnerOfRecords(1, new List<String> {'Mobile'});
        user SysUser =[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        
        System.runAs(SysUser){
            cscfga__Product_Category__c prodCatgryAMDevice  =   new cscfga__Product_Category__c();
            prodCatgryAMDevice.Name                         =   'Adaptive Mobility Device';
            prodCatgryAMDevice.Product_Family_Level_1__c    =   'Mobile';
            insert prodCatgryAMDevice;
            
            Marketable_Offer__c moAMDevAcc                  =   new Marketable_Offer__c();
            moAMDevAcc.OfferDefinationName__c               =   'Next Generation Enterprise Mobility';
            moAMDevAcc.Name                                 =   'Standalone Devices and Accessories';
            moAMDevAcc.Offer_ID__c                          =   'DMCAT_Offer_001231';
            moAMDevAcc.Product_Category__c                  =   prodCatgryAMDevice.Id;
            insert moAMDevAcc;     
        }
    }
    @istest public static void getPORCategoriesTest() 
    {	
        System.Test.starttest();
        Partner_of_Record_Domain__c porDomain= [select id,Partner_of_Record__c from Partner_of_Record_Domain__c limit 1];
        porDomain.Status__c='Customer Review';
        update porDomain;
        PORDataHandler dataHandler= new PORDataHandler();
        List<Map<String,Object>> rows =dataHandler.getPORCategories(porDomain.Partner_of_Record__c, null);
        System.assert(rows.isEmpty() == false);
        System.Test.stopTest();
    }
}
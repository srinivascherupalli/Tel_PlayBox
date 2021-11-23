@isTest
public class ValidatePRMBasketOperationsTest {
    @isTest(seeAllData=true)   
    static void checkActivePORTest(){
        PRMTestUtility.createPartnerOfRecords(2, new List<String> {'Mobile'});        
        user SysUser =[select id from user where profile.name='System Administrator' and isactive=true  order by  createddate desc limit 1];
        
        System.runAs(SysUser){  
            System.Test.starttest();
            Partner_of_Record__c porRecord=[select id,Customer__c,Partner_Signatories__c,Customer_Signatories__c from Partner_of_Record__c where Status__c='Active' AND Customer_Signatories__r.MobilePhone = '+61123456789' order by  createddate desc limit 1 ];
            Partner_of_Record__c porRecord2=[select id,Customer__c,Partner_Signatories__c from Partner_of_Record__c where Status__c='Active' and id != :porRecord.id AND Customer_Signatories__r.MobilePhone = '+61123456789' order by  createddate desc limit 1 ];
            porRecord2.Customer__c=porRecord.Customer__c;
            System.debug('Print the porRecord->'+porRecord.Customer__c);
            porRecord2.Customer_Signatories__c=porRecord.Customer_Signatories__c;
            update porRecord2;
            
            user partnerUser =[select id from user where profile.name='PRM Community User - Australia' and isactive=true and contactid=:porRecord.Partner_Signatories__c order by  createddate desc limit 1];
            Account acc = [select id from Account where id=:porRecord.Customer__c];
            Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
            opp.Product_Type__c = 'Modular';
            opp.Accountid=porRecord.Customer__c;
            opp.SubmittoPartnerStatus__c='Approved';
            opp.OwnerId=partnerUser.id;
            insert opp;
            opp.Accountid=porRecord.Customer__c;
            update opp;
            system.debug('After update-->'+opp.AccountId);
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.csbb__Account__c = porRecord.Customer__c;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'IoT Basket';
            basket.Device_Care_Contact__c =porRecord.Customer_Signatories__c;
            basket.cscfga__Basket_Status__c = 'valid';
            basket.Order_Requester__c =porRecord.Customer_Signatories__c;
            basket.csordtelcoa__Basket_Stage__c ='Draft';
            basket.csbb__Synchronised_with_Opportunity__c =true;
            insert basket;
            cscfga__Product_Basket__c basketObj= [select recordType.Name,id,Opportunity_Type__c,cscfga__Product_Basket__c.csordtelcoa__Change_Type__c,Primary_Basket__c,cscfga__Opportunity__r.AccountId,cscfga__Opportunity__r.Basket_Redemption_amount__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Account__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,Name,Device_Care_Contact__c from cscfga__Product_Basket__c where id=:basket.id limit 1];
            basket.cscfga__Opportunity__c = opp.id;
            update basket;
            String basketId = basket.id;
            
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
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,csedm__CFS_Mapping_List__c = 'TestSpec',Marketable_Offer__c= moAMDevAcc.id);
            insert pc1;
            
            list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [
                SELECT id, Name, OfferName__c,Type__c,Marketable_Offer__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c,Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c  
                FROM cscfga__Product_Configuration__c
                WHERE cscfga__Product_Basket__c = :basketId 
            ];
            
            System.runAs(partnerUser){
                ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
                string response = bs.performValidation(basketObj,prodConfigList,'contract');
                string response1 = ValidatePRMBasketOperations.checkActivePOR(basketObj,prodConfigList);
                system.assertEquals(true,response1.contains('Ok'));
            }
            
            Partner_of_Record_Domain__c porDomain= [select id from Partner_of_Record_Domain__c where Partner_of_Record__c=:porRecord.id AND Status__c='Active' limit 1];
            delete porDomain;
            
            System.runAs(partnerUser){
                string response1 = ValidatePRMBasketOperations.checkActivePOR(basketObj,prodConfigList);
                system.assertEquals(true,response1.contains('error'));
            }
            System.Test.stopTest();
        }
    }
}
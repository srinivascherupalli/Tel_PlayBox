/**
* Author: Sandeep Soni
* Team: Jaipur
* Sprint: 20.12
* JIRA Story: P2OB-8394
* Date: 27 Aug 2020
* Class Name: UserTerritory2AssContTest
* Description: Test class for UserTerritory2AssociationController
* @Last Modified	:   02/09/2021 21.12 by Chhaveel, Team SFO
					    as part of DIGI-14600 Sales Territory to reflect the same recursive model as the Service Territory
**/
@isTest(SeeAllData = false)
public class UserTerritory2AssContTest {
    /**
* Method Name: createTestData
* Description: This method will create test data
*/
    @TestSetup
    static void createTestData(){
        integer recordCount = 2;
        //Fetching account record type
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        //Fetching profile id
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        List<Account> lstAcc = new List<Account>();
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC'});
        insert territories;
        //Creating user
        List<User> lstuser = soc_TestUtility.createListUser(recordCount, p.Id);
        insert lstuser;
        //validating lstuser is not null and has size more than 0
        if(lstuser!=null && lstuser.size()>0){
            //creating a record using specific user
            System.runAs(lstuser.get(0)){
                //creating account record
                lstAcc = soc_TestUtility.createListAccount(recordCount, accRecordTypeId);
                //validating lstAcc is not null and size is greater than zero.
                if(lstAcc!=null && lstAcc.size()>0){
                    lstAcc.get(0).Portfolio_Code__c = 'ABC';
                    //creating new account record
                    Insert lstAcc;
                    /*
                    Territory2Model terrModel = new Territory2Model();
                    terrModel.DeveloperName='ModelName'; // required field
                    terrModel.Name = 'Name'; // required field
                    //creating Territory2Model record.
                    insert terrModel ;*/
                    Id modelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
                    //Fetching Territory2Type record
                    List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1];
                    //Creating Territory2 record.

                    List<Territory2> TerrObj = new List<Territory2>();
                    Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=modelId, Name='CSDTestTerritory', Territory2TypeId=terriType.get(0).Id);
                    Territory2 objTerr1 = new Territory2(DeveloperName = 'TestTerritory1', Territory2ModelId=modelId, Name='UAT01', Territory2TypeId=terriType.get(0).Id);
					TerrObj.add(objTerr);
					TerrObj.add(objTerr1);
                    insert TerrObj;
                    
                    //Creating UserTerritory2Association record
                    UserTerritory2Association uta = new UserTerritory2Association();
                    uta.Territory2Id = objTerr.Id;
                    uta.RoleInTerritory2 = 'Specialist';
                    uta.UserId = lstuser.get(0).id;
                    insert uta;
                    ObjectTerritory2Association ota = new ObjectTerritory2Association();
                    ota.ObjectId = lstAcc.get(0).id;
                    ota.Territory2Id = objTerr.id;
                    ota.AssociationCause = 'Territory2Manual';
                    insert ota;
                }
            }
        }
    }
    /**
* Method Name: getUserTerritory2AssociationPositiveTest
* Description: This method is used for calling to getUserTerritory2Association().
*/
    static testMethod void getUserTerritory2AssociationPositiveTest(){
        List<Account> lstAccount = [SELECT ID FROM Account];
        if(lstAccount!=null && lstAccount.size()>0){
            Test.startTest();
            List<UserTerritory2AssociationController.UserTerritoryWrapper> lstUTW = UserTerritory2AssociationController.getUserTerritory2Association(lstAccount.get(0).id);
            //validate the list of UserTerritoryWrapper, it should not null
            System.assert(lstUTW != null, true);
            Test.stopTest();
        }
    }
    /**
* Method Name: getUserTerritory2AssociationNegativeTest
* Description: This method is used for calling to getUserTerritory2Association() for negative scenario
*/
    static testMethod void getUserTerritory2AssociationNegativeTest(){
        Test.startTest();
        List<UserTerritory2AssociationController.UserTerritoryWrapper> lstUTW = UserTerritory2AssociationController.getUserTerritory2Association(null);
        //validate the list of UserTerritoryWrapper, it should not null
        System.assert(lstUTW.size() < 1,true);
        Test.stopTest();
    }
    /**
* Method Name: getUserTerritory2AssociationBulkRecordTest
* Description: This method is used for calling to getUserTerritory2Association() for bulk records scenario
*/
    
        static testMethod void getUserTerritory2AssociationBulkRecordTest(){
        UserTerritory2Association uta = null;
        List<Account> lstAccount = [SELECT ID FROM Account];
        if(lstAccount!=null){
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
            List<User> lstUser = new List<User>();
            List<UserTerritory2Association> lstTerritory = new List<UserTerritory2Association>();
            List<Territory2> lstTerritory2 = [SELECT ID FROM Territory2 where name = 'CSDTestTerritory' LIMIT 1];
            User testUser = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', 'System Administrator');
            insert testUser;
            If(testUser!=null){
                for(integer i=0;i<100;i++){
                    lstUser.add(new User(Alias = 'test', Email='testuser'+i+'@test.com.sample', 
                              EmailEncodingKey='UTF-8', LastName='Testing'+i, LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_AU', ProfileId = p.Id, 
                              TimeZoneSidKey='Australia/Sydney', UserName='testuser'+i+'@test.com.sample'));
                }
                Test.startTest();
                insert lstUser;
                System.runAs(testUser){
                    if(lstTerritory2 !=null && lstTerritory2.size()>0 && lstuser!=null){
                        for(User usr: lstUser){
                            uta = new UserTerritory2Association();
                            uta.Territory2Id = lstTerritory2.get(0).Id;
                            uta.RoleInTerritory2 = 'Specialist';
                            uta.UserId = usr.id;
                            lstTerritory.add(uta);
                        }
                    }
                    insert lstTerritory;
                }
            }
            List<UserTerritory2AssociationController.UserTerritoryWrapper> lstUTW = UserTerritory2AssociationController.getUserTerritory2Association(lstAccount.get(0).id);
            //validate the list of UserTerritoryWrapper, it should not null
            System.assert(lstUTW != null, true);
            Test.stopTest();
        }
    }
    
/*******************************************************************
@Method Name    :   getUserTerritory2AssociationBulkRecordTest2
@Sprint         :   20.12 & DIGI-14600
@Author         :   SFO Team (Chhaveel
@CreateDate     :   09/02/2021
@Description    :   This method is used for calling to getUserTerritory2Association() for bulk records scenario for sales Territory
*********************************************************************/
    /*
    static testMethod void getUserTerritory2AssociationBulkRecordTest2(){
        UserTerritory2Association uta = null;
        List<Account> lstAccount = [SELECT ID FROM Account];
        if(lstAccount!=null){
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
            List<User> lstUser = new List<User>();
            List<UserTerritory2Association> lstTerritory = new List<UserTerritory2Association>();
            List<Territory2> lstTerritory2 = [SELECT ID FROM Territory2 where name = 'UAT01' LIMIT 1];
            User testUser = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', 'System Administrator');
            insert testUser;
            If(testUser!=null){
                for(integer i=0;i<100;i++){
                    lstUser.add(new User(Alias = 'test', Email='testuser'+i+'@test.com.sample', 
                                         EmailEncodingKey='UTF-8', LastName='Testing'+i, LanguageLocaleKey='en_US', 
                                         LocaleSidKey='en_AU', ProfileId = p.Id, 
                                         TimeZoneSidKey='Australia/Sydney', UserName='testuser'+i+'@test.com.sample'));
                }
                Test.startTest();
                insert lstUser;
                System.runAs(testUser){
                    if(lstTerritory2 !=null && lstTerritory2.size()>0 && lstuser!=null){
                        for(User usr: lstUser){
                            uta = new UserTerritory2Association();
                            uta.Territory2Id = lstTerritory2.get(0).Id;
                            uta.RoleInTerritory2 = 'Specialist';
                            uta.UserId = usr.id;
                            lstTerritory.add(uta);
                        }
                    }
                    insert lstTerritory;
                }
            }
            List<UserTerritory2AssociationController.UserTerritoryWrapper> lstUTW = UserTerritory2AssociationController.getUserTerritory2Association(lstAccount.get(0).id);
            //validate the list of UserTerritoryWrapper, it should not null
            System.assert(lstUTW != null, true);
            Test.stopTest();
        }
    }*/	
}
/****************************************************************************
@Name: SFONPSSRoleAlignmentTriggerHandlerTest.
@Author: SFO/Sravanthi
@CreateDate: 30/09/2019.
@Description: This Class is for test coverage SFONPSSRoleAlignmentTriggerHandler,SFONPSSRoleAlignmentTriggerHandlerTest - P2OB-2214
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] 
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
********************************************************************************/
@isTest
public  class SFONPSSRoleAlignmentTriggerHandlerTest {
    @testSetup
    public static void createData(){
        
        UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Cloud Team Role');
        
        insert role;
        List<UserRole> userRoleList = new  List<UserRole>();
        for(integer i=0 ; i<=10 ;i++){
            UserRole role1 = new UserRole(DeveloperName = 'MyCustomRole1'+i, Name = 'Cloud Team Role'+i,ParentRoleId = role.id);
            userRoleList.add(role1);
        }
        insert userRoleList;          
        
    } 
    /****************************************************************************
@Method Name: SFONPSSRoleAlignmentTriggerHandlerTest.
@Author: SFO/Sravanthi
@Sprint : 19.13[P2OB-2214]
@CreateDate: 30/09/2019.
@Description:Test Method for SFONPSSRoleAlignmentTriggerHandler handleBeforeInsert,handleBeforeUpdate  
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] 
********************************************************************************/
    public static testMethod void  sfoNPSSRoleAlignmentTriggerHandlerUnitTest(){
        Test.startTest();
        Map<String,String> roleNameIDMap = new Map<String,String>();
        for(UserRole ur : [SELECT id,Name FROM UserRole]){
            roleNameIDMap.put(ur.Name,ur.id);
        }
        List<NPSS_Role_Alignment__c> npssRAList = new List<NPSS_Role_Alignment__c>();
        
        Schema.DescribeFieldResult fieldResultGroup1 = NPSS_Role_Alignment__c.Group1__c.getDescribe();
        List<Schema.PicklistEntry> pleGroup1 = fieldResultGroup1.getPicklistValues();
        Schema.DescribeFieldResult fieldResultGroup2 = NPSS_Role_Alignment__c.Group2__c.getDescribe();
        List<Schema.PicklistEntry> pleGroup2 = fieldResultGroup2.getPicklistValues();
        Schema.DescribeFieldResult fieldResultGroup3 = NPSS_Role_Alignment__c.Group3__c.getDescribe();
        List<Schema.PicklistEntry> pleGroup3 = fieldResultGroup3.getPicklistValues();
        
        for( Schema.PicklistEntry f1 : pleGroup1){
            for( Schema.PicklistEntry f2 : pleGroup2){
                for( Schema.PicklistEntry f3 : pleGroup3){
                    if(npssRAList.size()<50 && f1.getValue()=='CLOUD SERVICES' ){
                        NPSS_Role_Alignment__c npssRoleAlignment = new NPSS_Role_Alignment__c(Role_Name__c ='Cloud Team Role'+ npssRAList.size(),Role_Id__c=roleNameIDMap.get('Cloud Team Role'+ npssRAList.size()),Group1__c = f1.getValue(), Group2__c = f2.getValue(), Group3__c = f3.getValue());
                        npssRAList.add(npssRoleAlignment);
                    }
                    else if(npssRAList.size()<70 && f1.getValue()=='DATA & IP' ){
                        NPSS_Role_Alignment__c npssRoleAlignment = new NPSS_Role_Alignment__c(Role_Name__c ='Cloud Team Role'+ npssRAList.size(),Role_Id__c=roleNameIDMap.get('Cloud Team Role'+ npssRAList.size()),Group1__c = f1.getValue(), Group2__c = f2.getValue(), Group3__c = f3.getValue());
                        npssRAList.add(npssRoleAlignment);
                    }
                    
                }
            }
            
        }
        insert npssRAList;
        List<NPSS_Role_Alignment__c> npssRAListUpdate = new List<NPSS_Role_Alignment__c>();
        for(NPSS_Role_Alignment__c npssRoleAlignment1 : [SELECT id FROM NPSS_Role_Alignment__c WHERE Group1__c='CLOUD SERVICES' LIMIT 20]){
            //Updating valid role name
            npssRoleAlignment1.Role_Id__c ='';
            npssRoleAlignment1.Role_Name__c ='Cloud Team Role2';
            npssRAListUpdate.add(npssRoleAlignment1);
        }
        for(NPSS_Role_Alignment__c npssRoleAlignment2 : [SELECT id FROM NPSS_Role_Alignment__c WHERE Group1__c='DATA & IP'LIMIT 20]){
            npssRoleAlignment2.Role_Id__c ='3424'+npssRAListUpdate.size();
            npssRoleAlignment2.Group1__c='DATA & IP';
            //Updating Invalid Role Name
            npssRoleAlignment2.Role_Name__c ='Cloud Team Role32';
            npssRAListUpdate.add(npssRoleAlignment2);
        }
        update npssRAListUpdate;
        NPSS_Role_Alignment__c npssRoleAlignment11 = [SELECT id,Role_Name__c,Role_Id__c FROM NPSS_Role_Alignment__c WHERE id IN : npssRAListUpdate  AND Group1__c='CLOUD SERVICES' LIMIT 1];
        NPSS_Role_Alignment__c npssRoleAlignment12 = [SELECT id,Role_Name__c,Role_Id__c FROM NPSS_Role_Alignment__c WHERE id IN : npssRAListUpdate  AND Group1__c='DATA & IP' LIMIT 1];            
        System.assertEquals(npssRoleAlignment11.Role_Id__c ,String.ValueOf([SELECT id FROM UserRole WHERE DeveloperName = 'MyCustomRole12'].id));
        System.assertNotEquals(npssRoleAlignment11.Role_Id__c ,null);
        npssRoleAlignment12.Role_Id__c ='2313';
        update npssRoleAlignment12;
        Test.stopTest();
    }
}
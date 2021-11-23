/****************************************************************************
@Name: SFOTargetsTriggerHandlerTest.
@Author: SFO(SanFrancisco)/Sravanthi
@CreateDate: 14/10/2019.
@Description: This Class is for test coverage SFOTargetsTriggerHandler,SFONPSSRoleAlignmentTriggerHandlerTest - P2OB-3297
********************************************************************************/
@isTest
public class SFOTargetsTriggerHandlerTest {
    @testSetup
    public static void createData(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Cloud Security RV Team');
        insert r;
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'Cloud Security RV Team Role2' , ParentRoleId = r.id);
        insert r1;
        
        
    } 
    /****************************************************************************
    @Method Name: sfoTargetsTriggerHandlerTestUnitTest.
    @Author: SFO/Sravanthi
    @Sprint : 19.14[P2OB-3297]
    @CreateDate: 14/10/2019.
    @Description:Test Method for SFOTargetsTriggerHandler handleBeforeInsert,handleBeforeUpdate  
    ********************************************************************************/
    public static testMethod void  sfoTargetsTriggerHandlerTestUnitTest(){
        Test.startTest();
        List<Targets__c> targetsList = new List<Targets__c>();
        Targets__c targetsrec1 = new Targets__c(Archetype__c='Balanced');
        targetsrec1.Role_Id__c ='';
        targetsrec1.Role_Name__c ='Cloud Security RV Team';
        Targets__c targetsrec2 = new Targets__c(Archetype__c ='Account Executive');
        targetsrec2.Role_Id__c ='';
        targetsrec2.Role_Name__c ='Cloud Security RV Team';
        Targets__c targetsrec3 = new Targets__c(Archetype__c ='Pre-Sales');
        targetsrec3.Role_Id__c ='';
        targetsrec3.Role_Name__c ='Cloud Security RV Team Role2';
        targetsList.add(targetsrec1);
        targetsList.add(targetsrec2);
        targetsList.add(targetsrec3);
        insert targetsList;
        //Updating Invalid Role Name
        targetsrec1.Role_Name__c ='Cloud Security RV Team32';
        update targetsrec1;
        //Updating valid role name
        targetsrec2.Role_Name__c = 'Cloud Security RV Team Role2';
        update targetsrec2;
        //Updating invalid role id
        targetsrec3.Role_Id__c = 'efewf';
        update targetsrec3;
        Targets__c targetsrec11 = [SELECT id,Role_Name__c,Role_Id__c FROM Targets__c WHERE Archetype__c='Balanced' LIMIT 1];
        Targets__c targetsrec12 = [SELECT id,Role_Name__c,Role_Id__c FROM Targets__c WHERE Archetype__c ='Account Executive' LIMIT 1];            
        System.assertEquals(targetsrec11.Role_Id__c ,null);
        Test.stopTest();
    }
}
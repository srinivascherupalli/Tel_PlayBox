/****************************************************************************
@Name			: PortfolioAlignmentHelper_Test.
@Author			: SFo/Sri
@CreateDate		: 30/01/2018.
@UpdatedDate	: 30/09/2019[P2OB-2214].
@Description	: This is Test Class for PortfolioAlignmentHelper - EDGE-62548
@Modified 		: 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15]  Bulkified Test Data
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: FDR Fix fue to rearrangement of Role_in_Territory__c values for P2OB-13988
********************************************************************************/
@istest
public class PortfolioAlignmentHelper_Test {
    @testSetup
    public static void createData(){
        Profile pf = [SELECT id FROM profile WHERE name =:Label.Profile_SalesEnterprise];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', 
                              profileid = pf.id, 
                              timezonesidkey='Australia/Sydney', 
                              username='salesuser@testsales.com',phone='+121231231234');    
        insert sales;
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE name =:Label.PermissionSet_ReferenceDataAdmin LIMIT 1];
        
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = sales.id,
            PermissionSetId = ps.Id
        );
        insert psa;
        List<UserRole> roleList = new List<UserRole>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Cloud Security RV Team');
        roleList.add(r);
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'Cloud Security RV Team Role2',ParentRoleId = r.id);
        roleList.add(r1);
        
        UserRole r2 = new UserRole(DeveloperName = 'MyCustomRole2', Name = 'Cloud Security RV Team Role3',ParentRoleId = r1.id);
        roleList.add(r2);
        
        UserRole r3 = new UserRole(DeveloperName = 'MyCustomRole3', Name = 'Cloud Security RV Team Role4',ParentRoleId = r2.id);
        roleList.add(r3);
        
        insert roleList;
        
        r2.ParentRoleId  = r1.id;
        update r2;
        system.runas(sales){
            List<Portfolio_Alignment__c> portfolioRAList = new List<Portfolio_Alignment__c>();
            Schema.DescribeFieldResult fieldResultRoleTer = Portfolio_Alignment__c.Role_in_Territory__c.getDescribe();
            List<Schema.PicklistEntry> pleRoleTer = fieldResultRoleTer.getPicklistValues();
            While(portfolioRAList.size()<=100){
                for( Schema.PicklistEntry f1 : pleRoleTer){
                    if(portfolioRAList.size() < 50){
                        Portfolio_Alignment__c portfolioRA = new Portfolio_Alignment__c(Role_in_Territory__c=f1.getValue(),Role_Name__c ='Cloud Security RV Team Role2');
                        portfolioRAList.add(portfolioRA);
                    }
                    else{
                        Portfolio_Alignment__c portfolioRA = new Portfolio_Alignment__c(Role_in_Territory__c=f1.getValue(),Role_Name__c ='Cloud Security RV Team');                    
                        portfolioRAList.add(portfolioRA);
                    }
                    
                }}
            
            insert portfolioRAList;
        }
    } 
    /****************************************************************************
@Name: roleNameRoleIdAssignmenttest.
@Author: SFO/Sravanthi
@Sprint : 19.13
@CreateDate: 30/09/2019.
@Description:Test Method for PortfolioAlignmentHelper roleNameRoleIdAssignment  P2OB-2214
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] 
********************************************************************************/
    public static testMethod void  roleNameRoleIdAssignmenttest(){
        Test.startTest();
        User sales = [SELECT id,IsActive FROM user WHERE lastname ='Testing' AND IsActive =true Limit 1 ];
        system.runas(sales){
            List<Portfolio_Alignment__c> portfolioRAList = new List<Portfolio_Alignment__c>();
            for(Portfolio_Alignment__c portfolioRA1 : [SELECT id FROM Portfolio_Alignment__c WHERE Role_Name__c ='Cloud Security RV Team Role2'AND Role_in_Territory__c= 'Owner' LIMIT 20]){
                //Updating valid role name
                portfolioRA1.Role_Name__c ='Cloud Security RV Team Role2dd23';
                portfolioRA1.Role_in_Territory__c= 'Owner' ;
                portfolioRAList.add(portfolioRA1);
            }            
            for(Portfolio_Alignment__c portfolioRA2 : [SELECT id FROM Portfolio_Alignment__c WHERE Role_Name__c ='Cloud Security RV Team' LIMIT 20]){
                //Updating valid role name
                portfolioRA2.Role_Name__c ='Cloud Security RV Team Role3';
                portfolioRA2.Role_in_Territory__c='Multi-Domain Specialist';
                portfolioRAList.add(portfolioRA2);
            }
            update portfolioRAList;
            
            Portfolio_Alignment__c portfolioRA11 = [SELECT id,Role_Name__c,Role_Id__c FROM Portfolio_Alignment__c WHERE  Role_in_Territory__c= 'Owner' AND Id in :portfolioRAList  LIMIT 1];            
            System.assertEquals(portfolioRA11.Role_Id__c ,null);
            Portfolio_Alignment__c portfolioRA112 = [SELECT id,Role_Name__c,Role_Id__c FROM Portfolio_Alignment__c WHERE id IN : portfolioRAList AND Role_in_Territory__c='Multi-Domain Specialist'LIMIT 1];            
            System.assertEquals(portfolioRA112.Role_Id__c ,[SELECT id FROM UserRole WHERE DeveloperName = 'MyCustomRole2'].id);
            System.assertNotEquals(portfolioRA112.Role_Id__c ,[SELECT id FROM UserRole WHERE DeveloperName = 'MyCustomRole'].id);
            portfolioRA112.Role_Id__c ='2313';
            update portfolioRA112;
        }
        Test.stopTest();
    }    
}
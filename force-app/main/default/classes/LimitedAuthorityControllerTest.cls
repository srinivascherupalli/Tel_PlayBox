/*******************************************************************
@Class Name:LimitedAuthorityControllerTest
@Sprint :20.05  & P2OB-4922
@Author:SFO Team (Srikanth & Sravanthi)
@CreateDate: 01/04/2020
@Description:Test class for LimitedAuthorityController
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772  updating API version to 50.
*********************************************************************/
@isTest
public with sharing class LimitedAuthorityControllerTest {
    @testSetup
    public static void createData(){
        List<user> userList = new List<user>();
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        sales.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        System.runAs(admin){
            
            
            list<Account> acclist =new list<Account>();
            list<Contact> conlist =new list<Contact>();
            for(integer i=0;i<20;i++){
                Account customerAccount=TestUtil.createAccount('Testacc'+i);
                customerAccount.OwnerId=sales.id;
                customerAccount.CIDN__c='48445074'+i;
                if(i!=0){
                    customerAccount.Parent_CIDN__c='48445074'+(i-1);
                }
                acclist.add(customerAccount);
            }
            insert acclist;
            Contact con = TestUtil.createContact(acclist[0].id,'First','Last');
            con.OwnerId=sales.id;
            conlist.add(con);
            Contact con1 = TestUtil.createContact(acclist[19].id,'First','Last');
            con1.OwnerId=sales.id;
            conlist.add(con1);
            insert conlist;
        }
    }
    /****************************************************************************
    @Method Name:limitedAuthorityGetCIDNSTest
    @Author: SFO/Srikanth & Sravanthi
    @Sprint :20.05  & P2OB-4922
    @CreateDate: 01/04/2020
    @Description: Checks for number of Account Heirarchy for the given contact
    ******************************************************************************/
    @isTest
    static void limitedAuthorityGetCIDNSTest(){
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        List<String> CIDNActNameList = new List<String>();
        Contact con =[SELECT id FROM Contact WHERE Account.CIDN__c = '484450740' LIMIT 1];
        test.startTest();
        System.runAs(sales){
        CIDNActNameList=LimitedAuthorityController.getCIDNs(con.id);
        }
        test.stopTest();
        system.assertEquals(20, CIDNActNameList.size());
    }
    /****************************************************************************
    @Method Name:limitedAuthorityGetOneCIDNSTest
    @Author: SFO/Srikanth & Sravanthi
    @Sprint :20.05  & P2OB-4922
    @CreateDate: 01/04/2020
    @Description: Checks for single account record  for the given contact.
    ******************************************************************************/
    @isTest
    static void limitedAuthorityGetOneCIDNSTest(){
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        List<String> CIDNActNameList = new List<String>();
        Contact con =[SELECT id FROM Contact WHERE Account.CIDN__c = '4844507419' LIMIT 1];
        test.startTest();
        System.runAs(sales){
        CIDNActNameList=LimitedAuthorityController.getCIDNs(con.id);
        }
        test.stopTest();
        system.assertEquals(1, CIDNActNameList.size());
        system.assertNotEquals(true, CIDNActNameList.contains('4844507402'));
    }
}
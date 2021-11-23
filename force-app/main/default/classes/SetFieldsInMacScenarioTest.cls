/*
* @Author : Aman Soni
* @Date : 23 March 2020
* @Desc : SetFieldsInMacScenarioTest Class 
* @Jira : EDGE-138169//EDGE-135278
*/

@isTest
public class SetFieldsInMacScenarioTest{
 @TestSetup static void CreateData()
    {               
 // Data cannot be setup for this functionality
    }
    
    public static List<Discount_Line_Item__c> CreateDummyData(String status, String busIdCheck)
    {
        List<Charge_Line_Item__c> cliLst = new  List<Charge_Line_Item__c>();
        List<Discount_Line_Item__c> FinalList = new List<Discount_Line_Item__c>();
        
        if(status == 'Active' && busIdCheck == 'Same'){
        Charge_Line_Item__c CLattr= new Charge_Line_Item__c();
        CLattr.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr.status__c='Active';
        cliLst.add(CLattr);     
        insert cliLst;
        
        Discount_Line_Item__c dli1 = new Discount_Line_Item__c ();
        dli1.actionCode__c = 'New';
        dli1.chargeInstance__c=CLattr.id;
        dli1.appliedDate__c=system.today();
        dli1.BusinessID__c ='DMCAT_Discount_000944';
        FinalList.add(dli1);
        insert FinalList;       
        }
        
        if(status == 'New' && busIdCheck=='Same'){
        Charge_Line_Item__c CLattr1= new Charge_Line_Item__c();
        CLattr1.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr1.status__c='New';
        cliLst.add(CLattr1);
        insert cliLst;
        
        Discount_Line_Item__c dli2 = new Discount_Line_Item__c ();
        dli2.actionCode__c = '';
        dli2.chargeInstance__c=CLattr1.id;
        dli2.BusinessID__c ='DMCAT_Discount_000944';
        FinalList.add(dli2);
        insert FinalList;       
        }   

        if(status == 'Active' && busIdCheck== 'Diff'){
        Charge_Line_Item__c CLattr= new Charge_Line_Item__c();
        CLattr.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr.status__c='Active';
        cliLst.add(CLattr);     
        insert cliLst;
        
        Discount_Line_Item__c dli3 = new Discount_Line_Item__c ();
        dli3.actionCode__c = 'New';
        dli3.chargeInstance__c=CLattr.id;
        dli3.appliedDate__c=system.today();
        dli3.BusinessID__c ='DMCAT_Discount_000944';
        FinalList.add(dli3);
        insert FinalList;       
        }
        
        if(status == 'New' && busIdCheck=='Diff'){
        Charge_Line_Item__c CLattr1= new Charge_Line_Item__c();
        CLattr1.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr1.status__c='New';
        cliLst.add(CLattr1);
        insert cliLst;
        
        Discount_Line_Item__c dli4 = new Discount_Line_Item__c ();
        dli4.actionCode__c = '';
        dli4.chargeInstance__c=CLattr1.id;
        dli4.BusinessID__c ='DMCAT_Discount_000945';
        FinalList.add(dli4);
        insert FinalList;       
        }
        
        if(status == 'Active' && busIdCheck==''){
        Charge_Line_Item__c CLattr1= new Charge_Line_Item__c();
        CLattr1.guid__c='c20a039b-80fe-8876-5328-4006a5143ccl';
        CLattr1.status__c='Active';
        cliLst.add(CLattr1);
        insert cliLst;
        
        Discount_Line_Item__c dli5 = new Discount_Line_Item__c ();
        dli5.actionCode__c = '';
        dli5.chargeInstance__c=null;
        dli5.appliedDate__c=system.today();
        dli5.BusinessID__c ='';
        FinalList.add(dli5);
        insert FinalList;       
        }
        
        if(status == 'New' && busIdCheck==''){
        Charge_Line_Item__c CLattr1= new Charge_Line_Item__c();
        CLattr1.guid__c='c20a039b-80fe-8876-5328-4006a5143ccl';
        CLattr1.status__c='New';
        cliLst.add(CLattr1);
        insert cliLst;
        
        Discount_Line_Item__c dli6 = new Discount_Line_Item__c ();
        dli6.actionCode__c = '';
        dli6.chargeInstance__c=CLattr1.id;
        dli6.BusinessID__c ='DMCAT_Discount_000947';
        FinalList.add(dli6);
        insert FinalList;       
        }

        if(status == 'Active' && busIdCheck=='Same1'){
        Charge_Line_Item__c CLattr2= new Charge_Line_Item__c();
        CLattr2.guid__c='c20a039b-80fe-8876-5328-4006a5143cct';
        CLattr2.status__c='Active';
        cliLst.add(CLattr2);
        insert cliLst;
        
        Discount_Line_Item__c dli7 = new Discount_Line_Item__c ();
        dli7.actionCode__c = 'New';
        dli7.chargeInstance__c=CLattr2.id;
        dli7.BusinessID__c ='DMCAT_Discount_000947';
        FinalList.add(dli7);
        insert FinalList;       
        }

        if(status == 'New' && busIdCheck=='Same1'){
        Charge_Line_Item__c CLattr2= new Charge_Line_Item__c();
        CLattr2.guid__c='c20a039b-80fe-8876-5328-4006a5143cct';
        CLattr2.status__c='New';
        cliLst.add(CLattr2);
        insert cliLst;
        
        Discount_Line_Item__c dli7 = new Discount_Line_Item__c();
        dli7.actionCode__c = 'New';
        dli7.chargeInstance__c=null;
        dli7.BusinessID__c ='DMCAT_Discount_000947';
        FinalList.add(dli7);
        insert FinalList;       
        }

        if(status == 'New' && busIdCheck=='Same2'){
        Charge_Line_Item__c CLattr3= new Charge_Line_Item__c();
        CLattr3.guid__c='c20a039b-80fe-8876-5328-4006a5143ccr';
        CLattr3.status__c='New';
        cliLst.add(CLattr3);
        insert cliLst;
        
        Discount_Line_Item__c dli8 = new Discount_Line_Item__c ();
        dli8.actionCode__c = 'New';
        dli8.chargeInstance__c=CLattr3.id;
        dli8.BusinessID__c ='DMCAT_Discount_000947';
        FinalList.add(dli8);
        insert FinalList;       
        }
        
        return FinalList;       
    }
    
    @isTest
    public static void TestDLIforGuid(){
        
        List<Discount_Line_Item__c> DListActv = CreateDummyData('Active','Same');         
        String configGuid='c20a039b-80fe-8876-5328-4006a5143cce';
        Set<String> guidSet=new Set<string>();
        guidSet.add(configGuid);
        
        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        Map<String,List<Discount_Line_Item__c>> FinalMap = new Map<String,List<Discount_Line_Item__c>>();
        FinalMap = setfld.getExistingDiscountLevelList(guidSet);
        Test.stopTest();
        
        System.assertEquals(DListActv[0].actionCode__c,'New');
        System.assertEquals(FinalMap.containsKey('c20a039b-80fe-8876-5328-4006a5143cce'), True);
        System.assertEquals(FinalMap.containsKey('c20a039b-80fe-8876-5328-4006a5143cck'), False);
    }
    
     @isTest
    public static void TestNoDLIforGuid(){
        
        List<Discount_Line_Item__c> DListBlnk = CreateDummyData('New','');
        List<Discount_Line_Item__c> DListActv =CreateDummyData('Active','');        
        String configGuid='c20a039b-80fe-8876-5328-4006a5143ccl';
        Set<String> guidSet=new Set<string>();
        guidSet.add(configGuid);
        
        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        Map<String,List<Discount_Line_Item__c>> FinalMap = new Map<String,List<Discount_Line_Item__c>>();
        FinalMap = setfld.getExistingDiscountLevelList(guidSet);
        Test.stopTest();

        System.assertEquals(FinalMap.containsKey('c20a039b-80fe-8876-5328-4006a5143ccl'), False);
    }
        
    @isTest
    public static void TestBusIdEqual(){
        
        List<Discount_Line_Item__c> DListActv = CreateDummyData('Active','Same');        
        List<Discount_Line_Item__c> DListBlnk = CreateDummyData('New','Same');

        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        List<Discount_Line_Item__c> FinalLst = new  List<Discount_Line_Item__c>();
        FinalLst = setfld.SetActionCodeOnDLIs(DListBlnk,DListActv); 
        Test.stopTest();
        
        if(DListBlnk[0].BusinessID__c == DListActv[0].BusinessID__c)
        System.assertEquals(FinalLst[0].actionCode__c,'Carry Forward');     
    }
    
    @isTest
    public static void TestBusIdUnEqual(){
        
        List<Discount_Line_Item__c> DListActv = CreateDummyData('Active','Diff');        
        List<Discount_Line_Item__c> DListBlnk = CreateDummyData('New','Diff');

        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        List<Discount_Line_Item__c> FinalLst = new  List<Discount_Line_Item__c>();
        FinalLst = setfld.SetActionCodeOnDLIs(DListBlnk,DListActv); 
        Test.stopTest();
        
        if(DListBlnk[0].BusinessID__c != DListActv[0].BusinessID__c)
        System.assertEquals(FinalLst[0].actionCode__c,'New');       
    }
    
    @isTest
    public static void TestActiveNull(){
        
        List<Discount_Line_Item__c> DListBlnk = CreateDummyData('New','Same2');
        List<Discount_Line_Item__c> DListActv;   
      
        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        List<Discount_Line_Item__c> FinalLst = new  List<Discount_Line_Item__c>();
        FinalLst = setfld.SetActionCodeOnDLIs(DListBlnk,DListActv);
        Test.stopTest();
        
        System.assertEquals(FinalLst[0].actionCode__c,'New');
    }

    @isTest
    public static void TestForCurrentDLINUll(){
        
        List<Discount_Line_Item__c> DListBlnk;
        List<Discount_Line_Item__c> DListActv =CreateDummyData('Active','Same1');   
      
        Test.startTest();
        SetFieldsInMacScenario setfld = new SetFieldsInMacScenario();
        List<Discount_Line_Item__c> FinalLst = new  List<Discount_Line_Item__c>();
        FinalLst = setfld.SetActionCodeOnDLIs(DListBlnk,DListActv);
        Test.stopTest();
        
        System.assertEquals(DListActv[0].actionCode__c,'New');
        System.assertEquals(FinalLst[0].actionCode__c,'New');
    }    
}
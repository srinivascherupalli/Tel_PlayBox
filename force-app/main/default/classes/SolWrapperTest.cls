/*********************************************************************************************************************************
 *Class Name      :   SolWrapperTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        Vaibhav Deshpande     27/05/2020      EDGE-138655
2.        Vaibhav Deshpande     01/06/2020      EDGE-149079
*********************************************************************************************************************************
*/

@isTest
public class SolWrapperTest {
    @isTest
    public static void testWrapper() {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CWS_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace Solution', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CWS_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfigS = new cscfga__Product_Configuration__c();
        testConfigS.Name = 'Connected Workplace Solution';
        testConfigS.cscfga__Product_Definition__c=CWS_PD.id;
        prodconfigList.add(testConfigS);
        insert prodconfigList;

        csord__Solution__c sol = new csord__Solution__c(Name = 'Connected Workplace Solution', csord__Status__c = 'Completed', 
        cssdm__total_contract_value__c = 3700.00, cssdm__total_one_off_charge__c = 100.00, cssdm__total_recurring_charge__c = 100.00, 
        csordtelcoa__Product_Configuration__c = testConfigS.Id,
        csord__Account__c = testAccount.Id, csord__External_Identifier__c = '12345', 
        csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        
        INSERT sol;
        
        List < String > args = new String[] {
            '0',
            'number',
            '###,###,##0.00'
        };
            
        SolWrapper solw = new SolWrapper();
        
        csord__Solution__c solList = [SELECT Id, Name, CreatedDate, csord__Status__c, cssdm__total_contract_value__c, cssdm__total_one_off_charge__c, cssdm__total_recurring_charge__c, 
                CreatedById, CreatedBy.Name, csord__Account__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name 
                FROM csord__Solution__c LIMIT 1];
        
        solw.SolutionID = solList.Id;
        solw.SolutionName = solList.Name;
        solw.status = solList.csord__Status__c;
        solw.createdBy = solList.CreatedBy.Name;
        solw.disableRow = false;
        solw.solutionNameLink = '/' + solList.Name + '/';
        String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
        solw.createdDate = solList.CreatedDate.format(dateFormatString);
        Decimal rc = solList.cssdm__total_recurring_charge__c;
        Decimal oc = solList.cssdm__total_one_off_charge__c;
        Decimal cv = solList.cssdm__total_contract_value__c;
        String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
        String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
        String finalcv = cv.format().contains('.') ? cv.format() : (cv.format() + '.00');
        solw.totalRC = '$ ' + String.format(finalrc, args);
        solw.totalOC = '$ ' + String.format(finaloc, args);
        solw.totalCV = '$ ' + String.format(finalcv, args);
        solw.isCWP = true;
        solw.productDefinitionName = solList.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name;
        solw.solutionNameLink='test';
        solw.site='abc';
        solw.mobile='5685655';
        solw.fixedNo='15423';
        solw.deviceId='5414564';
        
        System.assertEquals('Connected Workplace Solution', solw.SolutionName);
        System.assertEquals('Completed', solw.status);
        System.assertEquals('Connected Workplace Solution', solw.productDefinitionName);
        System.assertEquals(true, solw.isCWP);
        System.assertEquals(false, solw.disableRow);
        System.assertEquals('test', solw.solutionNameLink);
        System.assertEquals('abc', solw.site);
        System.assertEquals('5685655', solw.mobile);
        System.assertEquals('15423', solw.fixedNo);
        System.assertEquals('5414564', solw.deviceId);
        
    }

}
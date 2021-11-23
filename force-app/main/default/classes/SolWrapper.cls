/*********************************************************************************************************************************
 *Class Name      :   SolWrapper
  Test Class      :   SolWrapperTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        Vaibhav Deshpande     27/05/2020      EDGE-138655
2.        Vaibhav Deshpande     01/06/2020      EDGE-149079
*********************************************************************************************************************************
*/
public with sharing class SolWrapper{
    @AuraEnabled public Id SolutionID{get; set;}
    @AuraEnabled public string SolutionName{get;set;}
    @AuraEnabled public string status{get;set;}
    @AuraEnabled public string createdBy{get;set;}
    @AuraEnabled public boolean disableRow{get;set;}
    @AuraEnabled public String createdDate{get;set;}
    @AuraEnabled public String totalRC{get;set;}
    @AuraEnabled public String totalOC{get;set;}
    @AuraEnabled public String totalCV{get;set;}
    @AuraEnabled public boolean isCWP{get;set;}
    @AuraEnabled public String productDefinitionName{get;set;}
    @AuraEnabled public String solutionNameLink{get;set;}
    @AuraEnabled public String site{get;set;} // added as part of EDGE-138655
    @AuraEnabled public String mobile{get;set;} // added as part of EDGE-138655
    @AuraEnabled public String fixedNo{get;set;} // added as part of EDGE-138655
    @AuraEnabled public String deviceId{get;set;} // added as part of EDGE-149079

    
}
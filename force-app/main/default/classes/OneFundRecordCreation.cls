/*
* AUTHOR : Shivaprasad
* TEAM: Napier
* EDGE-205066 Advance fund payment frequency allocation
* DATE: 07/04/2021 
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Ankush Rana           08/06/2021      EDGE-219116 As a Sales/Partner user, When I have offered Fund (Flexi/Advance or No Fund) for a product during NEW FA journey, Then system should update Fund console data as "Allocated" on FA Activation
2.    Shashidhar Kumar  24/06/2021    EDGE-219471: updated field Contract_Term to PF_Contract_Term
3.    Shivaprasad Patil  25/06/2021    EDGE-219475: Added field Fund Expiry (Fund Term)
4. 	  		  Shivaprasad Patil     14/07/2021		EDGE-228130: Tech Story: Governance team review updates
*/
public class OneFundRecordCreation {

  public static void createOneFundRecord(Id faId) {
         
    System.debug('FA Id...' + faId);          
      try{
          List<csconta__Frame_Agreement__c> fa = [SELECT Id,csconta__Account__c,Opportunity__r.Type,Mark_as_Variation__c, csconta__effective_start_date__c, csconta__effective_end_date__c, Delegated_Pricing_Request__c, Delegated_Pricing_Request__r.Tech_Reward_Type__c FROM csconta__Frame_Agreement__c where Id =:faId];
          //EDGE-219116(updated query by adding IsAllocated__c, ContractStartDate__c, ContractEndDate__c )
          List<DPR_Offer__c> dprList = [SELECT Id,Fund_Amount__c, Fund_Term__c,Fund_Amount_Calc__c, Advance_Fund_Amount_Percent__c, Fund_Increment_Frequency__c, Fund_Contribution__c, Fund_Type__c, Net_Recurring_Price__c,Minimum_Spend_per_Month__c, Product_Family__c, PF_Contract_Term__c, Total_Spend_over_Contract_Term__c, IsAllocated__c, ContractStartDate__c, ContractEndDate__c from DPR_Offer__c where Delegated_Pricing_Request__r.Id =:fa[0].Delegated_Pricing_Request__c];
  
        List<OneFund__c> lstOfOneFundUpdated = OneFundRecordCreationController.createOneFund(fa,dprList);
        
      if(!lstOfOneFundUpdated.isEmpty()){
          OneFundRecordCreationController.createOneFundTransactions(lstOfOneFundUpdated,fa,dprList);
      }
      //EDGE-219116
      OneFundRecordCreationController.updateFAAttachmentRecord(fa,dprList);
      }catch(Exception ex){
          new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','createOneFundRecord', '', faId, ex.getMessage(), 'One Fund Creation Failed.',false);
      }
  }

}
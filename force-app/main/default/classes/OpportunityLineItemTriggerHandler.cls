/****************************************************************************
@Name			: OpportunityLineItemTriggerHandler
@TestCoverage   : OpportunityLineItemTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Class is for OpportunityLineItem Trigger
********************************************************************************/
public without sharing class OpportunityLineItemTriggerHandler{
    OpportunityLineItemTriggerHelper oppLineItemTriggerHelper=new OpportunityLineItemTriggerHelper();
    /****************************************************************************
@Method Name	: handleBeforeInsert
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Method is triggered before insert 
********************************************************************************/    
    public  void OnBeforeInsert(List<OpportunityLineItem> newOppLineItemList){
        oppLineItemTriggerHelper.setNPSS(null,newOppLineItemList);
    }
    /****************************************************************************
@Method Name	: handleBeforeUpdate
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Method is triggered before update 
********************************************************************************/ 
    public  void onBeforeUpdate (Map<id,OpportunityLineItem> oldOppLineItemMap,List<OpportunityLineItem> newOppLineItemList){
        oppLineItemTriggerHelper.setNPSS(oldOppLineItemMap,newOppLineItemList);
        
    }
    
    
}
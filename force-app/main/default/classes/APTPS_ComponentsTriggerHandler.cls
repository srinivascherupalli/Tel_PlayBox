public with sharing class APTPS_ComponentsTriggerHandler
{
    public void handleAllAfterEvents(List<APTPS_Component__c> componentsList)
    {
        Set<Id> lineItemIds = new Set<Id>();
        
        for(APTPS_Component__c cmpnt : componentsList)
        {
           if(!lineItemIds.contains(cmpnt.Agreement_Line_Item__c))
           {
               lineItemIds.add(cmpnt.Agreement_Line_Item__c);
           }
        }
        
       updateLineItems(lineItemIds);
    }
    
    
    private void updateLineItems(Set<Id> lineItemIds)
    {
        Map<Id, Apttus__AgreementLineItem__c> agreementLineItemMap = new
            Map<Id, Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineItem =null;
       
        
       
        
        for(Apttus__AgreementLineItem__c lnItem : [select Id, FF_Attribute__c,
                                                   (select Id, APTPS_Attribute__c from Components__r) 
                                                   from Apttus__AgreementLineItem__c where id in : lineItemIds])
        {
            lnItem.FF_Attribute__c = null;
            
            for(APTPS_Component__c cmpnt : lnItem.Components__r)
            {                
                if(lnItem.FF_Attribute__c == null)
                {
                    lnItem.FF_Attribute__c = cmpnt.APTPS_Attribute__c;
                }
                else
                {
                    lnItem.FF_Attribute__c = lnItem.FF_Attribute__c + ';'  + cmpnt.APTPS_Attribute__c;
                }                
            }
            
            agreementLineItemMap.put(lnItem.Id, lnItem);
        }
        
      update agreementLineItemMap.values();
    }
}
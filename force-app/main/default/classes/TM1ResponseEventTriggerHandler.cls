/*
===============================================================================================================================
Class : TM1ResponseEventTriggerHandler
Developer Name : Rohit
Test Class : TM1ResponseEventTriggerHandler
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/

public without sharing class TM1ResponseEventTriggerHandler {

    public static void updateFlag(String basketId)
    {
        Boolean isUpdateBasket=true;// Flag to update basket isEligibilityCheckComplete__c flag on basket
        List<cscfga__Product_Basket__c> prdbasket = [select id ,isEligibilityTriggered__c,isEligibilityCheckComplete__c from cscfga__Product_Basket__c where id = :basketId ];// Fetching Basket Object from Basket ID
        List<cscfga__Product_Basket__c> prdbasketToUpdate = new List<cscfga__Product_Basket__c> ();// List add all Basket to update
        List<cscfga__Product_Configuration__c> prdConfigToUpdate = new List<cscfga__Product_Configuration__c> ();// List add all PC to update
        List<cscfga__Product_Configuration__c> prdConfigToUpdate2 = new List<cscfga__Product_Configuration__c> ();// List add all PC to update
        // Fetching all PC from given Basket
        List<cscfga__Product_Configuration__c> prdConfig = [select id, name , isEligibleForTriggered__c ,isEligibleForTransition__c,cscfga__Product_Basket__c,cscfga__Product_Basket__r.isEligibilityCheckComplete__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__r.id = : basketId and name = 'IP Site'];
            for (cscfga__Product_Configuration__c pc : prdConfig ){
                if (pc.isEligibleForTriggered__c == false){// If Transition is triggered for PC then update the flag to true
                  pc.isEligibleForTriggered__c = true;
                    prdConfigToUpdate2.add(pc);
                }
            }
        if (!prdConfigToUpdate2.isEmpty())
            update prdConfigToUpdate2;
        
        Map<ID, String>  TM1Object = new Map<ID, String>();
        for (TramasElgibilityCallbackResponse__c tm1 : [select id , 
                                                        Product_Configuration__r.id ,
                                                        Eligibility_Criteria__c 
                                                        from TramasElgibilityCallbackResponse__c 
                                                        where Product_Configuration__c in : prdConfig 
                                                        order by lastmodifieddate asc]){
            TM1Object.put(tm1.Product_Configuration__r.id , tm1.Eligibility_Criteria__c);
        }
        for (cscfga__Product_Configuration__c pc :prdConfig  )
        {
            if (pc.isEligibleForTriggered__c  == true && TM1Object.containsKey(pc.id) && TM1Object.get(pc.id) == 'Eligible')
            {
                    pc.isEligibleForTransition__c   = true;//// If site is eligible foe transition then update the flag to true   
            }      
            if (pc.isEligibleForTriggered__c == true && TM1Object.containsKey(pc.id) && !(TM1Object.get(pc.id).containsIgnoreCase('Eligible'))) // updated condition for Edge-90736
            {
                    isUpdateBasket = false;
            }
            else if (pc.isEligibleForTriggered__c == false)
            {
                    isUpdateBasket = false;
            }
            prdConfigToUpdate.add(pc);  
        }
        if (!prdConfigToUpdate.isEmpty())
            update prdConfigToUpdate;
        for (cscfga__Product_Basket__c pb : prdbasket )
        {
            if (pb.isEligibilityCheckComplete__c == false) // updated condition for Edge-90736
            {
                //pb.isEligibilityTriggered__c = true;
                // After getting response from TM update isEligibilityTriggered__c flag on basket to true
                pb.isEligibilityCheckComplete__c = isUpdateBasket;
                prdbasketToUpdate.add(pb);
            }
        }
        if(!prdbasketToUpdate.isEmpty())
            update prdbasketToUpdate;  
    }

}
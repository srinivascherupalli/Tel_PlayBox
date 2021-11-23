/* 
* @Author : Ravi Shankar
* @Date : 6 Apr 2021
* @Desc : Helper class for BillingAccountCreate
* @Jira : EDGE-200254
Not IN:

Closed Replaced,Failed,Inactive,Paid Out,Paid Out1

BA_Open_Status:Active
Pending,Provisioning In Progress,Provisioned,Ready for Activation,Bill Readiness In Progress,Update In Progress,

*/
public without sharing class BillingAccountCreateHelper {
     Public Static list<csord__Subscription__c> isCheckForFinal(String billingAccId){
        boolean checkstatus = true;
        List<csord__Subscription__c> lstMACDSubLst = new List<csord__Subscription__c>();
        List<csord__Subscription__c> lstManualCloseSubLst = new List<csord__Subscription__c>();
        List<String> lstStatus = System.label.Service_Status.split(',');
        List<String> lstOpenStatus = System.label.BA_Open_Status.split(',');
        integer count = 0;
        string status = null;
        Map<Id, cscfga__Product_Configuration__c> mpPC = new Map<Id, cscfga__Product_Configuration__c>();
        set<Id> pcSet = new set<Id>();
        Map<String, ActiveSubsforBAFinal__c> mpDMCAT = new Map<String, ActiveSubsforBAFinal__c>();
        List<ActiveSubsforBAFinal__c> csDMCAT = ActiveSubsforBAFinal__c.getall().values();
        for(ActiveSubsforBAFinal__c cs :csDMCAT){
            mpDMCAT.put(cs.Name, cs);
        }       
        if(billingAccId != null){
            
            Map<Id, csord__Subscription__c> mpSubs = new Map<Id, csord__Subscription__c>([SELECT Id,Name,csordtelcoa__Subscription_Number__c,csord__Status__c,Billing_Account__c,csordtelcoa__Product_Configuration__c,ConfigSpecID__c,csord__Total_Recurring_Charges__c,Initial_Activation_DateTime__c,expiryDuration__c,autoExpiry__c FROM csord__Subscription__c WHERE Billing_Account__c =:billingAccId AND csord__Status__c NOT IN :lstStatus and csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent']);
            for(csord__Subscription__c sub: mpSubs.values()){               
                if(lstOpenStatus.contains(sub.csord__Status__c) ){
                    if(sub.csord__Status__c != 'Active'){
                        lstMACDSubLst.add(sub);
                    }else{
                        //mpSubs.remove(sub.Id);
                        pcSet.add(sub.csordtelcoa__Product_Configuration__c);
                        system.debug('pcSet'+pcSet);
                    }
                }
            }
            if(pcSet.size()>0){
                mpPC = checkPaymentType(new List<Id>(pcSet));
            }           
            for(csord__Subscription__c sub: mpSubs.values()){
                if(sub.csord__Status__c == 'Active'){                   
                    if(sub.csord__Total_Recurring_Charges__c != null && sub.csord__Total_Recurring_Charges__c > 0){
                        lstMACDSubLst.add(sub);
                        //lstManualCloseSubLst.add(sub);
                        mpSubs.remove(sub.Id);
                    }
                    
                    else if(mpPC.keySet().contains(sub.csordtelcoa__Product_Configuration__c)){
                        if(sub.autoExpiry__c == false || (sub.autoExpiry__c == true && sub.Initial_Activation_DateTime__c.addMonths(Integer.valueof(sub.expiryDuration__c)) > System.now())){
                            lstMACDSubLst.add(sub);
                            // lstManualCloseSubLst.add(sub);
                            mpSubs.remove(sub.Id);
                        }
                    }
                    
                    else if(mpDMCAT.keySet().contains(sub.ConfigSpecID__c) && mpDMCAT.get(sub.ConfigSpecID__c).TYPE__c=='ConsumptionBased'){
                        lstMACDSubLst.add(sub);
                        //lstManualCloseSubLst.add(sub);
                        mpSubs.remove(sub.Id);
                    }
                    
                    else{
                        lstManualCloseSubLst.add(sub);
                        mpSubs.remove(sub.Id);
                    }
                }
                
            }
            //lstMACDSubLst.size() == 0 && 
            
            if(lstMACDSubLst.size() == 0 && lstManualCloseSubLst.size() > 0){
                for(csord__Subscription__c sub :lstManualCloseSubLst){
                    if(sub.ConfigSpecID__c != 'DMCAT_ProductSpecification_000537'
                    && !mpPC.keySet().contains(sub.csordtelcoa__Product_Configuration__c)
                    && mpDMCAT.keySet().contains(sub.ConfigSpecID__c)
                    && mpDMCAT.get(sub.ConfigSpecID__c).Closed__c == true){
                        sub.csord__Status__c = 'Closed';
                    }

                }
                update lstManualCloseSubLst;
            }
        }
        return lstMACDSubLst;
    }
    Public Static Map<Id, cscfga__Product_Configuration__c> checkPaymentType(List<Id> pcList){
        Map<Id, cscfga__Product_Configuration__c> mpPC = new Map<Id, cscfga__Product_Configuration__c>();
        List<cscfga__Product_Configuration__c> pcLst = [SELECT id,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,Marketable_Offer__r.Offer_ID__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c where Id IN :pcList];
        for(cscfga__Product_Configuration__c pc: pcLst){
            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                if(attribute.Name.equals('PaymentTypeShadow') && attribute.cscfga__Value__c.equals('Hardware Repayment') ||
                   (attribute.Name.equals('PaymentTypeString') && attribute.cscfga__Value__c.equals('Hardware Repayment'))){
                       mpPC.put(pc.Id, pc);
                       break;
                   }
            }
        }
        return mpPC;
    }
}
/**
 * @Author   :   Aarathi Iyer
 * @Date     :   28 Aug 2020
 * @Desc     :   Logic to enable one fund reversal for cancelled Mobile device care product
 * @US       :   EDGE-164351
 * Updated.  : As a part of EDGE-197579
*/

public class EnableOneFundReversal {
    @InvocableMethod
    public static void OneFundTransactionInsert(List<Id> ContractId){
        
        List<ContractJunction__c> CJList = [SELECT Related_Basket__c from ContractJunction__c WHERE ID IN :ContractID];
        Set<Id> PBSet = new set<Id>();
        String basketId = '';
        // Created as a part of EDGE-197579
        List<String> specList=  Label.OneFundReversalProductCode.split(',');
        for (ContractJunction__c cj: CJList)
        {
            PBSet.add(cj.Related_Basket__c);
            basketId= cj.Related_Basket__c;
        }      
        
        Map<String,cscfga__Attribute__c> mapOfPcVsAtt=new Map<String,cscfga__Attribute__c>();
        Map<String,string> mapOfPcVsBasketId=new Map<String,string>();
        List<cscfga__Attribute__c> AtList = [Select Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.cscfga__Product_Basket__c,cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c 
                                             FROM cscfga__Attribute__c 
                                             WHERE cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN :PBSet
                                             AND name = 'RedeemFundCopy'
                                             AND cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c IN : specList // Updated as a part of EDGE-197579
                                             AND cscfga__Product_Configuration__r.Type__c = 'Cancel'];
       
        Set <String> AccSet = new Set<String>();        
        if(!AtList.isEmpty()){
            for(cscfga__Attribute__c attr:AtList){
                if(attr.cscfga__Value__c!='' && attr.cscfga__Value__c!=null && Integer.ValueOf(attr.cscfga__Value__c)>0){
                    mapOfPcVsAtt.put(attr.cscfga__Product_Configuration__c,attr);
                    AccSet.add(attr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c);
                        }
            }
        }
        MAp<String,String> mapOfAccountVsOneFund = new MAp<String,String>();
        for(String acset : AccSet){
        String OneFund = null;   
        OneFund = GetActiveOneFundForAccount.getOneFundId(acset);
        system.debug('onefund returned' +OneFund);     
        if(OneFund!=null){
          mapOfAccountVsOneFund.put(acset,OneFund);
           }
        }
        
        Id recordTypeId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
        Date currentDate = System.today();
        List<OneFund_Transactions__c> OFTList = new List<OneFund_Transactions__c>();
        List<cscfga__Product_Basket__c> PBList = new List<cscfga__Product_Basket__c>();
        if(mapOfPcVsAtt!=null){
            for(String pcId:mapOfPcVsAtt.keySet()){
                cscfga__Attribute__c refundAttr=mapOfPcVsAtt.get(pcId);
                OneFund_Transactions__c OFTObj = new OneFund_Transactions__c();
                OFTObj.OneFund__c = mapOfAccountVsOneFund.get(refundAttr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c);
                OFTObj.Product_Basket__c = refundAttr.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
                OFTObj.Product_Configuration__c = refundAttr.cscfga__Product_Configuration__c;
                OFTObj.RecordTypeId = recordTypeId;
                OFTObj.Sub_Type__c = 'Reversal';
                OFTObj.Transaction_Status__c = 'Active';
                OFTObj.Start_Date__c = currentDate;
                OFTObj.Expiry_Date__c = currentDate.addMonths(12);
                OFTObj.Transaction_Amount__c = Decimal.valueOf(refundAttr.cscfga__Value__c);
                OFTList.add(OFTObj);
            }
            if(!OFTList.isEmpty()){
                insert OFTList;
                cscfga__Product_Basket__c PBObj = new cscfga__Product_Basket__c();
                PBObj.Id = basketId;
                PBObj.OF_Reversal_Inserted__c = true; 
                PBList.add(PBObj);
                update PBList;
            }             
            
        }             
        
    }
    
}
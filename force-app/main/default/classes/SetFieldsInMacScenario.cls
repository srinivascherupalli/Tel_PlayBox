/******************************************************************************************************************************
Class Name : SetFieldsInMacScenario
Test Class : SetFieldsInMacScenarioTest
===============================================================================================================================
Sr.No.  Developer       Date          Story Description                Sprint
1.      Aman Soni       20/03/2020    EDGE-135278                      20.03
2.      Aman Soni       20/03/2020    EDGE-138169(New Class)           20.04
******************************************************************************************************************************/
public with sharing  class SetFieldsInMacScenario{        
   public List<Discount_Line_Item__c> SetActionCodeOnDLIs(List<Discount_Line_Item__c> currentDLIList,List<Discount_Line_Item__c> existingDLIList){
        system.debug ('currentDLIList--->'+ currentDLIList +''+ 'existingDLIList--->' +existingDLIList);
        
        List<Discount_Line_Item__c> FinalLst = new List<Discount_Line_Item__c>();
        Map<String,Map<String,String>> FinalMap=new Map<String,Map<String,String>>();
        Map<String,Discount_Line_Item__c> ActvCLIStatDliMap = new Map<String,Discount_Line_Item__c>();
        
        if(existingDLIList!=null && !existingDLIList.isEmpty()){                 
          for(Discount_Line_Item__c dlis:existingDLIList){ 
          ActvCLIStatDliMap.put(dlis.BusinessID__c,dlis);
          system.debug ('ActvCLIStatDliMap in SetActionCodeOnDLIs--->'+ActvCLIStatDliMap);
           }
        }        
        
        if(!ActvCLIStatDliMap.isEmpty() && (currentDLIList != null && currentDLIList.size()>0)){                 
                    for(Discount_Line_Item__c dliToUpdateActnCode : currentDLIList){
                        if(ActvCLIStatDliMap.containsKey(dliToUpdateActnCode.BusinessID__c)){
                            Discount_Line_Item__c dli=dliToUpdateActnCode;
                            dli.appliedDate__c = ActvCLIStatDliMap.get(dliToUpdateActnCode.BusinessID__c).appliedDate__c;
                            dli.actionCode__c = 'Carry Forward';
                            FinalLst.add(dli);                    
                        }
                        else{
                            Discount_Line_Item__c dli=dliToUpdateActnCode;
                            dli.actionCode__c = 'New';
                            FinalLst.add(dli);
                        }
                    }
                    
        }else if(ActvCLIStatDliMap.isEmpty() && (currentDLIList != null && currentDLIList.size()>0)){
                for(Discount_Line_Item__c dliToUpdateActnCode : currentDLIList){
                    dliToUpdateActnCode.actionCode__c = 'New';
                    FinalLst.add(dliToUpdateActnCode);
                }                       
        }else if(!ActvCLIStatDliMap.isEmpty() && (currentDLIList == null || currentDLIList.isEmpty())){
                for(Discount_Line_Item__c dliToUpdateActnCode : ActvCLIStatDliMap.values()){
                    dliToUpdateActnCode.actionCode__c = 'New';
                    FinalLst.add(dliToUpdateActnCode);
                }                       
        }
        system.debug('finalLst--->'+finalLst);
        return FinalLst;    
   }
   public Map<String,List<Discount_Line_Item__c>> getExistingDiscountLevelList(Set<String> guidSet){
        Map<String,List<Discount_Line_Item__c>> cliguidToDLIMap=new Map<String,List<Discount_Line_Item__c>>();
        List<Discount_Line_Item__c> discountLevelList=new List<Discount_Line_Item__c>();
        if(guidSet!=null && !guidSet.isEmpty()){                 
            for(Discount_Line_Item__c dlis:[Select id,chargeInstance__c,actionCode__c,chargeInstance__r.status__c,chargeInstance__r.guid__c,appliedDate__c,BusinessID__c from Discount_Line_Item__c where chargeInstance__r.guid__c IN: guidSet AND chargeInstance__r.status__c='Active']){ 
            discountLevelList.add(dlis);
            if(discountLevelList!=null && discountLevelList.size()>0)
            cliguidToDLIMap.put(dlis.chargeInstance__r.guid__c,discountLevelList);
            system.debug('cliguidToDLIMap in SetActionCodeOnDLIs--->'+cliguidToDLIMap);
            }            
        }
        return cliguidToDLIMap;
    } 
}
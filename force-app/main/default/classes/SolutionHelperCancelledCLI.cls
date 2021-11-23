/* ****************************************************************************
Class Name      : SolutionHelperCancelledCLI
* Author        : Ankit Goswami : Edge-134880
* Date          : 16 Feb 2020
* Description   : Remote Action Class for update PlanTCV and IDDTCV
* *****************************************************************************/
global with sharing class SolutionHelperCancelledCLI implements cssmgnt.RemoteActionDataProvider {
    /****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
* Devloper    : Ankit Goswami 
****************************************************************************************************/
     global Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();      
        System.debug('inputMap'+inputMap);
        Map<String,list<Charge_Line_Item__c>> fetchChargeLineItemForEM=new Map<String,list<Charge_Line_Item__c>>();
        Map<String,list<Charge_Line_Item__c>> fetchPreviousChargeLineItemForEM=new Map<String,list<Charge_Line_Item__c>>();
        set<String> guidLIst=new set<String> ();
        if(inputMap != null){
            String guid = (inputMap.containsKey('guid') && (String)inputMap.get('guid') != '')? (String)inputMap.get('guid'):'';
            String basketId = (inputMap.containsKey('basketId') &&(String) inputMap.get('basketId') != '')? (String)inputMap.get('basketId'):'';
            String solutionID = (inputMap.containsKey('solutionID') &&(String) inputMap.get('solutionID') != '')? (String)inputMap.get('solutionID'):'';
            if(guid !=null && guid!=''){
                guidLIst.add(guid);
            }
            ChargeDiscountQueryUtility CharDis= new ChargeDiscountQueryUtility();
            if(!guidLIst.isEmpty()){
                fetchChargeLineItemForEM =CharDis.fetchChargeLineItemForSolution(guidLIst,basketId,solutionID); 
                system.debug('fetchChargeLineItemForEM::::::'+fetchChargeLineItemForEM);
                if(fetchChargeLineItemForEM != null && fetchChargeLineItemForEM.containsKey(guid)){
                    UpdateCLIStatus(fetchChargeLineItemForEM.get(guid));
                    fetchPreviousChargeLineItemForEM=CharDis.fetchPreviousChargeLineItemForSolution(guidLIst);
                    if(fetchPreviousChargeLineItemForEM.containsKey(guid)){
                        for(Charge_Line_Item__c clList:fetchPreviousChargeLineItemForEM.get(guid)){
                            if(clList.Product_Charge_Identifier__c =='AddOn' && clList.status__c =='Active'){
                            returnMap.put('avgDiscountedPriceAddon',clList.totalContractValue__c); 
                            }else if(clList.Product_Charge_Identifier__c =='Price Item' && clList.status__c =='Active'){
                                returnMap.put('avgDiscountedPricePlan',clList.totalContractValue__c); 
                            }
                        }
                    }
                }
            }
            system.debug('returnMap::::::'+returnMap);
        }
        return returnMap;
    }
    
      /****************************************************************************************************
* Method Name : UpdateCLIStatus
* Description :calling from getdataFromEm
* Parameters  : list<Charge_Line_Item__c>  
* Return      : void   
* Devloper    : Ankit Goswami 
****************************************************************************************************/
    public void UpdateCLIStatus(list<Charge_Line_Item__c> fetchChargeLineItem){
        ComplexChargeDisountFactory comChar= new  ComplexChargeDisountFactory();
        for(Charge_Line_Item__c LineItem:fetchChargeLineItem){
            LineItem.status__c='Cancelled';
        }
        if(!fetchChargeLineItem.isEmpty())
        comChar.updateChargeLineItem(fetchChargeLineItem);
        
    }
      
}
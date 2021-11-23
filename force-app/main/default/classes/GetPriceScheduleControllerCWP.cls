/*
* @Author : Ila
* @Date : 23 Mar 2020
* @Desc : GetPriceScheduleControllerCWP is cloned from GetPriceScheduleController
* @Jira : DPG-1513
* @TestClass : GetPriceScheduleContollerCWPTest
*/
global with Sharing class GetPriceScheduleControllerCWP{
    public String commercialProductIdentifier='Select Plan';
    public string solutionName {get; set;}
    //public Map<String, Map<String,List<String>>> GuidToPI_AddonMap {get; set;}
    public List<PriceScheduleEvent__e> eventList=new List<PriceScheduleEvent__e>();
    public string solutionID {get; set;}
    public String correlationId {get; set;}
    public String DiscountApplicableStatus {get; set;}
    Public Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems {get; set;}
    public Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap  {get; set;} 
    String basketID {get;set;}
    
    /*method to be executed on load Edge-127073*/ 
    public void onLoadMethod(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basktId,String accountId,String solID,    String IsDiscountCheckNeeded,String solName,String basketNum,String correlId){ // updated onload Edge-143527
        DiscountApplicableStatus='Initial';
        solutionName=solName;
        basketID=basktId;
        solutionID=solID;
        if(IsDiscountCheckNeeded=='true'){           
            List<SolutionDTO> solutionDTO;
        if(String.isNotBlank(solutionID)){
            Set<String> commercialProductList=new Set<String>();
            Set<String> addonList=new Set<String>();
            system.debug('@@@guidToAttMapofMap@@@'+guidToAttMapofMap);
            correlationId=correlId; 
            if(guidToAttMapofMap!=null && !guidToAttMapofMap.isEmpty()&& !String.isBlank(basketID) && !String.isBlank(solutionName)){
                DiscountLineItemsMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>();                              
					 processMRO(guidToAttMapofMap);
                        system.debug('DiscountLineItemsMap after MRO--->'+DiscountLineItemsMap+''+'finalChargeLineItems after MRO--->'+finalChargeLineItems);                       
                     

                     //Added by Aman Soni as a part of EDGE-138169 || Start                      
                    if(finalChargeLineItems!=null && finalChargeLineItems.size()>0 && DiscountLineItemsMap!=null && !DiscountLineItemsMap.isEmpty()){
                        ComplexChargeDisountFactory chargeDiscountDML=new ComplexChargeDisountFactory();
                        chargeDiscountDML.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems);// updated by shubhi as the method got renamed Edge-133963
                        DiscountApplicableStatus='Discount Applicable';
                        GetPriceSchedulevirtualClass.publishEventRequest(correlationId,solutionName,basketNum,false);////updated for Edge-143527 
                    }else{
                        DiscountApplicableStatus='No discount applicable';
                    }        
                                    
        }else{
                DiscountApplicableStatus='No discount applicable';
            }
        }else{
            DiscountApplicableStatus='Initial';
        }
    
    } else{
        DiscountApplicableStatus='Already triggered';
    } 
     
    system.debug('---DiscountApplicableStatus---->'+DiscountApplicableStatus);        
   }
     /******************************************************************************
     * Author : Laxmi Rahate: EDGE-127421
     * Date : 12/Nov/2020
     * Description : This method gets the CLI and DLI for MRO based on teh condition that TotalBonus for the config is 
     * greater than Zero and Customer doesnt have OneFund Option. 
     * Then this Method compares the final Maps and if CLI is already then it doesnt create the CLI just creates the DLI.
     * DLI will be in any case created provided the Total Bonus and One Fund Criteria is satisfied
     * Parameter : Solution DTO and Final Maps
     * *******************************************************************************/
            public void processMRO( Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap){
                //updated for Edge-143527 added guidToAttMapofMap
            Map<String,Charge_Line_Item__c> pITOCLiMap;
            List<Discount_Line_Item__c> disLineItemListChk;
            List<Discount_Line_Item__c> disLineItemList;
            Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();
            Charge_Line_Item__c cliPI;
            Discount_Line_Item__c  dliPI;    
            
            if(!guidToAttMapofMap.isEmpty()){
                for(String guid:guidToAttMapofMap.keyset()){
                    disLineItemList =new List<Discount_Line_Item__c>();
                    Map<String,SolutionDTO.Attributes> AttMap=guidToAttMapofMap.get(guid);
                    system.debug('IsDiscountCheckNeeded::'+AttMap.get('IsDiscountCheckNeeded'));
                    system.debug('TotalPlanBonus::'+AttMap.get('TotalPlanBonus'));
                    if(AttMap.size()>0){
                        /*****Check if the  isPaymentTypeOneFund is false and TotalPlanBonus > 0***/
                         if ((AttMap.containsKey('IsDiscountCheckNeeded') && AttMap.get('IsDiscountCheckNeeded').value=='true') 
                            && (AttMap.containsKey('TotalPlanBonus') && AttMap.get('TotalPlanBonus').value!='' && Decimal.valueOf(AttMap.get('TotalPlanBonus').value)>0 ) && (AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value!='Active' && AttMap.get('ChangeType').value!='Cancel')   
                           )// Laxmi Added for EDGE-131531 not to create cli when Action is cancel and Active
                           {
                               System.debug ('Meets the Criteria');
                               cliPI=new Charge_Line_Item__c();
                               dliPI = new Discount_Line_Item__c ();                            
                               cliPI.solutionId__c=solutionID;
                               cliPI.componentName__c=solutionName;
                               cliPI.guid__c=guid;   
                               cliPI.CorrelationId__c=correlationId; 
                               cliPI.Quantity__c=1;
                               cliPI.basketId__c=basketID;  
                               cliPI.status__c='New';//Added by Aman Soni as a part of EDGE-138169
                               //commercialProductIdentifier - has Value as 'Select Plan' - 
                               //below condition gets the value of Select Plan - salesforce ID of the CommercialProduct
                               if(AttMap.containsKey(commercialProductIdentifier)){ 
                                   if(!String.isBlank(AttMap.get(commercialProductIdentifier).value)){
                                       cliPI.commercialProductId__c=AttMap.get(commercialProductIdentifier).value;
                                       System.debug ('Select Plan has value');
                                       cliPI.Product_Charge_Identifier__c='Price Item';
                                       cliPI.targetChargeProduct__c = 'Plan';
                                       if(AttMap.containsKey('RC')&& !String.isBlank(AttMap.get('RC').value)){
                                           cliPI.unitPrice__c=Decimal.valueof(AttMap.get('RC').value);
                                     }
                                       if(AttMap.containsKey('BussinessId_PI')&&  !String.isBlank(AttMap.get('BussinessId_PI').value)){
                                           cliPI.BusinessID__c=AttMap.get('BussinessId_PI').value;
                                           cliPI.chargeType__c = Constants.getChargeType(cliPI.BusinessID__c);
                                       }
                                       if(AttMap.containsKey('RemainingTerm') && !String.isBlank(AttMap.get('RemainingTerm').value) && AttMap.get('RemainingTerm').value!='0'){
                                           cliPI.contractTerm__c=Integer.valueof(AttMap.get('RemainingTerm').value);
                                       }else{
                                           cliPI.contractTerm__c=24;
                                       }
                                   }
                                   //Add code here to check if the CLI is already there in the NON MRO CLI MAP 
                                   if(AttMap.containsKey('deviceTypeBusinessID')&&  !String.isBlank(AttMap.get('deviceTypeBusinessID').value)){
                                       dliPI.BusinessID__c=AttMap.get('deviceTypeBusinessID').value;
                                   }
                                   
                         //Added by Aman Soni as a part of EDGE-135278 || Start
                        if(AttMap.containsKey('BillingAccountNumber') && !String.isBlank(AttMap.get('BillingAccountNumber').value) && AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value=='Modify'){
                            cliPI.billingAccountNumber__c=AttMap.get('BillingAccountNumber').value;
                        }
                        //Added by Aman Soni as a part of EDGE-135278 || End
                        
                        //Added by Aman Soni as a part of EDGE-138169 || Start
                            if(AttMap.containsKey('initialActivationDate')&& !String.isBlank(AttMap.get('initialActivationDate').value)){
                            cliPI.originalActivationDate__c=Date.valueof(AttMap.get('initialActivationDate').value);
                                system.debug('initialActivationDate on plan CLI MRO-->'+ cliPI.originalActivationDate__c);
                            }
                                   system.debug('cliPI' +cliPI);
                        //Added by Aman Soni as a part of EDGE-138169 || End
                                
                                   dliPI.description__c=Constants.MRO_DISCOUNT_DESC;
                                   dliPI.name = Constants.MRO_DISCOUNT_NAME;
                                   dliPI.discountType__c= Constants.DISCOUNT_TYPE;
                                   dliPI.discountValue__c=String.valueOf(AttMap.get('TotalPlanBonus').value);
                                   dliPI.duration__c=Constants.DURATION;
                                   dliPI.durationUoM__c=Constants.DURATION_Months;
                                   dliPI.Priority__c=1;
                                   dliPI.actionCode__c= 'New';
                                   dliPI.discountClass__c = 'Amount';//Added by Aman Soni as a part of EDGE-138169
                                   disLineItemList.add(dliPI);
                                   system.debug('disLineItemListValue' +disLineItemList);
     
                                   if(disLineItemList!=null)
                                   {
                                       priceitemToeligibleDLMap = new Map<String,List<Discount_Line_Item__c>>();
                                       priceitemToeligibleDLMap.put(cliPI.commercialProductId__c,disLineItemList);
                                       system.debug('priceitemToeligibleDLMap' +priceitemToeligibleDLMap);
                                   }
                                   if (!priceitemToeligibleDLMap.isEmpty()){
                                       system.debug('inside priceitemToeligibleDLMap ');
                                        DiscountLineItemsMap.put(guid,priceitemToeligibleDLMap);
                                       system.debug('DiscountLineItemsMap MRO'+DiscountLineItemsMap);
                                   }
                                   if(cliPI!=null)
                                   {
                                        system.debug(' @@@ NON MRO Charge Line Map was Null hence creating new CLi!!');
                                        pITOCLiMap = new Map<String,Charge_Line_Item__c> ();  
                                        if(finalChargeLineItems == null){//Added for CLI fix || Single CLI Fix is getting created for multiple MRO Configs || Aman Soni
                                            finalChargeLineItems = new Map<String, Map<String,Charge_Line_Item__c>>();
                                        }
                                        
                                        pITOCLiMap.put(cliPI.commercialProductId__c,cliPI); 
                                        system.debug('pITOCLiMap**' +pITOCLiMap);
                                        if(pITOCLiMap != null && pITOCLiMap.size()>0 && !String.isBlank(guid)){
                                            finalChargeLineItems.put(guid,pITOCLiMap);
                                            system.debug('finalChargeLineItems+++++ ' +finalChargeLineItems);
                                       }
                                   }
                               } //if attMap containsKey end
                           }// end Attmap check
                    }
                }           
            }
                
        } //Method END ProcessMRO                
}
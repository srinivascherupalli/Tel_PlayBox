/*  
* @Author : Yash    
* @Date : 7th June 2020 
* @Desc : To display NGEM details to Q & C  
* @Jira : EDGE-148721, EDGE-150587 and EDGE-148728  
*/  
/***History of Updates 
1. Mahima Gandhe  DPG-3508 | DPG-3708                 Quote/Contract for AM Accessories
2. Anand       DPG-4161 | DPG-4151            Quote/Contract for AM Accessories Device care
3. Mahima      DPG-4929              prod issue fix
4. Mahima       DPG-4972              Apple care quantity issue.
5. Mahima     DPG-4796/97        NGEM Plan Accelerator
6. Mahima     DPG-5639                      NGEM Plan Accelerator Modify fix
7. Mahima 	  DPG-5624 						Accessory Cancel/Payout
8. Monali     EDGE-218180     Order quote template changes for APN service boltons
9. Mahima       DPG-5844      NGEM Plan TON MAC
10. Kshitiz    EDGE-204960         NO Fault Return Chnages       
**/
global with sharing class NGEMDataHandler { 
    static final String ngemDevicePDName = 'Next Generation Mobile Device';//EDGE-165486
    static final String ngemCarePDName = 'Mobile Device Care';//EDGE-165486
  static final String ngemAccPDName = 'Mobile Accessory';  //DPG-3508
    static final String rcAttr= 'RC';//EDGE-165486
    static final String ocAttr= 'OC'; //EDGE-184433
    static final String ProoductModName='Product_Module_Name';//EDGE-181997
    static final String exId='ExternalId';//EDGE-181997
    static final string rcAcctermAttr='ContractTermShadow'; //DPG-3508
    
    public List<Map<String,Object>> getNGEMDevices(String basketId, Map<String,String> subfilters){ 
    List<Map<String,Object> > rows = new List<Map<String,Object> >();   
    Map<Id, String> map_DeviceModelVsPriceItem = new Map<Id, String>(); 
    Map<Id, String> map_DeviceModelVsAddon = new Map<Id, String>(); 
    Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>(); 
    Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>(); //EDGE-148776  
    Integer externalId=1;   
    List<cscfga__Product_Configuration__c> devicePCList = new List<cscfga__Product_Configuration__c>(); 
    List<cscfga__Product_Configuration__c> devicePCRCList = new List<cscfga__Product_Configuration__c>();   
    List<cscfga__Product_Configuration__c> devicePCOCList = new List<cscfga__Product_Configuration__c>();   
    List<String> specIdList = new List<String>(); //EDGE-148776 
    //List<cscfga__Product_Basket__c> faIdList = new List<cscfga__Product_Basket__c>(); //EDGE-184433 //EDGE-176688 | Removed FA
    String objectAPIName='';    
    //EDGE-148776 - START   
    String paymentTypeStringAttr = 'PaymentTypeString'; 
    String oneOffPaymentTypeValue = 'Purchase'; 
    String repaymentPaymentTypeValue = 'Hardware Repayment';    
    String priceItem = 'cspmb__Price_Item__c';  
    String addOn = 'cspmb__Add_On_Price_Item__c';   
    String priceItemValue = 'PaymentTypeLookup';    
    String addOnValue = 'DeviceCarePaymentTypeLookup';  
    //String ngemDevicePDName = 'Next Generation Mobile Device';  //EDGE-165486
    //String ngemCarePDName = 'Mobile Device Care';   //EDGE-165486
    //EDGE-148776 - END 
    //EDGE-148722 - Start   
    String remainingTermAttr = 'RemainingTerm'; 
    String etcAttr = 'EarlyTerminationCharge';  
    //String rcAttr = 'RC';   //EDGE-165486
    String uom = '';    
    //EDGE-148722 - End 
    Id temp;    
  try{  
        if(basketId.length()>0){    
            //POS redemption information    
            for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id=:basketId and (name ='RedeemFund')]){    
                System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:cscfga__Product_Configuration__c.ID:'+attr.cscfga__Product_Configuration__c);  
                System.debug('attr: '+attr);    
                if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){  
                     map_DeviceWithRedeemAmount.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c);   
                }                                       
            }                                       
            /*EDGE-184433 - Start //EDGE-176688 | Removed FA
            faIdList = [SELECT id,csconta__Frame_Agreement__r.csconta__Status__c from cscfga__Product_Basket__c WHERE id=:basketId LIMIT 1];
            system.debug('FA Id'+faIdList[0].csconta__Frame_Agreement__r.csconta__Status__c);
            //EDGE-184433 - End  */                                    
        }   
        //EDGE-148776 - Start   
        List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];    
        for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){    
            if(ngemSpec.ProductCategory__c=='NGEM'){    
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                specIdList.add(ngemSpec.ProdSpecId__c); 
            }   
        }   
        String ngemDevicePDId = map_PDvsSecId.get(ngemDevicePDName).ProdSpecId__c;  
        //specIdList = map_PDvsSecId.values();  
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:ngemSpecIds'+ngemSpecIds); 
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:map_PDvsSecId'+map_PDvsSecId); 
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:specIdList'+specIdList);   
        //EDGE-148776 - End 
        //EDGE-148776 | Added DeviceCare    
        if(subfilters.get('Type') =='New'){     


            devicePCList =[SELECT id,name,Type__c, subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r), cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND (Type__c='New' OR Type__c='CHOWN') AND csordtelcoa__Replaced_Product_Configuration__c=null AND subType__c!='Inflight Cancel' AND subType__c!='Inflight Amend']; //EDGE-184433 | Added oneoff/recurring //EDGE-171311 Added Subtype in WHERE clause


        }   
        //EDGE-148722 - Start   
        else if(subfilters.get('Type') =='Cancel'){ 
       if(subfilters.get('Query_Type') =='NGEMDeviceOCIC' || subfilters.get('Query_Type') =='NGEMDeviceRCIC'){//EDGE-171311 Inflight Basket


        devicePCList =[SELECT id,name,Type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND subType__c='Inflight Cancel' AND cscfga__Product_Basket__r.recordtype.developername='Inflight_Change'];
       }
       else{
        devicePCList =[SELECT id,name,Type__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,subType__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND Type__c='Cancel']; //EDGE-164623 
       }
        }   

      

        //EDGE-148722 - End 
        for(cscfga__Product_Configuration__c pc:devicePCList) { 
            System.debug('Pc Config===>'+pc);
            //DPG-4161 | DPG-4151 | Added DeviceCare | Start  |Anand 
            if(isAddOnForAccessory(pc)) {
                System.debug('isAddOnForAccessory  true');
                continue;
            }
            //DPG-4161 | DPG-4151 | End
            //EDGE-164623   
            if(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c!=null && pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){// Added condition to include Apple Care Plus PC   
                 devicePCRCList.add(pc);    
            }   
            //EDGE-164623 End   
            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {  
                if(attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue) ){ //EDGE-164623   
                    devicePCOCList.add(pc); 
                }   
                if((pc.Type__c == 'Cancel' && pc.Name != 'AppleCare+ Purchase' && attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue))
                   || (attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(repaymentPaymentTypeValue))){   //added one condition
                    devicePCRCList.add(pc); 
                }   
                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {  
                    temp = attribute.cscfga__Value__c;  
                    objectAPIName = temp.getSObjectType().getDescribe().getName();  
                    System.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);  
                    if(objectAPIName.equalsIgnoreCase(priceItem) && attribute.name.equals(priceItemValue)){ 
                        map_DeviceModelVsPriceItem.put(pc.Id,attribute.cscfga__Value__c);   
                    }   
                    //EDGE-148776 | Added DeviceCare | Start    
                    if(objectAPIName.equalsIgnoreCase(addOn) && attribute.name.equals(addOnValue)){ 
                        map_DeviceModelVsAddon.put(pc.Id,attribute.cscfga__Value__c);   
                    }   
                    //EDGE-148776 | Added DeviceCare | End  
                }       
            }   
        }   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:devicePCList'+devicePCList);   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:devicePCRCList'+devicePCRCList);   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:devicePCOCList'+devicePCOCList);   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:map_DeviceWithRedeemAmount:'+map_DeviceWithRedeemAmount);  
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:map_DeviceModelVsPriceItem:'+map_DeviceModelVsPriceItem);  
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:map_DeviceModelVsAddon:'+map_DeviceModelVsAddon);  
        List<String> attrIdList = map_DeviceModelVsPriceItem.values();  
        System.debug('attrIdList: '+attrIdList);    
        List<cspmb__Price_Item__c> priceItemList = [SELECT id,name,Unit_Of_Measure__c,cspmb__Contract_Term__c,Billing_Description__c,cspmb__One_Off_Charge__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c WHERE id IN :attrIdList]; //EDGE-181997 changes Billing_Description__c field added 
        system.debug('priceItemList: '+priceItemList);  
        Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:priceItemsRecords:'+priceItemsRecords);    
        //EDGE-148776 | Added DeviceCare | Start    
        List<String> attrAddonIdList = map_DeviceModelVsAddon.values(); 
        System.debug('attrAddonIdList: '+attrAddonIdList);  
        List<cspmb__Add_On_Price_Item__c> addOnList = [SELECT id,name,cspmb__One_Off_Charge__c,Billing_Description__c,Unit_Of_Measure__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrAddonIdList]; //EDGE-183882 
        system.debug('addOnList: '+addOnList);  
        Map<id,cspmb__Add_On_Price_Item__c> addOnRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnList);  
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:addOnRecords:'+addOnRecords);  
        //EDGE-148776 | Added DeviceCare | End  
        if(subfilters.get('Query_Type') =='NGEMDeviceOC' || subfilters.get('Query_Type') =='NGEMDeviceOCIC'){//EDGE-171311 Added NGEMDeviceOCIC for Inflight Cancel
            System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices: INSIDE OC BLOCK');
            //EDGE-165486-- Calling New method for OC charges Agreegation--Changes Start
            rows=getGenericAggregatedOCRows(devicePCOCList,map_DeviceModelVsPriceItem, priceItemList,'OneTimeCharges',map_DeviceWithRedeemAmount,map_DeviceModelVsAddon);   //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
            system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OCRow: '+rows); 
            //EDGE-165486-- Calling New method for OC charges Agreegation--Changes End
        }   
        if((subfilters.get('Query_Type') =='NGEMDeviceRC' && subfilters.get('Type')!='Cancel')||(subfilters.get('Query_Type') =='NGEMDeviceRCIC')){//EDGE-155059 Added Extra Condition to bypass logic for Cancel //EDGE-171311 Added NGEMDeviceRCIC for Inflight Cancel
            System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices: INSIDE RC BLOCK');
            //EDGE-165486-- Calling New method for RC charges Agreegation--Changes Start
            rows = getGenericAggregatedRows(devicePCRCList,map_DeviceModelVsPriceItem, priceItemList,map_DeviceWithRedeemAmount,'RecurringCharges');     //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
            system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RCCancelRow: '+rows);          
            //EDGE-165486-- Calling New method for RC charges Agreegation--Changes End  
        }   
      //EDGE-155059 Start   
      if(subfilters.get('Query_Type') =='NGEMDeviceRC' && subfilters.get('Type') == 'Cancel'){  
        //EDGE-181997 changes Passing additional variable map_DeviceModelVsAddon
          rows = getAggregatedRows(devicePCRCList,map_DeviceModelVsPriceItem, priceItemList,true,map_DeviceWithRedeemAmount,map_DeviceModelVsAddon);     //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
          system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:CancelRow: '+rows);  
      }//EDGE-155059 End    
    }   
    catch(Exception e)  
    {   
        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:exception:'+e.getLineNumber()+' '+e.getMessage()); 
    }   
  system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:rows: '+rows);   
    return rows;    
  } 
  //EDGE-165326 - Start | To Display NGEM Plan details in Q & C Docs    
  public List<map<String,Object>> getNGEMPlans(String basketId, Map<String,String> subfilters){ 
    List<Map<String,Object>> rows = new List<Map<String,Object>>();     
    Map<Id, String> map_PlanVsPriceItem = new Map<Id, String>();    
  Map<Id, String> map_AttrVsAddOn = new Map<Id, String>();//EDGE-166406
    Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();    
    List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>(); 
    List<cscfga__Product_Configuration__c> planChildPCList = new List<cscfga__Product_Configuration__c>(); //EDGE-185762
    //List<cscfga__Product_Basket__c> faIdList = new List<cscfga__Product_Basket__c>(); //EDGE-184433   //EDGE-176688 | Removed FA
    List<cscfga__Product_Configuration__c> mbbPCList = new List<cscfga__Product_Configuration__c>();    
    List<cscfga__Product_Configuration__c> wirelessplanPCList = new List<cscfga__Product_Configuration__c>();   
    List<cscfga__Product_Configuration__c> hhplanPCList = new List<cscfga__Product_Configuration__c>(); 
  List<cscfga__Attribute__c> boltOnAttrList = new List<cscfga__Attribute__c>();//EDGE-166406
    Map<string, string> labelMap = new Map<string, string>();  
      Map<Id, cscfga__Product_Configuration__c> attVsPCMap = new Map<Id, cscfga__Product_Configuration__c>(); 
    List<String> specIdList = new List<String>();   
    String objectAPIName='';    
    String priceItem = 'cspmb__Price_Item__c';  
  String addonPriceitem = 'cspmb__Add_On_Price_Item__c';//EDGE-166406
    String ngemPlan = 'NGEMPlan';   
    List<String> ngemPlanPDId = new List<String>();//EDGE-155059 Changed to list    
    Id temp;    
    List<cscfga__Attribute__c> attListNew = new List<cscfga__Attribute__c>();
    Map<Id , cscfga__Product_Configuration__c> planPCMap = new  Map<Id , cscfga__Product_Configuration__c>(); 
    List<String> labelsNGEM =  new List<String>();
    try{    
      //  List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];    
        for(ProductSpecificationCode__mdt ngemSpec:[Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt]){    
            if(ngemSpec.ProductCategory__c==ngemPlan){  
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                specIdList.add(ngemSpec.ProdSpecId__c); 
            }   
        }   
      //  List<Apex_Label__mdt> labels = [Select id,Label, Value__c from Apex_Label__mdt where isActive__c = true];   
        for(Apex_Label__mdt l:[Select id,Label, Value__c from Apex_Label__mdt where isActive__c = true]){  
            labelMap.put(l.label,l.value__c);   
        }   
    //EDGE-166406 Start
 //   List<NGEM_Bolt_On_Attribute__mdt> labelsNGEM = [Select id,Label from NGEM_Bolt_On_Attribute__mdt where isActive__c = true];
        for(NGEM_Bolt_On_Attribute__mdt ngemLabel : [Select id,Label from NGEM_Bolt_On_Attribute__mdt where isActive__c = true]){
            labelsNGEM.add(ngemLabel.Label);
        }
       
    system.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabelNGEM:'+labelsNGEM);
    //EDGE-166406 End
    /* //EDGE-184433 - Start //EDGE-176688 | Removed FA
    faIdList = [SELECT id,csconta__Frame_Agreement__r.csconta__Status__c from cscfga__Product_Basket__c WHERE id=:basketId LIMIT 1];
    system.debug('FA Id'+faIdList[0].csconta__Frame_Agreement__r.csconta__Status__c);
    //EDGE-184433 - End */
    //    System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labels);  
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap);    
    //    System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('planTypeStringAttr'));  
    //    System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('mbbplanTypeStringVal'));    
     //   System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('wirelessplanTypeStringVal'));   
     //   System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('hhplanTypeStringVal')); 
     //   System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('priceItemValue'));  
     //   System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('ngemPlanPDName'));  
      //  System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabel'+labelMap.get('ngemDataPDname'));  
        if(map_PDvsSecId != null && !map_PDvsSecId.isEmpty()){  
    //EDGE-155059 Adding rows in list   
            if(labelMap.get('ngemPlanPDName')!=null)    
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemPlanPDName')).ProdSpecId__c);  
            if(labelMap.get('ngemDataPDname')!=null)    
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemDataPDname')).ProdSpecId__c);  
            if(labelMap.get('ngemVoicePDName')!=null)   
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemVoicePDName')).ProdSpecId__c); 
            if(labelMap.get('ngemCallMsgPDName')!=null) 
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemCallMsgPDName')).ProdSpecId__c);   
      //EDGE-176737 Start
            if(labelMap.get('ngemIRPDName')!=null)
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemIRPDName')).ProdSpecId__c);
            //EDGE-176737 End
            //DPG-4796/97 Start
            if(labelMap.get('ngemAcceleratorPDname')!=null)
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemAcceleratorPDname')).ProdSpecId__c);
          //DPG-4796/97 End
        //EDGE-218180
        if(labelMap.get('EnterpriseMobilityData-Custom')!=null)
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('EnterpriseMobilityData-Custom')).ProdSpecId__c);
        //EDGE-218180 End 
        //DPG-5844 Start
        //if(system.label.Is_TON_Enabled=='true'){
            if(labelMap.get('ngemTONPDname')!=null)
            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemTONPDname')).ProdSpecId__c);
        //}
        //DPG-5844 End
          
        }   
   //     System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:ngemSpecIds'+ngemSpecIds);    
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:map_PDvsSecId'+map_PDvsSecId);    
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:specIdList'+specIdList);      
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:ngemPlanPDId'+ngemPlanPDId);  
       if(subfilters.get('Type') =='New'){      
            planPCMap =new Map<Id,cscfga__Product_Configuration__c>([SELECT id,name,Type__c,QCDiscountText__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.name,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c/*,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) */ FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND ((Type__c='New' AND subtype__c=null) OR (Type__c='CHOWN' AND subType__c='CHOWN IN')) AND csordtelcoa__Replaced_Product_Configuration__c=null]);//EDGE-155059 Added cscfga__Parent_Configuration__r.name //EDGE-184433 | Added oneoff/recurring fields //EDGE-188100 Added subtype
            attListNew = [SELECT Id,cscfga__Product_Configuration__r.QCDiscountText__c, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c,cscfga__Product_Configuration__r.Id, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attribute__c where cscfga__Product_Configuration__c IN: planPCMap.keySet() AND (Name IN: labelsNGEM OR Name =: 'Select Plan' OR name =: 'PlanTypeString')]; 
        }
    else if(subfilters.get('Type') =='Reactivate'){//EDGE-188100      
            planPCList =[SELECT id,name,Type__c,subType__c,QCDiscountText__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.name,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND Type__c='New' AND subtype__c='Reactivate' AND csordtelcoa__Replaced_Product_Configuration__c=null];//EDGE-155059 Added cscfga__Parent_Configuration__r.name //EDGE-184433 | Added oneoff/recurring fields //EDGE-188100 Added subtype
        }    
       else if(subfilters.get('Type') =='Modify'){   
            planPCList =[SELECT id,name,Type__c,subType__c,QCDiscountText__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.name,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND Type__c='Modify' AND csordtelcoa__Replaced_Product_Configuration__c!=null];//EDGE-155059 Added cscfga__Parent_Configuration__r.name //EDGE-184433 | Added oneoff/recurring fields
            planChildPCList =[SELECT id,name,QCDiscountText__c,Type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.name,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND Type__c='New' AND cscfga__Parent_Configuration__r.type__C = 'Modify'];//EDGE-185762 //EDGE-184433 | Added oneoff/recurring fields
          //  system.debug('planChildPCList@@::' + planChildPCList);//EDGE-185762
       }
    //EDGE-155059 Added below for cancel scenario
    else if(subfilters.get('Type') =='Cancel'){   
            planPCList =[SELECT id,name,Type__c,QCDiscountText__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.name,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name,cscfga__Product_Configuration__r.name,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null];
        }   
        System.debug('Log for test class: ----> ' + planPCList);    
        if(subfilters.get('Type') =='New'){
            for(cscfga__Attribute__c attribute:attListNew) { 
                 if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('mbbplanTypeStringVal'))){    //PlanTypeString
                    mbbPCList.add(planPCMap.get(attribute.cscfga__Product_Configuration__c));  
                 system.debug('mbbPCList@@inside::' + mbbPCList);    
                }   
                if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('wirelessplanTypeStringVal'))){  
                    wirelessplanPCList.add(planPCMap.get(attribute.cscfga__Product_Configuration__c)); 
                }   
                if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('hhplanTypeStringVal'))){    
                    hhplanPCList.add(planPCMap.get(attribute.cscfga__Product_Configuration__c));   
                }   
          //      if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {  
                /*    temp = attribute.cscfga__Value__c;  
                    objectAPIName = temp.getSObjectType().getDescribe().getName();  
                    System.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);  
                    if(objectAPIName.equalsIgnoreCase(priceItem) && attribute.name.equals(labelMap.get('priceItemValue'))){  // Select Plan
                        map_PlanVsPriceItem.put(pc.Id,attribute.cscfga__Value__c);  
                    }  */
                     if(attribute.name.equals(labelMap.get('priceItemValue'))){  // Select Plan 
                       String attVal = attribute.cscfga__Value__c; 
                       if(attribute.cscfga__Value__c != null && attVal.startswith('a3u'))
                        map_PlanVsPriceItem.put(attribute.cscfga__Product_Configuration__r.Id,attribute.cscfga__Value__c);  
                    } 
          //EDGE-166406 Start
             /*   if(objectAPIName.equalsIgnoreCase(addonPriceitem)){
                    for(NGEM_Bolt_On_Attribute__mdt attrBoltOn:labelsNGEM)
                    {  system.debug('attrBoltOn.label@@' + attrBoltOn.label +'::' + attribute.name);
                    if(attribute.name == attrBoltOn.label){
                        boltOnAttrList.add(attribute);
                        attVsPCMap.put(attribute.Id,pc);
                        map_AttrVsAddOn.put(attribute.Id,attribute.cscfga__Value__c);
                        //system.debug('attribute@@::' + attribute.id + '::' + attribute.name);
                        system.debug('map_AttrVsAddOn@@::' + map_AttrVsAddOn);
                        system.debug('match for :' + attribute.name +':'+boltOnAttrList);
                    }
                    }
                } */
             for(String attrBoltOn:labelsNGEM){
                String attVal = attribute.cscfga__Value__c; 
                if(attribute.name == attrBoltOn && attribute.cscfga__Value__c != null && attVal.startswith('a3l')){
                    boltOnAttrList.add(attribute);
                    attVsPCMap.put(attribute.Id,planPCMap.get(attribute.cscfga__Product_Configuration__c));
                    map_AttrVsAddOn.put(attribute.Id,attribute.cscfga__Value__c);
                    //system.debug('attribute@@::' + attribute.id + '::' + attribute.name);
                    system.debug('map_AttrVsAddOn@@::' + map_AttrVsAddOn);
                    system.debug('match for :' + attribute.name +':'+boltOnAttrList);
                }
              }
          //EDGE-166406 End
             //   }   
            }
            for(cscfga__Product_Configuration__c pc:planPCMap.values()) { // Delete this loop 

                if(labelMap.get('ngemDataPDname')!=null && labelMap.get('ngemVoicePDName')!=null && labelMap.get('ngemCallMsgPDName')!=null)    
                if(pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemDataPDname')).ProdSpecId__c || pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemVoicePDName')).ProdSpecId__c || pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemCallMsgPDName')).ProdSpecId__c)    
                {   
                    mbbPCList.add(pc);  
                    wirelessplanPCList.add(pc); 
                    hhplanPCList.add(pc);   
                System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:mbbPCListInsideForLoop'+mbbPCList);   
                System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:wirelessplanPCListInsideForLoop'+wirelessplanPCList); 
                System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:hhplanPCListInsideForLoop'+hhplanPCList); 
                }   
            }   
        }
        else{
        for(cscfga__Product_Configuration__c pc:planPCList) {   
            system.debug('pc.name@@::first loop' + pc.name);    
            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {  
                if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('mbbplanTypeStringVal'))){    //PlanTypeString
                    mbbPCList.add(pc);  
            system.debug('mbbPCList@@inside::' + mbbPCList);    
                }   
                if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('wirelessplanTypeStringVal'))){  
                    wirelessplanPCList.add(pc); 
                }   
                if(attribute.Name.equals(labelMap.get('planTypeStringAttr')) && attribute.cscfga__Value__c.equals(labelMap.get('hhplanTypeStringVal'))){    
                    hhplanPCList.add(pc);   
                }   
                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {  
                    temp = attribute.cscfga__Value__c;  
                    objectAPIName = temp.getSObjectType().getDescribe().getName();  
                    System.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);  
                    if(objectAPIName.equalsIgnoreCase(priceItem) && attribute.name.equals(labelMap.get('priceItemValue'))){  // Select Plan
                        map_PlanVsPriceItem.put(pc.Id,attribute.cscfga__Value__c);  
                    }   
          //EDGE-166406 Start
          if(objectAPIName.equalsIgnoreCase(addonPriceitem)){
            for(String attrBoltOn:labelsNGEM)
            {  system.debug('attrBoltOn.label@@' + attrBoltOn +'::' + attribute.name);
              if(attribute.name == attrBoltOn){
                boltOnAttrList.add(attribute);
                attVsPCMap.put(attribute.Id,pc);
                map_AttrVsAddOn.put(attribute.Id,attribute.cscfga__Value__c);
                //system.debug('attribute@@::' + attribute.id + '::' + attribute.name);
                system.debug('map_AttrVsAddOn@@::' + map_AttrVsAddOn);
                system.debug('match for :' + attribute.name +':'+boltOnAttrList);
              }
            }
                    }
          //EDGE-166406 End
                }   
            }   
            //EDGE-155059 Start 
            if(labelMap.get('ngemDataPDname')!=null && labelMap.get('ngemVoicePDName')!=null && labelMap.get('ngemCallMsgPDName')!=null)    
            if(pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemDataPDname')).ProdSpecId__c || pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemVoicePDName')).ProdSpecId__c || pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(labelMap.get('ngemCallMsgPDName')).ProdSpecId__c)    
            {   
                mbbPCList.add(pc);  
                wirelessplanPCList.add(pc); 
                hhplanPCList.add(pc);   
            System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:mbbPCListInsideForLoop'+mbbPCList);   
            System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:wirelessplanPCListInsideForLoop'+wirelessplanPCList); 
            System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:hhplanPCListInsideForLoop'+hhplanPCList); 
            }   
        }   
    }
    //EDGE-166406 Start
   /*  for(cscfga__Product_Configuration__c pc:hhplanPCList) 
        {  system.debug('pc.namemgetngemplan@@::' + pc.name);
        }
        for(cscfga__Attribute__c pc:boltOnAttrList) 
        { system.debug('pc.getboltonparentpc@@::' + pc.name +'@@' + pc.cscfga__Product_Configuration__r.name + '@@' +pc.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name);
            //system.debug('pc.getboltonparentpc@@::' + pc.id);
        } */
    system.debug('***Telstra:NGEMDataHandler:getNGEMPlans:boltOnAttrList:' + boltOnAttrList);//EDGE-166406
    system.debug('***Telstra:NGEMDataHandler:getNGEMPlans:map_AttrVsAddOn:' + map_AttrVsAddOn.keyset());//EDGE-166406
    //EDGE-166406 End
        //EDGE-155059 End   
        //EDGE-185762 Start
        if(subfilters.get('Type') =='Modify'){
          for(cscfga__Product_Configuration__c pc:planChildPCList){   
              system.debug('pc.name@@::IRNew' + pc.name);    
               for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){ 
                    system.debug('attributeAddonNew@@::' + attribute);
                  if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {  
                      temp = attribute.cscfga__Value__c;  
                      objectAPIName = temp.getSObjectType().getDescribe().getName();  
                      System.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);  
                      if(objectAPIName.equalsIgnoreCase(addonPriceitem)){

                          system.debug('attributeAddonNewPriceitem@@::' + attribute);
                     for(String attrBoltOn:labelsNGEM){  
                            system.debug('attrBoltOn.label@@IRNew' + attrBoltOn +'::' + attribute.name);
                        if(attribute.name == attrBoltOn){
                           boltOnAttrList.add(attribute);
                            // DPG-5639-- added by Mahima -start
                           if(!attVsPCMap.containsKey(attribute.Id)){
                            attVsPCMap.put(attribute.Id,pc);
                            system.debug('attVsPCMap :AddonNew' + attribute.name +':'+pc);
                           }
                           // DPG-5639-- added by Mahima -end
                          map_AttrVsAddOn.put(attribute.Id,attribute.cscfga__Value__c);
                          system.debug('map_AttrVsAddOn@@IRNew::' + map_AttrVsAddOn);
                        }
                    }
                      }
                    }     
            }   
            }  
      /*  for(cscfga__Attribute__c pc:boltOnAttrList) 
        {
            system.debug('pc.getboltonparentpc@@::IRNew' + pc.name +'@@' + pc.cscfga__Product_Configuration__r.name + '@@' +pc.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.name);
            //system.debug('pc.getboltonparentpc@@::IRNew' + pc.id+'::' + pc.name);
        }*/
        }  
        
         //EDGE-185762 End
        List<String> attrIdList = map_PlanVsPriceItem.values(); 
        System.debug('attrIdList: '+attrIdList);    
        List<cspmb__Price_Item__c> priceItemList = [SELECT id,name,Unit_Of_Measure__c,cspmb__Recurring_Charge__c,Billing_Description__c FROM cspmb__Price_Item__c WHERE id IN :attrIdList]; //EDGE-181997 changes Billing_Description__c field added    
        system.debug('priceItemList: '+priceItemList);  
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:planPCList'+planPCList);  
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:mbbPCList'+mbbPCList);    
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:wirelessplanPCList'+wirelessplanPCList);  
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:hhplanPCList'+hhplanPCList);  
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:map_PlanVsPriceItem:'+map_PlanVsPriceItem);   
        //EDGE-18800 Added Reactivate merge queries
        if(subfilters.get('Query_Type') =='NGEMPlanMBB' || subfilters.get('Query_Type') =='NGEMPlanMBBMAC' || subfilters.get('Query_Type') =='NGEMPlanMBBCancel' || subfilters.get('Query_Type') =='NGEMPlanMBBReact'){  
           rows = getAggregatedRowsPlan(mbbPCList,map_PlanVsPriceItem, priceItemList,false,null,map_AttrVsAddOn,boltOnAttrList,attVsPCMap);//EDGE-155059 Added last two arguments //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
           System.debug('***Telstra:NGEMDataHandler:getNGEMPlans: INSIDE MBB BLOCK'+rows);
         }
        if(subfilters.get('Query_Type') =='NGEMPlanWLS' || subfilters.get('Query_Type') =='NGEMPlanWLSMAC' || subfilters.get('Query_Type') =='NGEMPlanWLSCancel' || subfilters.get('Query_Type') =='NGEMPlanWLSReact'){
           rows = getAggregatedRowsPlan(wirelessplanPCList,map_PlanVsPriceItem , priceItemList,false,null,map_AttrVsAddOn,boltOnAttrList,attVsPCMap);//EDGE-155059 Added last two arguments //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
           System.debug('***Telstra:NGEMDataHandler:getNGEMPlans: INSIDE Wireless BLOCK'+rows);
        }
        if(subfilters.get('Query_Type') =='NGEMPlanHH' || subfilters.get('Query_Type') =='NGEMPlanHHMAC' || subfilters.get('Query_Type') =='NGEMPlanHHCancel' || subfilters.get('Query_Type') =='NGEMPlanHHReact'){
          rows = getAggregatedRowsPlan(hhplanPCList,map_PlanVsPriceItem , priceItemList,false,null,map_AttrVsAddOn,boltOnAttrList,attVsPCMap);//EDGE-155059 Added last two arguments //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
          System.debug('***Telstra:NGEMDataHandler:getNGEMPlans: INSIDE HH BLOCK'+rows);    
        }           
    }   
    catch(Exception e)  
    {   
        System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:exception:'+e.getLineNumber()+' '+e.getMessage());    
    }   
        system.debug('========== Heap Size ::getNGEMPlans:: ' + Limits.getHeapSize());
     System.debug('***Telstra:NGEMDataHandler:getNGEMPlans:Final Rows '+rows);  
      return rows;  
  } 
  // To get plan rows for perticular plan type
   //EDGE-181997 changes Added map_DeviceModelVsAddon variable
   public List<map<String,Object>> getAggregatedRows(List<cscfga__Product_Configuration__c> pcList , Map<Id, String> priceMap ,List<cspmb__Price_Item__c> priceItemList, Boolean deviceCancelFlg,Map<String, String> map_DeviceWithRedeemAmount,Map<Id, String> map_DeviceModelVsAddon){    
      List<Map<String,Object>> rows = new List<Map<String,Object>>();   
      String etcAttr = 'EarlyTerminationCharge';//EDGE-155059 && EDGE-172755    
      Map<String, Map<String,Object> > checkDuplicate = new Map<String,Map<String,Object>>();   
      String remainingTermAttr = 'RemainingTerm';//EDGE-155059 && EDGE-172755   
      String remainingTermValue ='';//EDGE-155059 && EDGE-172755    
      Map<String, Map<String,Object> > checkDuplicateBoltOn = new Map<String,Map<String,Object>>();//EDGE-155059 && EDGE-172755       
      // EDGE-204960 start
      String oneOffPaymentTypeValue = 'Purchase'; 
      String repaymentPaymentTypeValue = 'Hardware Repayment';   
      String paymentTypeStringAttr = 'PaymentTypeString';
       //EDGE-204960  end
      System.debug('***Telstra:NGEMDataHandler:getAggregatedRows: Insdide' + pcList);   
      //EDGE-164623 
      Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();  
      String uniqueKey = ''; //EDGE-196119
      //String ngemCarePDName = 'Mobile Device Care'; 

       List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt]; 
        for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){    
            if(ngemSpec.ProductCategory__c=='NGEM'){    
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
            }   
        }   
      //EDGE-164623 End     
      try{  
        String uom = '';    
        Integer externalId=1;
        String productModuleName = '';//EDGE-204960 start   
        Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);
        //EDGE-181997 Changes Start here        
        Map<String,String>  map_DeviceWithRedeemAmountAC = new  Map<String,String>();   
        List<String> attrAddonIdList = map_DeviceModelVsAddon.values();
        Map<id,cspmb__Add_On_Price_Item__c> addOnRecords= new Map<id,cspmb__Add_On_Price_Item__c>();
        if(attrAddonIdList!=null){
        List<cspmb__Add_On_Price_Item__c> addOnList = [SELECT id,name,cspmb__One_Off_Charge__c,Billing_Description__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrAddonIdList];       
         addOnRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnList);
        }
         //EDGE-181997 Changes End here
        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemsRecords:'+priceItemsRecords);  
        if(pcList.isEmpty() != null ){  
            //164623 Start  
            for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__c IN :pcList and (name ='RedeemFundCopy')]){    
                System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:cscfga__Product_Configuration__c.ID:'+attr.cscfga__Product_Configuration__c);  
                System.debug('attr: '+attr);    
                if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){  
                     map_DeviceWithRedeemAmountAC.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c);     
                }                                       
            }   
            //164623 End    
          //Aggregation Logic
          String paymentType= '';//EDGE-204960   
          String redeemFundCopySuffix = '';
            
            for(cscfga__Product_Configuration__c pc:pcList) {               
                
                //EDGE-204960  start                           
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {                    
                    if(attribute.Name == paymentTypeStringAttr){
                        paymentType = attribute.cscfga__Value__c;
                    } 
                     if(attribute.Name == 'RedeemFundCopy' && attribute.cscfga__Value__c != null && Double.valueOf(attribute.cscfga__Value__c)!=0){
                        redeemFundCopySuffix = '^';
                    }   
                }
                
                System.debug('paymentType === '+paymentType + ' pcid == '+pc.id);
                //EDGE-204960  end               
                //EDGE-155059 && EDGE-172755 Start  
                if(pc.cscfga__Parent_Configuration__c == null){ 
              //EDGE-196119 - Start  
                    cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                    if(priceItemRecord!=null){
                        uniqueKey = priceItemRecord.Billing_Description__c;
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows: uniqueKey' + uniqueKey);
                    }
                    //EDGE-196119 - End 
              if(deviceCancelFlg) 
              {   
                  for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {  
                  if(attribute.name.equals(remainingTermAttr) && attribute.cscfga__Value__c!=null && attribute.cscfga__Value__c!='' && priceItemRecord!=null){ //EDGE-196119 Added priceItemRecord null check
                              remainingTermValue = string.valueOf(attribute.cscfga__Value__c);    
                              System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:remainingTermAttr:' + string.valueOf(attribute.cscfga__Value__c));   
                              uniqueKey = priceItemRecord.Billing_Description__c + '~' + string.valueOf(attribute.cscfga__Value__c); //EDGE-196119 Replacing pc.name with priceItemRecord.Billing_Description__c
                              break;  
                          }       
                  }   
                  if(map_DeviceWithRedeemAmount != null){ 
                  String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);    
                  System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:redeemAmt '+redeemAmt); 
                  //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information 
                  if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){    
                      uniqueKey = uniqueKey +'~'+'#'; 
                  }   
              }
              //EDGE-204960  start
              if(pc.subType__c=='No Fault Return' && !productModuleName.contains(system.label.Apple_Care_Plus)) 
              {
                  uniqueKey = uniqueKey  +  ' - refund <sup>~</sup> '+redeemFundCopySuffix;
              } //EDGE-204960   end   
              }   
              system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:uniqueKey:' + uniqueKey);    
              //EDGE-155059 && EDGE-172755 End    
              system.debug('pc.name@@::::' + pc.name);    
              Map<String,Object> planRow = new Map<String,Object>();  
              Map<String,Object> modifyRecord = checkDuplicate.get(uniqueKey);//EDGE-155059 && EDGE-172755 Introduced uniquekey   
              System.debug('Before check duplicate: ' + checkDuplicate);  
              if(checkDuplicate.containsKey(uniqueKey)){//EDGE-155059 && EDGE-172755 Introduced uniquekey 
                  Decimal existingQty =  Integer.valueOf(modifyRecord.get('Quantity'));   
                  existingQty = existingQty+pc.Quantity_Product_Configuration__c; 
                  modifyRecord.put('Quantity', existingQty);  
                  // EDGE-196119 cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));  
                  if(priceItemRecord!=null && !deviceCancelFlg) {//EDGE-155059 && EDGE-172755 Added extra condition for device cancellation aggregation   
                      modifyRecord.put('GSTExcl_Total_Recurring_Charges',existingQty*priceItemRecord.cspmb__Recurring_Charge__c); 
                      modifyRecord.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(existingQty*priceItemRecord.cspmb__Recurring_Charge__c)); 
                  }   
                  //EDGE-155059 && EDGE-172755 Start  
                          if(pc.Type__c=='Cancel'){   
                              System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC: Inside Cancel');    
                              //rcRow.put('Discount_Text','('+term+' month hardware repayment option)');  
                              System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attributes: '+pc.cscfga__Attributes__r);  
                              productModuleName = ''; //EDGE-204960  
                              String redeemAmtforPC =map_DeviceWithRedeemAmount.get(pc.Id);
                              System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:redeemAmtforPC '+redeemAmtforPC);
                              //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                              if(redeemAmtforPC != '0.00' && String.isNotEmpty(redeemAmtforPC)){
                                  productModuleName = priceItemRecord.Billing_Description__c+' <sup>#</sup>';//pc.Name+' <sup>#</sup>';
                                  System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:productModuleName::' + productModuleName); 
                                  //productModuleName = productModuleName.replaceAll('#', '<sup>#</sup>');
                              }
                              else{
                                  productModuleName = priceItemRecord.Billing_Description__c;//EDGE-181997 Changes 
                              }
                              
                              //EDGE-204960 starts
                              if(pc.subType__c=='No Fault Return' && !productModuleName.contains(system.label.Apple_Care_Plus)) 
                              {
                                  productModuleName = productModuleName  +  ' - refund <sup>~</sup> '+paymentType;
                              }
                              
                             // planRow.put(ProoductModName,productModuleName);//EDGE-181997 Changes 
                             
                              System.debug('productModuleName ======== '+productModuleName+ ' pcid == '+ pc.id);
                              //EDGE-204960 ends 
                              for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {  
                                  if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){  
                                      System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attribute with Value: '+attribute);   
                                      /*if(attribute.name.equals(remainingTermAttr)){ 
                                          rcRow.put('RemainingTerm','Your hardware repayment option has '+attribute.cscfga__Value__c+' months remaining');    
                                      }*/ 
                                      if(attribute.name.equals(etcAttr) && attribute.cscfga__Value__c!=null && pc.subType__c != 'No Fault Return')//added one condition
                                      {
                                          String tempETC = String.valueof(modifyRecord.get('GSTExcl_TotalETC'));//EDGE-179422
                                          system.debug('tempETC');//EDGE-179422
                                          Decimal existingETC =  Decimal.valueOf(tempETC);//EDGE-179422   
                                          existingETC = existingETC + decimal.valueof(attribute.cscfga__Value__c);    
                                          modifyRecord.put('GSTExcl_TotalETC',string.valueOf(existingETC));   
                                          modifyRecord.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));   
                                      }
                                      //EDGE-204960  start
                                      else if(pc.subType__c == 'No Fault Return' && paymentType.equals(oneOffPaymentTypeValue) && attribute.name.equals(ocAttr)){//display one month charges in case of Purchase- no fault return
                                        String tempETC = String.valueof(modifyRecord.get('GSTExcl_TotalETC'));
                                        
                                        Decimal existingETC =  Decimal.valueOf(tempETC);
                                        existingETC = existingETC + (decimal.valueof(attribute.cscfga__Value__c)*(-1));    
                                        modifyRecord.put('GSTExcl_TotalETC',string.valueOf(existingETC));   
                                        modifyRecord.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));   
                                         
                                    }  
                                   else if(pc.subType__c == 'No Fault Return' && paymentType.equals(repaymentPaymentTypeValue) && attribute.name.equals(rcAttr)){//display one month charges in case of purchase- no fault return
                                       String tempETC = String.valueof(modifyRecord.get('GSTExcl_TotalETC'));
                                       
                                        Decimal existingETC =  Decimal.valueOf(tempETC);
                                        existingETC = existingETC +( decimal.valueof(attribute.cscfga__Value__c)*(-1));    
                                        modifyRecord.put('GSTExcl_TotalETC',string.valueOf(existingETC));   
                                        modifyRecord.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));   
                                         
                                   }  
                                    /*else if(pc.subType__c.equals('No Fault Return') && paymentType.equals(oneOffPaymentTypeValue)
                                          && attribute.name.equals('RedeemFundCopy') && attribute.cscfga__Value__c != null)
                                          {
                                        String tempETC = String.valueof(modifyRecord.get('GSTExcl_TotalETC'));
                                        Decimal existingETC =  Decimal.valueOf(tempETC)+ double.valueOf(attribute.cscfga__Value__c);
                                        modifyRecord.put('GSTExcl_TotalETC',string.valueOf(existingETC));   
                                        modifyRecord.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                    }*/
                                    //EDGE-204960 end
                                       
                                  }   
                              }   
                          }   
                          //EDGE-155059 && EDGE-172755 End    
                          System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecord:'+ modifyRecord); 
              } 
              else{
                          //planRow.put('Product_Module_Name',pc.Name);//EDGE-181997 Changes 
                          planRow.put(exId, externalID++);
                          if(deviceCancelFlg)//EDGE-155059 && EDGE-172755

                          if(pc.subType__c == 'No Fault Return'){//EDGE-204960  
                            planRow.put('RemainingTerm','');
                        }else{
                      planRow.put('RemainingTerm',remainingTermValue+' months remaining');//EDGE-165486 changes////EDGE-155059 && EDGE-172755
                        }
                            Decimal qty = 1;
                            qty = pc.Quantity_Product_Configuration__c;
                            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qty '+qty);
                            planRow.put('Quantity',qty);
                            // EDGE-196119 cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecord '+priceItemRecord);
                            if(priceItemRecord!=null && !deviceCancelFlg) {//EDGE-155059 && EDGE-172755 Added extra condition for device cancellation aggregation
                                // planRow.put(ProoductModName,priceItemRecord.Billing_Description__c);//EDGE-181997 Changes 
                                planRow.put(ProoductModName,productModuleName);//EDGE-181997 Changes
                                planRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                                planRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                                planRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                                planRow.put('Discount_Text','$ '+priceItemRecord.cspmb__Recurring_Charge__c+' ex GST '+priceItemRecord.Unit_Of_Measure__c); //EDGE-183882
                            }
                            //EDGE-155059 && EDGE-172755 Start
                        if(pc.Type__c=='Cancel'){
                            System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC: Inside Cancel');
                            //Start For Devices Cancel Aggregation
                                if(map_DeviceWithRedeemAmount != null){
                                    productModuleName = '';  
                                        String redeemAmtforPC =map_DeviceWithRedeemAmount.get(pc.Id);
                                        System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:redeemAmtforPC '+redeemAmtforPC);
                                        //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                                        if(redeemAmtforPC != '0.00' && String.isNotEmpty(redeemAmtforPC)){
                                            productModuleName = priceItemRecord.Billing_Description__c+' <sup>#</sup>';//pc.Name+' <sup>#</sup>';
                                             System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:productModuleName::' + productModuleName); 
                                            //productModuleName = productModuleName.replaceAll('#', '<sup>#</sup>');
                                        }
                                        else{
                                            productModuleName = priceItemRecord.Billing_Description__c;//EDGE-181997 Changes 
                                        }

                                        //EDGE-204960 starts
                                                                              if(pc.subType__c=='No Fault Return' && !productModuleName.contains(system.label.Apple_Care_Plus)) 
                                                                               {
                                                                                productModuleName = productModuleName  +  ' - refund <sup>~</sup> '+redeemFundCopySuffix;
                                                                                }
                                                                                 
                                                                               planRow.put(ProoductModName,productModuleName);//EDGE-181997 Changes 
                                       
                                                                               //EDGE-204960 ends
                                                                       }
                            //End For Devices Cancel Aggregation
                            //rcRow.put('Discount_Text','('+term+' month hardware repayment option)');
                            System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attributes: '+pc.cscfga__Attributes__r);
                            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){
                                    System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attribute with Value: '+attribute);
                                    /*if(attribute.name.equals(remainingTermAttr)){
                                        rcRow.put('RemainingTerm','Your hardware repayment option has '+attribute.cscfga__Value__c+' months remaining');
                                    }*/
                                    if(attribute.name.equals(etcAttr) && pc.subType__c != 'No Fault Return'){// EDGE-204960  added no fault return check

                                        if(attribute.cscfga__Value__c == null)
                                        {
                                            planRow.put('GSTExcl_TotalETC','0.00');
                                            planRow.put('GSTIncl_TotalETC','0.00');
                                        }
                                        else{
                                        planRow.put('GSTExcl_TotalETC',string.valueOf(attribute.cscfga__Value__c));
                                        planRow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                                        }
                                    }
                                    // EDGE-204960  start
                                            else if(pc.subType__c == 'No Fault Return' && paymentType.equals(oneOffPaymentTypeValue) && attribute.name.equals(ocAttr)){//display one month charges in case of HRO- no fault return
    
                                             String tempETC = String.valueof(planRow.get('GSTExcl_TotalETC'));
                                             Decimal existingETC = 0.0;
                                             if(tempETC != null &&  tempETC != ''){
                                                 existingETC = Decimal.valueOf(tempETC);
                                             }
                                             if(attribute.cscfga__Value__c == null){
                                                planRow.put('GSTExcl_TotalETC','0.00');
                                                planRow.put('GSTIncl_TotalETC','0.00');
                                                
                                            }else{   
                                                existingETC= existingETC + (double.valueOf(attribute.cscfga__Value__c)*(-1));
                                                planRow.put('GSTExcl_TotalETC',string.valueOf(existingETC));
                                                planRow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                            }
                                             System.debug('planrow GST == '+String.valueof(planRow.get('GSTExcl_TotalETC')));
                                        }
                                         else if(pc.subType__c == 'No Fault Return' && paymentType.equals(repaymentPaymentTypeValue) && attribute.name.equals(rcAttr)){//display one month charges in case of purchase- no fault return
    
                                            if(attribute.cscfga__Value__c == null){
                                                planRow.put('GSTExcl_TotalETC','0.00');
                                                planRow.put('GSTIncl_TotalETC','0.00');
                                                
                                            }else{
                                                planRow.put('GSTExcl_TotalETC',string.valueOf(decimal.valueof(attribute.cscfga__Value__c)*(-1)));
                                                planRow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c)*(-1))));
                                            }
                                            
                                        }
                                        /*else if(pc.subType__c.equals('No Fault Return') && paymentType.equals(oneOffPaymentTypeValue)
                                                && attribute.name.equals('RedeemFundCopy') && attribute.cscfga__Value__c != null){ 
                                                    String tempETC = String.valueof(planRow.get('GSTExcl_TotalETC'));
                                                    Decimal existingETC = 0.0;
                                                    if(tempETC != null && tempETC != ''){
                                                        existingETC =  Decimal.valueOf(tempETC); 
                                                    }
                                                    existingETC =  existingETC + double.valueOf(attribute.cscfga__Value__c); 
    
                                                    planRow.put('GSTExcl_TotalETC',string.valueOf(existingETC));
                                                    planRow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                                }*/
                                        
                                    }
                                }
                            }
    
                        //EDGE-155059 && EDGE-172755 End
                        checkDuplicate.put(uniqueKey,planRow);
                        system.debug('planRow@@::' + planRow);
                        rows.add(planRow);
                                    //EDGE-155059 && EDGE-172755 Start //EDGE-164623 Commenting below code as Bolt-On will be enabled in Sprint 20.13
                                /*if(!deviceCancelFlg){//Added extra condition for device cancellation aggregation  
                                for(cscfga__Product_Configuration__c pcBoltOn:pcList) { 
                                    system.debug('pcBoltOn.cscfga__Parent_Configuration__c@@::' + pcBoltOn.cscfga__Parent_Configuration__c + '@@::' + pcBoltOn.cscfga__Parent_Configuration__r.name);   
                                    if(pcBoltOn.cscfga__Parent_Configuration__c != null && pcBoltOn.cscfga__Parent_Configuration__r.name == pc.name)    
                                    {   
                                        system.debug('Bolts Ons@@::' + pcBoltOn.name +'::@@' + pcBoltOn.cscfga__Parent_Configuration__r.name);  
                                        Map<String,Object> planRowBoltOn = new Map<String,Object>();    
                                        Map<String,Object> modifyRecordBoltOn = checkDuplicateBoltOn.get(pcBoltOn.Name + pcBoltOn.cscfga__Parent_Configuration__r.name);    
                                        System.debug('Before check DuplicateBoltOn: ' + checkDuplicateBoltOn);  
                                        if(checkDuplicateBoltOn.containsKey(pcBoltOn.Name + pcBoltOn.cscfga__Parent_Configuration__r.name)){    
                                            Decimal existingQtyBO =  Integer.valueOf(modifyRecordBoltOn.get('Quantity'));   
                                            existingQtyBO = existingQtyBO+pcBoltOn.Quantity_Product_Configuration__c;   
                                            modifyRecordBoltOn.put('Quantity', existingQtyBO);  
                                            cspmb__Price_Item__c priceItemRecordBoltOn = priceItemsRecords.get(priceMap.get(pcBoltOn.Id));  
                                            if(priceItemRecordBoltOn!=null) {   
                                                modifyRecordBoltOn.put('GSTExcl_Total_Recurring_Charges',existingQtyBO*priceItemRecordBoltOn.cspmb__Recurring_Charge__c);   
                                                modifyRecordBoltOn.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(existingQtyBO*priceItemRecordBoltOn.cspmb__Recurring_Charge__c));   
                                            }   
                                            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecordBoltOn:'+ modifyRecordBoltOn);   
                                            }   
                                            else{   
                                                planRowBoltOn.put('Product_Module_Name','     '+pcBoltOn.Name); 
                                                planRowBoltOn.put('ExternalId', externalID++);  
                                                Decimal qtyBO = 1;  
                                                qtyBO = pcBoltOn.Quantity_Product_Configuration__c; 
                                                System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qtyBO '+qtyBO);  
                                                planRowBoltOn.put('Quantity',qtyBO);    
                                                cspmb__Price_Item__c priceItemRecordBoltOn = priceItemsRecords.get(priceMap.get(pcBoltOn.Id));  
                                                System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecordBoltOn '+priceItemRecordBoltOn);  
                                                if(priceItemRecordBoltOn!=null) {   
                                                    planRowBoltOn.put('Unit_Of_Measure',priceItemRecordBoltOn.Unit_Of_Measure__c);  
                                                    planRowBoltOn.put('GSTExcl_Total_Recurring_Charges',qtyBO*priceItemRecordBoltOn.cspmb__Recurring_Charge__c);    
                                                    planRowBoltOn.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qtyBO*priceItemRecordBoltOn.cspmb__Recurring_Charge__c));    
                                                    planRowBoltOn.put('Discount_Text','Catalogue price: $ '+priceItemRecordBoltOn.cspmb__Recurring_Charge__c+' ex GST '+priceItemRecordBoltOn.Unit_Of_Measure__c);  
                                                }   
                                                checkDuplicateBoltOn.put(pcBoltOn.Name + pcBoltOn.cscfga__Parent_Configuration__r.name,planRowBoltOn);  
                                                system.debug('planRowBoltOn@@::' + planRowBoltOn);  
                                                rows.add(planRowBoltOn);    
                                            }   
                                    }   
                                }   
                            }   
                            //EDGE-155059 && EDGE-172755 End */ 
                }
                    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:insideElse:CheckDuplicate '+checkDuplicate);
                    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:planRow: '+planRow);
            }    
                  //EDGE-164623 Apple Care + Cancellation 
                if(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c!=null && pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                system.debug('InapplecareCancelBlock');
                    cspmb__Add_On_Price_Item__c addOnRecord = addOnRecords.get(map_DeviceModelVsAddon.get(pc.Id));//EDGE-181997 Changes
                    
                     Map<String,Object> appleCareRow = new Map<String,Object>();
                     productModuleName ='';
                     if(addOnRecord!=null){
                     productModuleName = addOnRecord.Billing_Description__c;//pc.name;  
                     }                   
                     if(map_DeviceWithRedeemAmountAC != null){
                         String redeemAmt =map_DeviceWithRedeemAmountAC.get(pc.Id);
                         System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:redeemAmt '+redeemAmt);
                         if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){
                            productModuleName = productModuleName+'<sup>^</sup>';
                        } 
                        else{
                            productModuleName = productModuleName;
                        }
                    } 
                                            
                    Map<String,Object> modifyRecord = checkDuplicate.get(productModuleName);
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:checkDuplicate '+checkDuplicate);
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:modifyRecord '+modifyRecord);
                if(checkDuplicate.containsKey(productModuleName)){ 
                     Decimal existingQty =  Integer.valueOf(modifyRecord.get('Quantity')); 
                     existingQty = existingQty+pc.Quantity_Product_Configuration__c;
                     modifyRecord.put('Quantity', existingQty);
                     String exGST =  String.valueof(modifyRecord.get('GSTExcl_TotalETC'));
                     System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecord:exGST'+ exGST); 
                     //Decimal oneOffCharge = 0 - (pc.cscfga__One_Off_Charge__c+(0- Decimal.valueOf(exGST)));
                     Decimal oneOffCharge = 0 - (addOnRecord.cspmb__One_Off_Charge__c+(0- Decimal.valueOf(exGST)));// Added as part of EDGE-200765
                     modifyRecord.put('GSTExcl_TotalETC',string.valueOf(oneOffCharge));
                     Decimal etcIncludingGST = ProductBasketDataHandler.calculateGSTIncludedPrice(oneOffCharge);
                     modifyRecord.put('GSTIncl_TotalETC',+etcIncludingGST);
                     System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecord:'+ modifyRecord); 
                 } 
             else{
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:productModuleName '+productModuleName);
                    //EDGE-181997 Changes Start 
                    String pcModularName=addOnRecord.Billing_Description__c;
                    if(map_DeviceWithRedeemAmountAC != null){
                         String redeemAmt =map_DeviceWithRedeemAmountAC.get(pc.Id);
                         System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:redeemAmt '+redeemAmt);
                         if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){
                            pcModularName = pcModularName+'<sup>^</sup>';
                        } 
                        else{
                            pcModularName = pcModularName;
                        }
                    }    
                    
                    
                    appleCareRow.put(ProoductModName,pcModularName);
                    //EDGE-181997 Changes End 
                    appleCareRow.put('ExternalId', externalID++);
                    Decimal qty = 1;     //Aggregation ? 
                    qty = pc.Quantity_Product_Configuration__c;
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:qty '+qty);
                    appleCareRow.put('Quantity',qty);
                    //decimal oneOffCharge = 0- pc.cscfga__One_Off_Charge__c;
                    decimal oneOffCharge = 0- addOnRecord.cspmb__One_Off_Charge__c;//Added as part of EDGE-200765
                    appleCareRow.put('GSTExcl_TotalETC',string.valueOf(oneOffCharge));
                    Decimal etcIncludingGST = ProductBasketDataHandler.calculateGSTIncludedPrice(oneOffCharge);
                    appleCareRow.put('GSTIncl_TotalETC',etcIncludingGST );
                    checkDuplicate.put(pcModularName,appleCareRow);
                    rows.add(appleCareRow);
                    system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:appleCareRow: '+appleCareRow);
                    system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:Rows: '+rows);
                    system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:checkDuplicate: '+checkDuplicate);
                }
            }
                //EDGE-164623 Apple Care + Cancellation 
            } 
            /*for(cscfga__Product_Configuration__c pc:pcList) {
             Map<String,Object> planRow = new Map<String,Object>(); 
                    planRow.put('Product_Module_Name',pc.Name);
                    planRow.put('ExternalId', externalID++);
                    Decimal qty = 1;
                    qty = pc.Quantity_Product_Configuration__c;
                    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qty '+qty);
                    planRow.put('Quantity',qty);
                    cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecord '+priceItemRecord);
                    if(priceItemRecord!=null) {
                        planRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                        planRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                        planRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                        planRow.put('Discount_Text','Catalogue price: $ '+priceItemRecord.cspmb__Recurring_Charge__c+' ex GST '+priceItemRecord.Unit_Of_Measure__c);
                    }
                    rows.add(planRow);
            }*/
        }
    }
    catch(Exception e)
    {
        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:exception:'+e.getLineNumber()+' '+e.getMessage());
    }
    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:rows: '+rows);
    for (Map<String,Object> checkrows : rows)
    {
        system.debug('checkrows@@::' + checkrows);
    }
     return rows ;         
    }
    //EDGE-165326 - End
    public List<map<String,Object>> getAggregatedRowsPlan(List<cscfga__Product_Configuration__c> pcList , Map<Id, String> priceMap ,List<cspmb__Price_Item__c> priceItemList, Boolean deviceCancelFlg,Map<String, String> map_DeviceWithRedeemAmount,Map<Id, String> map_AttrVsAddOn,List<cscfga__Attribute__c> boltOnAttrList,map<Id,cscfga__Product_Configuration__c> attVsPCMap){
      List<Map<String,Object>> rows = new List<Map<String,Object>>();
      String etcAttr = 'EarlyTerminationCharge';//EDGE-155059 && EDGE-172755
      Map<String, Map<String,Object> > checkDuplicate = new Map<String,Map<String,Object>>();
      String remainingTermAttr = 'RemainingTerm';//EDGE-155059 && EDGE-172755
      String remainingTermValue ='';//EDGE-155059 && EDGE-172755
      String amType='Plan'; //EDGE-176688
      String uniqueKey = ''; //EDGE-196119
      String AccPromoAttr= '__Price_Adjustment_Recurring__'; //DPG-4899/98
      Map<String, Map<String,Object> > checkDuplicateBoltOn = new Map<String,Map<String,Object>>();//EDGE-155059 && EDGE-172755
      Map<Id,String> map_PCvsBillingDescr = new Map<Id,String>(); //EDGE-196119
      //EDGE-166406 Start
    //  List<UsageBasedBoltOnList__mdt> usageBasedBoltOnList = [SELECT id,label,chargeid__c from UsageBasedBoltOnList__mdt where isActive__c = true];//EDGE-166406
      List<String> usageBasedChargeIds = new List<String>();
      for(UsageBasedBoltOnList__mdt usageBasedBoltOn : [SELECT id,label,chargeid__c from UsageBasedBoltOnList__mdt where isActive__c = true]){
          usageBasedChargeIds.add(usageBasedBoltOn.chargeid__c);
      }
      system.debug('usageBasedChargeIds::' + usageBasedChargeIds);
      //EDGE-166406 End
    //  System.debug('***Telstra:NGEMDataHandler:getAggregatedRows: Insdide' + pcList);
      //EDGE-164623
      Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
      String ngemCarePDName = 'Mobile Device Care';
       List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
        for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
            if(ngemSpec.ProductCategory__c=='NGEM'){
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
            }
        }
        //EDGE-164623 End 
        try{
            String uom = '';
            Integer externalId=1;
            //EDGE-166406 Start
            List<String> attrIdList = map_AttrVsAddOn.values();
            System.debug('attrIdList:getAggregatedRows '+attrIdList);
            List<cspmb__Add_On_Price_Item__c> addOnpriceItemList = [SELECT id,name,Unit_Of_Measure__c,Charge_Id__c,Billing_Description__c,cspmb__One_Off_Charge__c,taxTreatment__c,cspmb__Recurring_Charge__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrIdList];
            system.debug('addOnpriceItemList: '+addOnpriceItemList);
            Map<id,cspmb__Add_On_Price_Item__c> addOnPriceItemsRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnpriceItemList);
            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:addOnPriceItemsRecords:'+addOnPriceItemsRecords);
            //EDGE-166406 End
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);
            Map<String,String>  map_DeviceWithRedeemAmountAC = new  Map<String,String>(); 
            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemsRecords:'+priceItemsRecords);
            if(pcList.isEmpty() != null ){
                //164623 Start 
                for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__c IN :pcList and (name ='RedeemFundCopy')]){
               //     System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:cscfga__Product_Configuration__c.ID:'+attr.cscfga__Product_Configuration__c); 
                  //  System.debug('attr: '+attr);
                    if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){
                        map_DeviceWithRedeemAmountAC.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c); 
                    }                                    
                }  
                //164623 End
                //EDGE-196119 - Start
                for(cscfga__Product_Configuration__c pc1:pcList) {
                    if(pc1.cscfga__Parent_Configuration__c == null){
                        cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc1.Id));
                        if(priceItemRecord!=null){
                            map_PCvsBillingDescr.put(pc1.Id,priceItemRecord.Billing_Description__c);
                        //    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:map_PCvsBillingDescr' + map_PCvsBillingDescr);
                        }
                    }
                }
                //EDGE-196119 - End
                //Aggregation Logic 
                for(cscfga__Product_Configuration__c pc:pcList) {
                    //EDGE-155059 && EDGE-172755 Start
                    if(pc.cscfga__Parent_Configuration__c == null){
                        //EDGE-196119 - Start
                        cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                        if(priceItemRecord!=null){
                            uniqueKey = priceItemRecord.Billing_Description__c;
                            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows: uniqueKey' + uniqueKey);
                        }
                        //EDGE-196119 - End 
                    //EDGE-196119 String uniqueKey = pc.name;
                    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:uniqueKey:' + uniqueKey);
                    //EDGE-155059 && EDGE-172755 End
                    system.debug('pc.name@@::::' + pc.name);
                    Map<String,Object> planRow = new Map<String,Object>(); 
                    Map<String,Object> modifyRecord = checkDuplicate.get(uniqueKey);//EDGE-155059 && EDGE-172755 Introduced uniquekey
                    System.debug('Before check duplicate: ' + checkDuplicate);
                    if(checkDuplicate.containsKey(uniqueKey)){//EDGE-155059 && EDGE-172755 Introduced uniquekey
                        Decimal existingQty =  Integer.valueOf(modifyRecord.get('Quantity')); 
                        existingQty = existingQty+pc.Quantity_Product_Configuration__c;
                        modifyRecord.put('Quantity', existingQty);
                        //EDGE-196119 cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                        if(priceItemRecord!=null){
                            //EDGE-184433 - Start
                            Decimal rcCharge = ProductPricingHandler.getPricingDetails(amType,pc,priceItemRecord,rcAttr); //EDGE-176688
                            modifyRecord.put('GSTExcl_Total_Recurring_Charges',existingQty*rcCharge);
                            modifyRecord.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(existingQty*rcCharge));
                            //EDGE-184433 - End
                        }
                        //EDGE-155059 && EDGE-172755 Start
                        if(pc.Type__c=='Cancel'){
                            System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC: Inside Cancel');
                            //rcRow.put('Discount_Text','('+term+' month hardware repayment option)');
                     //       System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attributes: '+pc.cscfga__Attributes__r);
                            //EDGE-199301 - Start
                            /*for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){
                                    System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attribute with Value: '+attribute);
                                    if(attribute.name.equals(etcAttr) && attribute.cscfga__Value__c!=null){
                                        String tempETC = String.valueof(modifyRecord.get('GSTExcl_TotalETC'));//EDGE-179422
                                        system.debug('tempETC');//EDGE-179422
                                        Decimal existingETC =  Decimal.valueOf(tempETC);//EDGE-179422
                                        //Decimal existingETC =  Integer.valueOf(modifyRecord.get('GSTExcl_TotalETC'));//EDGE-179422
                                        existingETC = existingETC + decimal.valueof(attribute.cscfga__Value__c);
                                        modifyRecord.put('GSTExcl_TotalETC',string.valueOf(existingETC));
                                        modifyRecord.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                    }
                                }
                            } */
                            modifyRecord.put('GSTExcl_TotalETC','0.00'); 
                            modifyRecord.put('GSTIncl_TotalETC','0.00');
                            //EDGE-199301 - Start
                        }
                        //EDGE-155059 && EDGE-172755 End
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecord:'+ modifyRecord); 
                    }   
                    else{   
                        //planRow.put('Product_Module_Name',pc.Name); //EDGE-181997 Changes
                        planRow.put('ExternalId', externalID++);    
                        Decimal qty = 1;    
                        qty = pc.Quantity_Product_Configuration__c; 
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qty '+qty);  
                        planRow.put('Quantity',qty);    
                        //EDGE-196119 cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));  
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecord '+priceItemRecord);  
                        if(priceItemRecord!=null){
                            planRow.put(ProoductModName,priceItemRecord.Billing_Description__c);//EDGE-181997 Changes Start  
                            planRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                            //EDGE-184433 - Start
                            Decimal rcCharge = ProductPricingHandler.getPricingDetails(amType,pc,priceItemRecord,rcAttr); //EDGE-176688
                            String rate = String.valueof(rcCharge);  
                            planRow.put('GSTExcl_Total_Recurring_Charges',qty*rcCharge);  
                            planRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*rcCharge));
                            //DIGI-33532 starts
                            system.debug('******1119*******');
                            String finalList=''; //list to store text which needs to be append
                            system.debug('******QCDiscountText__c*******' +pc.QCDiscountText__c);
                            if(String.isNotEmpty(pc.QCDiscountText__c))
                            {	
                              //system.debug('******QCDiscountText__c*******' +pc.QCDiscountText__c);
                             List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(pc.QCDiscountText__c); //Json Parsing
                             for(Object fld : fieldList){
                             Map<String,Object> data = (Map<String,Object>)fld; // Map to store Json fields and their values
                             system.debug('discountText ' +data.get('discountText'));
                             system.debug('*****data*******' +data);   
                             finalList= (data.get('discountText').toString()); //adding discountText to the list
                              //system.debug('*****finalList*******' +finalList);
                            }
                            system.debug('*****finalList*******' +finalList);
                            planRow.put('Discount_Text','$ '+rcCharge+' ex GST '+priceItemRecord.Unit_Of_Measure__c + '<br>' + finalList );
                            }
                            else{
                            system.debug('else part');
                            planRow.put('Discount_Text','$ '+rcCharge+' ex GST '+priceItemRecord.Unit_Of_Measure__c);
                            }
                            //DIGI-33532 ends  
                            //planRow.put('Discount_Text','$ '+rcCharge+' ex GST '+priceItemRecord.Unit_Of_Measure__c);  //EDGE-183882 
                            //EDGE-184433 - End 
                        }   
                        //EDGE-155059 && EDGE-172755 Start  
                        if(pc.Type__c=='Cancel'){   
                            System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC: Inside Cancel');    
                            System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attributes: '+pc.cscfga__Attributes__r);  
                            //EDGE-199301 - Start
                            /* for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {  
                                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){  
                                    System.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:RC:Cancel Attribute with Value: '+attribute);   
                                    if(attribute.name.equals(etcAttr)){ 
                                        if(attribute.cscfga__Value__c == null)  
                                        {   
                                            planRow.put('GSTExcl_TotalETC','0.00'); 
                                            planRow.put('GSTIncl_TotalETC','0.00'); 
                                        }   
                                        else{   
                                        planRow.put('GSTExcl_TotalETC',string.valueOf(attribute.cscfga__Value__c)); 
                                        planRow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));    
                                        }   
                                    }   
                                }   
                            } */
                            planRow.put('GSTExcl_TotalETC','0.00'); 
                            planRow.put('GSTIncl_TotalETC','0.00');
                            //EDGE-199301 - End   
                        }   
                        //EDGE-155059 && EDGE-172755 End    
                        checkDuplicate.put(uniqueKey,planRow);  
                        system.debug('planRow@@::' + planRow);  
                        rows.add(planRow);  
                        for(cscfga__Attribute__c boltOnAttr:boltOnAttrList) {
                            system.debug('******boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c*******' +boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c);
                            system.debug('map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c)' + map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c)  + ':: uniqueKey ' + uniqueKey);
                            if(map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.Id) == uniqueKey) //EDGE-196119
                            {
                                cspmb__Add_On_Price_Item__c addOnpriceItemRecord = addOnPriceItemsRecords.get(map_AttrVsAddOn.get(boltOnAttr.Id));
                                system.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:addOnpriceItemRecord:' + addOnpriceItemRecord.Billing_Description__c);
                             //   system.debug('***Telstra:ProductBasketDataHandler:getAggregatedRows:addOnParent:' + map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c) +'::' + boltOnAttr.Name); //EDGE-196119
                                Map<String,Object> planRowBoltOn = new Map<String,Object>();
                                Map<String,Object> modifyRecordBoltOn = checkDuplicateBoltOn.get(addOnpriceItemRecord.Billing_Description__c + map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c)); //EDGE-196119
                                System.debug('Before check DuplicateBoltOn: ' + checkDuplicateBoltOn);
                                if(checkDuplicateBoltOn.containsKey(addOnpriceItemRecord.Billing_Description__c + map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c))){ //EDGE-196119
                                    Decimal existingQtyBO =  Integer.valueOf(modifyRecordBoltOn.get('Quantity')); 
                                    existingQtyBO = existingQtyBO+1;
                                    modifyRecordBoltOn.put('Quantity', existingQtyBO);
                                    if(addOnpriceItemRecord!=null) {
                                        if(addOnpriceItemRecord.cspmb__Recurring_Charge__c!= null){
                                            //EDGE-184433 - Start 
                                            Decimal rcCharge = ProductPricingHandler.getPricingDetails(amType,attVsPCMap.get(boltOnAttr.Id),addOnpriceItemRecord,rcAttr); //EDGE-176688
                                            modifyRecordBoltOn.put('GSTExcl_Total_Recurring_Charges',existingQtyBO*rcCharge);
                                            if(addOnpriceItemRecord.taxTreatment__c =='TAX Exempt'){
                                                modifyRecordBoltOn.put('GSTIncl_Total_Recurring_Charges',existingQtyBO*rcCharge);
                                            }
                                            else{
                                                modifyRecordBoltOn.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(existingQtyBO*rcCharge));
                                            }
                                            //EDGE-184433 - End
                                        }
                                    }   
                                    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:modifyRecordBoltOn:'+ modifyRecordBoltOn);   
                                    }   
                                    else{   
                                        if(addOnpriceItemRecord!=null) {
                                            if(addOnpriceItemRecord.taxTreatment__c =='TAX Exempt')
                                            {
                                                planRowBoltOn.put('Product_Module_Name','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + addOnpriceItemRecord.Billing_Description__c+' <sup>†</sup>');
                                            }
                                            else{
                                                planRowBoltOn.put('Product_Module_Name','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + addOnpriceItemRecord.Billing_Description__c);
                                            }    
                                            planRowBoltOn.put('ExternalId', externalID++);
                                            system.debug('addOnpriceItemRecord.Billing_Description__c@@::' + addOnpriceItemRecord.Billing_Description__c);
                                            Decimal qtyBO = 1;
                                            System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qtyBO '+qtyBO);
                                            planRowBoltOn.put('Quantity',qtyBO);
                                            planRowBoltOn.put('Unit_Of_Measure',addOnpriceItemRecord.Unit_Of_Measure__c);
                                            if(addOnpriceItemRecord.cspmb__Recurring_Charge__c!= null){
                                                //EDGE-184433 - Start
                                                Decimal rcCharge = ProductPricingHandler.getPricingDetails(amType,attVsPCMap.get(boltOnAttr.Id),addOnpriceItemRecord,rcAttr); //EDGE-176688
                                                String rate = String.valueof(rcCharge);
                                                planRowBoltOn.put('GSTExcl_Total_Recurring_Charges',qtyBO*rcCharge);
                                                if(addOnpriceItemRecord.taxTreatment__c =='TAX Exempt'){
                                                    planRowBoltOn.put('GSTIncl_Total_Recurring_Charges',qtyBO*rcCharge);
                                                }
                                                else{
                                                    planRowBoltOn.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qtyBO*rcCharge));
                                                }
                                                //DIGI-33532 starts
                                                system.debug('******1229*******');
                                                system.debug('******boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c*******' +boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c);
                                                String finalList= ''; //list to store text which needs to be append
                                                 if(String.isNotEmpty(boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c))
                                                   {	
                                                    List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(boltOnAttr.cscfga__Product_Configuration__r.QCDiscountText__c); //Json Parsing
                                                        for(Object fld : fieldList){
                                                        Map<String,Object> data = (Map<String,Object>)fld; // Map to store Json fields and their values
                                                        system.debug('discountText ' +data.get('discountText'));
                                                 		system.debug('*****data*******' +data);   
                                                 		finalList = (data.get('discountText').toString()); //adding discountText to the list
                                                  		
                                               	        }
                                                   		system.debug('*****finalList*******' +finalList);
                                                   		planRowBoltOn.put('Discount_Text','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '$ '+rcCharge+' ex GST '+priceItemRecord.Unit_Of_Measure__c + '<br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + finalList );
                                                   }
                                                   else{
                                                    	system.debug('else part');
                                                		planRowBoltOn.put('Discount_Text','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +'$ '+rcCharge+' ex GST '+priceItemRecord.Unit_Of_Measure__c);
                                                   }
                                                   //DIGI-33532 ends
                                                //planRowBoltOn.put('Discount_Text','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '$ '+rcCharge+' ex GST '+addOnpriceItemRecord.Unit_Of_Measure__c); //EDGE-183882
                                                //EDGE-184433 - End
                                            }
                                            system.debug('addOnpriceItemRecord.Charge_Id__c1::' + addOnpriceItemRecord.Charge_Id__c + '::' + boltOnAttr.name);
                                            if(usageBasedChargeIds.contains(addOnpriceItemRecord.Charge_Id__c)){
                                                planRowBoltOn.put('GSTExcl_Total_Recurring_Charges','-');
                                                planRowBoltOn.put('GSTIncl_Total_Recurring_Charges','-');
                                                planRowBoltOn.put('Discount_Text','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + System.Label.BoltOnUsageDesc);
                                            }
                                            if(boltOnAttr.cscfga__Product_Configuration__r.type__c =='Cancel'){
                                                planRowBoltOn.put('GSTExcl_TotalETC','0.00');
                                            planRowBoltOn.put('GSTIncl_TotalETC','0.00');
                                            }
                                        }
                                        checkDuplicateBoltOn.put(addOnpriceItemRecord.Billing_Description__c + map_PCvsBillingDescr.get(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c),planRowBoltOn); //EDGE-196119
                                        system.debug('planRowBoltOn@@::' + planRowBoltOn);  
                                        rows.add(planRowBoltOn);    
                                    }   
                            }   
                        }   
                        //EDGE-155059 && EDGE-172755 End 
                    }   
                    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:insideElse:CheckDuplicate '+checkDuplicate); 
                    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:planRow: '+planRow); 
            }       
            }   
            /*for(cscfga__Product_Configuration__c pc:pcList) { 
             Map<String,Object> planRow = new Map<String,Object>();     
                    planRow.put('Product_Module_Name',pc.Name); 
                    planRow.put('ExternalId', externalID++);    
                    Decimal qty = 1;    
                    qty = pc.Quantity_Product_Configuration__c; 
                    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qty '+qty);  
                    planRow.put('Quantity',qty);    
                    cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));  
                    System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecord '+priceItemRecord);  
                    if(priceItemRecord!=null) { 
                        planRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);  
                        planRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);  
                        planRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));  
                        planRow.put('Discount_Text','Catalogue price: $ '+priceItemRecord.cspmb__Recurring_Charge__c+' ex GST '+priceItemRecord.Unit_Of_Measure__c);    
                    }   
                    rows.add(planRow);  
            }*/ 
        }   
    }   
    catch(Exception e)  
    {   
        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:exception:'+e.getLineNumber()+' '+e.getMessage());   
    }   
    system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:rows: '+rows);   
     return rows ;          
    }
    /**
     * @Author   :   Rahul Asarma
     * @Date     :   23 Sep 2020
     * @US       :   EDGE-165486
     * @Status   :   This method is for Agreegation of Recurring charges
     * */
    
    public List<map<String,Object>> getGenericAggregatedRows(List<cscfga__Product_Configuration__c> devicePCRCList, Map<Id, String> priceMap ,List<cspmb__Price_Item__c> priceItemList,Map<String,String> map_DeviceWithRedeemAmount, String typeOfAggregation){   //EDGE-184433 | Added a new parameter
        system.debug('UndergetGenericAggregatedRows');
        List<Map<String,Object>> agrgregatedrows = new List<Map<String,Object>>();
        Map<String, Map<String,Object> > checkDuplicate = new Map<String,Map<String,Object>>();
        String uniqueKey=''; 
        String uom='';
        String productModuleName='';
        String term='';
        String amType='Device'; //EDGE-176688
        Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
        String ngemCarePDName = 'Mobile Device Care';
        List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
        for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
            if(ngemSpec.ProductCategory__c=='NGEM'){
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
            }
        }
        Integer exId=1;
        //Map<String,Object> planRow = new Map<String,Object>(); 
        Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);
        if(typeOfAggregation=='RecurringCharges'){
            for(cscfga__Product_Configuration__c pc:devicePCRCList) {
                if(pc.cscfga__Product_Definition__r.product_Specification__c != map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                    Map<String,Object> planRow = new Map<String,Object>(); 
                    //EDGE-181997- Code Change Start
                    cspmb__Price_Item__c priceItemRecorddetails;
                    if(priceMap.containsKey(pc.Id)){
                        priceItemRecorddetails = priceItemsRecords.get(priceMap.get(pc.Id));
                        productModuleName=priceItemRecorddetails.Billing_Description__c;
                    }
                    //productModuleName = priceItemRecorddetails.pc.Name;
                    //EDGE-181997- Code Change End
                    system.debug('@@@@@@@@@@productModuleName'+productModuleName );
                    if(map_DeviceWithRedeemAmount.containsKey(pc.Id)){//Added null check as per review comments for EDGE-155059
                        String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:redeemAmt '+redeemAmt);
                        //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                        if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){
                            //productModuleName = pc.Name+' <sup>#</sup>';
                            productModuleName = productModuleName+' <sup>#</sup>';
                            //productModuleName = productModuleName.replaceAll('#', '<sup>#</sup>');
                        }
                    }
                    uniqueKey=productModuleName+'_'+String.valueof(pc.cscfga__Contract_Term__c);
                    system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:uniqueKeyuniqueKey'+uniqueKey);
                    Map<String,Object> modifyRecord = checkDuplicate.get(uniqueKey);
                    if(checkDuplicate.containsKey(uniqueKey)){//EDGE-155059 && EDGE-172755 Introduced uniquekey
                        Decimal existingQty =  Integer.valueOf(modifyRecord.get('Quantity')); 
                        existingQty = existingQty+pc.Quantity_Product_Configuration__c;
                        modifyRecord.put('Quantity', existingQty);
                        cspmb__Price_Item__c priceItemRecord;
                        if(priceMap.containsKey(pc.Id)){
                            priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                        }
                        if(priceItemRecord!=null) {
                            uom = priceItemRecord.Unit_Of_Measure__c;
                        }
                        term = String.valueof(pc.cscfga__Contract_Term__c);
                        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC: Inside New');
                        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:RC:Cancel Attributes: '+pc.cscfga__Attributes__r);
                        for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                            if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){
                                if(attribute.name.equals(rcAttr)){
                                    //EDGE-184433 - Start
                                    Decimal rcCharge = ProductPricingHandler.getPricingDetails(amType,pc,attribute,rcAttr); //EDGE-176688
                                    String rate = String.valueof(rcCharge);
                                    modifyRecord.put('GSTExcl_Total_Recurring_Charges',existingQty*rcCharge);
                                    Decimal totalRecurring = (existingQty*rcCharge);
                                    Decimal totalRecurringGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalRecurring);
                                    modifyRecord.put('GSTIncl_Total_Recurring_Charges',totalRecurringGSTIncl);
                                    modifyRecord.put('Discount_Text','$ '+rate+' ex GST '+uom+' per month over '+term+' months'); //EDGE-183882
                                    //EDGE-184433 - End
                                }
                            }
                        }
                        system.debug('valueofmodifyRecord'+modifyRecord);
                    }
                    else{
                        //planRow.put('Product_Module_Name',pc.Name);
                        planRow.put(ProoductModName,productModuleName);//EDGE-181997- Code Change
                        //planRow.put('ExternalId', String.valueOf(exId));
                        planRow.put('ExternalId', exId++);
                        System.debug('***PCID'+pc.id+String.valueof(pc.cscfga__Contract_Term__c));
                        Decimal qty = 1;
                        string rate='0';
                        Decimal rcCharge=0;
                        term = String.valueof(pc.cscfga__Contract_Term__c);
                        qty = pc.Quantity_Product_Configuration__c;
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:qty '+qty);
                        system.debug('valueofProduct'+pc.Name+'_'+term );
                        planRow.put('Quantity',qty);
                        cspmb__Price_Item__c priceItemRecord;
                        if(priceMap.containsKey(pc.Id)){
                            priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                        }
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:priceItemRecord '+priceItemRecord);
                        for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                            if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){
                                if(attribute.name.equals(rcAttr)){
                                    //EDGE-184433 - Start

                                    rcCharge = ProductPricingHandler.getPricingDetails(amType,pc,attribute,rcAttr); //EDGE-176688
                                    rate = String.valueof(rcCharge);
                                    }                                    
                                    //DPG-3508-- added to capture term for Mobile Accessory.
                      if(attribute.name.equals(rcAcctermAttr)){
                        System.debug('***Telstra:NGEMDataHandler:getAggregatedRows:rcAcctermAttr '+attribute.cscfga__Value__c);
                        term=attribute.cscfga__Value__c;                                                

                                }
                            }
                        }
                                      //DPG- 3508--- Put outside the for loop.
              
                                    planRow.put('Rate',rate);
                                    planRow.put('GSTExcl_Total_Recurring_Charges',qty*rcCharge);
                                    Decimal totalRecurring = (qty*rcCharge);
                                    Decimal totalRecurringGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalRecurring);
                                    planRow.put('GSTIncl_Total_Recurring_Charges',totalRecurringGSTIncl);
                                    planRow.put('Discount_Text','$ '+rate+' ex GST '+uom+' per month over '+term+' months'); //EDGE-183882
                                    //EDGE-184433 - End
                                                            
                        
                        checkDuplicate.put(uniqueKey,planRow);
                        system.debug('checkDuplicateafterPut'+checkDuplicate);
                        system.debug('planRow@@::' + planRow);
                        agrgregatedrows.add(planRow);
                    }
                        }
                    }
                }
            system.debug('NewFunctionrows'+agrgregatedrows  );
            return agrgregatedrows ; 
    }
    /**
     * @Author   :   Rahul Asarma
     * @Date     :   23 Sep 2020
     * @US       :   EDGE-165486
     * @Status   :   This method is for Agreegation of One time charges
     * */
    public List<map<String,Object>> getGenericAggregatedOCRows(List<cscfga__Product_Configuration__c> devicePCOCList, Map<Id, String> priceMap ,List<cspmb__Price_Item__c> priceItemList, String typeOfAggregation,Map<String,String> map_DeviceWithRedeemAmount, Map<Id, String> map_DeviceModelVsAddon){ //EDGE-184433 | Added a new parameter //EDGE-176688 | Removed FA parameter
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
    //Taken variable out of if block - DPG-3508
    Map<id,cspmb__Add_On_Price_Item__c> addOnRecords= new Map<id,cspmb__Add_On_Price_Item__c>();


        system.debug('map_DeviceModelVsAddon size'+map_DeviceModelVsAddon.size());


        if(typeOfAggregation=='OneTimeCharges'){
        //if condition added by Mahima - DPG-3508
        if(map_DeviceModelVsAddon!= null)
    {
            List<String> attrAddonIdList = map_DeviceModelVsAddon.values();
            List<cspmb__Add_On_Price_Item__c> addOnList = [SELECT id,name,cspmb__One_Off_Charge__c,Billing_Description__c,Unit_Of_Measure__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrAddonIdList]; //EDGE-183882
            system.debug('addOnList: '+addOnList);
            addOnRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnList);
        }
            Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
            //String ngemDevicePDName = 'Next Generation Mobile Device';
            //String ngemCarePDName = 'Mobile Device Care';
            String uniqueKey='';
            String productModuleName='';
            String uom='';
            String amType ='Device'; //EDGE-176688
            Integer exId=1;
            List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
            for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
                if(ngemSpec.ProductCategory__c=='NGEM'){
                    map_PDvsSecId.put(ngemSpec.Label,ngemSpec);

                }
            }
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);
            Map<String, Map<String,Object> > checkDuplicate = new Map<String,Map<String,Object>>();
            for(cscfga__Product_Configuration__c pc:devicePCOCList) {
        productModuleName=''; //DPG-4972 Mahima
                Map<String,Object> ocRow = new Map<String,Object>();
                //EDGE-181997- Code Change Start
                cspmb__Price_Item__c priceItemRecord;
                if(priceMap.containsKey(pc.Id)){
                    priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
          //system.debug('inside priceItemRecord==>'+priceItemRecord.Billing_Description__c);
          productModuleName=priceItemRecord.Billing_Description__c; //DPG-4972 Mahima
                }
                //EDGE-181997- Code Change End
                //productModuleName = pc.Name;   //EDGE-164623 | Set PC name for non-Redeemed Devices 
                //Added if conditon for size greater than zero- DPg -3508
        cspmb__Add_On_Price_Item__c addOnRecord ;
                if(addOnRecords.size()>0)
        {
          addOnRecord = addOnRecords.get(map_DeviceModelVsAddon.get(pc.Id));
          system.debug('addOnRecord=' +addOnRecord);
                if(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c!=null && pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                        //system.debug('inside addon==>'+addOnRecord.Billing_Description__c);
                    productModuleName=addOnRecord.Billing_Description__c;
                } //EDGE-181997- Code Change Start  
                }else{
                    if(priceItemRecord!=null){
                        productModuleName=priceItemRecord.Billing_Description__c;
                    }
                } 
        system.debug(' before duplicate check productModuleName==>'+productModuleName);        
                //EDGE-181997- Code Change End                                                  
                if(map_DeviceWithRedeemAmount.containsKey(pc.Id)){//Added null check as per review comments for EDGE-155059
                    String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:redeemAmt '+redeemAmt);
                    if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){
                        productModuleName = productModuleName+' <sup>#</sup>';//EDGE-181997 COde change
                        //productModuleName = productModuleName.replaceAll('#', '<sup>#</sup>');
                    }
                }  
                uniqueKey=productModuleName; 
                system.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OneTime:checkDuplicate'+checkDuplicate);
                Map<String,Object> modifyRecord = checkDuplicate.get(uniqueKey);
                if(checkDuplicate.containsKey(uniqueKey)){
                    Decimal existingQty =  Integer.valueOf(modifyRecord.get('Quantity')); 
                    existingQty = existingQty+pc.Quantity_Product_Configuration__c;
                    modifyRecord.put('Quantity', existingQty);
                    /*cspmb__Price_Item__c priceItemRecord;//EDGE-181997- Code Change
                    if(priceMap.containsKey(pc.Id)){
                    priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                    }*/

                    //System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:priceItemRecord  inside duplicate'+priceItemRecord);
                    
                    //DPG-4929- added condition for ngemAccPDName by Mahima
                    if(priceItemRecord!=null &&( pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemDevicePDName).ProdSpecId__c) || pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemAccPDName).ProdSpecId__c)) ) {
            system.debug('inside PriceItem');

                        uom = priceItemRecord.Unit_Of_Measure__c;
                        //EDGE-184433 - Start
                        Decimal onceOffCharge = ProductPricingHandler.getPricingDetails(amType,pc,priceItemRecord,ocAttr); //EDGE-176688
                        String rate = String.valueof(onceOffCharge);
                        modifyRecord.put('Discount_Text','$ '+rate+' ex GST '+uom); //EDGE-183882
                        modifyRecord.put('GSTExcl_Total_Onceoff_Charges',existingQty*onceOffCharge);
                        Decimal totalOnceOff = (existingQty*onceOffCharge);
                        //EDGE-184433 - End
                        Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                        modifyRecord.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                    }
                    //EDGE-148776 | Added DeviceCare | Start
                    //cspmb__Add_On_Price_Item__c addOnRecord = addOnRecords.get(map_DeviceModelVsAddon.get(pc.Id));
                    //System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:addOnRecord '+addOnRecord);
                    if(addOnRecord!=null && pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c)) {
                        //system.debug('inside Addon');
                        //EDGE-184433 - Start
                        Decimal onceOffCharge = ProductPricingHandler.getPricingDetails(amType,pc,addOnRecord,ocAttr); //EDGE-176688
                        modifyRecord.put('GSTExcl_Total_Onceoff_Charges',existingQty*onceOffCharge);
                        modifyRecord.put('Rate',onceOffCharge);
                        Decimal totalOnceOff = (existingQty*onceOffCharge);
                        //EDGE-184433 - End
                        Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                        modifyRecord.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                    }
                }
                else{
                    //EDGE-181997- Code Change Start
                    
                    if(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c!=null && pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                        productModuleName=addOnRecord.Billing_Description__c;
                    }   
                    else{
                        productModuleName=priceItemRecord.Billing_Description__c;
                    }  
          system.debug('outside duplicate productModuleName==>'+productModuleName);
                    //productModuleName = productModuleName;//pc.Name;
                    //EDGE-181997- Code Change End
                    ocRow.put('ExternalId', exId++);                    
                    if(map_DeviceWithRedeemAmount.containsKey(pc.Id)){//Added null check as per review comments for EDGE-155059
                        String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                        System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:redeemAmt '+redeemAmt);
                        if(redeemAmt != '0.00' && String.isNotEmpty(redeemAmt)){
                            productModuleName = productModuleName+' <sup>#</sup>';
                            //productModuleName = productModuleName.replaceAll('#', '<sup>#</sup>');
                        }
                    }     
                    ocRow.put('Product_Module_Name',productModuleName);
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:productModuleName '+productModuleName);
                    //ocRow.put('ExternalId', externalID++);
                    Decimal qty = 1;
                    qty = pc.Quantity_Product_Configuration__c;
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:qty '+qty);
                    ocRow.put('Quantity',qty);
                    //cspmb__Price_Item__c priceItemRecord;
                    system.debug('valueofmap_DeviceWithRedeemAmount'+map_DeviceWithRedeemAmount);
                    system.debug('valueofpriceMap'+priceMap);
                    if(priceMap.containsKey(pc.Id)){
                        //if(map_DeviceWithRedeemAmount.containsKey(pc.Id))//Added as per review comments for EDGE-155059
                        priceItemRecord = priceItemsRecords.get(priceMap.get(pc.Id));
                    }
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:priceItemRecord '+priceItemRecord);
                    if(priceItemRecord!=null && pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemDevicePDName).ProdSpecId__c)) {
                        uom = priceItemRecord.Unit_Of_Measure__c;
                        //EDGE-184433 - Start
                        Decimal onceOffCharge = ProductPricingHandler.getPricingDetails(amType,pc,priceItemRecord,ocAttr); //EDGE-176688
                        String rate = String.valueof(onceOffCharge);
                        ocRow.put('Discount_Text','$ '+rate+' ex GST '+uom); //EDGE-183882
                        ocRow.put('GSTExcl_Total_Onceoff_Charges',qty*onceOffCharge);
                        Decimal totalOnceOff = (qty*onceOffCharge);
                        //EDGE-184433 - End
                        Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                        ocRow.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                    }
                    //DPG-3508- start
                else  if(priceItemRecord!=null && pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemAccPDName).ProdSpecId__c)) {
                  system.debug(' inside accessory');
                  uom = priceItemRecord.Unit_Of_Measure__c;
                                    String rate = String.valueof(priceItemRecord.cspmb__One_Off_Charge__c);
                                    ocRow.put('Discount_Text','$ '+rate+' ex GST '+uom);
                                    ocRow.put('GSTExcl_Total_Onceoff_Charges',qty*priceItemRecord.cspmb__One_Off_Charge__c);
                                    Decimal totalOnceOff = (qty*priceItemRecord.cspmb__One_Off_Charge__c);
                                    Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                                    ocRow.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                }
                //DPG-3508- start
                    //cspmb__Add_On_Price_Item__c addOnRecord = addOnRecords.get(map_DeviceModelVsAddon.get(pc.Id));
                    System.debug('***Telstra:ProductBasketDataHandler:getNGEMDevices:OC:addOnRecord '+addOnRecord);
                    if(addOnRecord!=null && pc.cscfga__Product_Definition__r.product_Specification__c.equals(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c)) {
                        //EDGE-183882 | Start
                        String addOnuom = addOnRecord.Unit_Of_Measure__c;
                        //EDGE-184433 - Start
                        Decimal onceOffCharge = ProductPricingHandler.getPricingDetails(amType,pc,addOnRecord,ocAttr); //EDGE-176688
                        String rate = String.valueof(onceOffCharge);
                        ocRow.put('Discount_Text','$ '+rate+' ex GST '+addOnuom);
                        //EDGE-183882 | End
                        ocRow.put('Rate',onceOffCharge);
                        ocRow.put('GSTExcl_Total_Onceoff_Charges',qty*onceOffCharge);
            system.debug('qty addon ==>'+qty);
                        Decimal totalOnceOff = (qty*onceOffCharge);
                        //EDGE-184433 - End
                        Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                        ocRow.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                    }
                    system.debug('ocRow@@::' + ocRow);
                    //EDGE-148776 | Added DeviceCare | End
                    checkDuplicate.put(uniqueKey,ocRow);
                    rows.add(ocRow);
                }
            }
        }
        return rows;
    }  
    
    //DPG-3508-- Start
    public List<Map<String,Object>> getAMAccessory(String basketId, Map<String,String> subfilters){ 
    List<Map<String,Object> > rows = new List<Map<String,Object> >();   
    Map<Id, String> map_AccModelVsPriceItem = new Map<Id, String>(); 


        Map<Id, String> map_AccModelVsAddon = new Map<Id, String>(); 


    Map<String, String> map_AccWithRedeemAmount = new Map<String, String>(); 
    Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>(); //EDGE-148776  
    Integer externalId=1;   
    List<cscfga__Product_Configuration__c> accPCList = new List<cscfga__Product_Configuration__c>(); 
    List<cscfga__Product_Configuration__c> accPCRCList = new List<cscfga__Product_Configuration__c>();   
    List<cscfga__Product_Configuration__c> accPCOCList = new List<cscfga__Product_Configuration__c>();   
    List<String> specIdList = new List<String>(); //EDGE-148776 
    String objectAPIName='';    
    //EDGE-148776 - START   
    String paymentTypeStringAttr = 'PaymentTypeShadow'; 
    String oneOffPaymentTypeValue = 'Purchase'; 
    String repaymentPaymentTypeValue = 'Hardware Repayment';    
    String priceItem = 'cspmb__Price_Item__c';  




    String addOn = 'cspmb__Add_On_Price_Item__c';   //DPG-4161 | DPG-4151 | Ila
    String priceItemValue = 'AccessoryModel';   
    String addOnValue = 'DeviceCarePaymentTypeLookup';  //DPG-4161 | DPG-4151 | Ila  




    
    //String ngemCarePDName = 'Mobile Device Care';   //EDGE-165486
    //EDGE-148776 - END 
    //EDGE-148722 - Start   
    String remainingTermAttr = 'RemainingTerm'; 
    String etcAttr = 'EarlyTerminationCharge';  
    //String rcAttr = 'RC';   //EDGE-165486
    String uom = '';    
    //EDGE-148722 - End 
    Id temp;    
  try{  
        if(basketId.length()>0){    
            //POS redemption information    
            for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id=:basketId and (name ='RedeemFund')]){    
                System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:cscfga__Product_Configuration__c.ID:'+attr.cscfga__Product_Configuration__c);  
                System.debug('attr: '+attr);    
                if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){  
                     map_AccWithRedeemAmount.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c);   
                }                                       
            }                                       
        }   
        //EDGE-148776 - Start   
        List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];    
        for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){    
            system.debug('ngemSpec.ProductCategory__c=='+ngemSpec.ProductCategory__c);
             system.debug('ngemSpec.Label=='+ngemSpec.Label);
             system.debug('ngemSpec.ProdSpecId__c=='+ngemSpec.ProdSpecId__c);
            if(ngemSpec.ProductCategory__c=='NGEM'){    
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                specIdList.add(ngemSpec.ProdSpecId__c); 
            }   
        }   
        String ngemAccPDId = map_PDvsSecId.get(ngemAccPDName).ProdSpecId__c;  
        //specIdList = map_PDvsSecId.values();  
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:ngemSpecIds'+ngemSpecIds); 
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:map_PDvsSecId'+map_PDvsSecId); 
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:specIdList'+specIdList);   
        //EDGE-148776 - End 
        //EDGE-148776 | Added DeviceCare    
        if(subfilters.get('Type') =='New'){     
      //Added cscfga__One_Off_Charge__c column by Mahima- DPG-4929
            accPCList =[SELECT id,name,Type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND (Type__c='New' OR type__c='CHOWN') AND csordtelcoa__Replaced_Product_Configuration__c=null AND subType__c!='Inflight Cancel' AND subType__c!='Inflight Amend']; 

        }

        //DPG-5624 - Start   
        else if(subfilters.get('Type') =='Cancel'){     
			if(subfilters.get('Query_Type')=='AMaccessoryOCIC' || subfilters.get('Query_Type')=='AMaccessoryRCIC')
			{
				accPCList =[SELECT id,name,Type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND subType__c='Inflight Cancel' AND cscfga__Product_Basket__r.recordtype.developername='Inflight_Change']; 
        }    
			else {
				accPCList = [SELECT id,name,Type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND Type__c='Cancel']; 
				//accPCList =[SELECT id,name,Type__c,cscfga__Contract_Term__c,Quantity_Product_Configuration__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN :specIdList AND cscfga__Product_Basket__c=:basketId AND Type__c='Cancel']; //EDGE-164623  
			} 
		}
        //DPG-5624 - End
        for(cscfga__Product_Configuration__c pc:accPCList) { 
            System.debug('Pc Config===>'+pc);





            //DPG-4161 | DPG-4151 | Added DeviceCare | Start  | Anand 
            if(isAddOnForAccessory(pc)) {
                System.debug('isAddOnForAccessory true');
                paymentTypeStringAttr = 'PaymentTypeString';
            } else {                
                paymentTypeStringAttr = 'PaymentTypeShadow';
            }
            //DPG-4161 | DPG-4151 | End



            //EDGE-164623   
            /*if(map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c!=null && pc.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){// Added condition to include Apple Care Plus PC   
                 accPCRCList.add(pc);    
            }   */
            //EDGE-164623 End   
            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) { 
                system.debug('attribute.Name=='+attribute.Name);
                system.debug('attribute.Value=='+attribute.cscfga__Value__c);
                if(attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue) ){ //EDGE-164623   
                    accPCOCList.add(pc); 
                }   
                if(attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(repaymentPaymentTypeValue)){   
                    accPCRCList.add(pc); 
                }   
                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {  
                    temp = attribute.cscfga__Value__c;  
                    objectAPIName = temp.getSObjectType().getDescribe().getName();  
                    System.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);  
                    if(objectAPIName.equalsIgnoreCase(priceItem) && attribute.name.equals(priceItemValue)){ 
                        system.debug('attribute.Model=='+attribute.name);
                        map_AccModelVsPriceItem.put(pc.Id,attribute.cscfga__Value__c);   
                    } 
                    system.debug('map_AccModelVsPriceItem.size '+map_AccModelVsPriceItem.size());

                                           
                        //DPG-4161 | DPG-4151| Added DeviceCare | Start |Ila    
                        if(objectAPIName.equalsIgnoreCase(addOn) && attribute.name.equals(addOnValue)){ 
                            map_AccModelVsAddon.put(pc.Id,attribute.cscfga__Value__c);   

                    }   
                    //DPG-4161 | DPG-4151 | Added DeviceCare | End  




                }       
            }   
            system.debug('map_AccModelVsPriceItem.size '+map_AccModelVsPriceItem.size());
        }   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:accPCList'+accPCList);   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:accPCRCList'+accPCRCList.size());   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:accPCOCList'+accPCOCList);   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:map_AccWithRedeemAmount:'+map_AccWithRedeemAmount);  
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:map_AccModelVsPriceItem:'+map_AccModelVsPriceItem);  


            System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:map_AccModelVsAddon:'+map_AccModelVsAddon);  
            System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:map_AccModelVsAddon size:'+map_AccModelVsAddon.size());       

       
        List<String> attrIdList = map_AccModelVsPriceItem.values();  
        System.debug('attrIdList: '+attrIdList);    
        List<cspmb__Price_Item__c> priceItemList = [SELECT id,name,Unit_Of_Measure__c,cspmb__Contract_Term__c,Billing_Description__c,cspmb__One_Off_Charge__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c WHERE id IN :attrIdList]; //EDGE-181997 changes Billing_Description__c field added 
        system.debug('priceItemList: '+priceItemList);  
        Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>(priceItemList);   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:priceItemsRecords:'+priceItemsRecords);         

      


            //DPG-4161 | DPG-4151 | Added DeviceCare | Start  |Ila  
            List<String> attrAddonIdList = map_AccModelVsAddon.values(); 
            System.debug('attrAddonIdList: '+attrAddonIdList);  
            List<cspmb__Add_On_Price_Item__c> addOnList = [SELECT id,name,cspmb__One_Off_Charge__c,Billing_Description__c,Unit_Of_Measure__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrAddonIdList]; //EDGE-183882 
            system.debug('addOnList: '+addOnList);  
            system.debug('addOnList count: '+addOnList.size()); 

        Map<id,cspmb__Add_On_Price_Item__c> addOnRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnList);  
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:addOnRecords:'+addOnRecords);  
    //DPG-4161 | DPG-4151 End
    
        if(subfilters.get('Query_Type') =='AMaccessoryOC' || subfilters.get('Query_Type') =='AMaccessoryOCIC'){  
            System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory: INSIDE OC BLOCK');
            //EDGE-165486-- Calling New method for OC charges Agreegation--Changes Start

                rows=getGenericAggregatedOCRows(accPCOCList,map_AccModelVsPriceItem, priceItemList,'OneTimeCharges',map_AccWithRedeemAmount,map_AccModelVsAddon);   
            system.debug('***Telstra:NGEMDataHandler:getAMAccessory:OCRow: '+rows); 
            //EDGE-165486-- Calling New method for OC charges Agreegation--Changes End
        }   
        if((subfilters.get('Query_Type') =='AMaccessoryRC' && subfilters.get('Type') != 'Cancel') || subfilters.get('Query_Type') =='AMaccessoryRCIC'){//EDGE-155059 Added Extra Condition to bypass logic for Cancel    
            System.debug('***Telstra:NGEMDataHandler:getAMAccessory: INSIDE RC BLOCK');
            //EDGE-165486-- Calling New method for RC charges Agreegation--Changes Start
            rows = getGenericAggregatedRows(accPCRCList,map_AccModelVsPriceItem, priceItemList,map_AccWithRedeemAmount,'RecurringCharges');
            system.debug('***Telstra:NGEMDataHandler:getAMAccessory:RCRow: '+rows);          
            //EDGE-165486-- Calling New method for RC charges Agreegation--Changes End  

            }
		//DPG-5624 Start   
		if(subfilters.get('Query_Type') =='AMaccessoryRC' && subfilters.get('Type') == 'Cancel'){  
        //EDGE-181997 changes Passing additional variable map_DeviceModelVsAddon
          rows = getAggregatedRows(accPCRCList,map_AccModelVsPriceItem, priceItemList,true,map_AccWithRedeemAmount,map_AccModelVsAddon);    
          system.debug('***Telstra:NGEMDataHandler:getAMAccessory:CancelRow: '+rows);  
		}//DPG-5624 End 			
        }
    catch(Exception e)  
    {   
        System.debug('***Telstra:ProductBasketDataHandler:getAMAccessory:exception:'+e.getLineNumber()+' '+e.getMessage()); 
    }   
  
        return rows;
    }   
  //DPG-3508-- End
  //
  
  //DPG-3508-start
  Public List<Map<String, Object>> getDeviceAccessoryMobility(string basketId,  Map<string,Map<String, String>> filters){    
    
      
    List<Map<String,Object>>  finalRows= new List<Map<String,Object>>();
    system.debug('filters==>'+filters);
    if(filters.size()>0){
          for(string fltr:filters.keySet()){
              Map<String, String> Subfilters= filters.get(fltr);
              system.debug('Subfilters==>'+Subfilters);
              //Device
              if(subfilters.get('Query_Type') =='NGEMDeviceOC' || subfilters.get('Query_Type') =='NGEMDeviceRC' || subfilters.get('Query_Type') =='NGEMDeviceOCIC' || subfilters.get('Query_Type') =='NGEMDeviceRCIC'){//EDGE-171311 Added Inflight Basket related conga queries
                  finalRows.addAll(getNGEMDevices(basketId, Subfilters));       
                  
              }
              //Accessory // Added Suffix IC for inflight cancel
              else if(subfilters.get('Query_Type') =='AMaccessoryOC' || subfilters.get('Query_Type') =='AMaccessoryRC' || subfilters.get('Query_Type') =='AMaccessoryOCIC' || subfilters.get('Query_Type') =='AMaccessoryRCIC'){ //EDGE-171311 Added Inflight Basket related conga queries
                  finalRows.addAll(getAMAccessory(basketId, Subfilters));
              }
          }
    }
    system.debug('finalRows size==>'+finalRows.size()+' values==> '+ finalRows);
    return finalRows;
    
  }
  //DPG-3508-- End




  //DPG-4161 | DPG-4151 | Added DeviceCare | Start  | Anand 
    Private boolean isAddOnForAccessory(cscfga__Product_Configuration__c pc){
        
        if(pc.cscfga__Parent_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_001389') {
            return true;
        }
        
        return false;
    } 
    //DPG-4161 | DPG-4151 | End
}
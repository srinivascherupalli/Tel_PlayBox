/*
* @Author : Rahul
* @Date : 5 May 2019
* @Desc : Tramas Response JSON Compair with Transition JSON and Reconstruct.
* @Jira Cloud : EDGE-80464
*/
public with sharing class TramasEligiblityUpdate{
    static Final String tramasObjectName='TramasElgibilityCallbackResponse__c';//Variable has declare for Tramas Object API name.
    static Final String fileName='TransitionJSONData.json';//Variable has declare for Transition File Name.
    static Final String eligibleString='Eligible';//Variable has declare for Eligiblity Status.
    static Final String inEligibleString='Ineligible';//Variable has declare for InEligiblity Status.
    static Final String productNotMatchReason='Product Family is Different';//Variable has declare for Response when Product Family not match.
    static Final String auxiliaryReason='This Number is not Auxiliary';//Variable has declare for Auxiliary number not match.
    static Final String primaryReason='This Number is not Primary';//Variable has declare for Primary number not match.
    public static map<id,String> responseMap= new map<id,String>();
    public static Map<id,string> prRequestwithattch= new Map<id,string> ();
    public static Map<id,id> tramasWithPCRmap= new Map<id,id>();
    public static Map<String ,String> attachmentWithPCRidmap= new Map<String,String>();
    public static Map<id,string> prcWithAttachmentMap= new Map<id,string>();
    public static map<String,String> eligibiltyMap= new map<String,String>();
    public static map<String,String> eligibiltyReasonMap= new map<String,String>();
    public static map<string,string> eligibilityWithTramasRecordMap= new map<String,String>(); 
    public static set<id> parentIdSet= new set<id>();
    public static map<String,List<String>> rpidwithNumberMap= new map<String,List<String>> ();
    public static map<String,String> numberWithEligiblity= new map<String,String>();
    public static map<String,String> attachmentWithIdUpdatemap= new map<String,String>();
    
    public Static void tamasAttachmentsUpdate(map<id,Sobject> newMap,map<id,Sobject>oldMap){
        system.debug('***Telstra:TramasEligiblityUpdate:newMap'+newMap);
        for(attachment att:[SELECT Id,name,body,BodyLength,Description,ParentId FROM Attachment where id in:newMap.keyset()]){
            if((att.Description!=((Attachment)oldMap.get(att.id)).Description)||(att.BodyLength!=((Attachment)oldMap.get(att.id)).BodyLength)){
                if(String.valueOf((att.ParentId).getSObjectType())==tramasObjectName){
                    System.debug('***Telstra:TramasEligiblityUpdate:Started processing for -'+att);
                    responseMap.put(att.ParentId,att.body.tostring());
                    parentIdSet.add(att.ParentId);
                }
            }
        } 
        system.debug('***Telstra:TramasEligiblityUpdate:parentIdSet:'+parentIdSet);
        if(parentIdSet.size()>0)
            compairJSONFiles(parentIdSet);
    }
    //This method has written to Compare Transition JSON and Tramas JSON
    public Static void compairJSONFiles(set<id> parentIdSet){
        //This Loop has impletmented to Create map for Tramas Record id and Product Configuration Request id
        //EDGE-80772 : start Solution Console retrofit 
        for(TramasElgibilityCallbackResponse__c tMloop:[select id, Product_Configuration__c from TramasElgibilityCallbackResponse__c where id in:parentIdSet]){
            tramasWithPCRmap.put(tMloop.id,tMloop.Product_Configuration__c);
            
        }
        //EDGE-80772 : end Solution Console retrofit 
        system.debug('***Telstra:TramasEligiblityUpdate:tramasWithPCRmap:'+tramasWithPCRmap);
        //This Loop has Implemented to get the Attachement details with Parent Id against the TRAMAS record
        if(tramasWithPCRmap.size()>0){
            for( attachment attloop:[SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN:tramasWithPCRmap.values() AND name =:fileName]){
            prcWithAttachmentMap.put(attloop.ParentId,attloop.body.tostring());
            attachmentWithPCRidmap.put(attloop.ParentId,attloop.id);
            attachmentWithIdUpdatemap.put(attloop.id,attloop.body.tostring());
            
            }
        }
        system.debug('***Telstra:TramasEligiblityUpdate:prcWithAttachmentMap:'+tramasWithPCRmap+' attachmentWithPCRidmap:'+attachmentWithPCRidmap+' attachmentWithIdUpdatemap:'+attachmentWithIdUpdatemap);
        //This Loop has Implemented to create Map of RPID and numbers for Grouping/Range Scenario
        for(Id tmId:tramasWithPCRmap.keyset()){
            TramasDataObject tramasdto=TramasDataObject.parse(responseMap.get(tmId));
            for(TramasDataObject.Discovered_Objects dobject:tramasdto.Discovered_Objects){
                if((dobject.List_of_Relationships).size()>0){
                    numberWithEligiblity.put(dobject.PIID,dobject.Eligible);
                    for(Map<String,String> rmap:dobject.List_of_Relationships){
                        if(!rpidwithNumberMap.containsKey(rmap.get('RPID'))){
                            rpidwithNumberMap.put(rmap.get('RPID'), new List<String>{dobject.PIID});
                        }else{
                            rpidwithNumberMap.get(rmap.get('RPID')).add(dobject.PIID);
                        }
                    }
                }
            }
        }
        //This Loop has implement to compair both(transition & Tramas) json for Individual and Range/Group scenario
        for(Id tmId:tramasWithPCRmap.keyset()){
            ReplicatorGetServiceDataObject_V2 serviceObjDTO = ReplicatorGetServiceDataObject_V2.parse(prcWithAttachmentMap.get(tramasWithPCRmap.get(tmId)));
            eligibilityWithTramasRecordMap.put(tmId,eligibleString);
            for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : serviceObjDTO.site)
            {
                for(ReplicatorGetServiceDataObject_V2.productListDTO product: siteObj.productList)                         
                {
                    for(ReplicatorGetServiceDataObject_V2.serviceListDTO serlis:product.serviceList ){
                        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv : serlis.service ){
                            if((serv.serviceExtension).size()>0){
                                for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servExt:serv.serviceExtension){
                                    TramasDataObject tramasdto=TramasDataObject.parse(responseMap.get(tmId));
                                    for(TramasDataObject.Discovered_Objects dobject:tramasdto.Discovered_Objects){
                                        for(Map<String,String> rmap:dobject.List_of_Relationships){
                                            if((rpidwithNumberMap.get(rmap.get('RPID')).contains(servExt.Services_From)) && (rpidwithNumberMap.get(rmap.get('RPID')).contains(servExt.Services_To))){
                                                Boolean notEligible = false;
                                                for(String loopstring:rpidwithNumberMap.get(rmap.get('RPID'))){
                                                    if(integer.valueof(loopstring)>=integer.valueof(servExt.Services_From) && integer.valueof(loopstring)<=integer.valueof(servExt.Services_To)){
                                                        if(numberWithEligiblity.get(loopstring)!='Eligible'){
                                                            notEligible = true;
                                                            eligibiltyMap.put(servExt.Services_From,inEligibleString);
                                                            eligibiltyReasonMap.put(servExt.Services_From,'Numbers are InEligible');
                                                            eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                                            break;
                                                        }
                                                        else{
                                                            if(dobject.Product_Technology_Family!=product.Product_Type){
                                                                eligibiltyMap.put(servExt.Services_From,'InEligible');
                                                                eligibiltyReasonMap.put(servExt.Services_From,'Product Family Not Matched');
                                                                eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                                            }else{
                                                                eligibiltyMap.put(servExt.Services_From,eligibleString);
                                                                eligibiltyReasonMap.put(servExt.Services_From,'');
                                                                eligibilityWithTramasRecordMap.put(tmId,eligibleString);
                                                            }
                                                        }
                                                        
                                                    }
                                                    else{
                                                        eligibiltyMap.put(servExt.Services_From,inEligibleString);
                                                        eligibiltyReasonMap.put(servExt.Services_From,'All Numbers are not available');
                                                        eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                                    }
                                                }
                                                
                                            }
                                            else{
                                                eligibiltyMap.put(servExt.Services_From,inEligibleString);
                                                eligibiltyReasonMap.put(servExt.Services_From,'All Numbers are not available');
                                                eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                            }
                                            
                                        }   
                                    }
                                    
                                }
                                system.debug('***Telstra:TramasEligiblityUpdate:eligibiltyMapValue'+eligibiltyMap);
                                
                            }
                            else{
                                TramasDataObject tramasdto=TramasDataObject.parse(responseMap.get(tmId));
                                for(TramasDataObject.Discovered_Objects dobject:tramasdto.Discovered_Objects){
                                    if(serv.Service_Id==dobject.PIID){
                                        if(dobject.Eligible!='Eligible'){
                                            eligibiltyMap.put(serv.Service_Id,dobject.Eligible);
                                            String ReasonString='';
                                            for(String rString:dobject.Reason){
                                                if(ReasonString=='')
                                                    ReasonString=rString;
                                                else
                                                    ReasonString=ReasonString+','+rString;
                                            }
                                            eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                            eligibiltyReasonMap.put(serv.Service_Id,ReasonString);
                                        }
                                        
                                        else{
                                            if(dobject.Product_Technology_Family==product.Product_Type){
                                                if(serv.Association_Role==''){  
                                                    if(dobject.Characteristics_Of_Interest.get('Prime')!='Active'){
                                                        eligibiltyMap.put(serv.Service_Id,inEligibleString);
                                                        eligibiltyReasonMap.put(serv.Service_Id,primaryReason);
                                                    }
                                                    else{
                                                        eligibiltyMap.put(serv.Service_Id,eligibleString);
                                                        eligibiltyReasonMap.put(serv.Service_Id,'');
                                                    }
                                                    
                                                }
                                                if(serv.Association_Role=='Auxiliary'){
                                                    if(dobject.Characteristics_Of_Interest.get('Aux')!='Active'){
                                                        eligibiltyMap.put(serv.Service_Id,inEligibleString);
                                                        eligibiltyReasonMap.put(serv.Service_Id,auxiliaryReason);
                                                        eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                                    }
                                                    else{
                                                        eligibiltyMap.put(serv.Service_Id,eligibleString);
                                                        eligibiltyReasonMap.put(serv.Service_Id,'');
                                                    }
                                                }
                                                
                                            }
                                            else{
                                                eligibiltyMap.put(serv.Service_Id,inEligibleString);
                                                eligibiltyReasonMap.put(serv.Service_Id,productNotMatchReason);
                                                eligibilityWithTramasRecordMap.put(tmId,inEligibleString);
                                            }
                                        }
                                    }
                                    
                                }
                             system.debug('***Telstra:TramasEligiblityUpdate:eligibiltyMapValue'+eligibiltyMap);   
                            }
                        }
                    }
                }
            }
        }
        reconstructJSON(eligibiltyMap,eligibiltyReasonMap);
    }
    //This method has written to reconstruct/Update the Transition JSON
    public Static void reconstructJSON(map<String,String> eligibiltyMap,map<String,String> eligibiltyReasonMap){
        for(Id tmId:tramasWithPCRmap.keyset()){
            
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(prcWithAttachmentMap.get(tramasWithPCRmap.get(tmId)));
            List<Object> sites = (List<Object>)meta.get('site');
            for(object site:sites){
                Map<String, Object> products=(Map<String, Object>)site;
                List<Object> productlst = (List<Object>)products.get('productList');
                for(object product:productlst){
                    Map<String, Object> servs=(Map<String, Object>)product;
                    List<Object> servlst = (List<Object>)servs.get('serviceList');
                    for(object serv:servlst){
                        Map<String, Object> services=(Map<String, Object>)serv;
                        List<Object> serviceslst = (List<Object>)services.get('service');
                        for(object service:serviceslst){
                            Map<String, Object> servicextns=(Map<String, Object>)service;
                            List<object> extnlist=(List<Object>)servicextns.get('serviceExtension');
                            if(extnlist.size()>0){
                                for(Object ext:extnlist){
                                    Map<String, Object> extnsmap=(Map<String, Object>)ext;
                                    for (String attributeName : extnsmap.keyset()) {
                                        if(attributeName=='Services_From'){
                                            for(String fnnNumber:eligibiltyMap.keyset()){
                                                if(fnnNumber==extnsmap.get('Services_From')){
                                                    extnsmap.put('eligibilityStatus',eligibiltyMap.get(fnnNumber));
                                                    extnsmap.put('eligibilityReason',eligibiltyReasonMap.get(fnnNumber));
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                            else{
                                for(String attributeName : servicextns.keyset()) {
                                    if(attributeName=='Service_Id'){
                                        for(String fnnNumber:eligibiltyMap.keyset()){
                                            if(fnnNumber==servicextns.get('Service_Id')){
                                                servicextns.put('eligibilityStatus',eligibiltyMap.get(fnnNumber));
                                                servicextns.put('eligibilityReason',eligibiltyReasonMap.get(fnnNumber));
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                }
            }
            
            attachmentWithIdUpdatemap.put((attachmentWithPCRidmap.get(tramasWithPCRmap.get(tmId))),string.valueof(JSON.serializePretty(meta)));
            
            System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+attachmentWithIdUpdatemap);
            
            
        }
        if(attachmentWithIdUpdatemap.size()>0)
            tramasAttachmentUpdate(attachmentWithIdUpdatemap);
    }
    
    /* ****************************************************************************
* Author : Maqsood : EDGE-81600
* Date : 03 May 2019
* Description : update attachment json
* Parameters : map <string,string>
* Return type : Void
* *****************************************************************************/
    
    public static void tramasAttachmentUpdate(map<string, string> attachmentDetails){
        system.debug('***Telstra:TramasEligiblityUpdate:attachmentDetails'+attachmentDetails);
        string basketId = '';
        try{
            List<Attachment> listAttachment = new List<Attachment>();
            /* for(String jsonStrId : attachmentDetails.keySet()){
Attachment attachmentRecord  = new Attachment();
attachmentRecord.Body = EncodingUtil.base64Decode(attachmentDetails.get(jsonStrId));
attachmentRecord.id = jsonStrId;
listAttachment.add(attachmentRecord);
}*/
            List<attachment> dltlist= new List<attachment>();
            map<string, string> attachmentPCR = new map<string, string>();
            for(attachment attloop:[Select id,Parentid,body from attachment where id in:attachmentDetails.keyset()]){
                
                Attachment att = new Attachment();
                att.Name =  'TransitionJSONData.json';
                att.ParentId = attloop.Parentid;
                att.Body = blob.valueof(attachmentDetails.get(attloop.id));
                listAttachment.add(att);
                dltlist.add(attloop);
                attachmentPCR.put(attloop.Parentid, attloop.id);
            }
            if(listAttachment.size()>0)
                delete dltlist;
            insert listAttachment;
            updateTramasRecord(eligibilityWithTramasRecordMap);
            map<string, string> mapPCAttachment = new map<string, string>();
            //EDGE-80772 : Query updated for Solution Console retrofit 
            for(cscfga__Product_Configuration__c pc : [SELECT ID,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE ID IN : attachmentPCR.keySet()]){
                basketId = pc.cscfga__Product_Basket__c;
                if(pc!= null){
                    if (attachmentPCR.get(pc.Id) != ''){
                        mapPCAttachment.put(pc.Id,attachmentPCR.get(pc.Id) );
                    }
                    
                }
            }
            firePlatformEventTramas(basketId,mapPCAttachment);
            
        } 
        Catch(Exception ex){
            System.debug('***Telstra:TramasEligiblityUpdate:Exception Occured '+ex.getMessage()); 
        }    
        
    }
    
/* ****************************************************************************
* Author : Maqsood : EDGE-81600
* Date : 03 May 2019
* Description : Fire Platform Event TM1TransactionEvent on Tramas response Validation
* Parameters : String BasketId, String configurationId,String eligibilityRecordId
* Return type : Boolean
* *****************************************************************************/
    public static Boolean firePlatformEventTramas(String basketId,map<string, string> mapPCAttachment){
        try{
            List<TM1TransactionEvent__e> tramasEventList=new List<TM1TransactionEvent__e>();
            List<Database.SaveResult> saveRes =new List<Database.SaveResult>();
            /* for(string recordId : eligibilityRecordId){
            tramasEventList.add(publishPlatformEventTramas(basketId, configurationId, recordId)); 
            } */
            for (String key : mapPCAttachment.keySet()) {                      
                tramasEventList.add(publishPlatformEventTramas(basketId, key, mapPCAttachment.get(key))); 
            }
            
            if(!tramasEventList.isEmpty()){
                saveRes = EventBus.publish(tramasEventList);    
            } 
            system.debug('***Telstra:TramasEligiblityUpdate:saveRes '+saveRes);
            
        }
        Catch(Exception ex){
            System.debug('***Telstra:TramasEligiblityUpdate:Exception Occured '+ex.getMessage()); 
        }  
        
        return null;
    }
/* ****************************************************************************
* Author : Maqsood : EDGE-81600
* Date : 03 May 2019
* Description : Fire Platform Event TM1TransactionEvent on Tramas response Validation
* Parameters : String BasketId, String configurationId,String eligibilityRecordId
* Return type : sObject
* *****************************************************************************/
    //-----Publish Platform Event for  update of response record 
    public static TM1TransactionEvent__e publishPlatformEventTramas(String basketId,String configurationId,String eligibilityRecordId){
        TM1TransactionEvent__e tramasEvent =new TM1TransactionEvent__e();
        tramasEvent.basketId__c = basketId;
        tramasEvent.configurationId__c = configurationId;
        tramasEvent.eligibilityRecordId__c = eligibilityRecordId;
        System.debug('***Telstra:TramasEligiblityUpdate:Service_tramasEvent::' + tramasEvent);
        return tramasEvent;
    }
    
    /* ****************************************************************************
* Author : Maqsood : EDGE-81600
* Date : 03 May 2019
* Description : update TRAMAS Record
* Return type : boolean
* *****************************************************************************/
    //-----Publish Platform Event for  update of response record 
    public static boolean updateTramasRecord(map<string,string> eligibilityWithTramasRecordMap){
        try{
            list<TramasElgibilityCallbackResponse__c> updateTramasRecord = new list<TramasElgibilityCallbackResponse__c>();
            String statusValue = '';
            for(String key : eligibilityWithTramasRecordMap.keySet() ){
                TramasElgibilityCallbackResponse__c newRecord = new TramasElgibilityCallbackResponse__c();
                newRecord.Id = key;
                if(eligibilityWithTramasRecordMap.get(key) == 'Ineligible')
                    statusValue = 'Not Eligible';
                else if (eligibilityWithTramasRecordMap.get(key) == 'Eligible')
                    statusValue = 'Eligible';
                newRecord.Eligibility_Criteria__c= statusValue;
                updateTramasRecord.add(newRecord);
            }
            if(updateTramasRecord.size() > 0){
                update updateTramasRecord;   
                return true;
            }
        }
        Catch(Exception ex){
            System.debug('***Telstra:TramasEligiblityUpdate:Exception Occured '+ex.getMessage()); 
        }                               
        
        return false;
    }
}
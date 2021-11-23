/*
* @Author : Rahul/Ritika
* @Date : 3 April 2019
* @Desc : DTO class for TM1 Eligibility Request for Transition
* @Jira Cloud : EDGE-66569
*/
public with sharing class TM1EligibilityCheckService{
    
    
    public static void TramasEligibilityRequestMethod(Map<String,ReplicatorGetServiceDataObject_V2> mapPCToServiceDTO){
        Logger2 logger2 = Logger2.getLogger('TramasEligibilityRequestMethod');
        try{    
            //Retrieve all PCR records for obtaining PC and Basket details
        //EDGE-80772 - start SolutionConsole RetroFit for TM1
        Map<String,cscfga__Product_Configuration__c> mapIdtoPC = new Map<String,cscfga__Product_Configuration__c>();
            for(cscfga__Product_Configuration__c pc :[SELECT id,cscfga__Product_Basket__c, name FROM cscfga__Product_Configuration__c WHERE Id in:mapPCToServiceDTO.keySet()]){
                mapIdtoPC.put(pc.Id , pc);
            }
            //EDGE-80772 - end SolutionConsole RetroFit for TM1
            //Logic to create TramasEligibilityCheckRequestDTO for each site, and inserting a callout-request for each site
            Integer index=0;
            Attachment attachmentRecord = null; 
            TramasElgibilityCallbackResponse__c newResponse = null;   
            List<TramasElgibilityCallbackResponse__c> listOfResponseRecords= new List<TramasElgibilityCallbackResponse__c>();
            List<Attachment> listOfAttachments =new List<Attachment>();
            TM1EligibilityCheckRequestDTO trEligibilityRequest= new TM1EligibilityCheckRequestDTO();
            Map<TM1EligibilityCheckRequestDTO,Attachment> mapRequestVsAttachment = new Map<TM1EligibilityCheckRequestDTO,Attachment>();                     
            //EDGE-80772 - start SolutionConsole RetroFit for TM1
            for(Id pcID:mapIdtoPC.keySet()){
                           
                //adding details to request
                trEligibilityRequest.Correlation_ID=getCorrelationId();
                trEligibilityRequest.Product_Technology_Family_Name='PSTN';
                trEligibilityRequest.Service_Provider_ID='Retail (002)';
                trEligibilityRequest.Match_Type='Any';
                trEligibilityRequest.Effective_Date=Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS');
                trEligibilityRequest.Start_Date=Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS');
                trEligibilityRequest.End_Date=Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS');
                trEligibilityRequest.Client_ID=Label.TM1ClientID;
                
       
                system.debug('***Telstra:TM1EligibilityCheckService:value of pcID:'+ pcID +' serviceObjDTO:'+mapPCToServiceDTO.get(pcID));
                for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : (mapPCToServiceDTO.get(pcID)).site)  //EDGE-80772 - end SolutionConsole RetroFit for TM1
                {
                    for(ReplicatorGetServiceDataObject_V2.productListDTO product: siteObj.productList)                         
                    {
                        System.debug('***Telstra:TM1EligibilityCheckService:value of Product List:'+product);
                        if(product.checkValue){
                            for(ReplicatorGetServiceDataObject_V2.serviceListDTO serlis:product.serviceList ){
                                for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv:serlis.service ){
                                    TM1EligibilityCheckRequestDTO.Query_Key_WhiteList queryKey = new TM1EligibilityCheckRequestDTO.Query_Key_WhiteList();
                                    queryKey.ID_Catergory='Resource';
                                    queryKey.ID_Type='Dialable Number';
                                    for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servExt:serv.serviceExtension){
                                        if(servExt!=null){
                                            queryKey.ID=servExt.Services_From;
                                            queryKey.Range_Start=servExt.Services_From;
                                            queryKey.Range_End=servExt.Services_To;
                                            //EDGE-93194 - defectFix
                                            trEligibilityRequest.Query_Key_White_List.add(queryKey);                                          
                                            queryKey = new TM1EligibilityCheckRequestDTO.Query_Key_WhiteList();
                                        }
                                    }
                                    
                                    //EDGE-93194 - defectFix
                                    if((serv.serviceExtension==null || serv.serviceExtension.size()==0) && queryKey.ID==null){
                                        queryKey.ID=serv.Service_Id;
                                        queryKey.Range_Start=serv.Service_Id;
                                        queryKey.Range_End=serv.Service_Id;                                    
                                        trEligibilityRequest.Query_Key_White_List.add(queryKey);
                                    }                                
                                    
                                }
                            }                        
                        }                    
                    }                
                }
               
                //Logic to process tramas-eligibility request only if query-key-white-list has values
                if(trEligibilityRequest.Query_Key_White_List.size()>0){
                    //EDGE-80772 :Solution Console retrofit 
                    newResponse = new TramasElgibilityCallbackResponse__c(Product_Basket__c=mapIdtoPC.get(pcID).cscfga__Product_Basket__c,name='TM1Callback',Correlation_ID__c=trEligibilityRequest.Correlation_ID,UUID__c='',Product_Configuration__c=pcID);                                
                    //create corresponding Attachment-record and add it to list
                    attachmentRecord = new Attachment();
                    attachmentRecord.Body = Blob.valueOf('');
                    attachmentRecord.Name = String.valueOf('EligibilityResults.txt');                   
                    System.debug('attachment:'+attachmentRecord); 
                    
                    listOfResponseRecords.add(newResponse);
                    listOfAttachments.add(attachmentRecord);    
                                      
                    mapRequestVsAttachment.put(trEligibilityRequest,attachmentRecord);                   
                }
                trEligibilityRequest = new TM1EligibilityCheckRequestDTO();
                index++;
            }
            //Throwing an exception, if mismatch occurs
            if(listOfResponseRecords.size() != listOfAttachments.size())
                throw new TM1EligibilityCheckException('Error occured while processing TM1Eligibilityrequest: Mismatch in list-sizes of response and attachment records. Aborting the process.');
               
            if(listOfResponseRecords.size()>0)
                insert listOfResponseRecords;                
            System.debug('***Telstra:TM1EligibilityCheckService:trEligibilityRequest:listOfResponseRecords'+listOfResponseRecords);          
            
            for(integer count=0;count<listOfResponseRecords.size();count++){
                TramasElgibilityCallbackResponse__c responseRecord=listOfResponseRecords[count];
                listOfAttachments[count].parentId = responseRecord.Id;
            }    
            if(listOfAttachments.size()>0)
                insert listOfAttachments;
                
            //set callback-URL in request, and then make a callout
            for(TM1EligibilityCheckRequestDTO requestDTO:mapRequestVsAttachment.keySet()){
                requestDTO.CallBack_URL = Label.TM1okapiAPI_baseURL+'/services/data/v45.0/sobjects/Attachment/'+mapRequestVsAttachment.get(requestDTO).id;                
                IntegrationRecordHandlerUtil.createRequests('TM1EligibilityCheckHandler', new List<String>{requestDTO.Correlation_ID},JSON.serialize(requestDTO));                
            }
        }
        catch(TM1EligibilityCheckException texception){
            System.debug('***Telstra:TM1EligibilityCheckService:TM1EligibilityCheckException:texception.getMessage()');
            logger2.logMessages('TM1EligibilityCheckService:TramasEligibilityRequestMethod',texception.getMessage() , '', '', '', '', false, false, null , null, null, null);
        }
        catch(Exception e){
            system.debug('***Telstra:TM1EligibilityCheckService:trException:'+e.getMessage());   
            logger2.logMessages('TM1EligibilityCheckService:TramasEligibilityRequestMethod',e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
        }
        finally{
            logger2.exitLogger();
        }
    }
    
    //Method to form correlation-id 
    public static String getCorrelationId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String CorrelationId = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return CorrelationId;
    }
    
    //Future method for integration-handler-framework, for making a callout to TM1 interface
    @future(callout=true)
    public static void sendEligibilityCheckRequest(String param) {
        System.debug('***Telstra:TM1EligibilityCheckService:sendEligibilityCheckRequest:'+param);
        String handlerName = 'TM1EligibilityCheckHandler';
        Logger2 logger2 = Logger2.getLogger(handlerName);
        try{            
            //Get the request details from Integration-record
            Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c
                                                  FROM Integration_Record__c
                                                  WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
            Map<String,String> headerMap = new Map<String, String>();
            //token-generation for OAuth
            if(Label.Use_OAuth_token_for_TM1=='True'){
                String token = AuthenticationManager.getOauthToken(TM1EligibilityCheckHandler.class.getName());
       
                headerMap = new Map<String, String>{'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer '+token};
            }
            else
                headerMap = new Map<String, String>{'Content-Type' => 'application/json'};
                
            String requestDtoJson =  paramRequest.paramPayload__c;
            System.debug('***Telstra:TM1EligibilityCheckService:Telstra:TM1EligibilityCheckService:sendEligibilityCheckRequest:requestDtoJson:' + requestDtoJson );
            TM1EligibilityCheckRequestDTO trEligibilityRequest= (TM1EligibilityCheckRequestDTO) JSON.deserialize(requestDtoJson, TM1EligibilityCheckRequestDTO.class);
            
            //Callout to TRAMAS
            HTTPResponse response = IntegrationRecordHandlerUtil.callout(JSON.serialize(trEligibilityRequest),
                                                                         IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                         headerMap, 'TM1EligibilityCheckHandler', new List<String>{param},null);
            
            System.debug('***Telstra:TM1EligibilityCheckService:sendEligibilityCheckRequest:Response:'+response);
            
            //Logic to update UUID in TramasElgibilityCallbackResponse
            Map<String, String> responseValues = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
            System.debug('***Telstra:TM1EligibilityCheckService:responseValues:'+responseValues);        
            TramasElgibilityCallbackResponse__c responseRecord = [SELECT id,Correlation_ID__c,UUID__c FROM TramasElgibilityCallbackResponse__c WHERE Correlation_ID__c=:trEligibilityRequest.Correlation_ID];
            if(responseRecord!=null){
                responseRecord.UUID__c  =responseValues.get('UUID');         
                update responseRecord; 
                System.debug('responseRecord:'+responseRecord);                              
            }          
            //Adding the request-response in Application-logs
            if(response!= null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_SUCCESS) { //Request was successfully accepted
                logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            } else {
                System.debug('***Telstra:TM1EligibilityCheckService:ERROR sending email');
                String corId='';           
                if(response!= null && !String.isEmpty(response.getBody()))               
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                 else 
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), null, '', '', '', '', false, false, null , null, null, null);                         
                   }
            
        }
        catch(Exception e){
            System.debug('***Telstra:TM1EligibilityCheckService:trException:'+e.getMessage());
            logger2.logMessages('TM1EligibilityCheckService:sendEligibilityCheckRequest',e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
        }
        finally{
            logger2.exitLogger();
        }
    }
    
    //Custom exception for handling 
    public class TM1EligibilityCheckException extends Exception {}

}
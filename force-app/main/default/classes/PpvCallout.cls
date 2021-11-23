/*************************************************************************************************
Name : PpvCallout
Description : Used for callouts to PPV tool
Author: Kalashree Borgaonkar
Story: EDGE-90327
***************************************************************************************************/
public with sharing class PpvCallout {
    
    /*-------------------------------------------------------- 
EDGE-90327
Method: getPortInMsisdns
Description: Method to make callout to PPV tool
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static PpvResponseDTO calloutToPpvTool(PpvRequestDTO ppvRequest)
    {
        String handlerName = 'PPVHandler'; 
        Logger2 logger = Logger2.getLogger(handlerName);
        PpvResponseDTO res = new PpvResponseDTO();
        String reqBody = JSON.serialize(ppvRequest,true);
        HttpResponse response;
        try {
            
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('response::' + response.getBody());
            String responseCode = String.valueOf(response.getStatusCode());
            if (responseCode.startsWith('2')) {
                res = PpvResponseDTO.parse(response.getBody());
                System.debug('res: '+res);
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
            }
            else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                res = PpvResponseDTO.parse(response.getBody());
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return res;
    }  
    /*-------------------------------------------------------- 
EDGE-90327
Method: createPayload
Description: Method to create payload for PPV tool callout
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static PpvRequestDTO createPayload(String portNumber,String externalId){
        //String childrecordid = createPPVrecord(externalId);
        PpvRequestDTO requestDto = new PpvRequestDTO();
        requestDto.correlationId=EDISSingleManager.getUID();
        requestDto.timestamp = JSON.serialize(Datetime.now());
        PpvRequestDTO.Data reqData= new PpvRequestDTO.Data();
        reqData.externalId=externalId;
        reqData.portNumber=portNumber;
        //Kalashree Borgaonkar. Removing this attribute.
        //reqData.prePaidBrand='N';
        requestDto.data = reqData;
        return requestDto;
    }
    /*-------------------------------------------------------- 
EDGE-132716
Method: ppvCalloutFromTrigger
Description: Method to create payload for PPV tool callout
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @future(callout=true)
    public static void ppvCalloutFromTrigger(String id){
        System.debug('ppvCalloutFromTrigger: '+id);
        List<Customer_Authority_Form__c> caForm =[SELECT Id ,MSISDN__c,PPV_status__c,Account__c,Contact__c,
                                            Is_active__c,Customer_Authority_Form__c,Opportunity__c,Status__c,
                                            (SELECT Id
                                            FROM Customer_Authority_Forms__r 
                                            WHERE type__C='PPV' ORDER BY createdDate DESC LIMIT 1)
                                            FROM Customer_Authority_Form__c 
                                            WHERE Id =:id];  
        if(!caForm.isEmpty() && !caForm[0].Customer_Authority_Forms__r.isEmpty()){
            if(caForm[0].MSISDN__c!=null){
            String externalid = caForm[0].Customer_Authority_Forms__r[0].id;
            PpvRequestDTO requestDto = createPayload(caForm[0].MSISDN__c,externalid);
            PpvResponseDTO responseDto= calloutToPpvTool(requestDto);
            System.debug('responseDto: '+responseDto);
            if(responseDto!=null){
                saveResponse(caForm[0],responseDto);  
            }
        }   
        }
        
    }
/*--------------------------------------------------------
EDGE		-144140
Method		-createPPVrecord
Description -create child record (PPV)
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/  
    public static String createPPVrecord(Id parentCAFid,String msisdn){
        Customer_Authority_Form__c childPPV = new Customer_Authority_Form__c();
        String childRecordid=null;
        try{
            childPPV.Customer_Authority_Form__c= parentCAFid;
            childPPV.Type__c = 'PPV';
            childPPV.MSISDN__c = msisdn ;
            insert childPPV;
            childRecordid = childPPV.id;
        }
        catch(Exception e){
            System.debug('Exception in createPPVrecord: '+e.getStackTraceString());
        }
        return childRecordid;
    }
    /*--------------------------------------------------------
EDGE		-144140
Method		-createResendPPVrecord
Description -create child record (PPV) through resend ppv button
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/ 
    public static String createResendPPVrecord(Id parentCAFid,String msisdn,String contactid){
        Customer_Authority_Form__c childPPV = new Customer_Authority_Form__c();
        String childRecordid=null;
        try{
            childPPV.Customer_Authority_Form__c= parentCAFid;
            childPPV.Type__c = 'PPV';
            childPPV.MSISDN__c = msisdn ;
            childPPV.Contact__c = contactid;
            insert childPPV;
            childRecordid = childPPV.id;
        }
        catch(Exception e){
            System.debug('Exception in createResendPPVrecord: '+e.getStackTraceString());
        }
        return childRecordid;
    }
 /*--------------------------------------------------------
EDGE		-88791,144140
Method		-saveResponse
Description -save response from PPV tool in child record
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/       
    public static void saveResponse(Customer_Authority_Form__c caForm,PpvResponseDTO responseDto){
        String externalId=null;
        List<Customer_Authority_Form__c> selfCaf ;
        List<cscfga__Product_Basket__c> bList = new List<cscfga__Product_Basket__c>();
        System.debug('responseDto: '+responseDto);
        try{
            if(responseDto!=null && responseDto.responseCode!=null ){
                //externalId = responseDto.data!=null?responseDto.data.externalId:null;
                selfCaf = [SELECT Contact__c,MSISDN__c,Status__c,PPV_status__c,
                           Opportunity__c,Type__c,Resource_Id__c,Account__c
                           FROM Customer_Authority_Form__c
                           WHERE Customer_Authority_Form__r.id = :caForm.id
                           AND Customer_Authority_Form__r.is_active__c = true
                           ORDER BY createdDate DESC LIMIT 1
                          ];
                System.debug('selfCaf: '+selfCaf);
                if(!selfCaf.isEmpty()){
                    selfCaf[0].Contact__c = caForm.contact__c;
                    selfCaf[0].Status__c = responseDto.responseCode;   
                    selfCaf[0].PPV_status__c = PpvComponentController.getStatusValue(responseDto.responseCode); 
                    selfCaf[0].Opportunity__c = caForm.Opportunity__c;
                    selfCaf[0].Account__c = caForm.Account__c;
                    if(!responseDto.responseCode.containsIgnoreCase('Failed')){
                            selfCaf[0].Resource_Id__c = responseDto.data!=null?responseDto.data.resourceId:null;
                    }
                }
                //DIGI-32979
                bList = [Select Id,Name,csbb__Account__c,csbb__Account__r.Name, cscfga__Opportunity__c, cscfga__Opportunity__r.OwnerId,csbb__Account__r.OwnerId from cscfga__Product_Basket__c where cscfga__Opportunity__c =: caForm.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
                System.debug('bList++'+bList);
            }
            if(!selfCaf.isEmpty()){
                upsert selfCaf;
                //DIGI-32979
                ConnectApiHelper.postFeedItemWithMentions(null,caForm.Opportunity__c,'CA Form (Customer Authorisation Form) was successfully signed by '+bList[0].csbb__Account__r.Name+' on the ' +System.Now()+' . You can now proceed to basket ' +bList[0].Name+ ' , to initiate PPV (Pre Port Verification).'); 
            }   
        }
        catch(Exception e){
            system.debug('Exception in saveResponse '+e.getStackTraceString());   
        }        
    }   
}
/*-------------------------
Author: Ila Anmol Verma
US: EDGE-66239/66226
Description: Generate appointment pre requisite for BOM 
---------------------------------*/

public with sharing class AppointmentServiceCallout {
    
    //Initialize locals
        public Static String cancel = 'Cancel';
        public Static String add = 'ADD';
        public Static String modify = 'MODIFY';
        public Static String cease = 'CEASE';
        public Static String existingActive = 'EXISTING-ACTIVE';
        public Static String fulfilment = 'FULFILMENT';
        public Static String fulfil = '_Fulfilment';
        public Static String parentSpec = 'parentSpec';
        public Static String amdocs = 'B2B_Amdocs';
        public Static String genericOrder = 'GENERIC ORDER';
        public Static String metro = 'METRO';
        public Static String regional = 'REGIONAL';
        public Static String std = 'STD';
        public Static String telstra = 'TELSTRA';
        public static String handler =  'GenerateAppointmentHandler';
        public static Integer counter =0;
        public Static Datetime dt = null;
        public Static Datetime suggDate = null;
        //public static String iPSiteprodID = 'DMCAT_ProductOffering_000304';
        public static String iPSiteInstanceID = '877ca8f5-2487-752c-ad43-5b6dba91fe82';
        public Static Map<Id,AppointmentResponseDTO> subToResponseMap = new Map<Id,AppointmentResponseDTO>(); 
        
        
  //Get subscritions for order
        public static void getSubscriptionIds(String ordID){
            if(ordID!=NULL){
                 //Vimal: remove reference to Primary Orders and accommodate changes to the secondary order data model 
                List<csord__Subscription__c> subsList = [select id,Site__c,toBeCancelled__c,csord__Order__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,csord__Order__r.csord__Order_Number__c,site__r.cscrm__Installation_Address_Details__c from csord__Subscription__c where csord__Order__c = :ordID  and Site__c!=NULL];
              //List<csord__Subscription__c> subsList = [select id,Site__c,toBeCancelled__c,csord__Order__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c= :ordID and Site__c!=NULL];
            system.debug('subsList++' +subsList);
                String jobId=System.enqueueJob(new AppointmentServiceCalloutQ(subsList,ordID));
            }
        }
       
       /*-------------------------------------------------------- 
EDGE-EDGE-75207
Method: generateAppointmentForErrorScenario 
Description: Appointment for error scenario
Author: Pradeep
--------------------------------------------------------*/
       public void generateAppointmentForErrorScenario(String orderId,String subscriptionId){
            //List<Required_Appointment__c> appointmentList = [select Id,name from Required_Appointment__c where Generate_Appointment_Order__c=:orderId and Generate_Appointment_Subscription__c=:subscriptionId and isActive__c=False];                           
            if((subscriptionId!=NULL)||(orderId!=NULL)){
                List<csord__Subscription__c> subsList = [select id,toBeCancelled__c,csord__Order__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,csord__Order__r.csord__Order_Number__c,site__r.cscrm__Installation_Address_Details__c from csord__Subscription__c where Id= :subscriptionId and csord__Order__c= :orderId];
                system.debug('subsList++' +subsList);
                String jobId=System.enqueueJob(new AppointmentServiceCalloutQ(subsList,orderId));
            }   
        }  
     
// Return the list of sites where appointment is required
    public static void generateAppointment(List<csord__Subscription__c> subsList, String token, String ordID){
        Logger2 logger = Logger2.getLogger(handler);
        AppointmentResponseDTO appointRes =null;
        Map<String,ResponseWrapper> addressToResponseMap = new Map<String,ResponseWrapper>();
        String reqBody = null;
        String resBody= null;
        Integer statCode = null;
        String offerprodID ='';
        List<Id> subscripList = new List<Id>();
        Map<ID, csord__Subscription__c> subsMap= new Map<ID, csord__Subscription__c>();
        for(csord__Subscription__c subscrip: subsList){
            //subscripList.add(subscrip.id);  // Vilas
            subsMap.put(subscrip.id,subscrip);
        }

        List<csord__Service__c> servList = new List<csord__Service__c>();
        List<Attachment> attachmentList = new List<Attachment>();

        //*******Vilas **********
        //servList = [SELECT Id, Name, csord__Status__c,SiteId__c,Cust_Req_Disconn_Date__c, Customer_Requested_Date__c,csord__Order__c,csord__Order__r.csord__Order_Type__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c, csord__Subscription__c, ReplacedSubscription__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c WHERE csord__Subscription__r.id IN:subscripList];
                
        Map<ID, List<csord__Service__c>> serviceListPerSub = new Map<ID, List<csord__Service__c>>();
        Map<ID, List<Attachment>> attachListPerSub = new Map<ID, List<Attachment>>();
        Map<ID, csord__Service__c> serviceMap = new Map<ID, csord__Service__c>([SELECT Id, Name, Zone__c, csord__Status__c,SiteId__c,Cust_Req_Disconn_Date__c,Not_Before_CRD__c, Customer_Requested_Date__c,csord__Order__c,csord__Order__r.csord__Order_Type__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c, csord__Subscription__c, ReplacedSubscription__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c WHERE csord__Subscription__r.id IN:subsMap.keySet()]);
        Map<ID, Attachment> attachmentMap = new Map<ID, Attachment>([Select id,body,parentId from Attachment where parentId IN :serviceMap.keySet() and name = 'ServiceSpecifications.json']);
        for(ID srviceid : serviceMap.keyset()){
            csord__Service__c serviceRec = serviceMap.get(srviceid);
            List<csord__Service__c> lst = new List<csord__Service__c>();
            if(serviceListPerSub.get(serviceRec.csord__Subscription__r.id)!= null){
                lst = serviceListPerSub.get(serviceRec.csord__Subscription__r.id);
                lst.add(serviceRec);
                serviceListPerSub.put(serviceRec.csord__Subscription__r.id,lst);
            }else{
                lst.add(serviceRec);
                serviceListPerSub.put(serviceRec.csord__Subscription__r.id,lst);
            }
        }
        for(ID attachmentId : attachmentMap.keyset()){
            Attachment attachmentRec = attachmentMap.get(attachmentId);
            csord__Service__c serviceRec = serviceMap.get(attachmentRec.parentId);
            List<Attachment> attachList = new List<Attachment>();
            if(attachListPerSub.get(serviceRec.csord__Subscription__r.id)!= null){
                attachList = attachListPerSub.get(serviceRec.csord__Subscription__r.id);
                attachList.add(attachmentRec);
                attachListPerSub.put(serviceRec.csord__Subscription__r.id,attachList);
            }else{
                attachList.add(attachmentRec);
                attachListPerSub.put(serviceRec.csord__Subscription__r.id,attachList);
            }
        }
        //*******Vilas **********

        for(ID subsId: subsMap.keySet()){
            csord__Subscription__c subs = subsMap.get(subsId);
            system.debug('subs++' +subs);
            AppointmentRequestDTO appoint = new AppointmentRequestDTO();
            AppointmentRequestDTO.Data appointReq = new AppointmentRequestDTO.Data();
            List<AppointmentRequestDTO.TransactionProducts> transProdList = new List<AppointmentRequestDTO.TransactionProducts>();
            AppointmentRequestDTO.TransactionProducts transProd = null;
            List<AppointmentRequestDTO.ProductParameters> prodParamList = null;
            AppointmentRequestDTO.ProductParameters prodParam =null;
            List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            List<csord__Service__c> srvcList = serviceListPerSub.get(subsId);

            //Retrive the services and service specificationJson for a subscription
            /*for(csord__Service__c servi: servList){
                if(servi.csord__Subscription__r.id == subs.id){
                    srvcList.add(servi);
                }
            }*/
            try{

                Map<Id,String> serviceAttachmentMap = new Map<Id,String>(); 
                for(Attachment att: attachListPerSub.get(subsId)){
                    serviceAttachmentMap.put(att.parentId,att.body.toString());
                    system.debug('serviceAttachmentMap++' +serviceAttachmentMap);
                }
                for(String eachService: serviceAttachmentMap.keySet()){
                 fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT')) ;

                 System.debug('fulfilmentSrvspecList::' + fulfilmentSrvspecList);
                }
            }catch (Exception e){
                System.debug(' Exception in getAllServSpecs:' + e);
            }

   //Initialize TransactionProducts
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : fulfilmentSrvspecList){
                system.debug('fulfilmentSrvspecList++' +fulfilmentSrvspecList);
                transProd = new AppointmentRequestDTO.TransactionProducts();
                if(subs.csordtelcoa__Replacement_Subscription__c == NULL && subs.csordtelcoa__Product_Configuration__r.Type__c!=cancel){
                transProd.productAction = add;
                } else if(subs.csordtelcoa__Replacement_Subscription__c!=NULL && subs.csordtelcoa__Product_Configuration__r.Type__c!=cancel){
                    transProd.productAction = modify;
                }else if(subs.csordtelcoa__Product_Configuration__r.Type__c==cancel){
                    transProd.productAction = cease;
                }else{
                    transProd.productAction = existingActive;
                }
                transProd.productID = srvSpec.code.remove(fulfil);
                transProd.productInstanceID = srvSpec.guid;
                
                 if(srvSpec.identifier.contains('ProductOffering'))
                     {
                    offerprodID  = srvSpec.identifier.substringBeforeLast('DMCAT');
                      }

                if(srvSpec.additionalAttributes != NULL){
                    for(CS_SpecificationDTO.SimpleAttributes additionalAttr : srvSpec.additionalAttributes){
                        if(additionalAttr.name.contains(parentSpec)){
                            transProd.parentProductInstanceID = additionalAttr.value;
                        }
                    }
                }
            //Initialize ProductParameters
                prodParamList = new List<AppointmentRequestDTO.ProductParameters>();
                for(CS_SpecificationDTO.SimpleAttributes simpleAttr : srvSpec.SimpleAttributes){
                   if(simpleAttr.name!='' && simpleAttr.value!= '')  {
                            /*Pattern MyPattern = Pattern.compile('^[a-zA-Z0-9-_ ]*$');
                        Matcher MyMatcher = MyPattern.matcher(simpleAttr.value);
                            if(MyMatcher.matches())*/
                        prodParam = new AppointmentRequestDTO.ProductParameters();
                        prodParam.parameterName = simpleAttr.name;
                        prodParam.parameterValue = simpleAttr.value;
                        prodParamList.add(prodParam);

                    }
                }
                transProd.productParameters = prodParamList;
                transProdList.add(transProd);
            }
            //EDGE-93418 : For Cease Order
            transProd = new AppointmentRequestDTO.TransactionProducts();
            if(subs.csordtelcoa__Replacement_Subscription__c == NULL && subs.csordtelcoa__Product_Configuration__r.Type__c!=cancel){
                transProd.productAction = add;
            } else if(subs.csordtelcoa__Replacement_Subscription__c!=NULL && subs.csordtelcoa__Product_Configuration__r.Type__c!=cancel){
                transProd.productAction = modify;
            }else if(subs.csordtelcoa__Product_Configuration__r.Type__c==cancel){
                transProd.productAction = cease;
            }else{
                transProd.productAction = existingActive;
            }
                        transProd.productID = offerprodID ;
                        transProd.productInstanceID = iPSiteInstanceID;
                        transProdList.add(transProd);
                        system.debug('transProdList++' +transProdList);

    //Initialize AppointmentRequest
    // Added for 66450: Mapping for notEarlierThanDate
            
            List<csord__Service__c> serviceList = new List<csord__Service__c>(); // Vilas
            for(csord__Service__c servi: srvcList) {
                if(servi.SiteId__c!=NULL && subs.toBeCancelled__c=='true' && servi.Cust_Req_Disconn_Date__c!=NULL){
                    String dc =String.valueOfGMT(servi.Cust_Req_Disconn_Date__c);
                    system.debug('dc+' +dc);
                    appointReq.notEarlierThanDate=dc.replace(' ', 'T');
                    system.debug('appointReq.notEarlierThanDate+_' +appointReq.notEarlierThanDate);
                }   else if(servi.SiteId__c!=NULL && subs.toBeCancelled__c=='false' && servi.Not_Before_CRD__c!=NULL){
                    String dt =String.valueOfGMT(servi.Not_Before_CRD__c);
                    system.debug('dt+' +dt);
                    appointReq.notEarlierThanDate=dt.replace(' ', 'T');
                    system.debug('appointReq.notEarlierThanDate+' +appointReq.notEarlierThanDate);
                }
                //// Vilas
                if(servi.name != null && servi.name.containsIgnoreCase('User - Fixed Seat - ')){
                    serviceList.add(servi);
                }
            }
            appointReq.ruleSetID = amdocs;
            appointReq.transactionType = genericOrder;
                if(subs.site__r.cscrm__Installation_Address_Details__c!=null){
                    String stateAdd = subs.site__r.cscrm__Installation_Address_Details__c;
                    system.debug('stateAdd++' +stateAdd);
                    appointReq.state = stateAdd.substringBefore(',');
                }
            // Vilas
            //List<csord__Service__c> serviceList = new List<csord__Service__c>([Select Zone__c,name from csord__Service__c where name like 'User - Fixed Seat - %' and csord__Subscription__r.id =:subs.id]);
            if(!serviceList.isEmpty()){
                if(serviceList[0].Zone__c!=NULL && (serviceList[0].Zone__c=='1' || serviceList[0].Zone__c=='2')){
                    appointReq.locationType = metro;
                }else if(serviceList[0].Zone__c!=NULL && (serviceList[0].Zone__c=='3' || serviceList[0].Zone__c=='4')){
                appointReq.locationType = regional;
            }
        }
        appointReq.complexityBand = std;
          appointReq.transactionReferenceID = subs.csord__Order__r.csord__Order_Number__c; //EDGE-90307 QA2 issue fix
        //appointReq.transactionReferenceID = subs.Primary_Order__r.csord__Order_Number__c; //EDGE-90307 QA2 issue fix
        appointReq.transactionProducts = transProdList;
        appoint.correlationId = EDISSingleManager.getUID();
        appoint.data = appointReq;
        System.debug('ApptPayload::' + JSON.serialize(appoint,true));

        HttpResponse resp = bookAppointment(subs.Id,appoint,token);
        reqBody = JSON.serialize(appoint,true);
        if(resp!= null)
        {
            resBody= resp.getBody();
            statCode = resp.getStatusCode();
        }

        ResponseWrapper resWarp = new ResponseWrapper(reqBody,resBody,statCode);
        addressToResponseMap.put(subs.Id,resWarp);
            system.debug('***' +subs.Id +resWarp);
            system.debug('addressToResponseMap++' +addressToResponseMap);
        counter++;
        system.debug('counter ++' +counter);
        }
        if(counter==subsList.size()){
            system.debug('subsList.size()++'+subsList.size());
            for(String subID : addressToResponseMap.keySet()){
                ResponseWrapper ares = addressToResponseMap.get(subID);

                if (ares.statusCode == 200 || ares.statusCode == 201 || ares.statusCode == 202) {
                    appointRes = AppointmentResponseDTO.parse(ares.adRes);
                logger.logMessages(ares.reqBody, ares.adRes, '', '', '', '', false, false,ares.statusCode , null, null, null);

                    saveAppointment(appointRes,ordID,subID);
            }
            else{
                logger.logMessages(ares.reqBody, ares.adRes, '', '', '', '', false, false, ares.statusCode , null, null, null);
            }
                logger.exitLogger();

            }
            
            
        }
        
      /*EDGE-121760 , Kalashree Borgaonkar. Remove change order status logic from this step
       *   List<csord__Subscription__c> subsListErr = [select id,Site__c,toBeCancelled__c,csord__Order__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,csord__Order__r.csord__Order_Number__c,site__r.cscrm__Installation_Address_Details__c from csord__Subscription__c where csord__Order__c = :ordID  and Site__c!=NULL];
        
List<Required_Appointment__c> apptNotReq = [select id,required_AppointmentCount__c,Generate_Appointment_Subscription__c,Generate_Appointment_Order__c,Appointment_BOM_ID__c from Required_Appointment__c
where Generate_Appointment_Order__c=:ordID and required_AppointmentCount__c=0];

   if(apptNotReq.Size() == subsListErr.size())
   {
   nextOrderStatus(ordID);

    }*/
   }

//Create Appointment Record
    public static void saveAppointment(AppointmentResponseDTO appointRes, String ordID,String subID){
system.debug('in savke' +appointRes +ordID +subID);
        Required_Appointment__c appointment;
        Integer appSize =0;
        List<Required_Appointment__c> appointmentList = new List<Required_Appointment__c>();
        if(appointRes != NULL && appointRes.data != NULL ){
                
                 if(appointRes.data.numberOfAppointmentsRequired == 0)
                 {   
                 appSize=0;
                appointment = new Required_Appointment__c();
                appointment.Generate_Appointment_Order__c = ordID;
                appointment.Generate_Appointment_Subscription__c = subID; //EDGE - 75002
                appointment.Appointment_BOM_ID__c = appointRes.data.bomID;
                appointment.required_AppointmentCount__c = appointRes.data.numberOfAppointmentsRequired ;
                appointmentList.add(appointment);
                  }
                 else {appSize= appointRes.data.requiredAppointments.size();}
            
            for(Integer i=0; i<appSize;i++){
                appointment = new Required_Appointment__c();
                appointment.Generate_Appointment_Order__c = ordID;
                appointment.Generate_Appointment_Subscription__c = subID; //EDGE - 75002
                appointment.Appointment_BOM_ID__c = appointRes.data.bomID;
                appointment.required_AppointmentCount__c = appointRes.data.numberOfAppointmentsRequired ;
                appointment.array_ItemNumber__c = appointRes.data.requiredAppointments[i].arrayItemNumber;
                appointment.Appointment_Category__c = appointRes.data.requiredAppointments[i].appointmentCategory;
                appointment.Appointment_SubType__c = appointRes.data.requiredAppointments[i].appointmentSubType;
                appointment.Appointment_Type__c = appointRes.data.requiredAppointments[i].appointmentType;
                      //EDGE - 66462, <Pradeep>         
               if(appointRes.data.requiredAppointments[i].dependencies!=null){
                 appointment.LeadTime_Days__c = appointRes.data.requiredAppointments[i].dependencies[0].leadTimeDaysApplied;             
                 appointment.Dependencies__c=String.valueOf(appointRes.data.requiredAppointments[i].dependencies);                
                 appointment.dependent_ArrayItemNumber__c=appointRes.data.requiredAppointments[i].dependencies[0].dependentArraryItemNumber ;
                          }       
               
               
                appointment.Minimum_StartDate__c = Date.valueOf(appointRes.data.requiredAppointments[i].minimumStartDate);
                    appointment.Request_Time__c = Date.valueOf(appointRes.restime);
                appointment.Sequence_of_Appointment__c = String.valueOf(appointRes.data.requiredAppointments[i].arrayItemNumber);
                appointment.Suggested_StartDate__c = Date.valueOf(appointRes.data.requiredAppointments[i].suggestedStartDate);
                appointment.Transaction_Reference_ID__c = appointRes.data.transactionReferenceID;
                //EDGE - 75002, AC1 Retrieve baseRuleProducts array
                if(appointRes.data.requiredAppointments[i].baseRuleProducts!=null){
                    appointment.baseRuleProducts__c = getBaseRuleProductsJson(appointRes.data.requiredAppointments[i].baseRuleProducts);
                }
                system.debug('appointment++' +appointment);
                appointmentList.add(appointment);
            }
            System.debug('appointmentList::' + appointmentList);
            insert appointmentList;
           csord__Order__c ordApptReq = [Select id,isAppointmentRequired__c from csord__Order__c where id=:ordID];

            if(!appointmentList.isEmpty()){
                 ordApptReq.isAppointmentRequired__c = 'true';
            }else{
            ordApptReq.isAppointmentRequired__c = 'false';
            }
            update ordApptReq;
            system.debug('ordApptReq.isAppointmentRequired__c' +ordApptReq.isAppointmentRequired__c);

        } 
        
         for(Required_Appointment__c appt:appointmentList){
             if(appt.Appointment_Category__c==telstra){
                 dt=appt.Suggested_StartDate__c;
                 break;
             }
         }
        // return String.valueOf(dt);
        }

    
        public static String getSuggestedDate(String subID, String apptCategory){
            system.debug('apptCategory++' +apptCategory +subID);
            String appntCat = apptCategory.substringBefore('+');
                system.debug('AppntCat ++' +appntCat );
            Required_Appointment__c reqApp =[Select id,Appointment_Category__c,Generate_Appointment_Subscription__c,Suggested_StartDate__c from Required_Appointment__c where Generate_Appointment_Subscription__c =:subID and Appointment_Category__c=:appntCat ORDER BY createdDate DESC limit 1];
            system.debug('reqApp++' +reqApp);
            
                suggDate=reqApp.Suggested_StartDate__c;
        
            system.debug('suggDate++**' +suggDate);
            return string.valueOf(suggDate);
        }
    
//Callout
    public static HttpResponse bookAppointment(String subsID,
    AppointmentRequestDTO appoint, String token){
         Map<String,ResponseWrapper> addressToResponseMap = new Map<String,ResponseWrapper>();
        String reqBody = JSON.serialize(appoint,true);
        system.debug('reqBody++' +reqBody);
        Logger2 logger = Logger2.getLogger(handler);
        AppointmentResponseDTO appointRes = new AppointmentResponseDTO();
        HttpResponse adResponse = new HttpResponse();
        try {
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token, 'callingSystemID' => 'COM-B2B-FORCE'};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handler);
            system.debug('adResponse::'+adResponse.getBody());
            
        } 

        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        return adResponse;
    }

 //Wrapper to insert Application log
    public class ResponseWrapper{
        public String reqBody {get;set;}
        public String adRes {get;set;}
        public Integer statusCode {get;set;}
        
        public ResponseWrapper(String reqBody,String adRes,Integer statusCode){
            this.reqBody = reqBody;
            this.adRes = adRes;
            this.statusCode = statusCode;
        }
    }
    
    
 /*------------------------------------------------------------ 
Author: Pradeep 
Description: Order Next avaliable status if Appointment not Required 
------------------------------------------------------------*/

public static void nextOrderStatus(String OrderId)
{
List<RecordType> orderRecordTypeList =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
Map<String, Id> orderRecordTypeNameToIdMap = new Map<String, Id>();
for(RecordType recTypeInstance : orderRecordTypeList){
orderRecordTypeNameToIdMap.put(recTypeInstance.Name, recTypeInstance.Id);      
}
            
Map<Id, csord__Order__c> primaryOrderForSubmitMap = new Map<Id, csord__Order__c>();

List<csord__Order__c> appPrimaryOrd= [select id,name from csord__Order__c where id=:OrderId];   


OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(appPrimaryOrd, 'Ready for Submit', orderRecordTypeNameToIdMap.get('Ready for Submit'));

}
    
    
    /*------------------------------------------------------------ 
Author: Kalashree 
US: EDGE - 75002 AC1 
Description: Function to store baseRuleProd array
------------------------------------------------------------*/
    //EDGE - 75002 AC1
    public static String getBaseRuleProductsJson(List<AppointmentResponseDTO.BaseRuleProducts> baseRuleProdList){
        
        List<Object> onlst = (List<Object>)baseRuleProdList;
        String baseRuleProdJson=JSON.serialize(onlst);
        system.debug('baseRuleProdJson+' +baseRuleProdJson);
        return baseRuleProdJson;
    }

}
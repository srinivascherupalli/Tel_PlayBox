/*Author: Ila/Aishwarya/Jawahar/Ravi
Company: Tesltra 
User Story :EDGE-66226/66239/66474/70304
*/
public with sharing class GenerateAppointmentHandler {
    
    public Date sugDate {get;set;}
    public Date toDate {get;set;}
    public Date fromDate {get;set;}
    public Integer timesRefreshed { get; set; }
    public String appointmentTitle {get;set;}
    public boolean renderReschedulePanel {get;set;} //variable to be used for rendered property
    public boolean renderRebookPanel {get;set;} //variable to be used for rendered property
    public String selectedRescheduleInitiator {get;set;}    //variable to store the value of reschedule initiator dropdown value
    public String selectedRescheduleReason {get;set;}   //variable to store the value of reschedule reason dropdown value
    public Boolean rescheduleReasonValidation {get;set;}
    public List<Selectoption> rescheduleInitiators {get;set;}
    public List<Selectoption> rescheduleReasons {get;set;}
    public Date OrderStartDateForRescheduleAppointment {get; set;}
    public String originalApptId {get;set;} //variable to store Appointment ID TAPTxxx for reschedule scenario
    public String parentApptId {get;set;}
    public String appointmentOperation {get;set;}
    public String subscriptionIDGlobal {get;set;}    //holds the value of Config Id passed from the URL
    public Date startDate{get;set;}
    public String stDate;
    public String Categoryapp {get;set;}
    public String appunescaped {get;set;}
    public Boolean isEnriched{get;set;} //variable to handle hide/show for scenario if appointment is created/already created
    public String isEnrichedText{get;set;}
    public Boolean isRescheduled {get;set;} //variable to be used for rendered property 
    public Boolean isRebook {get;set;} //variable to be used for rendered property
    public Boolean showAppDetail {get;set;} //variable to handle hide/show for static appt details screeen
    public String appointmentId {get;set;}  //holds the value of appointmentID
    public String popupTitle {get;set;} //Title for Popup on click of confirm button
    public String popupMessage {get;set;}   //Message for popup on click of confirm button
    public Map<String,String> appDetails {get;set;} //holds the value of appointment details if already created
    public AppointmentSearchResponseDTO detailsList{get;set;}
    public AppointmentBOMReserveResponseDTO reserveResponse{get;set;}
    public class SlotWrapper{
        public String startDate{get;set;}
        public Map<String,String> slotDetail{get;set;}
    }
    public boolean blockConfirmBtn{get;set;}    //variable to be used for rendered property
    public boolean displayPb2{get;set;} //variable to handle hide/show
    public boolean displayOP{get;set;}  //variable to handle hide/show
    public String causeEventReason{get;set;}    //holds the value of CauseReason to be displayed on VF
    public Boolean isCauseEvent{get;set;}   //variable to handle causeEvent scenario
    public String hasMessageString {get;set;}
    public String apptErrorMsg {get;set;}
    public Boolean areSlotsAvailable{get;set;}  //variable to be used for rendered property
    //public string areSlotsAvailable{get;set;}  //variable to be used for rendered property
    public List<SlotWrapper> finalSlotWrapperList{get;set;} //this holds the value of the wrapper for the slots displayed on VF
    public String isCauseEventText{get;set;}
    public string notes{get;set;}       //holds the value of Notes from VF
    public string selectedSlotId{get;set;}  //holds the value of the Slot selected by user on VF
    
    //Mahima- changed the date component
    public string startDateDisplay{get;set;}
    public string toDateDisplay{get;set;}
    
    public GenerateAppointmentHandler(){
        //Fetch the subscription ID and operation from the url
        String unescapedParamID = ApexPages.currentPage().getParameters().get('id');
        String unescapedParamOperation = ApexPages.currentPage().getParameters().get('operation');
        String unescapedParamCategory = ApexPages.currentPage().getParameters().get('Category');
        system.debug('unescapedParamOperation++' +unescapedParamOperation);
        //Assing the subscription Id and operation to the global variables
        subscriptionIDGlobal = EncodingUtil.urlEncode(unescapedParamID,'UTF-8');
        appointmentOperation = EncodingUtil.urlEncode(unescapedParamOperation,'UTF-8');
        Categoryapp = EncodingUtil.urlEncode(unescapedParamCategory,'UTF-8');
        //String stDate = ApexPages.currentPage().getParameters().get('fromDate'); startDate
        
        //EDGE-66437- end
        System.debug('unescapedParamOperation: '+unescapedParamOperation);
        if(unescapedParamOperation=='Reschedule' || unescapedParamOperation=='FollowOn')
        {            
            string apptId = ApexPages.currentPage().getParameters().get('ApptId');
            appunescaped=EncodingUtil.urlEncode(apptId,'UTF-8');
            List<Appointment__c> app= [SELECT StartDate__c,Reschdeule_required__c,Suggested_Start_Date__c from Appointment__c where SlotId__c=:appunescaped ];
            //EDGE-66476
            DateTime startdate=DateTime.now(); 
            if(app!=null && app.size()>0)
            {
                if(app[0].Reschdeule_required__c!=null && app[0].Reschdeule_required__c)
                {
                    Integer d = app[0].Suggested_Start_Date__c.day();
                    Integer mo = app[0].Suggested_Start_Date__c.month();
                    Integer yr = app[0].Suggested_Start_Date__c.year(); 
                    startdate=  DateTime.newInstance(yr, mo, d);
                }
                else
                {
                    startdate=  app[0].StartDate__c;
                }
            }
            sugDate=startdate.date();
            //Mahima- changed the date component
            system.debug('startdate'+startdate);
            startDateDisplay = startDate.format('dd/MM/yyyy');
        }
        //EDGE-66437- end
        else
        {
            
            stDate = ApexPages.currentPage().getParameters().get('fromDate');
            DateTime startDate= DateTime.valueOf(stDate);
            system.debug('stDate+++' +startDate);            
            sugDate=Date.valueOf(stDate);
            system.debug('sugDate__' +sugDate);
            //Mahima- changed the date component
            startDateDisplay = startDate.format('dd/MM/yyyy');
        }
        
        blockConfirmBtn=false;       
        
        system.debug('sugDate__' +sugDate);
        

        /*if(sugDate == null) {
system.debug('Search appointment cons');
Apexpages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No appointments required, please select another site'));
}*/
        OrderStartDateForRescheduleAppointment=CalcOrderStartDateForRescheduleAppointment(subscriptionIDGlobal);
        secondaryConstructor(subscriptionIDGlobal);
    }
    
    
    //handling the remaining part of the above constructor in different method to tackle the test class execution
    public void secondaryConstructor(String subscriptionID){
        try{
            isEnriched=false;
            isEnrichedText='false';
            showAppDetail = false;
            areSlotsAvailable=false;
            isRescheduled = false;
            isRebook = false;
            system.debug('<><><> Appt Operation ' + appointmentOperation);
             String Catstring = Categoryapp.substringbefore('+');
            
            if(appointmentOperation == 'Reschedule' && !isRescheduled){
                appointmentTitle = 'RESCHEDULE APPOINTMENT';
                for(Appointment__c appt: [SELECT SlotId__c,Category__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal AND Category__c= : Catstring ]){
                    originalApptId = appt.SlotId__c;
                }
                renderReschedulePanel = true;
                Set<String> rescheduleApptSet = new Set<String>();
                for(EWOMRescheduleAppointment__c apt : [SELECT name, Initiated_By__c from EWOMRescheduleAppointment__c order by Initiated_By__c asc]){
                    rescheduleApptSet.add(apt.Initiated_By__c);
                }
                rescheduleReasons = new List<Selectoption>();
                rescheduleReasons.add(new SelectOption('--None--','--None--'));
                
                rescheduleInitiators = new List<Selectoption>();
                rescheduleInitiators.add(new SelectOption('--None--','--None--'));
                for(String reschInit :  rescheduleApptSet){
                    rescheduleInitiators.add(new SelectOption(reschInit,reschInit));
                }
                displayPb2=false;
                timesRefreshed = 0;
                displayOP=false;
                
                isCauseEvent=false;
                isCauseEventText = 'false';
                
            }else if(appointmentOperation == 'Reschedule' && isRescheduled){
                appointmentTitle = 'RESCHEDULE APPOINTMENT';
                checkForExistingAppointment(subscriptionID);
                getAppoinmentDetails(subscriptionID);
            }
            else if(appointmentOperation == 'FollowOn' && !isRebook){
                appointmentTitle = 'REBOOK APPOINTMENT';
                checkForExistingAppointment(subscriptionID);
                getAppoinmentDetails(subscriptionID);
                renderRebookPanel = true;
                isEnriched=false;
                isEnrichedText = 'false';
                 for(Appointment__c appt: [SELECT SlotId__c,Category__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal AND Category__c =: Catstring ]){
                    parentApptId = appt.SlotId__c;
                    system.debug('<><><> Enrichstatus ' + isEnriched);
                }
                if(isEnriched){getAppoinmentDetails(subscriptionID);}
                else{
                    displayPb2=false;
                    timesRefreshed = 0;
                    displayOP=false;
                    
                    isCauseEvent=false;
                    isCauseEventText = 'false';
                    
                }
            }
            else{
                appointmentTitle = 'SCHEDULE APPOINTMENT';
                renderReschedulePanel = false;
                /*checkForExistingAppointment(subscriptionID);
                if(isEnriched){getAppoinmentDetails(subscriptionID);}
                else{
                    displayPb2=false;
                    timesRefreshed = 0;
                    displayOP=false;
                    
                    isCauseEvent=false;
                    isCauseEventText = 'false';
                    
                }*/
            }
            
            
            
        }catch(Exception e){
            system.debug('Exception in secondaryConstructor ' + e);
            system.debug('<><><> Enrichstatus ' + isEnriched);
        }
    }
    //EDGE-66437
    public PageReference loadRescheduleReasonList(){
        rescheduleReasons = new List<Selectoption>();
        rescheduleReasons.add(new SelectOption('--None--','--None--'));
        if(selectedRescheduleInitiator == '--None--'){
            
        }else{
            for(EWOMRescheduleAppointment__c apt : [SELECT name, Initiated_By__c,RescheduleReason__c,RescheduleReasonCode__c from EWOMRescheduleAppointment__c where Initiated_By__c =: selectedRescheduleInitiator order by RescheduleReason__c asc]){
                rescheduleReasons.add(new Selectoption(apt.RescheduleReasonCode__c,apt.RescheduleReason__c));
            }    
        }
        return null;
    }
    public PageReference searchAppointments(){
        areSlotsAvailable=false;
        //areSlotsAvailable = null;
        blockConfirmBtn=false;
        displayOP = false;
        displayPb2=false;
        hasMessageString = 'false';
        selectedSlotId=null;
        
        //Mahima- changed the date component
        string startDateP=Apexpages.currentPage().getParameters().get('startDateP');
        string toDateP= Apexpages.currentPage().getParameters().get('toDateP');
        system.debug(toDateP);
        if(startDateP!= null && startDateP!='')
        {
            system.debug('startDateP==>'+startDateP);
            List<string> datebreak=startDateP.split('/');
            sugDate= date.newInstance(integer.valueOf(datebreak[2]), integer.valueOf(datebreak[1]), integer.valueOf(datebreak[0]));
        }
        
        if(startDateP =='' || sugDate == NULL){
            //rescheduleReasonValidation = false;
            //fromDateValidation =true;
            hasMessageString = 'true';
            apptErrorMsg = 'From Date is mandatory for search.';
        }
        else if(appointmentOperation == 'Reschedule' && (selectedRescheduleInitiator == '--None--' || selectedRescheduleReason == '--None--')){
            hasMessageString = 'true';
            apptErrorMsg = 'Reschedule Appointment and Reason are mandatory for search.';
        }            
        
     else if(appointmentOperation=='Schedule'){
         system.debug('Search appointment1');
         system.debug('appointmentOperation++' +appointmentOperation);
            system.debug('Search appointment2');
            appointmentTitle = 'SCHEDULE APPOINTMENT';
                map<id,id> ordermap =new map<id,id>();
                map<id,id> sitevalue =new map<id,id>();
                AppointmentSearchRequestDTO slotRequestDTO = new AppointmentSearchRequestDTO();
                AppointmentSearchRequestDTO.Data appointReq  = new AppointmentSearchRequestDTO.Data();
                AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
                AppointmentSearchRequestDTO.Place place  = new AppointmentSearchRequestDTO.Place();
                csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
                ordermap.put(Subscription.csord__order__r.id,Subscription.csord__order__r.id);
                sitevalue.put(Subscription.Site__r.id,Subscription.Site__r.id);
                cscrm__Site__c  site = [SELECT id,name,AdborID__c from cscrm__Site__c where id IN: sitevalue.keyset() ];
                string orderNumber = Subscription.Primary_Order__r.id ;
                string subscriptionId = Subscription.id;
                system.debug('Order Id --->>>>'+Subscription.Primary_Order__r.id);
                system.debug('Subscription Id -->>>>'+Subscription.id); 
                system.debug('Categoryapp -->>>>'+Categoryapp); 
                String Catstring = Categoryapp.substringbefore('+');
                Catstring =Catstring.trim();
              Required_Appointment__c reqAppointment= new Required_Appointment__c();
                List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1]; 
                
                if(lstReqAppointment!= null && lstReqAppointment.size()>0)
                    reqAppointment=lstReqAppointment[0];
                
                //Required_Appointment__c reqAppointment = [select id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id order by createdDate DESC limit 1]; 
                //Required_Appointment__c reqAppointment =[select id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c,Generate_Appointment_Order__c from Required_Appointment__c where Generate_Appointment_Order__c ='a4b2O0000004JVhQAM' and  Generate_Appointment_Subscription__c ='a4g2O0000005l8MQAQ']; 
                system.debug('Required Appoint__>>>>'+reqAppointment);
                
                
                //Datetime fromDateTime = fromDate;
                Datetime fromDateTime = sugDate;
                
               
                 //Mahima- changed the date component
                 system.debug('toDateP==>'+toDateP);
                if(toDateP!= null && toDateP!='')
                {
                  List<string> datebreak=toDateP.split('/');
                    toDate= date.newInstance(integer.valueOf(datebreak[2]), integer.valueOf(datebreak[1]), integer.valueOf(datebreak[0]));
                }               
                Datetime toDateTime = toDate;
                system.debug('toDate==>'+toDate);
                
                appoint.searchStartDate = fromDateTime.format('dd-MM-yyyy\'T\'HH:mm:ss');
                if(toDate==null){
                appoint.searchEndDate = (fromDateTime.addDays(45)).format('dd-MM-yyyy\'T\'HH:mm:ss');    
                }else{
                appoint.searchEndDate = toDateTime.format('dd-MM-yyyy\'T\'HH:mm:ss');
                }
                appointReq.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c; //EDGE-90307 QA2 issue fix
                appointReq.bomID=reqAppointment.Appointment_BOM_ID__c;
                slotRequestDTO.correlationId = EDISSingleManager.getUID();
                string appointmentCat = reqAppointment.Appointment_Category__c;
                if(appointmentCat=='TELSTRA'){
                    appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
                    place.id = site.AdborID__c;
                    place.type = 'ADBOR_ID';
                    appoint.Place=place;
                }
                if(appointmentCat =='NBN'){
                    appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
                    List<Service_Qualification__c> serviceQualification = [SELECT id,name,Location_ID__c from Service_Qualification__c where Site__c =: site.id limit 1];
                    if(!serviceQualification.isEmpty()){
                    place.id = serviceQualification[0].Location_ID__c;
                    }
                    //place.id=4564656;  
                    place.type = 'NBN_LOCATION_ID';
                    appoint.Place=place;
                }
                //appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
                appoint.appointmentType = reqAppointment.Appointment_Type__c;
                appoint.appointmentSubType = reqAppointment.Appointment_SubType__c;
                appoint.priority ='STANDARD';
                appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                
                if(toDate==null){
                    appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                
                //place.id = Integer.valueof(site.AdborID__c);
                //place.type = 'ADBOR_ID';
                //appoint.Place=place;
                appointReq.Appointment =appoint;
                slotRequestDTO.data = appointReq ;
                system.debug('Schedule RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
                detailsList=BOMAppointmentService.searchAppointment(slotRequestDTO);
            }
            /*------------------------------------------------------------ 
//EDGE -66475/44669 
Description: Rebook Appointment BOM 
<24-04-2019> <Ila><Jawahar>
------------------------------------------------------------*/
            else if(appointmentOperation=='FollowOn'){
                AppointmentBOMRebookSearchRequestDTO slotRequestDTO = new AppointmentBOMRebookSearchRequestDTO();
                AppointmentBOMRebookSearchRequestDTO.Data appointReq  = new AppointmentBOMRebookSearchRequestDTO.Data();
                AppointmentBOMRebookSearchRequestDTO.Appointment appoint  = new AppointmentBOMRebookSearchRequestDTO.Appointment();
                AppointmentBOMRebookSearchRequestDTO.Reason reason= new AppointmentBOMRebookSearchRequestDTO.Reason();
                map<id,id> ordermap =new map<id,id>();
                map<id,id> sitevalue =new map<id,id>();
                
                csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
                ordermap.put(Subscription.csord__order__r.id,Subscription.csord__order__r.id);
                sitevalue.put(Subscription.Site__r.id,Subscription.Site__r.id);
                cscrm__Site__c  site = [SELECT id,name,AdborID__c from cscrm__Site__c WHERE id IN: sitevalue.keyset() ];
                string orderNumber = Subscription.Primary_Order__r.id ;
                string subscriptionId = Subscription.id;
                system.debug('Order Id --->>>>'+Subscription.Primary_Order__r.id);
                system.debug('Subscription Id -->>>>'+Subscription.id); 
                
                String Catstring = Categoryapp.substringbefore('+');
                Required_Appointment__c reqAppointment= new Required_Appointment__c();
                
                List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1];
                if(lstReqAppointment!= null && lstReqAppointment.size()>0)
                    reqAppointment= lstReqAppointment[0];
                system.debug('Required Appoint__>>>>'+reqAppointment);
                
                
                //Datetime fromDateTime = fromDate;
                Datetime fromDateTime = sugDate;                
                
              //Mahima- changed the date component
               system.debug('toDateP==>'+toDateP);
                if(toDateP!= null && toDateP!='')
                {
                  List<string> datebreak=toDateP.split('/');
                    toDate= date.newInstance(integer.valueOf(datebreak[2]), integer.valueOf(datebreak[1]), integer.valueOf(datebreak[0]));
                }               
                Datetime toDateTime = toDate;
                appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                if(toDate==null){
                    appoint.searchEndDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                appointReq.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c; //EDGE-90307 QA2 issue fix
                slotRequestDTO.correlationId = EDISSingleManager.getUID();
                string appointmentCat = reqAppointment.Appointment_Category__c;
                
                appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
                reason.rebookReasonCode = '99';
                reason.note = 'Customer was not happy to open the cabinet at that time';
                appointReq.Reason=reason;
                
                
                appoint.priority ='STANDARD';
                appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                
                if(toDate==null){
                    appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                
                appointReq.Appointment =appoint;
                slotRequestDTO.data = appointReq ;
                
                system.debug('Rebook FollowOn RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
                for(Appointment__c appt: [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal and Category__c =: Catstring]){
                    parentApptId = appt.SlotId__c;
                    //parentApptId = appt.SlotId__c.substringBefore('_'); //Remove Substring
                    system.debug('<><><> Enrichstatus ' + isEnriched);
                }
                detailsList=BOMAppointmentService.searchRebookAppointment(slotRequestDTO,parentApptId);
            }            
            else if(appointmentOperation=='Reschedule'){//ravi EDGE-70303
                AppointmentSearchRequestDTO slotRequestDTO = new AppointmentSearchRequestDTO();
                AppointmentSearchRequestDTO.Data appointReq  = new AppointmentSearchRequestDTO.Data();
                AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
                AppointmentSearchRequestDTO.Reason reason= new AppointmentSearchRequestDTO.Reason();
                map<id,id> ordermap =new map<id,id>();
                map<id,id> sitevalue =new map<id,id>();
                List<EWOMRescheduleAppointment__c> ewomCS = EWOMRescheduleAppointment__c.getall().values();
                
                csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
                ordermap.put(Subscription.csord__order__r.id,Subscription.csord__order__r.id);
                sitevalue.put(Subscription.Site__r.id,Subscription.Site__r.id);
                //cscrm__Site__c  site = [select id,name,AdborID__c from cscrm__Site__c where id IN: sitevalue.keyset() ];
                string orderNumber = Subscription.Primary_Order__r.id ;
                string subscriptionId = Subscription.id;
                system.debug('Order Id --->>>>'+Subscription.Primary_Order__r.id);
                system.debug('Subscription Id -->>>>'+Subscription.id); 
                
                String Catstring = Categoryapp.substringbefore('+');
                
                list<Required_Appointment__c> reqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1];
                //system.debug('Required Appoint__>>>>'+reqAppointment);
                
                
                Datetime fromDateTime = sugDate;    
                //Mahima- changed the date component
                system.debug('toDateP==>'+toDateP);
                if(toDateP!= null && toDateP!='')
                {
                  List<string> datebreak=toDateP.split('/');
                    toDate= date.newInstance(integer.valueOf(datebreak[2]), integer.valueOf(datebreak[1]), integer.valueOf(datebreak[0]));
                }               
                Datetime toDateTime = toDate;
                appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                if(toDate==null){
                    appoint.searchEndDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                appointReq.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c; //EDGE-90307 QA2 issue fix
                slotRequestDTO.correlationId = EDISSingleManager.getUID();
                if(reqAppointment != null && reqAppointment.size()>0){
                    string appointmentCat = reqAppointment[0].Appointment_Category__c;
                    appoint.appointmentCategory =reqAppointment[0].Appointment_Category__c;  
                }
                reason.rescheduleReasonCode = selectedRescheduleReason;
                for(EWOMRescheduleAppointment__c rec: ewomCS){
                    if(selectedRescheduleReason == rec.RescheduleReasonCode__c){
                        reason.note = rec.RescheduleReason__c;
                    }
                }
                appointReq.Reason=reason;                   
                appoint.priority ='STANDARD';
                appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                
                if(toDate==null){
                    appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }   
                appointReq.Appointment = appoint;
                slotRequestDTO.data = appointReq;   
                system.debug('Rebook FollowOn RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
                
            for(Appointment__c appt: [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal and Category__c =: Catstring ]){
                 //parentApptId = appt.SlotId__c.substringBefore('_');    //Comment this  Before deployment              
                    parentApptId = appt.SlotId__c; //Uncomment Before deployment
                 
                    system.debug('<><><> Enrichstatus ' + isEnriched);
                }
                detailsList=BOMAppointmentService.searchReschedAppointment(slotRequestDTO,parentApptId);
            } 
          if(hasMessageString != 'true'){                
            if(checkSlotsNotAvailable(detailsList))
            {
                hasMessageString = 'true';
                apptErrorMsg = Label.AppointmentUnavailable;
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.AppointmentUnavailable);
                //ApexPages.addMessage(myMsg);
            }
            else{
                areSlotsAvailable=true;
                displayPb2=true;
                displayOP=true;
                isCauseEventText = 'false';
                finalSlotWrapperList = populateSlotWrapper(detailsList);
                /* if(isCauseEvent){
hasMessageString = 'true';
apptErrorMsg = Label.CauseEventReason.replace('<causeEventReason>', causeEventReason);
//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.CauseEventReason.replace('<causeEventReason>', causeEventReason));
//ApexPages.addMessage(myMsg);
}*/
            }    
        }
        system.debug('areSlotsAvailable-->>>>'+areSlotsAvailable);
        return null;
    }
    
    public boolean checkSlotsNotAvailable(AppointmentSearchResponseDTO responseDTO){
        if(responseDTO!=null && responseDTO.data != null && responseDTO.data.availableSlots != null)
        {
            return responseDTO.data.availableSlots.isEmpty(); 
            
        }
        return true;
    }
    /*Method to populate the List of Wrapper class to cater the scenario - to have multiple slots displayed within a single date
* as opposed to the response that has single slot - single date data structure
*/
    public List<SlotWrapper> populateSlotWrapper(AppointmentSearchResponseDTO responseDTO){
        System.debug('Response DTO '+responseDTO);
        List<SlotWrapper> finalSlotWrapperList = new List<SlotWrapper>();
        AppointmentSearchResponseDTO.Data data = responseDTO.data;
        List<SlotWrapper> slotWrapperList = new List<SlotWrapper>();
        try{
            for(AppointmentSearchResponseDTO.AvailableSlots availableSlot : data.availableSlots){
                SlotWrapper slot = new SlotWrapper();
                Datetime dt1 = Datetime.valueOf(availableSlot.startDate.replace('T', ' '));
                slot.startDate = dt1.format('EEEE') + ', ' + dt1.format('dd/MM/yyyy');
                //String startTime = availableSlot.startDate.split('T')[1].left(5);
                String startTime = '' + Datetime.valueOf(availableSlot.startDate.replace('T', ' ')).format('hh:mm a');
                //String endTime = availableSlot.endDate.split('T')[1].left(5);
                String endTime = '' + Datetime.valueOf(availableSlot.endDate.replace('T', ' ')).format('hh:mm a');
                Map<String,String> slotMap = new Map<String,String>();
                slotMap.put(availableSlot.slotID,startTime+' to ' + endTime);
                slot.slotDetail = slotMap;
                slotWrapperList.add(slot);
                system.debug('slot'+slot);
            }
            for(SlotWrapper slot : slotWrapperList){
                SlotWrapper resultSlot = new SlotWrapper();
                String startDate = slot.startDate;
                resultSlot.startDate = slot.startDate;
                resultSlot.slotDetail = new Map<String,String>();
                String slotId = slot.slotDetail.keySet()+'';
                for(String key : slot.slotDetail.keySet()){
                    resultSlot.slotDetail.put(key,slot.slotDetail.get(key));
                }
                for(SlotWrapper innerSlot : slotWrapperList){
                    String innerSlotId = innerSlot.slotDetail.keySet()+'';
                    if(innerSlot.startDate == startDate && innerSlotId!=slotId){
                        for(String key : innerSlot.slotDetail.keySet()){
                            resultSlot.slotDetail.put(key,innerSlot.slotDetail.get(key));
                        }
                    }
                }
                Boolean flag = true;
                for(SlotWrapper slotWrapperFinal : finalSlotWrapperList){
                    if(startDate.equals(slotWrapperFinal.startDate)){
                        flag = false;
                        break;
                    }
                }
                if(flag){
                    finalSlotWrapperList.add(resultSlot);    
                }
            }
            checkCauseEvent(responseDTO);
            system.debug('finalSlotWrapperList'+finalSlotWrapperList);
            
            return finalSlotWrapperList;
        }catch(Exception e){
            system.debug('Exception in populateSlotWrapper ' + e);
            return finalSlotWrapperList;
        }
    }
    
    /* Method to check if the response received has any Cause Event block. If yes, populate the fields on the controller
*/
    public void checkCauseEvent(AppointmentSearchResponseDTO responseDTO){
        try{
            if(responseDTO!= null && responseDTO.data!=null && responseDTO.data.causeEvent!=null){
                AppointmentSearchResponseDTO.CauseEvent causeEvent = responseDTO.data.causeEvent;
                if(causeEvent.eventReason!= null && causeEvent.eventReason!= ''){
                    isCauseEvent = true;
                    isCauseEventText = 'true';
                    causeEventReason = causeEvent.eventReason;
                }
            }
        }catch(Exception e){
            system.debug('Exception in checkCauseEvent ' + e);
        }
    }
    public PageReference clearBottomSection(){
        displayOP = false;
        displayPb2=false;
        return null;
    } 
    public PageReference switchOfTimerApex() {
        System.debug('Slot id--'+selectedSlotId);
        selectedSlotId=null;
        blockConfirmBtn=true;
        return null;
        
    }
    public PageReference setSlotId() {
        System.debug('Slot id--'+selectedSlotId);
        return null;
        
    }
   
    /* Method to create Appointment Record once BOM sends 200/201 response for Schedule Reserve operation
*/
    public String createAppointmentRecord(String slotId, String appointmentID,String appointmentCat,String subID,String appointmentOperation){
        try{
            system.debug('In createAppointmentRecord');
            String apptId;
            String startDate = null;
            String endDate = null ;
            String startDateText = '';
            String endDateText = '';
             String Catstring = Categoryapp.substringbefore('+');
            AppointmentSearchResponseDTO.Data data = detailsList.data;
            for(AppointmentSearchResponseDTO.AvailableSlots availableSlot : data.availableSlots){
                if(availableSlot.slotID == slotId){
                    startDate = availableSlot.startDate.replace('T', ' ');
                    startDateText = availableSlot.startDate;
                    endDate = availableSlot.endDate.replace('T', ' ');
                    endDateText = availableSlot.endDate;
                    break;
                }
            }
            csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
            
            //Required_Appointment__c reqAppointment = [select id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id ORDER BY createdDate limit 1];//ORDER BY createdDate limit 1
            
            Appointment__c appList = new Appointment__c();
            if(appointmentOperation == 'FollowOn'){
                appList  = [SELECT SlotId__c,Status__c,Category__c from Appointment__c where Subscription__c =: subID  and Category__c =:Catstring order by CreatedDate DESC limit 1];
            }
            system.debug('Exception in updateAppointmentRecord ' + appList);
            Appointment__c apptRecord = new Appointment__c();
            //apptRecord.Category__c='Telstra Installation'; //Modify this in future for category LOVs
            apptRecord.Category__c=appointmentCat;
            system.debug('create Appt startDate'+ startDate);
            system.debug('create Appt endDate'+ endDate);
            if(startDate!=null){apptRecord.StartDate__c = datetime.valueOf(startDate);apptRecord.StartDateText__c=startDateText;}
            if(endDate!=null){apptRecord.EndDate__c = datetime.valueOf(endDate);apptRecord.EndDateText__c = endDateText;}
            apptRecord.SlotId__c = appointmentID;
            //apptRecord.Subscription__c = subID;
            apptRecord.Notes__c = notes;
            apptRecord.Subscription__c = subID;
            if(appointmentOperation == 'FollowOn'){
                apptRecord.Parent_Appt_ID__c = appList.SlotId__c;
                //apptRecord.Status__c = 'REBOOKED'; //Kalashree, EDGE-86005 Change status of Appointment
            }
           /* else{
                apptRecord.Parent_Appt_ID__c = appointmentID;   
            }*/
            insert apptRecord;
            apptId = apptRecord.id;
            return apptId;
        }catch(Exception e){
            system.debug('Exception in createAppointmentRecord '+ e);
            return '';
        }
    }

    /* Method to fetch appointment details for the screen to display Appointment details if already Enriched
*/
    public void getAppoinmentDetails(String subscriptionID)
    {
        List<Appointment__c> apptList = [SELECT SlotId__c,Category__c,EndDate__c,StartDate__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionID order by SlotId__c Desc];
        for(Appointment__c appt: apptList){
            appDetails = new Map<String,String>();
            appDetails.put('SlotId', appt.SlotId__c);
            appDetails.put('Category', appt.Category__c);
            String appDate = '';
            String appStartTime = '';
            String appEndTime = '';
            //Time appStartTime = null;
            //Time appEndTime = null;
            if(appt.StartDate__c != null)
            {
                appDate = appt.StartDate__c.format('dd/MM/yyyy');
                appStartTime = appt.StartDate__c.format('hh:mm a');
            }
            if(appt.EndDate__c != null)
            {
                appEndTime = appt.EndDate__c.format('hh:mm a');
            }
            appDetails.put('Date', appDate);
            system.debug('*************App'+ appt.StartDate__c+'*******'+appt.EndDate__c+'******'+appt.SlotId__c);
            appDetails.put('StartTime', appStartTime);
            appDetails.put('EndTime', appEndTime);
            break;
        }
    }
    public string getAppStartEndTime(String slotID)
    {
        if(finalSlotWrapperList!= null){
        for(SlotWrapper sw : finalSlotWrapperList)
        {
            if(sw.slotDetail.containsKey(slotID))
            {
                return ' '+ sw.slotDetail.get(slotID)+' on '+sw.startDate +'.';
            }
        }}
        return null;
    }
    /*------------------------------------------------------------------------
     EDGE: 66238
    Description: Method to handle reserveAppointment scenario when user clicks on Confirm button
     <Aishwarya>
-------------------------------------------------------------------------------------*/
    public void reserveAppointment(String slotId,String subscriptionID, String notes){
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        //List<AppointmentBOMReserveRequestDTO.RelatedParty > relatedPartyList = null;
        AppointmentBOMReserveRequestDTO.RelatedParty relatedParty = new AppointmentBOMReserveRequestDTO.RelatedParty();
        AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note();
        
        try{
            if(appointmentOperation=='Schedule'){
                
                csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__order__r.id,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
                system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
                system.debug('Subscription Id -->>>>'+Subscription.id);
                //String subscriptionID=Subscription.id;
                data.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c; 
                String Catstring = Categoryapp.substringbefore('+');
                Required_Appointment__c reqAppointment = new Required_Appointment__c();
                
                List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1]; 
                if(lstReqAppointment!=null && lstReqAppointment.size()>0)
                {
                    reqAppointment= lstReqAppointment[0];
                }
                //Required_Appointment__c reqAppointment = [select id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id ORDER BY createdDate limit 1];//ORDER BY createdDate limit 1
                //relatedPartyList=new List<AppointmentBOMReserveRequestDTO.RelatedParty>();
                if(subscriptionID !=null && subscriptionID !=''){
                    system.debug('Inside if');
                    List<csord__Subscription__c> subList = [SELECT id, csord__Account__c, csord__Account__r.RecordType.Name,csord__Account__r.name,csord__Account__r.Type from csord__Subscription__c where id =:subscriptionID];
                    //for(csord__Subscription__c sub : [select id, csord__Account__c, csord__Account__r.name,csord__Account__r.Type from csord__Subscription__c where id =:subscriptionID]){
                        if( subList != Null && !subList.isEmpty() ){
                        relatedParty.name = subList[0].csord__Account__r.name;
                        relatedParty.type = subList[0].csord__Account__r.RecordType.Name;
                        relatedParty.role='CUSTOMER';
                        //relatedPartyList.add(relatedParty);
                        system.debug('Inside for');
                        }
                    //}
                    //appoint.relatedParty = relatedPartyList;
                    appoint.relatedParty = relatedParty;
                }else{
                    system.debug('ERROR : Subscription ID recevied in AppointmentBookPageHandler.reserveAppointment is null or empty');
                }
                appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
                appoint.appointmentType = reqAppointment.Appointment_Type__c;
                appoint.appointmentSubType = reqAppointment.Appointment_SubType__c;
                appoint.contacts = populateContactForReserveAppointmentAPV2(subscriptionID);
                note.text = notes;
                appoint.note =note;
                data.appointment=appoint;
                reserveDTO.correlationId = EDISSingleManager.getUID();
                reserveDTO.data = data;
                system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
                reserveResponse = BOMAppointmentService.reserveAppointment(reserveDTO, slotId);
            }
            if(reserveResponse!=null && reserveResponse.data !=null ){
                //system.debug('getheader++' +reserveResponse.getHeader('location'));
                //List<String> urlSplit = reserveResponse.getHeader('location').split('/');
                //String appointmentIDLocation='TAPT001529399876SVEU';
                String appointmentIDLocation=reserveResponse.data.appointmentID; //uncomment this before deployment
                //String appointmentIDLocation=reserveResponse.data.appointmentID+'_'+String.valueof(DateTime.now().getTime());//Temp change for EDGE-66476. Comment this before deployment
                //String appointmentIDLocation = urlSplit[urlSplit.size()];
                String appointmentCat=reserveResponse.data.appointmentCategory;
                String apptId = null;
                system.debug('appointmentOperation++' +appointmentOperation);
                if(appointmentOperation=='Schedule'){
                    
                    apptId = createAppointmentRecord(slotId,appointmentIDLocation,appointmentCat,subscriptionID,appointmentOperation);
                    if(apptId!=null){
                        system.debug('slotId' +slotId);
                        system.debug('appointmentIDLocation' +appointmentIDLocation);
                        system.debug('subscriptionID' +subscriptionID);
                        
                        
                        CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                        appointmentId = appointmentIDLocation;
                        createTaskRecords(apptId); //EDGE - 75002 
                        showAppDetail = true;
                        isEnriched=true;
                        isEnrichedText = 'true';
                        getAppoinmentDetails(subscriptionID);
                        popupTitle = 'Booking Successful';
                        popupMessage = Label.AppointmentBooked.replace('<AppId>', appointmentIDLocation) + getAppStartEndTime(selectedSlotId);
                    }else{
                        //need to handle exception for failure in creating appointment record
                        popupTitle = 'Booking Successful';
                        popupMessage = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);   
                    }
                }
            }else{
                //write somethinFailureg to show error while reserving appointment please try again later
                popupTitle = 'Booking Failure ';
                popupMessage = Label.AppointmentFailed;   
                
                displayOP = false;
                displayPb2=false;
            }
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e);
        }
    }
    
    /*---------------------------------------------------------------------------------
     EDGE: 66238
     Description: Method to take primary and secondary contact Details  to reserve Appointment
---------------------------------------------------------------------------------------*/
    
    public List<AppointmentBOMReserveRequestDTO.Contacts> populateContactForReserveAppointmentAPV2(String subscriptionID){
        List<AppointmentBOMReserveRequestDTO.Contacts> contactList = new List<AppointmentBOMReserveRequestDTO.Contacts>();
        //AppointmentBOMReserveRequestDTO.Data.appointment.contacts con = new AppointmentBOMReserveRequestDTO.Data.appointment.contacts();
        try{
            
            Map<Id,String> roleMap = new Map<Id,String>();
            Map<Id,String> roleMapTech = new Map<Id,String>();
            Set<Id> contactIdSet = new Set<Id>();
            
            
            for(csord__service__c servObj : [SELECT Id, Primary_Contact__c, Technical_Contact__c,After_Hours_Site_Contact__c, csordtelcoa__Main_Contact__c,Order_Primary_Contact__c,Site_Delivery_Contact__c,TenancyPrimaryContact__c,Project_Contact__c from csord__service__c where csord__Subscription__c =: subscriptionID and csord__service__c = null]){
                if(servObj.Primary_Contact__c!=null){
                    contactIdSet.add(servObj.Primary_Contact__c);
                    roleMap.put(servObj.Primary_Contact__c, 'PRIMARY');
                }
                if(servObj.Technical_Contact__c!=null ){
                    contactIdSet.add(servObj.Technical_Contact__c);
                    roleMapTech.put( servObj.Technical_Contact__c, 'SECONDARY');
                }
                
                if(servObj.After_Hours_Site_Contact__c!=null ){
                    contactIdSet.add(servObj.After_Hours_Site_Contact__c);
                    roleMapTech.put( servObj.After_Hours_Site_Contact__c, 'SECONDARY');
                }
                
                if(servObj.csordtelcoa__Main_Contact__c!=null ){
                    contactIdSet.add(servObj.csordtelcoa__Main_Contact__c);
                    roleMapTech.put( servObj.csordtelcoa__Main_Contact__c, 'SECONDARY');
                }
                
                if(servObj.Order_Primary_Contact__c!=null ){
                    contactIdSet.add(servObj.Order_Primary_Contact__c);
                    roleMapTech.put( servObj.Order_Primary_Contact__c, 'SECONDARY');
                }
                
                if(servObj.Project_Contact__c!=null ){
                    contactIdSet.add(servObj.Project_Contact__c);
                    roleMapTech.put( servObj.Project_Contact__c, 'SECONDARY');
                }
                
                 if(servObj.Site_Delivery_Contact__c!=null ){
                    contactIdSet.add(servObj.Site_Delivery_Contact__c);
                    roleMapTech.put( servObj.Site_Delivery_Contact__c, 'SECONDARY');
                }
                
                 if(servObj.TenancyPrimaryContact__c!=null ){
                    contactIdSet.add(servObj.TenancyPrimaryContact__c);
                    roleMapTech.put( servObj.TenancyPrimaryContact__c, 'SECONDARY');
                }
            }
            system.debug('roleMap' +roleMap);
            Map<Id, Contact> contactMap= new Map<Id, Contact>([Select Id, Name, Phone, MobilePhone from Contact where Id IN: contactIdSet]);
            
            
            if(contactMap!= null ){
                /*for(Id key : contactMap.keySet()){
                    // for(Functional_Contact_Role__c fContactRole : [select id, Role__c,ContactID__c,SiteID__c from Functional_Contact_Role__c where SiteID__c =:siteID and Role__c =: roleMap.get(key)]){
                    // for(Contact contactRecord : [select id,name,Phone,MobilePhone from Contact where id =:fContactRole.ContactID__c]){
                    
                    // if((contactRecord.Phone!=null && contactRecord.Phone.length()>0) || (contactRecord.MobilePhone!=null && contactRecord.MobilePhone.length()>0)){
                    Contact contactRecord = contactMap.get(key);
                    String contactPhoneNumber = '';
                    if(contactRecord.Phone!=null &&contactRecord.Phone.length()>0){
                        contactPhoneNumber=contactRecord.Phone;
                    }else{
                        contactPhoneNumber=contactRecord.MobilePhone;
                    }
					
					  }*/
					
                    for(ID key:roleMap.keySet())
                    {
                    AppointmentBOMReserveRequestDTO.Contacts contactInstance = new AppointmentBOMReserveRequestDTO.Contacts();
                    contactInstance.fullName = contactMap.get(key).Name;
					if(contactMap.get(key).Phone!=null && contactMap.get(key).Phone.length()>0)
						contactInstance.phoneNumber = ''+contactMap.get(key).Phone;
					else
						contactInstance.phoneNumber = ''+contactMap.get(key).MobilePhone;
                    contactInstance.role = roleMap.get(key); 
                    contactList.add(contactInstance);
                    }
                    
                     for(ID key:roleMapTech.keySet())
                    {
                    AppointmentBOMReserveRequestDTO.Contacts contactInstance = new AppointmentBOMReserveRequestDTO.Contacts();
                    contactInstance.fullName = contactMap.get(key).Name;
                    if(contactMap.get(key).Phone!=null && contactMap.get(key).Phone.length()>0)
						contactInstance.phoneNumber = ''+contactMap.get(key).Phone;
					else
						contactInstance.phoneNumber = ''+contactMap.get(key).MobilePhone;
                    contactInstance.role = roleMapTech.get(key); 
                    contactList.add(contactInstance);
                    }
                    //break;
                    // }
                    //}
                    //}
			
		}
            return contactList;
        }catch(Exception e){
            system.debug('Exception in populateContactForReserveAppointment ' + e);
            return contactList;
        }
    }
    
    //EDGE - 75002, AC2 : Create tasks for the appointment that is generated.
    public void createTaskRecords(String apptId){
        Task__c appTask ;
        List<Task__c> tasksList = new List<Task__c> ();
        Appointment__c appointment = [SELECT Subscription__c,Subscription__r.csord__Order__r.csord__Primary_Order__c FROM Appointment__c WHERE id = :apptId];
        System.debug('appointment'+appointment);
        List<Required_Appointment__c> reqAppointmentList ;
        List<String> baseRuleProdList = new List<String>();
        String Catstring = Categoryapp.substringbefore('+');
        if(appointment.Subscription__r.csord__Order__r.csord__Primary_Order__c!=null){
            reqAppointmentList = [SELECT id,baseRuleProducts__c FROM Required_Appointment__c WHERE Generate_Appointment_Subscription__c = :appointment.Subscription__c AND Generate_Appointment_Order__c=:appointment.Subscription__r.csord__Order__r.csord__Primary_Order__c AND Appointment_Category__c =: Catstring ORDER BY createdDate DESC LIMIT 1];
            System.debug('reqAppointmentList'+reqAppointmentList);
            if(reqAppointmentList!=null && !reqAppointmentList.isEmpty()){
                for(Required_Appointment__c reqApp : reqAppointmentList){
                    if(reqApp.baseRuleProducts__c!=null){
                        baseRuleProdList.add(reqApp.baseRuleProducts__c);
                    }
                }
            }
        }
        if(baseRuleProdList!=null && !baseRuleProdList.isEmpty()){
            List<String> prodInstanceIdList = new List<String> ();
            for(String baserule : baseRuleProdList){
                prodInstanceIdList.add(baserule.substringBetween('"productInstanceID":"','","productID"'));
            }
            if(prodInstanceIdList!=null && !prodInstanceIdList.isEmpty()){
                for(String instanceid : prodInstanceIdList){
                    appTask = new Task__c();
                    appTask.Appointment__c = apptId;
                    appTask.TaskId__c = instanceid;
                    tasksList.add(appTask);
                }
            }
            if(!tasksList.isEmpty()){
                insert tasksList;
            }
        }   
    }  
    
    /*------------------------------------------------------------ 
//EDGE -66470
Method: confirmAppointment 
Description: Initiate Appointment BOM API
Inputs: String
Returns:  
History 
<26-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    
    public void confirmAppointment() {
        system.debug('Selected Slot Id for reserve appointment '+selectedSlotId);
        system.debug('Notes for the selected slot '+notes); 
        //To have parameterised methods
        //selectedSlotId = this.selectedSlotId;
        //notes = this.notes;
        //subscriptionIDGlobal =this.subscriptionIDGlobal;
        //requestType = this.appointmentOperation;
        // system.debug('requestType '+requestType);
        if(appointmentOperation=='Schedule'){
            reserveAppointment(selectedSlotId,subscriptionIDGlobal,notes);
        }
        else if(appointmentOperation=='Reschedule'){
            rescheduleAppointment(selectedSlotId,subscriptionIDGlobal,notes); //EDGE -66470
        }
        else if(appointmentOperation=='FollowOn'){
            rebookAppointment(selectedSlotId,subscriptionIDGlobal,notes);
        }
        
    }
    
    /*EDGE -66474/66451
    Method: RebookAppointment 
    Description: Initiate Appointment BOM API
    History 
    <26-04-2019> <Aishwarya Yeware>
    <06-05-2019> <Mahima Gandhe>  <Added a call to method checkDependencyAppt>
    */
    public void rebookAppointment(String slotId,String subscriptionID, String notes)
    {
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        try
        {
            csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__order__r.id,csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :subscriptionIDGlobal];
            system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
            system.debug('Subscription Id -->>>>'+Subscription.id);
            data.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c;
            String Catstring = Categoryapp.substringbefore('+');
            Required_Appointment__c reqAppointment= new Required_Appointment__c();
            List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1]; 
            if(lstReqAppointment!= null && lstReqAppointment.size()>0)
            {
                reqAppointment=lstReqAppointment[0];
            }
            //Required_Appointment__c reqAppointment = [select id,name,Appointment_BOM_ID__c,Appointment_Category__c,Appointment_Type__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id ORDER BY createdDate DESC limit 1];//ORDER BY createdDate limit 1
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
            //note.text = notes;
            data.appointment=appoint;
            reserveDTO.correlationId = EDISSingleManager.getUID();
            reserveDTO.data = data;
        List<Appointment__c> apptList= [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c,status__c from Appointment__c where Subscription__c = : subscriptionIDGlobal and Category__c =: Catstring ORDER BY createdDate DESC LIMIT 1];
                if(apptList != NULL && apptList.size()>0){
                    //parentApptId = apptList[0].SlotId__c.substringBefore('_'); //comment Before Deployment
                parentApptId = apptList[0].SlotId__c; //Uncomment Before Deployment
                }
                system.debug('<><><> Enrichstatus ' + isEnriched);
            system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
            reserveResponse = BOMAppointmentService.rebookAppointment(reserveDTO,slotId,parentApptId);
            if(reserveResponse.status==200 && reserveResponse.data !=null ){
                String appointmentIDLocation=reserveResponse.data.appointmentID; //uncomment this before deployment
                //String appointmentIDLocation=reserveResponse.data.appointmentID+'_'+String.valueof(DateTime.now().getTime());//Temp change for EDGE-66476. Comment this before deployment
                String appointmentCat=reserveResponse.data.appointmentCategory;

                system.debug('appointmentIDLocation++' +appointmentIDLocation);
                String apptId = null;
                system.debug('appointmentOperation++' +appointmentOperation);
                
                apptId = createAppointmentRecord(slotId,appointmentIDLocation,appointmentCat,subscriptionID,appointmentOperation);
                if(apptId!=null){
                    system.debug('slotId' +slotId);
                    system.debug('appointmentIDLocation' +appointmentIDLocation);
                    system.debug('subscriptionID' +subscriptionID);
                    if(!apptList.isEmpty()){
                         updateParentApptStatus(apptList[0]);//Kalashree EDGE-66474,EDGE-66451 AC5
                    }
                   
                    CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                    appointmentId = appointmentIDLocation;
                        //createTaskRecords(apptId); //EDGE - 75002 
                    showAppDetail = true;
                    isEnriched=true;
                    isEnrichedText = 'true';
                    getAppoinmentDetails(subscriptionID);
                    popupTitle = 'Booking Successful';
                    popupMessage = Label.AppointmentBooked.replace('<AppId>', appointmentIDLocation) + getAppStartEndTime(selectedSlotId);
                    //EDGE-66476- Mahima                     
                    //checkDependencyAppt(reserveResponse, subscriptionID, true);
                    checkDependencyAppt(reserveResponse, subscriptionID, false);
                    System.debug('appointmentIDLocationtest::'+appointmentIDLocation);
                    System.debug('getAppStartEndTimeTest::'+getAppStartEndTime(selectedSlotId));
                }else{
                    //need to handle exception for failure in creating appointment record
                    popupTitle = 'Booking Successful';
                    popupMessage = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);   
                }
                
            }else{
                if(reserveResponse.status!=200 && reserveResponse.code=='1111'){
                    //display: This appointment cannot be rescheduled, try rebooking the appointment to change dates
                    popupTitle = 'Booking Failure';
                    popupMessage = Label.AppointmentRebookMessage;   
                }
                else {
                    
                    //display:Functionality currently unavailable and try again after sometime
                    popupTitle = 'Booking Failure';
                    popupMessage = Label.AppointmentRescheduleError;
                }      
            }
        }
        
        catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e.getStackTraceString());
        }
    }
    
    
    /*------------------------------------------------------------ 
//EDGE -66470
Method: rescheduleAppointment 
Description: Initiate Appointment BOM API
History 
<26-04-2019> <Kalashree Borgaonkar>
<06-05-2019> <Mahima Gandhe><Added a call to method checkDependencyAppt>
------------------------------------------------------------*/
    public  void rescheduleAppointment(String slotId,String subscriptionID, String notes){ //remove static later
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        AppointmentBOMReserveResponseDTO rescheduleResponse;
        //AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note(); //uncomment make changes after Rashmi confirms
        try{
            //EDGE-84675 , added Primary_Order__r.id in the SQOL
            csord__Subscription__c Subscription =[SELECT csord__Order__r.csord__Primary_Order__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where id= :subscriptionID];
            system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
            system.debug('Subscription Id -->>>>'+Subscription.id);
            data.transactionReferenceID = Subscription.Primary_Order__r.csord__Order_Number__c; 
            String Catstring = Categoryapp.substringbefore('+');
            system.debug('Catstring'+Catstring); 
            system.debug('Categoryapp'+Categoryapp);
            Required_Appointment__c reqAppointment= new Required_Appointment__c();
            List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.Primary_Order__r.id and Generate_Appointment_Subscription__c =: Subscription.id and Appointment_Category__c =: Catstring order by createdDate DESC limit 1]; 
            if(lstReqAppointment!= null && lstReqAppointment.size()>0)
            {
                reqAppointment=lstReqAppointment[0];
            }
            //Required_Appointment__c reqAppointment = [select Appointment_Category__c from Required_Appointment__c where Generate_Appointment_Order__c =: Subscription.csord__Order__r.csord__Primary_Order__c and Generate_Appointment_Subscription__c =: Subscription.id ORDER BY createdDate DESC limit 1];
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
            //note.text = notes; uncomment/make changes
            //appoint.note =note; uncomment/make changes
            data.appointment=appoint;
            reserveDTO.correlationId = EDISSingleManager.getUID();
            reserveDTO.data = data;
            String apptId='';
         for(Appointment__c appt: [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal and Category__c =: Catstring ]){
                 apptId = appt.SlotId__c; //uncomment this bedore deployment
                //apptId = appt.SlotId__c.substringBefore('_');//Temp change for EDGE-66476. Comment this before deployment
                system.debug('<><><> Enrichstatus ' + isEnriched);
            }
            system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
            rescheduleResponse = BOMAppointmentService.rescheduleAppointment(reserveDTO, slotId,apptId);    
            if(rescheduleResponse!=null ){
                if(rescheduleResponse.status==200 && rescheduleResponse.data!=null){
                    if(updateAppointmentRecord()){
                        //CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                        system.debug('Update Appointment Record successful after Reschedule');
                        isRescheduled = true;
                        getAppoinmentDetails(subscriptionID);
                        popupTitle = 'Booking Successful';
                        popupMessage = Label.AppointmentBooked.replace('<AppId>', parentApptId) + getAppStartEndTime(selectedSlotId);    
                        //EDGE-66476- Mahima                         
                        //checkDependencyAppt(rescheduleResponse,subscriptionID, true);
                        checkDependencyAppt(rescheduleResponse,subscriptionID, false);
                    }else{
                        system.debug('Update Appointment Record failed after Reschedule');
                        popupTitle = 'Booking Successful';
                        popupMessage = Label.AppointmentConfirmation.replace('<SlotId>', parentApptId);
                    }
                }
                else{
                    if(rescheduleResponse.status!=200 && rescheduleResponse.code=='1111'){
                        //display: This appointment cannot be rescheduled, try rebooking the appointment to change dates
                        popupTitle = 'Booking Failure';
                        popupMessage = Label.AppointmentRebookMessage;   
                    }
                    else {
                        
                        //display:Functionality currently unavailable and try again after sometime
                        popupTitle = 'Booking Failure';
                        popupMessage = Label.AppointmentRescheduleError;
                    }
                } 
            }     
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e.getStackTraceString());
        }
    }
    
    public Boolean updateAppointmentRecord(){
    String Catstring = Categoryapp.substringbefore('+');
        try{
            system.debug('Update the Appointment Record after Reschedule Operation');
            String startDate = null;
            String endDate = null ;
            String startDateText = '';
            String endDateText = '';
            AppointmentSearchResponseDTO.Data data = detailsList.data;
            if(data!= null && data.availableSlots!= null)
            {
            for(AppointmentSearchResponseDTO.AvailableSlots availableSlot : data.availableSlots){
                if(availableSlot.slotID == selectedSlotId){
                    startDate = availableSlot.startDate.replace('T', ' ');
                    endDate = availableSlot.endDate.replace('T', ' ');
                    startDateText = availableSlot.startDate;
                    endDateText = availableSlot.endDate;
                    break;
                }
            }
            }
            List<Appointment__c> updateApptList = new List<Appointment__c>();
            //edge-66476: added Reschdeule_required__c,Suggested_Start_Date__c in the query.
        for(Appointment__c apptRecord: [SELECT Reschdeule_required__c,Suggested_Start_Date__c,SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c,StartDate__c,EndDate__c,StartDateText__c,EndDateText__c,Status__c,Category__c  from Appointment__c where Subscription__c = : subscriptionIDGlobal and Category__c =: Catstring order by SlotId__c Desc]){
                apptRecord.Notes__c = notes; // modify this line to appt.Notes__c = appt.Notes__c + notes; if we want to append the new notes to previous notes for tracking
                if(startDate!=null){apptRecord.StartDate__c = datetime.valueOf(startDate);apptRecord.StartDateText__c=startDateText;}
                if(endDate!=null){apptRecord.EndDate__c = datetime.valueOf(endDate);apptRecord.EndDateText__c = endDateText;}
                //EDGE-66476- start
                if(apptRecord.Reschdeule_required__c!= null && apptRecord.Reschdeule_required__c==true)
                {
                    apptRecord.Reschdeule_required__c= false;
                    apptRecord.Suggested_Start_Date__c=null;
                }
                
                //EDGE-66476- end
                apptRecord.Status__c='RESCHEDULED';//Kalashree, EDGE-86005 Change status of Appointment
                system.debug('apptRecord.Status__++' +apptRecord.Status__c);
                updateApptList.add(apptRecord); 
               //update apptRecord;
                //break;
            }
            if(!updateApptList.isEmpty()){
                update updateApptList;
            }
            return true;
        }catch(Exception e){
            system.debug('Exception in updateAppointmentRecord ' + e);
            return false;
        }
    }
    
    
   
    /*------------------------------------------------------------ 
    //EDGE -66476
    Method: checkDependencyAppt 
    Description: Method to check if the Reschedule/rebook response have any dependency data.
    History 
    <06-05-2019> <Mahima Gandhe><Created the method>
    ------------------------------------------------------------*/
    public void checkDependencyAppt( AppointmentBOMReserveResponseDTO resDTO, Id SubId, boolean mockEnabled)
    {
        if(resDTO.data.dependencies!= null)
        {
            List<AppointmentBOMReserveResponseDTO.Dependencies> depArray= new List<AppointmentBOMReserveResponseDTO.Dependencies>();
            depArray=resDTO.data.dependencies;
            List<Appointment__C> lstAppt= new List<Appointment__C>();
            for(AppointmentBOMReserveResponseDTO.Dependencies dep:depArray)
            {
                
                List<Appointment__C> apptlist= new List<Appointment__C> ();
                if(mockEnabled)
                {
                apptlist=[SELECT id,Reschdeule_required__c,Suggested_Start_Date__c,SlotId__c from Appointment__C where SlotId__c LIKE 'TAPT2352213142342%' and Subscription__c=:SubId ];               
                }
                else
                {
                apptlist=[SELECT id,Reschdeule_required__c,Suggested_Start_Date__c,SlotId__c from Appointment__C where SlotId__c=:dep.appointmentID and Subscription__c=:SubId];
                }
                
                    Appointment__C appt=new Appointment__C();
                    if(apptlist!= null && apptlist.size()>0)
                    {
                        appt.id=apptlist[0].id;
                    appt.SlotId__c=apptlist[0].SlotId__c;
                    }else{                      
                        if(mockEnabled)
                        {
                            appt.SlotId__c=dep.appointmentID + String.valueof(DateTime.now().getTime());
                        }
                        else
                        appt.SlotId__c=dep.appointmentID;
                    }
                                    
                    appt.Reschdeule_required__c= true;
                    appt.Suggested_Start_Date__c=Date.valueof(dep.suggestedStartDate);
                    appt.Category__c=dep.appointmentCategory;
                    appt.EndDate__c=Date.valueOf(dep.currentSlotEndDate);                   
                    appt.StartDate__c=Date.valueOf(dep.currentSlotStartDate);                   
                    lstAppt.add(appt);
                
            }
            upsert lstAppt;
        }
    }
    public Date CalcOrderStartDateForRescheduleAppointment(String subscriptionID){
        Date OrderStartDate= null;
        if(appointmentOperation == 'Reschedule'){
            csord__Subscription__c Subscription =[SELECT id,csord__Order__c,csord__Order__r.csord__Start_Date__c from csord__Subscription__c where id= :subscriptionID];
            if(Subscription!=null && Subscription.csord__Order__r.csord__Start_Date__c!=null){
                OrderStartDate=Subscription.csord__Order__r.csord__Start_Date__c;
            }else{
                OrderStartDate=Date.Today();
            }
        }else{
            OrderStartDate=Date.Today();
        }
        system.debug('@@OrderStartDate@@'+OrderStartDate);
        return OrderStartDate;
    }
    
    public void checkForExistingAppointment(String subscriptionID){
        try{
            List<Appointment__c> apptList  = [SELECT id,Subscription__c from Appointment__c where Subscription__c =:subscriptionID];
            if(apptList!=null && apptList.size()>0){
                isEnriched = true;
                isEnrichedText = 'true';
            }
        }catch(Exception e){
            system.debug('Exception in checkForExistingAppointment ' + e);   
        }
    }
    public boolean hasMessages {
        get {
            return ApexPages.hasMessages();
        }
    }
    
    /**@description The custom error message */
    public String errorMessage {
        get {
            if (hasMessages) {
                return ApexPages.getMessages()[0].getDetail();
            }
            
            return null;
        }set;
    }
    /**@description The type of message: 'error' or 'success' */
    public string alertType {
        get {
            if (hasMessages) {
                return ApexPages.getMessages()[0].getSeverity() == ApexPages.Severity.CONFIRM ? 'success' : 'error';
            }
            
            return 'error';
        }
        private set;
    }
    //Kalashree EDGE-66474,EDGE-66451 AC5
    public void updateParentApptStatus(Appointment__c appt){
        appt.status__c  = 'REBOOKED';
        update appt;
    }
}
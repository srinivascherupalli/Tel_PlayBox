/*
User Story : EDGE - 182 and EDGE - 788
This class is the controller for the VF page designed to replace the existing Appointment Screen on IP Site product definition.
This method deals in setting the VF variables and handling - queryAppointment, reserveAppointment scenarios
The TAR calculation for Appointment is handled in TARManagerV2 class
*/
    public with sharing class AppointmentBookPageHandlerV2 {
    // property to hold number of time refreshed
    public boolean firstSection{get;set;}
    public boolean secondSection{get;set;}
    public boolean fromDateValidation{get;set;}
    public Integer timesRefreshed { get; set; }
    public List<SelectOption> selectedname{get;set;}
    public AppointmentSlotResponseDTO detailsList{get;set;}
    public List<SlotWrapper> detailList{get;set;}   //This holds the value of queryAppointmentResponse throughout the controller
    public List<SlotWrapper> finalSlotWrapperList{get;set;} //this holds the value of the wrapper for the slots displayed on VF
    public string selectedSlotId{get;set;}  //holds the value of the Slot selected by user on VF
    public class SlotWrapper{
        public String startDate{get;set;}
        public Map<String,String> slotDetail{get;set;}
    }
    public Date fromDate{get;set;} //holds the value of Start Date from VF
    /*
    get{
        if (fromDate==null) {
            return null;
        }
        return date.parse(fromDate.year() + '-' + fromDate.month() + '-' + fromDate.day());
    }set;
    }
    */
         
    public date todate{get;set;}        //holds the value of Latest Date from VG
    public boolean displayPb2{get;set;} //variable to handle hide/show
    public boolean displayOP{get;set;}  //variable to handle hide/show
    public string notes{get;set;}       //holds the value of Notes from VF
    public Integer daysAhead{get;set;}  //variable used on VF for Lead days
    public String causeEventReason{get;set;}    //holds the value of CauseReason to be displayed on VF
    public Boolean isCauseEvent{get;set;}   //variable to handle causeEvent scenario
    public String isCauseEventText{get;set;}
    public Boolean areSlotsAvailable{get;set;}  //variable to be used for rendered property
    public Boolean isEnriched{get;set;} //variable to handle hide/show for scenario if appointment is created/already created
    public String isEnrichedText{get;set;}
    public Map<String,String> appDetails {get;set;} //holds the value of appointment details if already created
    public Boolean showAppDetail {get;set;} //variable to handle hide/show for static appt details screeen
    public String appointmentId {get;set;}  //holds the value of appointmentID
    public String popupTitle {get;set;} //Title for Popup on click of confirm button
    public String popupMessage {get;set;}   //Message for popup on click of confirm button
    public String subscriptionIDGlobal {get;set;}    //holds the value of Config Id passed from the URL
    public boolean blockConfirmBtn{get;set;}    //variable to be used for rendered property
    public String appointmentOperation {get;set;} //variable to store value of appointment operation to be invoked
    public boolean renderReschedulePanel {get;set;} //variable to be used for rendered property
    public boolean renderRebookPanel {get;set;} //variable to be used for rendered property
    public String selectedRescheduleInitiator {get;set;}    //variable to store the value of reschedule initiator dropdown value
    public String selectedRescheduleReason {get;set;}   //variable to store the value of reschedule reason dropdown value
    public String originalApptId {get;set;} //variable to store Appointment ID TAPTxxx for reschedule scenario
    public String parentApptId {get;set;}
    public Boolean isRescheduled {get;set;} //variable to be used for rendered property
    public Boolean isRebook {get;set;} //variable to be used for rendered property
    public Boolean rescheduleReasonValidation {get;set;}
    public String appointmentTitle {get;set;}
    public String hasMessageString {get;set;}
    public String apptErrorMsg {get;set;}
    public String SubscriptionChangeType {get; set;}
    public TARManagerV2 tarManager;
    public List<TARManagerV2.ServiceSpecificationWrapper> serviceSpecWrapperList {get;set;}
    Public List<Selectoption> getCategories(){
        List<Selectoption> categories = new List<selectoption>();
        categories.add(new selectOption('Telstra Installation', 'Telstra Installation'));
        return categories; 
    }
    public List<Selectoption> rescheduleInitiators {get;set;}
    public List<Selectoption> rescheduleReasons {get;set;}
    public Date OrderStartDateForRescheduleAppointment {get; set;}
    
    //Constructor for the method
    public AppointmentBookPageHandlerV2(){
        tarManager = new TARManagerV2();
        
        //Fetch the subscription ID and operation from the url
        String unescapedParamID = ApexPages.currentPage().getParameters().get('id');
        String unescapedParamOperation = ApexPages.currentPage().getParameters().get('operation');
        
        //Assing the subscription Id and operation to the global variables
        subscriptionIDGlobal = EncodingUtil.urlEncode(unescapedParamID,'UTF-8');
        appointmentOperation = EncodingUtil.urlEncode(unescapedParamOperation,'UTF-8');
        
        system.debug('<><><> Subscription For Appt ' + subscriptionIDGlobal);
        system.debug('<><><> Appt Operation ' + appointmentOperation);
        firstSection=false;
        fromDateValidation=false;
        secondSection=false;
        blockConfirmBtn=false;
        SubscriptionChangeType=CalculateSubscriptionChangeType(subscriptionIDGlobal);
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
            if(SubscriptionChangeType!='Cancel'){
                if(appointmentOperation == 'Reschedule' && !isRescheduled){
                    appointmentTitle = 'RESCHEDULE APPOINTMENT';
                    for(Appointment__c appt: [select SlotId__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal]){
                        originalApptId = appt.SlotId__c;
                    }
                    renderReschedulePanel = true;
                    Set<String> rescheduleApptSet = new Set<String>();
                    for(EWOMRescheduleAppointment__c apt : [select name, Initiated_By__c from EWOMRescheduleAppointment__c order by Initiated_By__c asc]){
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
                    daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                    isCauseEvent=false;
                    isCauseEventText = 'false';
                    System.debug('Lead days for appointment '+daysAhead);
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
                    for(Appointment__c appt: [select SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal]){
                        parentApptId = appt.Parent_Appt_ID__c;
                        system.debug('<><><> Enrichstatus ' + isEnriched);
                    }
                    if(isEnriched){getAppoinmentDetails(subscriptionID);}
                    else{
                        displayPb2=false;
                        timesRefreshed = 0;
                        displayOP=false;
                        daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                        isCauseEvent=false;
                        isCauseEventText = 'false';
                        System.debug('Lead days for appointment '+daysAhead);
                    }
                }
                else{
                    appointmentTitle = 'SCHEDULE APPOINTMENT';
                    renderReschedulePanel = false;
                    checkForExistingAppointment(subscriptionID);
                    if(isEnriched){getAppoinmentDetails(subscriptionID);}
                    else{
                        displayPb2=false;
                        timesRefreshed = 0;
                        displayOP=false;
                        daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                        isCauseEvent=false;
                        isCauseEventText = 'false';
                        System.debug('Lead days for appointment '+daysAhead);
                    }
                }
            }else{
                system.debug('**Inside cancel***');
                appointmentTitle='DEVICE RECOVERY APPOINTMENT';
                if(appointmentOperation == 'Reschedule' && !isRescheduled){
                    //appointmentTitle = 'RESCHEDULE APPOINTMENT';
                    for(Appointment__c appt: [select SlotId__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal]){
                        originalApptId = appt.SlotId__c;
                    }
                    renderReschedulePanel = true;
                    Set<String> rescheduleApptSet = new Set<String>();
                    for(EWOMRescheduleAppointment__c apt : [select name, Initiated_By__c from EWOMRescheduleAppointment__c order by Initiated_By__c asc]){
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
                    daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                    isCauseEvent=false;
                    isCauseEventText = 'false';
                    System.debug('Lead days for appointment '+daysAhead);
                }else if(appointmentOperation == 'Reschedule' && isRescheduled){
                    //appointmentTitle = 'RESCHEDULE APPOINTMENT';
                    checkForExistingAppointment(subscriptionID);
                    getAppoinmentDetails(subscriptionID);
                }
                else if(appointmentOperation == 'FollowOn' && !isRebook){
                    //appointmentTitle = 'REBOOK APPOINTMENT';
                    checkForExistingAppointment(subscriptionID);
                    getAppoinmentDetails(subscriptionID);
                    renderRebookPanel = true;
                    isEnriched=false;
                    isEnrichedText = 'false';
                    for(Appointment__c appt: [select SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionIDGlobal]){
                        parentApptId = appt.Parent_Appt_ID__c;
                        system.debug('<><><> Enrichstatus ' + isEnriched);
                    }
                    if(isEnriched){getAppoinmentDetails(subscriptionID);}
                    else{
                        displayPb2=false;
                        timesRefreshed = 0;
                        displayOP=false;
                        daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                        isCauseEvent=false;
                        isCauseEventText = 'false';
                        System.debug('Lead days for appointment '+daysAhead);
                    }
                }
                else{
                    //appointmentTitle = 'SCHEDULE APPOINTMENT';
                    renderReschedulePanel = false;
                    checkForExistingAppointment(subscriptionID);
                    if(isEnriched){getAppoinmentDetails(subscriptionID);}
                    else{
                        displayPb2=false;
                        timesRefreshed = 0;
                        displayOP=false;
                        daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSiteAPV2(subscriptionID));
                        isCauseEvent=false;
                        isCauseEventText = 'false';
                        System.debug('Lead days for appointment '+daysAhead);
                    }
                }
            }
            
            
        }catch(Exception e){
            system.debug('Exception in secondaryConstructor ' + e);
            system.debug('<><><> Enrichstatus ' + isEnriched);
        }
    }
   
    /* Method to check for Existing Appointment for the current IP Site
*/
    public void checkForExistingAppointment(String subscriptionID){
        try{
            List<Appointment__c> apptList  = [select id,Subscription__c from Appointment__c where Subscription__c =:subscriptionID];
            if(apptList!=null && apptList.size()>0){
                isEnriched = true;
                isEnrichedText = 'true';
            }
        }catch(Exception e){
            system.debug('Exception in checkForExistingAppointment ' + e);   
        }
    }
    
    /* Method to handle the Action Function on VF page
*/
    public PageReference setSlotId() {
        System.debug('Slot id--'+selectedSlotId);
        return null;
        
    }
    public PageReference switchOfTimerApex() {
        System.debug('Slot id--'+selectedSlotId);
        selectedSlotId=null;
        blockConfirmBtn=true;
        return null;
        
    }
    public PageReference clearBottomSection(){
        displayOP = false;
        displayPb2=false;
        return null;
    } 
    public PageReference loadRescheduleReasonList(){
        rescheduleReasons = new List<Selectoption>();
        rescheduleReasons.add(new SelectOption('--None--','--None--'));
        if(selectedRescheduleInitiator == '--None--'){
            
        }else{
            for(EWOMRescheduleAppointment__c apt : [select name, Initiated_By__c,RescheduleReason__c,RescheduleReasonCode__c from EWOMRescheduleAppointment__c where Initiated_By__c =: selectedRescheduleInitiator order by RescheduleReason__c asc]){
                rescheduleReasons.add(new Selectoption(apt.RescheduleReasonCode__c,apt.RescheduleReason__c));
            }    
        }
        return null;
    }
    /* Method to handle the queryAppointment scenario when user clicks on Search button
*/
    public PageReference searchAppointments(){
        blockConfirmBtn=true;
        areSlotsAvailable = false;
        displayOP = false;
        displayPb2=false;
        hasMessageString = 'false';
        if(appointmentOperation=='Reschedule' && (selectedRescheduleInitiator == '--None--' || selectedRescheduleReason == '--None--')){
            rescheduleReasonValidation = true;
            createError(ApexPages.Severity.ERROR,'Please select valid option for Reschedule Appointment or Reason.');
            hasMessageString = 'true';
            apptErrorMsg = 'Please select valid option for Reschedule Appointment or Reason.';
        }
        else if(fromDate==NULL){
            rescheduleReasonValidation = false;
            fromDateValidation =true;
            hasMessageString = 'true';
            apptErrorMsg = 'From Date is mandatory for search.';
        }
       else if(toDate<fromDate){
            rescheduleReasonValidation = false;
            firstSection=true;
            fromDateValidation =false;
            hasMessageString = 'true';
            apptErrorMsg = 'Latest Date must be greater than From Date.';
        }
        else{
            blockConfirmBtn =false;
            fromDateValidation =false;
            selectedSlotId=null;
            firstSection=false;
            finalSlotWrapperList = null;
            rescheduleReasonValidation = false;
            //If condition to populate Schedule Appointment Query DTO and callout to fetch slots
            if(appointmentOperation=='Schedule'){
                AppointmentSlotRequestDTO slotRequestDTO = new AppointmentSlotRequestDTO();
                AppointmentSlotRequestDTO.Data data = new AppointmentSlotRequestDTO.Data();
                data.address = tarManager.populateSlotSiteAddressAPV2(subscriptionIDGlobal);
                data.taskItems = tarManager.populateSlotTasksAPV2(subscriptionIDGlobal);
                Datetime fromDateTime = fromDate;
                Datetime toDateTime = toDate;
                data.startDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                if(toDate==null){
                    data.endDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    data.endDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                slotRequestDTO.data = data;
                system.debug('Schedule RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
                detailsList=EWOMAppointmentManager.searchAppointment(slotRequestDTO);
            }
            //Else If condition to populate ReSchedule Appointment Query DTO and callout to fetch slots
            else if(appointmentOperation=='Reschedule'){
                AppointmentRescheduleRequestDTO rescheduleRequestDTO = new AppointmentRescheduleRequestDTO();
                AppointmentRescheduleRequestDTO.Data data = new AppointmentRescheduleRequestDTO.Data();
                Datetime fromDateTime = fromDate;
                Datetime toDateTime = toDate;
                data.startDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                if(toDate==null){
                    data.endDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    data.endDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                data.searchType = 'RESCHEDULE';
                String rescheduleReasonValue = '';
                for(EWOMRescheduleAppointment__c apt : [select name, Initiated_By__c,RescheduleReason__c,RescheduleReasonCode__c from EWOMRescheduleAppointment__c where RescheduleReasonCode__c =: selectedRescheduleReason]){
                    rescheduleReasonValue = apt.RescheduleReason__c;
                }
                //Format of Reason to be sent in DTO : ReasonCode - ReasonValue
                //Eg : data.rescheduleReason = '61 - Technician not available';
                data.rescheduleReason = selectedRescheduleReason;
                rescheduleRequestDTO.data = data;
                system.debug('Reschedule RequestAppointmentPayload '+JSON.serialize(rescheduleRequestDTO));
                detailsList=EWOMAppointmentManager.searchRescheduleAppointment(rescheduleRequestDTO,originalApptId);
            }
            
            //Search rebook Edge-10652
            else if(appointmentOperation=='FollowOn'){
                AppointmentRescheduleRequestDTO rescheduleRequestDTO = new AppointmentRescheduleRequestDTO();
                AppointmentRescheduleRequestDTO.Data data = new AppointmentRescheduleRequestDTO.Data();
                Datetime fromDateTime = fromDate;
                Datetime toDateTime = toDate;
                data.startDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                if(toDate==null){
                    data.endDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
                }else{
                    data.endDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
                data.searchType = 'PARTIAL_COMPLETE';
                rescheduleRequestDTO.data = data;
                system.debug('FollowOn RequestAppointmentPayload '+JSON.serialize(rescheduleRequestDTO));
                detailsList=EWOMAppointmentManager.searchRebookAppointment(rescheduleRequestDTO,parentApptId);
            }            
            if(checkSlotsNotAvailable(detailsList))
            {
                hasMessageString = 'true';
                apptErrorMsg = Label.AppointmentUnavailable;
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.AppointmentUnavailable);
                //ApexPages.addMessage(myMsg);
            }
            else{
                areSlotsAvailable = true;
                displayPb2=true;
                displayOP=true;
                finalSlotWrapperList = populateSlotWrapper(detailsList);
                if(isCauseEvent){
                    hasMessageString = 'true';
                    apptErrorMsg = Label.CauseEventReason.replace('<causeEventReason>', causeEventReason);
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.CauseEventReason.replace('<causeEventReason>', causeEventReason));
                    //ApexPages.addMessage(myMsg);
                }
            }
        }
        return null;
    }
    
    /*Method to populate the List of Wrapper class to cater the scenario - to have multiple slots displayed within a single date
* as opposed to the response that has single slot - single date data structure
*/
    public List<SlotWrapper> populateSlotWrapper(AppointmentSlotResponseDTO responseDTO){
        System.debug('Response DTO '+responseDTO);
        List<SlotWrapper> finalSlotWrapperList = new List<SlotWrapper>();
        AppointmentSlotResponseDTO.Data data = responseDTO.data;
        List<SlotWrapper> slotWrapperList = new List<SlotWrapper>();
        try{
            for(AppointmentSlotResponseDTO.AvailableSlot availableSlot : data.availableSlots){
                SlotWrapper slot = new SlotWrapper();
                Datetime dt1 = Datetime.valueOf(availableSlot.startDate.replace('T', ' '));
                slot.startDate = dt1.format('EEEE') + ', ' + dt1.format('dd/MM/yyyy');
                //String startTime = availableSlot.startDate.split('T')[1].left(5);
                String startTime = '' + Datetime.valueOf(availableSlot.startDate.replace('T', ' ')).format('hh:mm a');
                //String endTime = availableSlot.endDate.split('T')[1].left(5);
                String endTime = '' + Datetime.valueOf(availableSlot.endDate.replace('T', ' ')).format('hh:mm a');
                Map<String,String> slotMap = new Map<String,String>();
                slotMap.put(availableSlot.id,startTime+' to ' + endTime);
                slot.slotDetail = slotMap;
                slotWrapperList.add(slot);
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
            return finalSlotWrapperList;
        }catch(Exception e){
            system.debug('Exception in populateSlotWrapper ' + e);
            return finalSlotWrapperList;
        }
    }
    
    /* Method to check if the response received has any Cause Event block. If yes, populate the fields on the controller
*/
    public void checkCauseEvent(AppointmentSlotResponseDTO responseDTO){
        try{
            if(responseDTO!= null && responseDTO.data!=null && responseDTO.data.causeEvent!=null){
                AppointmentSlotResponseDTO.CauseEvent causeEvent = responseDTO.data.causeEvent;
                if(causeEvent.reason!= null && causeEvent.reason != ''){
                    isCauseEvent = true;
                    isCauseEventText = 'true';
                    causeEventReason = causeEvent.reason;
                }
            }
        }catch(Exception e){
            system.debug('Exception in checkCauseEvent ' + e);
        }
    }
    
    /*Methods to handle reserveAppointment scenario when user clicks on Confirm button
*/
    public void confirmAppointment() {
        system.debug('Selected Slot Id for reserve appointment '+selectedSlotId);
        system.debug('Notes for the selected slot '+notes);
        reserveAppointment(selectedSlotId,subscriptionIDGlobal,notes);
    }
    public void reserveAppointment(String slotId,String subscriptionID, String notes){
        AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
        AppointmentReserveRequestDTO.Data data = new AppointmentReserveRequestDTO.Data();
        AppointmentReserveRequestDTO.Customer customer = new AppointmentReserveRequestDTO.Customer();
        HttpResponse reserveResponse = null;
        try{
            if(appointmentOperation=='Reschedule'){
                //Do something for Reschedule Reserve operation
                data.notes = notes;
                reserveDTO.data = data;
                system.debug('Reschedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
                reserveResponse = EWOMAppointmentManager.reserveRescheduleAppointment(reserveDTO, slotId,originalApptId);
            }else if(appointmentOperation=='FollowOn'){
                //Do something for Reschedule Reserve operation
                data.notes = notes;
                reserveDTO.data = data;
                system.debug('FollowOn reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
                reserveResponse = EWOMAppointmentManager.reserveRebookAppointment(reserveDTO, slotId,parentApptId);
            }else{
                if(subscriptionID !=null && subscriptionID !=''){
                    for(csord__Subscription__c sub : [select id, csord__Account__c, csord__Account__r.name,csord__Account__r.Type from csord__Subscription__c where id =:subscriptionID]){
                        customer.name = sub.csord__Account__r.name;
                        customer.customerclass = sub.csord__Account__r.Type;
                        break;
                    }
                    data.customer = customer;
                }else{
                    system.debug('ERROR : Subscription ID recevied in AppointmentBookPageHandler.reserveAppointment is null or empty');
                }
                data.contacts = tarManager.populateContactForReserveAppointmentAPV2(subscriptionID);
                data.notes = notes;
                reserveDTO.data = data;
                system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
                reserveResponse = EWOMAppointmentManager.reserveAppointment(reserveDTO, slotId);
            }
            if(reserveResponse!=null && (reserveResponse.getStatusCode()==200 || reserveResponse.getStatusCode()==201)){
                List<String> urlSplit = reserveResponse.getHeader('location').split('/');
                String appointmentIDLocation = urlSplit[urlSplit.size()-1];
                String apptId = null;
                if(appointmentOperation=='Reschedule'){
                        showAppDetail = true;
                        isEnriched=true;
                        isEnrichedText = 'true';
                        if(updateAppointmentRecord()){
                            //CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                            system.debug('Update Appointment Record successful after Reschedule');
                            isRescheduled = true;
                            getAppoinmentDetails(subscriptionID);
                            popupTitle = 'Booking Successful';
                            popupMessage = Label.AppointmentBooked.replace('<AppId>', appointmentIDLocation) + getAppStartEndTime(selectedSlotId);    
                        }else{
                            system.debug('Update Appointment Record failed after Reschedule');
                            popupTitle = 'Booking Successful';
                            popupMessage = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);
                        }
                        
                }else{
                    apptId = createAppointmentRecord(slotId,appointmentIDLocation,subscriptionID,appointmentOperation);
                    if(apptId!=null){
                        //CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                        appointmentId = appointmentIDLocation;
                        createTaskRecords(detailsList,apptId);
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
                //write something to show error while reserving appointment please try again later
                popupTitle = 'Booking Failure';
                popupMessage = Label.AppointmentFailed;   
                displayOP = false;
                displayPb2=false;
            }
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e);
        }
    }
    /*Method to update the Appointment Record details like Notes, StartDate and EndDate after a Reschedule Reserve callout is successful
    */
    public Boolean updateAppointmentRecord(){
        try{
            system.debug('Update the Appointment Record after Reschedule Operation');
            String startDate = null;
            String endDate = null ;
            String startDateText = '';
            String endDateText = '';
            AppointmentSlotResponseDTO.Data data = detailsList.data;
            for(AppointmentSlotResponseDTO.AvailableSlot availableSlot : data.availableSlots){
                if(availableSlot.id == selectedSlotId){
                    startDate = availableSlot.startDate.replace('T', ' ');
                    endDate = availableSlot.endDate.replace('T', ' ');
                    startDateText = availableSlot.startDate;
                    endDateText = availableSlot.endDate;
                    break;
                }
            }
            for(Appointment__c apptRecord: [select SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c,StartDate__c,EndDate__c,StartDateText__c,EndDateText__c from Appointment__c where Subscription__c = : subscriptionIDGlobal order by SlotId__c Desc]){
                apptRecord.Notes__c = notes; // modify this line to appt.Notes__c = appt.Notes__c + notes; if we want to append the new notes to previous notes for tracking
                if(startDate!=null){apptRecord.StartDate__c = datetime.valueOf(startDate);apptRecord.StartDateText__c=startDateText;}
                if(endDate!=null){apptRecord.EndDate__c = datetime.valueOf(endDate);apptRecord.EndDateText__c = endDateText;}
                update apptRecord;
                break;
            }
            return true;
        }catch(Exception e){
            system.debug('Exception in updateAppointmentRecord ' + e);
            return false;
        }
    }
    /* Method to create Appointment Record once EWOM sends 200/201 response for Schedule Reserve operation
*/
    public String createAppointmentRecord(String slotId, String appointmentID,String subID,String appointmentOperation){
        try{
            String apptId;
            String startDate = null;
            String endDate = null ;
            String startDateText = '';
            String endDateText = '';
            AppointmentSlotResponseDTO.Data data = detailsList.data;
            for(AppointmentSlotResponseDTO.AvailableSlot availableSlot : data.availableSlots){
                if(availableSlot.id == slotId){
                    startDate = availableSlot.startDate.replace('T', ' ');
                    startDateText = availableSlot.startDate;
                    endDate = availableSlot.endDate.replace('T', ' ');
                    endDateText = availableSlot.endDate;
                    system.debug('Exception in updateAppointmentRecord ' + appointmentID);
                    system.debug('Exception in updateAppointmentRecord ' + slotId);
                    system.debug('Exception in updateAppointmentRecord ' + subID);
                    break;
                }
            }
            Appointment__c appList = new Appointment__c();
            if(appointmentOperation == 'FollowOn'){
            appList  = [select SlotId__c,Status__c from Appointment__c where Subscription__c =: subID  order by CreatedDate DESC limit 1];
            }
            system.debug('Exception in updateAppointmentRecord ' + appList);
            Appointment__c apptRecord = new Appointment__c();
            apptRecord.Category__c='Telstra Installation'; //Modify this in future for category LOVs
            if(startDate!=null){apptRecord.StartDate__c = datetime.valueOf(startDate);apptRecord.StartDateText__c=startDateText;}
            if(endDate!=null){apptRecord.EndDate__c = datetime.valueOf(endDate);apptRecord.EndDateText__c = endDateText;}
            apptRecord.SlotId__c = appointmentID;
            apptRecord.Notes__c = notes;
            apptRecord.Subscription__c = subID;
            if(appointmentOperation == 'FollowOn'){
            apptRecord.Parent_Appt_ID__c = appList.SlotId__c;
            }
            else{
            apptRecord.Parent_Appt_ID__c = appointmentID;   
            }
            insert apptRecord;
            apptId = apptRecord.id;
            return apptId;
        }catch(Exception e){
            system.debug('Exception in createAppointmentRecord '+ e);
            return '';
        }
    }
    /* Method to create TASK records for the Tasks to be installed associated with the appointment booked. 
*/
    public void createTaskRecords(AppointmentSlotResponseDTO detailsList, String apptId){
        try{
            List<Task__c> tasksToInsertList = new List<Task__c>();
            AppointmentSlotResponseDTO.Data dataRecord = detailsList.data;
            if(dataRecord != null && dataRecord.taskItems!=null){
                List<AppointmentSlotResponseDTO.Task> taskList = dataRecord.taskItems;
                for(AppointmentSlotResponseDTO.Task taskRecord : taskList){
                    Task__c task = new Task__c();
                    task.Appointment__c = apptId;
                    task.TaskId__c = taskRecord.id;
                    tasksToInsertList.add(task);
                }
            }
            if(tasksToInsertList!=null && tasksToInsertList.size()>0){
                insert tasksToInsertList;
            }
        }catch(Exception e){
            system.debug('Exception in createTaskRecords ' + e);
        }
    }
    
    /* Method to fetch appointment details for the screen to display Appointment details if already Enriched
*/
    public void getAppoinmentDetails(String subscriptionID)
    {
        List<Appointment__c> apptList = [select SlotId__c,Category__c,EndDate__c,StartDate__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : subscriptionID order by SlotId__c Desc];
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
            //system.debug('*************App'+ appt.StartDate__c+'*******'+appt.EndDate__c+'******'+appt.SlotId__c);
            appDetails.put('StartTime', appStartTime);
            appDetails.put('EndTime', appEndTime);
            break;
        }
    }
    /* Method to convert the time to appropriate format to be displayed on the VF
*/
    private string getTime(Time tm)
    {
        string appTimeStr='';
        if(tm != null)
        {
        if(tm.hour() <= 12)
        {
            appTimeStr = getHtMn(tm.hour()) +':'+ getHtMn(tm.minute()) +' AM';
        }
        else{
            appTimeStr = getHtMn(tm.hour()) +':'+ getHtMn(tm.minute()) +' PM';
        }
        }
        return appTimeStr;
    }
    private string getHtMn(Integer hm)
    {
        string hmstr;
        hmstr = String.valueOf(hm);
        if(hm < 10)
        {
            hmstr = '0' + hmstr;
        }
        return hmstr;
    }
    public string getAppStartEndTime(String slotID)
    {
        for(SlotWrapper sw : finalSlotWrapperList)
        {
            if(sw.slotDetail.containsKey(slotID))
            {
                return ' '+ sw.slotDetail.get(slotID)+' on '+sw.startDate +'.';
            }
        }
        return null;
    }
    public boolean checkSlotsNotAvailable(AppointmentSlotResponseDTO responseDTO){
        if(responseDTO!=null && responseDTO.data != null && responseDTO.data.availableSlots != null)
        {
           return responseDTO.data.availableSlots.isEmpty(); 
        }
        return true;
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
    
    public void createError(ApexPages.Severity s, String message) {
        ApexPages.addMessage(
                New ApexPages.Message(
                        s, string.escapeSingleQuotes(message.escapeJava())
                )
        );

    }
    public Date CalcOrderStartDateForRescheduleAppointment(String subscriptionID){
        Date OrderStartDate= null;
        if(appointmentOperation == 'Reschedule'){
            csord__Subscription__c Subscription =[Select id,csord__Order__c,csord__Order__r.csord__Start_Date__c from csord__Subscription__c where id= :subscriptionID];
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
    public String CalculateSubscriptionChangeType(String subscriptionID){
        String changetype=null;
        csord__Subscription__c Subscription =[Select id,csordtelcoa__Change_Type__c from csord__Subscription__c where id= :subscriptionID];
        if(Subscription!=null){
            changetype=Subscription.csordtelcoa__Change_Type__c;
        }
        system.debug('changetype***'+changetype);
        return changetype;
    }
}
/*
User Story : EDGE - 182 and EDGE - 788
This class is the controller for the VF page designed to replace the existing Appointment Screen on IP Site product definition.
This method deals in setting the VF variables and handling - queryAppointment, reserveAppointment scenarios
The TAR calculation for queryAppointment is handled in TARManager class
*/
    public with sharing class AppointmentBookPageHandler {
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
    public Date fromDate{get;set;}      //holds the value of Start Date from VF
    public date todate{get;set;}        //holds the value of Latest Date from VG
    public boolean displayPb2{get;set;} //variable to handle hide/show
    public boolean displayOP{get;set;}  //variable to handle hide/show
    public string notes{get;set;}       //holds the value of Notes from VF
    public Integer daysAhead{get;set;}  //variable used on VF for Lead days
    public String causeEventReason{get;set;}    //holds the value of CauseReason to be displayed on VF
    public Boolean isCauseEvent{get;set;}   //variable to handle causeEvent scenario
    public String isCauseEventText{get;set;}
    public Boolean isEnriched{get;set;} //variable to handle hide/show for scenario if appointment is created/already created
    public String isEnrichedText{get;set;}
    public Map<String,String> appDetails {get;set;} //holds the value of appointment details if already created
    public Boolean showAppDetail {get;set;} //variable to handle hide/show for static appt details screeen
    public String appointmentId {get;set;}  //holds the value of appointmentID
    public String popupTitle {get;set;} //Title for Popup on click of confirm button
    public String popupMessage {get;set;}   //Message for popup on click of confirm button
    public String rootCnfigId {get;set;}    //holds the value of Config Id passed from the URL
    public boolean blockConfirmBtn{get;set;}
    public TARManager tarManager;
    Public List<Selectoption> getCategories(){
        List<Selectoption> categories = new List<selectoption>();
        categories.add(new selectOption('Telstra Installation', 'Telstra Installation'));
        return categories; 
    }
    //Constructor for the method
    public AppointmentBookPageHandler(){
        tarManager = new TARManager();
        system.debug('currentURL ' + ApexPages.currentPage().getURL()); //fetches the parameters from the url
        String currentURL = ApexPages.currentPage().getURL();
        String[] urlArray = currentURL.split('id=');
        String rootId =null;
        if(urlArray.size()>1){
            rootId = urlArray[1];
        }
        if(rootId !=null){
            rootCnfigId = rootId;
        }
        //the else part is a tactical solution since we are not getting ID from the url due to package upgrade issue
        else{
            rootCnfigId = '';//System.Label.TemporaryIPSitePCId;
        }
        system.debug('<><><> R ' + rootId);
        firstSection=false;
        fromDateValidation=false;
        secondSection=false;
        blockConfirmBtn=false;
        secondaryConstructor(rootCnfigId);
    }
    
    //handling the remaining part of the above constructor in different method to tackle the test class execution
    public void secondaryConstructor(String rootPCId){
        try{
            isEnriched=false;
            isEnrichedText='false';
            showAppDetail = false;
            checkForExistingAppointment(rootPCId);
            if(isEnriched){getAppoinmentDetails(rootPCId);}
            else{
                displayPb2=false;
                timesRefreshed = 0;
                displayOP=false;
                daysAhead = Integer.ValueOf(tarManager.fetchStartDateForSite(rootPCId));
                isCauseEvent=false;
                isCauseEventText = 'false';
                System.debug('Lead days for appointment '+daysAhead);
            }
        }catch(Exception e){
            system.debug('Exception in secondaryConstructor ' + e);
        }
    }
    
    /*Method to set AppointmentID in Product Definition after creation of appointment record.
     * Please comment this method once we are able to use CSMSG javascripts from VF page
    */
    public void setAppointmentIDInPC(String prodConfigId, String attrName){
        try{
            for(cscfga__Product_Configuration__c rootConfig : [select id,name,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id =:prodConfigId]){
                List<cscfga__Product_Configuration__c> prodConfigList = [select id,name,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: rootConfig.cscfga__Product_Basket__c and name ='Appointment'];
                for(cscfga__Attribute__c attr: [select id, name, cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c in :prodConfigList and name =: attrName]){
                    attr.cscfga__Value__c=selectedSlotId;
                    update attr;
                    break;
                }
            }    
        }
        catch(Exception e){
            system.debug('Exception in setAppointmentIDInPC ' + e);
        }
    }
    /* Method to check for Existing Appointment for the current IP Site
    */
    public void checkForExistingAppointment(String rootConfigId){
        try{
            List<Appointment__c> apptList  = [select id,Product_Configuration__c from Appointment__c where Product_Configuration__c =:rootConfigId];
            if(apptList!=null && apptList.size()>0){
              //  system.debug('checkforExisiting');
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
    
    /* Method to handle the queryAppointment scenario when user clicks on Search button
    */
    public void searchAppointments(){
        if(fromDate==NULL){
            fromDateValidation =true;
            blockConfirmBtn=true;
        }
       else if(toDate<fromDate){
            firstSection=true;
            fromDateValidation =false;
            blockConfirmBtn=true;
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select Latest date greater than Start date');
            //ApexPages.addMessage(myMsg);
        }else{
            blockConfirmBtn =false;
            fromDateValidation =false;
            selectedSlotId=null;
            firstSection=false;
            displayPb2=true;
            displayOP=true;
            AppointmentSlotRequestDTO slotRequestDTO = new AppointmentSlotRequestDTO();
            AppointmentSlotRequestDTO.Data data = new AppointmentSlotRequestDTO.Data();
            data.address = tarManager.populateSlotSiteAddress(rootCnfigId);
            data.taskItems = tarManager.populateSlotTasks(rootCnfigId);
            Datetime fromDateTime = fromDate;
            Datetime toDateTime = toDate;
            data.startDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            if(toDate==null){
                data.endDate = (fromDateTime.addDays(45)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
            }else{
                data.endDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            }
        slotRequestDTO.data = data;
        system.debug('RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
        detailsList=EWOMAppointmentManager.searchAppointment(slotRequestDTO);
        if(checkSlotsNotAvailable(detailsList))
           {
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.AppointmentUnavailable);
               ApexPages.addMessage(myMsg);
           }
           else{
               finalSlotWrapperList = populateSlotWrapper(detailsList);
               if(isCauseEvent){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.CauseEventReason.replace('<causeEventReason>', causeEventReason));
                   ApexPages.addMessage(myMsg);
               }
           }
        }
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
                slot.startDate = dt1.format('EEEE') + ', ' + dt1.format('dd-MM-yyyy');
                String startTime = availableSlot.startDate.split('T')[1].left(5);
                String endTime = availableSlot.endDate.split('T')[1].left(5);
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
            system.debug('Exception in populateSlotWrapper ' + e.getLineNUmber());
            checkCauseEvent(responseDTO);
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
        reserveAppointment(selectedSlotId,rootCnfigId,notes);
    }
    public void reserveAppointment(String slotId,String rootPCId, String notes){
        AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
        AppointmentReserveRequestDTO.Data data = new AppointmentReserveRequestDTO.Data();
        AppointmentReserveRequestDTO.Customer customer = new AppointmentReserveRequestDTO.Customer();
        try{
            String accountId = tarManager.getProdConfigAttributeValue(rootPCId,'AccountId');
            if(accountId!=null){
                for(Account acc : [select id, name, Type from Account where id =:accountId]){
                    customer.name = acc.name;
                    customer.customerclass = acc.Type;
                    break;
                }
            }
            data.customer = customer;
            data.notes = notes;
            data.contacts = tarManager.populateContactForReserveAppointment(rootPCId);
            reserveDTO.data = data;
            system.debug('reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
            HttpResponse reserveResponse = EWOMAppointmentManager.reserveAppointment(reserveDTO, slotId);
            system.debug('<><><> Response ' + reserveResponse);
            if(reserveResponse!=null && (reserveResponse.getStatusCode()==200 || reserveResponse.getStatusCode()==201)){
                List<String> urlSplit = reserveResponse.getHeader('location').split('/');
                String appointmentIDLocation = urlSplit[urlSplit.size()-1];
                String apptId = createAppointmentRecord(slotId,rootPCId,appointmentIDLocation);
                if(apptId!=null){
                    appointmentId = appointmentIDLocation;
                    createTaskRecords(detailsList,apptId);
                    showAppDetail = true;
                    isEnriched=true;
                    isEnrichedText = 'true';
                    getAppoinmentDetails(rootPCId);
                    setAppointmentIDInPC(rootPCId,'Appointment ID');
                    popupTitle = 'Booking Successful';
                    popupMessage = Label.AppointmentBooked.replace('<AppId>', appointmentIDLocation) + getAppStartEndTime(selectedSlotId);
                }else{
                    //need to handle exception for failure in creating appointment record
                    popupTitle = 'Booking Successful';
                    popupMessage = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);   
                }
            }else{
                //write something to show error while reserving appointment please try again later
                popupTitle = 'Booking Failure';
                popupMessage = Label.AppointmentFailed;   
            }
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e);
        }
    }
    
    /* Method to create Appointment Record once EWOM sends 200/201 response
    */
    public String createAppointmentRecord(String slotId, String rootPCId,String appointmentID){
        try{
            String apptId;
            String startDate = null;
            String endDate = null ;
            AppointmentSlotResponseDTO.Data data = detailsList.data;
            for(AppointmentSlotResponseDTO.AvailableSlot availableSlot : data.availableSlots){
                if(availableSlot.id == slotId){
                    startDate = availableSlot.startDate.replace('T', ' ');
                    endDate = availableSlot.endDate.replace('T', ' ');
                    break;
                }
            }
            Appointment__c apptRecord = new Appointment__c();
            apptRecord.Category__c='Telstra Installation'; //Modify this in future for category LOVs
            if(startDate!=null){apptRecord.StartDate__c = datetime.valueOf(startDate);}
            if(endDate!=null){apptRecord.EndDate__c = datetime.valueOf(endDate);}
            apptRecord.SlotId__c = appointmentID;
            apptRecord.Notes__c = notes;
            apptRecord.Product_Configuration__c = rootPCId;
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
    public void getAppoinmentDetails(String rootConfigId)
    {
        List<Appointment__c> apptList = [select SlotId__c,Category__c,EndDate__c,StartDate__c,Product_Configuration__c, Notes__c from Appointment__c where Product_Configuration__c = : rootConfigId];
        for(Appointment__c appt: apptList){
            appDetails = new Map<String,String>();
            appDetails.put('SlotId', appt.SlotId__c);
            appDetails.put('Category', appt.Category__c);
            String appDate = '';
            Time appStartTime = null;
            Time appEndTime = null;
            if(appt.StartDate__c != null)
            {
                appDate = appt.StartDate__c.date().format();
                appStartTime = appt.StartDate__c.time();
            }
            if(appt.EndDate__c != null)
            {
                appEndTime = appt.EndDate__c.time();
            }
            
            appDetails.put('Date', appDate);
            //system.debug('*************App'+ appt.StartDate__c+'*******'+appt.EndDate__c+'******'+appt.SlotId__c);
            appDetails.put('StartTime', getTime(appStartTime));
            appDetails.put('EndTime', getTime(appEndTime));
            //showAppDetail = true;
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
        if(responseDTO.data != null && responseDTO.data.availableSlots != null)
        {
    return responseDTO.data.availableSlots.isEmpty();
   }
        return true;
    }
}
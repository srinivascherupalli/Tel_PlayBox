public with sharing class AppointmentSitePageHandler {
    public List<Account> AccList {get;set;}
    public String SubscriptionId {get;set;} 
    public Boolean displayPopUp {get;set;}
    public String selectedAction {get;set;}
    public String selectedActionVF {get;set;}
    public String primaryOrderIdGlobal {get;set;}
    public String primaryOrderName {get;set;}
    public Boolean displayBookAppointment {get;set;}
    //public Boolean generateReqAppt {get;set;}
    //public GenerateAppointment__c genAppt = GenerateAppointment__c.getValues('requiredAppt');
    public Boolean displaySaveButton {get;set;}
    public String selectedSite {get;set;}
    public String hasMessageString {get;set;}
    public String bookAppointmentURL {get;set;}
    public List<csord__Subscription__c> subDetailsList {get;set;}
    public Map<String,String> viewDetailMap {get;set;}
    public Boolean isOrderSubmitted {get;set;}
    public List<SiteAppointmentWrapper> siteApptWrapperList {get;set;}
    public String AppointmentCompletedForAllsitesText {get; set;}
    public String primaryOrderStatus {get; set;}
    public String popupMessage{get; set;}
  public String suggestedDate{get; set;}
    public boolean parentAppointmentID {get;set;}
    public String parentappointment {get;set;}
    public Class SiteAppointmentWrapper{
        public String Address {get;set;}
        public String SubscriptionId {get;set;}  
        public Integer appointmentCount {get;set;}
        public List<SubscriptionAppointmentWrapper> subApptWrapperList {get;set;}
        //comment below 6 fields
        /*public String StartDate {get;set;}
        public String EndDate {get;set;}
        public String AppointmentID {get;set;}
        public Boolean isSelected {get;set;}
        public String Status {get;set;}
        public List<SelectOption> actionOptions{get;set;}*/
    } 
    
    public Class SubscriptionAppointmentWrapper{
        public Boolean iteratorFlag{get;set;}
        public String StartDate {get;set;}
        public String EndDate {get;set;}
        public String AppointmentID {get;set;}
        public Boolean isSelected {get;set;}
        public String Status {get;set;}
        public List<SelectOption> actionOptions{get;set;}
        //public String SubscriptionId {get;set;}
    }
    
    //Constructor for the method
    public AppointmentSitePageHandler()
    {
        parentAppointmentID = false;
        system.debug('currentURL ' + ApexPages.currentPage().getURL()); //fetches the parameters from the url
        String currentURL = ApexPages.currentPage().getURL();
        bookAppointmentURL = currentURL;
        String[] urlArray = currentURL.split('id=');
        String primaryOrderId ='';
        if(urlArray.size()>1){
            primaryOrderId = urlArray[1];
        }
        String unescapedParam = ApexPages.currentPage().getParameters().get('id');
        primaryOrderIdGlobal = EncodingUtil.urlEncode(unescapedParam,'UTF-8');
        //primaryOrderIdGlobal = primaryOrderId;
        system.debug('<><><> R' + primaryOrderIdGlobal);
        siteApptWrapperList = getSubscriptions(primaryOrderIdGlobal);
        getPrimaryOrderDetails(primaryOrderIdGlobal);
        checkPrimaryOrderStatus(primaryOrderIdGlobal);
        popupMessage='All required appointments have been scheduled. This order can now be submitted.';
        //pollAppointmentStatus(); 
    }
    
    public void checkPrimaryOrderStatus(String orderID){
        try{
            for(csord__Order__c ord : [select id,csord__Status2__c from csord__Order__c where id =:orderID]){
                if(ord.csord__Status2__c == 'Appointment Required' || ord.csord__Status2__c == 'MSISDN Required'){
                    isOrderSubmitted = false;
                    primaryOrderStatus = 'Appointment Required';
                }else{isOrderSubmitted = true;}
            }
        }catch(Exception e){
            system.debug('Exception in checkPrimaryOrderStatus ' + e);
        }
    }
    /*Method to check  Subsription on Order*/
    public List<SiteAppointmentWrapper> getSubscriptions(String orderID)
    {
        List<SiteAppointmentWrapper> wrapperList = new List<SiteAppointmentWrapper>();
        List<String> subIDList = getAllSubscriptions(orderID);
        List<csord__Subscription__c> subList  = [select id, Site__r.Display_Name__c,(select SlotId__c,Parent_Appt_ID__c,
                                                StartDate__c,EndDate__c,Status__c,CreatedDate from Appointments__r 
                                                order by CreatedDate desc) from csord__Subscription__c 
                                                where id in : subIDList AND Site__r.Display_Name__c != null]; 
       for(csord__Subscription__c sub : subList){
            SiteAppointmentWrapper wrapper = new SiteAppointmentWrapper();
            List<SubscriptionAppointmentWrapper> subApptWrapperLst = new List<SubscriptionAppointmentWrapper>();
           
            wrapper.Address = '' + sub.Site__r.Display_Name__c;
            wrapper.SubscriptionId = sub.Id;
            wrapper.appointmentCount =1;
            List<Appointment__c> appList = [select id from Appointment__c where Subscription__c = :sub.Id];
            if(appList!=null && appList.size()>0){
                wrapper.appointmentCount = appList.size();
                Boolean dummyFlag= true;
                for(Appointment__c appt : sub.Appointments__r){
                    SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                    List<Selectoption> actionList2  = new List<Selectoption>();
                    List<String> rescheduleStatus = System.Label.Reschedule_Status_of_Appt.Split(',');
                    List<String> completeStatus = System.Label.Complete_Status_of_Appt.Split(',');
                    actionList2.add(new selectOption('None','--None--'));
                    if(appt.Status__c =='Partial Complete'){
                        //actionList.add(new selectOption('View Details','View Details'));
                        //actionList.add(new selectOption('Rebook','Rebook'));
                        actionList2.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('Rebook','Rebook'));
                        parentAppointmentID = true;
                    }
                    if(rescheduleStatus.contains(appt.Status__c)){
                        //actionList.add(new selectOption('View Details','View Details'));
                        //actionList.add(new selectOption('Reschedule','Reschedule'));
                        actionList2.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('Reschedule','Reschedule'));
                    }
                    if(completeStatus.contains(appt.Status__c)){
                        //actionList.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('View Details','View Details'));
                    }
                    if(appt.StartDate__c != null){
                        //wrapper.StartDate = appt.StartDate__c.format('dd/MM/yyyy') + ' ' +appt.StartDate__c.format('hh:mm a');    
                        subApptWrapper.StartDate = appt.StartDate__c.format('dd/MM/yyyy') + ' ' +appt.StartDate__c.format('hh:mm a');   
                    }else{
                        //wrapper.StartDate = '';
                        subApptWrapper.StartDate = '';
                    }
                    if(appt.EndDate__c!=null){
                        //wrapper.EndDate =appt.EndDate__c.format('dd/MM/yyyy') + ' ' +appt.EndDate__c.format('hh:mm a');
                        subApptWrapper.EndDate =appt.EndDate__c.format('dd/MM/yyyy') + ' ' +appt.EndDate__c.format('hh:mm a');
                    }else{
                        //wrapper.EndDate = ''; 
                        subApptWrapper.EndDate = '';
                    }
                    //wrapper.Status= '' + appt.Status__c;
                    subApptWrapper.Status = '' + appt.Status__c;
                    //wrapper.AppointmentID = '' + appt.SlotId__c;
                    subApptWrapper.AppointmentID = '' + appt.SlotId__c;
                    subApptWrapper.actionOptions = actionList2;
                    subApptWrapper.isSelected=false;
                    subApptWrapper.iteratorFlag= dummyFlag;
                    dummyFlag = false;
           
                    subApptWrapperLst.add(subApptWrapper);
                }
            }else{
                SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                subApptWrapper.iteratorFlag= true;
                List<Selectoption> actionList2  = new List<Selectoption>();
                actionList2.add(new selectOption('None','--None--'));
                actionList2.add(new selectOption('Schedule','Schedule'));
                /*if(genAppt.IsGenerateAppointment__c == false){
                actionList2.add(new selectOption('Generate Appointment','Generate Appointment'));
                }*/
                subApptWrapper.actionOptions = actionList2;
                subApptWrapperLst.add(subApptWrapper);
            }
            wrapper.subApptWrapperList = subApptWrapperLst;
            wrapperList.add(wrapper);
            //comment below 3 lines
            /*if(appList==null || (appList!=null && appList.size()==0)){
                actionList.add(new selectOption('Schedule','Schedule'));
            }*/
            
            //comment below two lines
            //wrapper.actionOptions = actionList;
            //wrapper.isSelected=false;
            

        }
        //csord__Order__c ord =[select recordtype.name from csord__Order__c where id =:orderID];
        
        pollAppointmentStatus();  
        return wrapperList;
    }
    public void getPrimaryOrderDetails(String orderID){
        for(csord__Order__c ord : [select id, name, csordtelcoa__Opportunity__r.name, csord__Status2__c from csord__Order__c where id =:orderID]){
            primaryOrderName = ord.name;
            primaryOrderStatus=ord.csord__Status2__c;
            break;
        }
    }
    public void reRenderApptDetails(){
        siteApptWrapperList = getSubscriptions(primaryOrderIdGlobal);
    }
    public void closePopup() {        
        displayPopUp = false;    
    }     
    public void setBookAppointmentParams(){
        displayBookAppointment = true;
        //generateReqAppt = false;
        for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c from csord__Subscription__c where id =:SubscriptionId]){
            selectedSite = sub.Site__r.Display_Name__c;
        }
    }
    
    // EDGE: 66226
    
    /*public void generateAppointmentBOM() {
            displayBookAppointment = true;
            generateReqAppt = true;
            for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where id =:SubscriptionId]){
            selectedSite = sub.Site__r.Display_Name__c;
      suggestedDate= AppointmentService.generateAppointment(sub);
      //suggestedDate=Datetime.valueOf(aptres);
      system.debug('suggestedDate**' +suggestedDate);
       
       }
    } */
    
    public void clearAllOnNoneAction(){
        displayPopUp = false;
        displayBookAppointment = false;
        //generateReqAppt= false;
    }
    public void setPrimaryOrderID(){}
    public void getAppDetails()
    {
        system.debug('selected Action in VF ' + selectedActionVF);
        if(selectedActionVF == 'View Details')
        {
            displayBookAppointment = false;
            //generateReqAppt = false;
            displayPopUp = true;
            List<String> roleList = new List<String>{'Primary Site Contact','Technical Contact'};
            String apptID = '';
            String apptStatus ='';
            String apptStartDate ='';
            String apptEndDate ='';
            String apptLastModifiedDate ='';
            String createdBy ='';
            String primaryContactName = '';
            String primaryContactPhone = '';
            String technicalContactName = '';
            String technicalContactPhone = '';
            String parentappointment = '';
            
            for(csord__Subscription__c sub : [select id, site__c from csord__Subscription__c where id =:SubscriptionId]){
                List<Functional_Contact_Role__c> contactlist = [select ContactID__r.Name ,ContactID__r.Phone,Role__c from Functional_Contact_Role__c where SiteID__c =: sub.site__c and Role__c in : roleList];
                for(Functional_Contact_Role__c contactRole : contactlist ){
                    if(contactRole.Role__c=='Primary Site Contact'){
                        primaryContactName = contactRole.ContactID__r.Name;
                        if(contactRole.ContactID__r.Phone !=null){
                            primaryContactPhone = contactRole.ContactID__r.Phone;    
                        }else{
                            primaryContactPhone = '';
                        }
                        
                    }
                    else if(contactRole.Role__c=='Technical Contact') {
                        technicalContactName = contactRole.ContactID__r.Name;
                        if(contactRole.ContactID__r.Phone !=null){
                            technicalContactPhone = contactRole.ContactID__r.Phone;    
                        }else{
                            technicalContactPhone = '';
                        }
                    }
                }
                break;
            }
            
            List<csord__Subscription__c> subList  = [select id, Site__r.Display_Name__c,(select SlotId__c,Parent_Appt_ID__c,StartDate__c,EndDate__c,Status__c,CreatedById,CreatedDate from Appointments__r order by SlotId__c Desc) from csord__Subscription__c where id =:SubscriptionId];
            viewDetailMap = new Map<String,String>();
            for(csord__Subscription__c sub : subList){
                viewDetailMap.put('address',sub.Site__r.Display_Name__c);
                viewDetailMap.put('subscriptionID',sub.id);
                 for(Appointment__c appt : sub.Appointments__r){
                     apptID  = appt.SlotId__c;
                     apptStatus = appt.Status__c;
                     if(appt.Parent_Appt_ID__c != '' || appt.Parent_Appt_ID__c != NULL){
                     parentappointment = appt.Parent_Appt_ID__c;
                        }
                     if(appt.StartDate__c!=null){
                        apptStartDate = appt.StartDate__c.format('dd/MM/yyyy') + ' ' +appt.StartDate__c.format('hh:mm a');    
                     }else{apptStartDate='';}
                     if(appt.EndDate__c!=null){
                        apptEndDate =appt.EndDate__c.format('dd/MM/yyyy') + ' ' +appt.EndDate__c.format('hh:mm a');    
                     }else{apptEndDate = '';}
                     if(appt.CreatedDate!=null){
                        apptLastModifiedDate = appt.CreatedDate.format('dd/MM/yyyy') + ' ' +appt.CreatedDate.format('hh:mm a');    
                     }else{apptLastModifiedDate = '';}
                     for(User us :[select id,email from User where id=:appt.CreatedById]){
                        createdBy =us.email;      
                         break;
                     }
                     break;
                }
                break;
            }
            viewDetailMap.put('appointmentID',apptID);
            viewDetailMap.put('status',apptStatus);
            viewDetailMap.put('startDate',apptStartDate);
            viewDetailMap.put('endDate',apptEndDate);
            viewDetailMap.put('lastModifiedDate',apptLastModifiedDate);
            viewDetailMap.put('createdBy',createdBy);
            viewDetailMap.put('primaryContactName',primaryContactName);
            viewDetailMap.put('primaryContactPhone',primaryContactPhone);
            viewDetailMap.put('technicalContactName',technicalContactName);
            viewDetailMap.put('technicalContactPhone',technicalContactPhone);
            viewDetailMap.put('parentappointment',parentappointment);
        }
    }
    
    public void pollAppointmentStatus(){
        try{
            List<String> subIDList = getAllSubscriptions(string.valueof((primaryOrderIdGlobal)));
            List<csord__Subscription__c> subList  = [select id, (select Status__c from Appointments__r) from csord__Subscription__c where id in :subIDList]; 
            List<Appointment__c> apptList = [select id from Appointment__c where Subscription__c in : subList];
            system.debug('apptList ' + apptList.size());
            if(apptList!=null && apptList.size()>=subList.size()){
                displaySaveButton = true;
                AppointmentCompletedForAllsitesText='true';
                //setPrimaryOrderStatus();
            }else{
                //hasMessageString = 'true';
                //createError(ApexPages.Severity.ERROR,'Appointment should be scheduled for all the sites to proceed.');
                //return null;
            }
        }catch(Exception e){
            hasMessageString = 'true';
            createError(ApexPages.Severity.ERROR,'Error.');
            system.debug('Exception in pollAppointmentStatuspollAppointmentStatus ' + e);
            //return null;
        }
    }
    
    public void setPrimaryOrderStatus(){
        try{
            Map<String,Id> recordTypeMap = new Map<String,Id>();
            List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
            
            for(RecordType recObj:orderRecordTypeList)
            {
                 recordTypeMap.put(recObj.Name,recObj.Id);           
            }
            for(csord__Order__c primaryOrder : [select id,csord__Status2__c,RecordTypeId, isMSISDNRequired__c,isMSISDNReserved__c,isAppointmentCompleted__c from csord__Order__c where id =:primaryOrderIdGlobal]){
                if (primaryOrder.isMSISDNRequired__c == true){
          
          if(primaryOrder.isMSISDNReserved__c == true){
            primaryOrder.csord__Status2__c = 'Ready for Submit';
            primaryOrder.RecordTypeId = recordTypeMap.get('Ready for Submit With Appointment');
            primaryOrder.isAppointmentCompleted__c = true;
            update primaryOrder;
            
            
          }
          else{
            primaryOrder.csord__Status2__c = 'MSISDN Required';
            primaryOrder.RecordTypeId =recordTypeMap.get('MSISDN Required');
            primaryOrder.isAppointmentCompleted__c = true;
            update primaryOrder;
          }
          
        }
        else{
          primaryOrder.csord__Status2__c = 'Ready for Submit';
          primaryOrder.RecordTypeId = recordTypeMap.get('Ready for Submit With Appointment');
          primaryOrder.isAppointmentCompleted__c = true;
          update primaryOrder;
          
        }
            }
            /*PageReference pageRef = new PageReference('/' + primaryOrderIdGlobal);
            pageRef.setRedirect(true);
            return pageRef;*/
            
        }
        catch(Exception e){
            //return null;
        }
    }
    
    public PageReference navigateBackToPrimaryOrder(){
        try{
            PageReference pageRef = new PageReference('/' + primaryOrderIdGlobal);
            pageRef.setRedirect(true);
            return pageRef;
        }catch(Exception e){
            return null;
        }
    }
    public List<String> getAllSubscriptions(String orderID){
        List<String> subList = new List<String>();
        try{
            Set<Id> setSubscriptionIds = new Set<Id>();
            for(csord__Subscription__c sub : [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :orderID]){
                setSubscriptionIds.add(sub.id);
            }
            //for(csord__Subscription__c sub : [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :orderID]){
               for(csord__Service__c serv : [select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c IN: setSubscriptionIds]){
                  if(serv.Appointment_Required__c == 'true'){
                      subList.add(''+serv.csord__Subscription__c);
                    // break;
                  }
                }
           //}
            return subList;
        }catch(Exception e){
            system.debug('Exception in getAllSubscriptions ' + e);
            return subList;
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
        }
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
    public PageReference OKPopup(){
        system.debug('AppointmentCompletedForAllsitesText@@'+AppointmentCompletedForAllsitesText);
        if(AppointmentCompletedForAllsitesText=='true'){
            setPrimaryOrderStatus();
        }
        return navigateBackToPrimaryOrder();    
    }
}
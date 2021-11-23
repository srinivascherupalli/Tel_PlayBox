/*

Class Name: AppointmentBOMSitePageHandler
ChagneSet No    Name            Date                    Description
CH-1            Ila/pradeep/jawahar/Aishwarya         04/16/2019       
CH-2            Mahima         04/16/2019         Made Small changes related to Pop show and hide for reschedule/rebook*/

public with sharing class AppointmentBOMSitePageHandler {
    public List<Account> accList {get;set;}
    public String SubscriptionId {get;set;} 
    public String Category {get;set;}
    public Boolean displayPopUp {get;set;}
    public String selectedAction {get;set;}
    public String selectedActionVF {get;set;}
    public String primaryOrderIdGlobal {get;set;}
    public String unescapedURL {get;set;}
    public String primaryOrderName {get;set;}
    public Integer reqAppCount {get;set;}
    public Boolean displayBookAppointment {get;set;}
    public Boolean generateReqAppt {get;set;}
    public Boolean isSchedule{get;set;}
    public List<requiredAppointmentWrapper> reqWrapperList {get;set;}
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
    public String suggDate {get;set;}
    public boolean parentAppointmentID {get;set;}
    public String AppointmentID {get;set;}
    public String parentappointment {get;set;}
    public boolean displayRescPopUp {get;set;}
    public String ApptId { get; set; }
    //EDGE-66476
    public List<Appointment__C> lstRequiredAppt{ get; set;}
    public boolean isAllRescheduled{get ;set;}
    
    public Class SiteAppointmentWrapper{
        public String Address {get;set;}
        public String SubscriptionId {get;set;}  
        public Integer appointmentCount {get;set;}
        public Integer reqAppCountNew {get;set;}
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
        //EDGE-66476- start
        public boolean isRescheduleRequired {get; set;}
        public  string suggestedRescheduleDate{get; set;}
        public string AppointmentCategory {get; set;}           
        //EDGE-66476- end
        //EDGE-85996.- start
        public boolean IsParent {get; set;}
        public string ParentApptID {get; set;}
         //EDGE-85996.- end
        //public String SubscriptionId {get;set;}
    }
    
    
    public Class RequiredAppointmentWrapper  {
        public String SubscriptionId {get;set;}
        public String appointmentID {get;set;}
        public String appointmentCategory {get;set;}  
        public String sequenceofAppointment {get;set;}  
        public Integer Count {get;set;}  
        public Boolean disable {get;set;} 
        //EDGE-84616            
        public String CategoryName {get;set;}  
    }
    
    //Constructor for the method
    public AppointmentBOMSitePageHandler ()
    {
        parentAppointmentID = false;
        //EDGE-66476
        isAllRescheduled=true;
        
        system.debug('currentURL ' + ApexPages.currentPage().getURL()); //fetches the parameters from the url
        String currentURL = ApexPages.currentPage().getURL();
        unescapedURL = EncodingUtil.urlEncode(currentURL,'UTF-8');
        bookAppointmentURL = unescapedURL;
        String[] urlArray = unescapedURL.split('id=');
        String primaryOrderId ='';
        if(urlArray.size()>1){
            primaryOrderId = urlArray[1];
        }
        String unescapedParam = ApexPages.currentPage().getParameters().get('id');
        primaryOrderIdGlobal = EncodingUtil.urlEncode(unescapedParam,'UTF-8');
        //primaryOrderIdGlobal = primaryOrderId;
        system.debug('<><><> R' + primaryOrderIdGlobal);
        reqWrapperList = requiredAppointmentValues(primaryOrderIdGlobal);
        
        system.debug('<><><> Prerequiste' + reqWrapperList.size() );
        siteApptWrapperList = getSubscriptions(primaryOrderIdGlobal);
        system.debug('Site Daata'+siteApptWrapperList.size() );
        getPrimaryOrderDetails(primaryOrderIdGlobal);
        checkPrimaryOrderStatus(primaryOrderIdGlobal);
        popupMessage='All required appointments have been scheduled. This order can now be submitted.';
        //pollAppointmentStatus(); 
        isSchedule=true;
        
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
        //EDGE-66476- Modified Query for Reschdeule_required__c,Suggested_Start_Date__c,Category__c
        List<csord__Subscription__c> subList  = [select id, Site__r.Display_Name__c,(select SlotId__c,Parent_Appt_ID__c,
                                                                                     StartDate__c,EndDate__c,Status__c,CreatedDate, Reschdeule_required__c,
                                                                                     Suggested_Start_Date__c,Category__c from Appointments__r 
                                                                                     order by CreatedDate desc) from csord__Subscription__c 
                                                 where id in : subIDList AND Site__r.Display_Name__c != null]; 
        for(csord__Subscription__c sub : subList){
            SiteAppointmentWrapper wrapper = new SiteAppointmentWrapper();
            //EDGE-85996
            Map<string, Appointment__c> parentDataMap= new Map<string, Appointment__c>();
            
            List<SubscriptionAppointmentWrapper> subApptWrapperLst = new List<SubscriptionAppointmentWrapper>();
            
            wrapper.Address = '' + sub.Site__r.Display_Name__c;
            wrapper.SubscriptionId = sub.Id;
            wrapper.appointmentCount =0;
            wrapper.reqAppCountNew = 0;
            //66462 - Fix for appointment status
            List<Required_Appointment__c> reqList= [select id,Generate_Appointment_Subscription__c,Generate_Appointment_Subscription__r.id,Appointment_BOM_ID__c,Appointment_Category__c,Generate_Appointment_Order__c,required_AppointmentCount__c, Sequence_of_Appointment__c,LeadTime_Days__c  from Required_Appointment__c  where Generate_Appointment_Subscription__c =:sub.Id order by Sequence_of_Appointment__c];
            if(reqList.size() == 1)
              {
             wrapper.reqAppCountNew = 1;
              }
             if(reqList.size() == 2)
             {
             wrapper.reqAppCountNew = 2;
             }
            
            List<Appointment__c> appList = [select id from Appointment__c where Subscription__c = :sub.Id];
            if(appList!=null && appList.size()>0){
                
                
                wrapper.appointmentCount = appList.size();
                    if(appList.size()>2)
                    {
                        wrapper.appointmentCount = 2;
                    }
                Boolean dummyFlag= true;
                for(Appointment__c appt : sub.Appointments__r){
                    SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                    List<Selectoption> actionList2  = new List<Selectoption>();
                    actionList2.add(new selectOption('None','--None--'));
                    if(appt.Status__c =='Partial Complete'){
                        //actionList.add(new selectOption('View Details','View Details'));
                        //actionList.add(new selectOption('Rebook','Rebook'));
                        actionList2.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('Rebook','Rebook'));
                        parentAppointmentID = true;
                    }
                    if(appt.Status__c == 'SCHEDULED' || appt.Status__c == 'Assigned'){
                        //actionList.add(new selectOption('View Details','View Details'));
                        //actionList.add(new selectOption('Reschedule','Reschedule'));
                        actionList2.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('Reschedule','Reschedule'));
                    }
                    if(appt.Status__c == 'Complete' || appt.Status__c == 'Onsite' || appt.Status__c == 'Dispatched'){
                        //actionList.add(new selectOption('View Details','View Details'));
                        actionList2.add(new selectOption('View Details','View Details'));
                    }
                    if(appt.StartDate__c != null){
                        subApptWrapper.StartDate = appt.StartDate__c.format('dd/MM/yyyy') + ' ' +appt.StartDate__c.format('hh:mm a');    
                          
                    }else{
                        //wrapper.StartDate = '';
                        subApptWrapper.StartDate = '';
                    }
                    if(appt.EndDate__c!=null){
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
                    //EDGE-66476- start
                    subApptWrapper.AppointmentCategory=appt.Category__c;
                    if(appt.Reschdeule_required__c != null && appt.Reschdeule_required__c){
                        subApptWrapper.isRescheduleRequired= appt.Reschdeule_required__c;
                        Integer d = appt.Suggested_Start_Date__c.day();
                        Integer mo = appt.Suggested_Start_Date__c.month();
                        Integer yr = appt.Suggested_Start_Date__c.year();
                        
                        subApptWrapper.suggestedRescheduleDate= DateTime.newInstance(yr, mo, d).format('dd/MM/yyyy');
                        //subApptWrapper.suggestedRescheduleDate= appt.Suggested_Start_Date__c.format('dd/MM/yyyy');
                        //subApptWrapper.suggestedRescheduleDate = appt.Suggested_Start_Date__c.format('MM/dd/yyyy');   
                        isAllRescheduled=false;
                    }
                    //system.debug('appt date==> '+appt.Suggested_Start_Date__c+' '+ appt.Suggested_Start_Date__c)    ;               
                    //EDGE-66476- end
                    //EDGE-85996-start
                    subApptWrapper.ParentApptID=appt.Parent_Appt_ID__c;
                    if(appt.Parent_Appt_ID__c!= null && appt.Parent_Appt_ID__c!='')
                    {
                        parentDataMap.put(appt.Parent_Appt_ID__c,appt);
                    }
                    //EDGE-85996- end
                    subApptWrapper.iteratorFlag= dummyFlag;
                    dummyFlag = false;
                    
                    subApptWrapperLst.add(subApptWrapper);
                }
                
                //EDGE-84616- start
                /*if(appList.size()==1)
                {
                    SubscriptionAppointmentWrapper subApptWrapperEx= subApptWrapperLst[0];
                    
                    SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                    if(subApptWrapperEx.AppointmentCategory=='NBN')
                    {subApptWrapper.AppointmentCategory='Telstra Installation';}
                    else{subApptWrapper.AppointmentCategory='NBN';}
                    subApptWrapperLst.add(subApptWrapper);  
                }*/
                //EDGE-84616- start
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
            
            system.debug('subApptWrapperLst==>'+subApptWrapperLst.size()); 
            //EDGE-85996- start
            integer nbnCount=0;
            integer telstraCount=0;
            List<AggregateResult> lstAppt = [select count(id) recCount,category__c from Appointment__c where Subscription__c = :sub.Id group by category__c ]; 
            system.debug('lstAppt'+lstAppt);    
            if(lstAppt!= null && lstAppt.size()>0)
            {
                for (AggregateResult ag: lstAppt)
                {  
                    Integer count= integer.valueof(ag.get('recCount'));
                    String apptCategory= string.valueof(ag.get('category__c'));
                    if(apptCategory=='NBN')
                    {
                        nbnCount=count;
                    }
                    if(apptCategory=='TELSTRA')
                    {
                        telstraCount=count;
                    }                
                }
                SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                if(telstraCount==0)
                {
                    subApptWrapper.AppointmentCategory='TELSTRA';
                    subApptWrapperLst.add(subApptWrapper);
                }
                if(nbnCount==0){
                    subApptWrapper.AppointmentCategory='NBN';
                    subApptWrapperLst.add(subApptWrapper);
                }
            }
            //To check if the appointment is once rebooked or not.
            Set<string> lstparentIds=parentDataMap.keyset();
            for(SubscriptionAppointmentWrapper saw:subApptWrapperLst)
            {
                if(lstparentIds.contains(saw.AppointmentID))
                {
                    saw.IsParent= true;
                }
            }
            //EDGE-85996- end
            
            wrapper.subApptWrapperList = subApptWrapperLst;
            wrapperList.add(wrapper);           
        }
        //csord__Order__c ord =[select recordtype.name from csord__Order__c where id =:orderID];
        isSchedule=true;
        pollAppointmentStatus();  
        return wrapperList;
    }
    
    //EDGE - 66462
    public List<requiredAppointmentWrapper> requiredAppointmentValues(String orderID)
    {
        
        List<Required_Appointment__c> reqAppList= [select id,Generate_Appointment_Subscription__c,Generate_Appointment_Subscription__r.id,Appointment_BOM_ID__c,Appointment_Category__c,Generate_Appointment_Order__c,required_AppointmentCount__c, Sequence_of_Appointment__c,LeadTime_Days__c  from Required_Appointment__c  where Generate_Appointment_Order__c =:orderID order by Sequence_of_Appointment__c];
        system.debug('reqAppList size'+ reqAppList.size());
        requiredAppointmentWrapper reqWrap;
        List<requiredAppointmentWrapper> reqWrapList = new List<requiredAppointmentWrapper>();
        if(!reqAppList.isEmpty())
        {
            for (Required_Appointment__c reqApp : reqAppList)
            {
                reqWrap= new requiredAppointmentWrapper();
                reqWrap.SubscriptionId=reqApp.Generate_Appointment_Subscription__c;
                reqWrap.appointmentID=reqApp.Appointment_BOM_ID__c;
                //EDGE-84616
                reqWrap.CategoryName=reqApp.Appointment_Category__c;                
                if (reqApp.Appointment_Category__c == 'TELSTRA' && reqApp.Sequence_of_Appointment__c == '2') 
                {
                    system.debug('reqApp.Appointment_Category__c +' +reqApp.Appointment_Category__c );                    
                    if (reqApp.LeadTime_Days__c != null)
                    {
                        reqWrap.appointmentCategory=reqApp.Appointment_Category__c+ ' Appointment (+'+reqApp.LeadTime_Days__c+' days after NBN Appointment)';
                    }
                    else
                    {
                        reqWrap.appointmentCategory=reqApp.Appointment_Category__c+ ' Appointment';
                    }
                    
                    reqAppCount = 2;
                List<Appointment__c>  appList = [select id,status__c,Category__c from Appointment__c where Subscription__c = :reqApp.Generate_Appointment_Subscription__c ];
                if(appList.isEmpty() && appList.size()<1)
                    {
                        reqWrap.disable = true;
                } else
                {
                reqWrap.disable = false;
                    }                    
                }
                else
                {
                    reqWrap.appointmentCategory=reqApp.Appointment_Category__c+ ' Appointment';
                    reqAppCount = 1;
                    reqWrap.disable = false;
                }    
                reqWrap.sequenceofAppointment=reqApp.Sequence_of_Appointment__c;
                reqWrap.Count=reqAppList.Size();                
                reqWrapList.add(reqWrap);
            }
        }
        system.debug('<><><> Prerequiste' + reqWrapperList+'reqAppList'+ reqAppList);
        system.debug('reqWrapList size'+ reqWrapList.size());
        return reqWrapList;
    }
    
     /*public static void generateAppointmentForErrorScenario(String orderId,String SubscriptionId)
    {
                AppointmentServiceCallout apc = new AppointmentServiceCallout();
                apc.generateAppointmentForErrorScenario(orderId,SubscriptionId);
    }*/
    
    
    public void getPrimaryOrderDetails(String orderID){
        for(csord__Order__c ord : [select id, name, csordtelcoa__Opportunity__r.name, csord__Status2__c from csord__Order__c where id =:orderID]){
            primaryOrderName = ord.name;
            primaryOrderStatus=ord.csord__Status2__c;
            break;
        }
    }
    public void reRenderApptDetails(){
        system.debug('reRenderApptDetails');
        isSchedule=true;
        displayBookAppointment=false;
        displayRescPopUp=false;
        //EDGE-66476
        isAllRescheduled= true;
        reqWrapperList = requiredAppointmentValues(primaryOrderIdGlobal);
        siteApptWrapperList = getSubscriptions(primaryOrderIdGlobal);
        
    }
    public void closePopup() {        
        displayPopUp = false;   
        //EDGE-66437
        displayRescPopUp= false;
    }     
    public void setBookAppointmentParams(){
        //EDGE-66437
        displayRescPopUp = true;
        
        generateReqAppt = false;
        for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c from csord__Subscription__c where id =:SubscriptionId]){
            selectedSite = sub.Site__r.Display_Name__c;
        }
    }
    
    // EDGE: 66226
    
    public void generateAppointmentBOMQ() {
        system.debug('in generateapp');
        system.debug('Category=' +Category );    
        displayBookAppointment = true;
        generateReqAppt = true;
        for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where id =:SubscriptionId]){
            selectedSite = sub.Site__r.Display_Name__c;
            String str = Category.substringBefore(' ');
            system.debug('categorydate+' +str);
            /*Required_Appointment__c reqAppt = [Select Appointment_Category__c,Generate_Appointment_Subscription__c from Required_Appointment__c where Generate_Appointment_Subscription__c =:sub.Id and Appointment_Category__c=:str order by createddate limit 1];
category = reqAppt.Appointment_Category__c;
system.debug('category**' +category);*/
            suggestedDate= AppointmentServiceCallout.getSuggestedDate(sub.Id,str);
            system.debug('suggestedDate**' +suggestedDate);
            //suggDate=String.valueOf(suggestedDate);
            //system.debug('suggDate**' +suggDate);
            
        }
    } 
    
    public void clearAllOnNoneAction(){
        displayPopUp = false;
        displayBookAppointment = false;
        generateReqAppt= false;
    }
    public void setPrimaryOrderID(){}
    public void getAppDetails()
    {
        system.debug('AppointmentID++' +AppointmentID);
        system.debug('in getAppdetails ');
        //if(selectedActionVF == 'View Details')
        isSchedule=true;
        displayBookAppointment = false;
        generateReqAppt = false;
        displayPopUp = true;
        List<String> roleList = new List<String>{'Primary Site Contact','Technical Contact'};
            String appttID = '';
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
                if(appt.SlotId__c == this.Apptid){
                    appttID  = appt.SlotId__c;
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
            }
            break;
        }
        viewDetailMap.put('appointmentID',appttID);
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
        system.debug('viewDetailMap++' +viewDetailMap);
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
        system.debug('In subscrption');
        List<String> subList = new List<String>();
        try{
            // CH-1 Start
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
            // CH-1 END
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
    /*private string getTime(Time tm)
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
}*/ 
    public PageReference oKPopup(){
        system.debug('AppointmentCompletedForAllsitesText@@'+AppointmentCompletedForAllsitesText);
        if(AppointmentCompletedForAllsitesText=='true'){
            setPrimaryOrderStatus();
        }
        return navigateBackToPrimaryOrder();    
    }
   

}
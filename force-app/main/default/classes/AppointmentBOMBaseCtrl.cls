//Class to paste on dev
/*Author: Mahima, Kalashree, Ila
Company: Tesltra 
User Story :EDGE-66472, EDGE-84934,EDGE-66471 
Description: Lightning UI controller.
*/
public with sharing class AppointmentBOMBaseCtrl {
    
    public static AppointmentSearchResponseDTO detailsList{get;set;}
    
    public static AppointmentBOMReserveResponseDTO reserveResponse{get;set;}
    
    public static String parentApptId {get;set;}
    
    //UI Response after appointment reservation
    public Class ConfirmResponseWrapper{
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String address {get;set;}
        @AuraEnabled
        public String subscriptionName {get;set;}
        @AuraEnabled
        public String apptDate {get;set;}
        @AuraEnabled
        public String apptTime {get;set;}
        @AuraEnabled
        public String apptId {get;set;}
    }
    
    //Site details wrapper
    public Class SiteAppointmentWrapper{
        @AuraEnabled
        public String Address {get;set;}
        @AuraEnabled
        public String SubscriptionId {get;set;}   
        @AuraEnabled
        public String orderId {get;set;}     
        @AuraEnabled
        public Integer appointmentCount {get;set;}
        @AuraEnabled
        public List<SubscriptionAppointmentWrapper> subApptWrapperList {get;set;}
        @AuraEnabled
        public String subscriptionName {get;set;}
        @AuraEnabled
        public Integer reqAppCount {get;set;}
        @AuraEnabled
        public Boolean appNotRequired {get;set;}
    }
    
    //Subscription details wrapper
    public Class SubscriptionAppointmentWrapper{
        @AuraEnabled
        public Boolean iteratorFlag{get;set;}
        @AuraEnabled
        public Boolean isScheduled{get;set;}
        @AuraEnabled
        public String SubsId {get;set;}
        @AuraEnabled
        public String ApptDate {get;set;}
        @AuraEnabled
        public String apptDay {get;set;}
        @AuraEnabled
        public Date ApptDateDT {get;set;}
        @AuraEnabled
        public String ApptTime {get;set;}
        @AuraEnabled
        public String AppointmentID {get;set;}
        @AuraEnabled
        public Boolean isSelected {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public List<SelectOption> actionOptions{get;set;}        
        @AuraEnabled
        public boolean isRescheduleRequired {get; set;}
        @AuraEnabled
        public  string suggestedRescheduleDate{get; set;}
        @AuraEnabled
        public string Category {get; set;} 
        @AuraEnabled
        public boolean IsParent {get; set;}
        @AuraEnabled
        public string ParentApptID {get; set;}         
    }
    
    //Required Appointment wrapper
    public Class RequiredAppointmentWrapper  {
        @AuraEnabled
        public String SubscriptionId {get;set;}
        @AuraEnabled
        public String appointmentID {get;set;}
        @AuraEnabled
        public String orderId{get;set;} 
        @AuraEnabled
        public String appointmentCategory {get;set;} 
        @AuraEnabled
        public String sequenceofAppointment {get;set;}
        @AuraEnabled
        public Integer Count {get;set;}  
        @AuraEnabled
        public Boolean disable {get;set;} 
        @AuraEnabled
        public String CategoryName {get;set;}  
        @AuraEnabled
        public String leadTime {get;set;}   
        @AuraEnabled
        public Date fromDate {get;set;}  
    }
    
    //Wrapper for callout parameters
    public class SearchReserveWrapper {
        @AuraEnabled
        public String subsID {get;set;}  
        @AuraEnabled
        public String operation{get;set;}  
        @AuraEnabled
        public String startDate{get;set;}  
        @AuraEnabled
        public String endDate{get;set;}  
        @AuraEnabled
        public String Category{get;set;}  
        @AuraEnabled
        public String parentApptId{get;set;}
        @AuraEnabled
        public String selectedRescheduleInitiator {get;set;} 
        @AuraEnabled
        public String selectedRescheduleReason {get;set;}
        @AuraEnabled
        public String slotId {get;set;}
        @AuraEnabled
        public String notes {get;set;}
    }
    
    //Slot details wrapper
    public class SlotWrapper{
        @AuraEnabled
        public String startDate{get;set;}
        @AuraEnabled
        public Integer availableSlots{get;set;}
        @AuraEnabled
        public Map<String,String> slotDetail{get;set;}
        @AuraEnabled
        public Set<String> keySetList {get;set;}
    }
    //Wrapper for BaseRuleProducts - EDGE-101122 
    public Class BaseRuleWrapper {
        String productInstanceID;
        String productID;
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getOrder 
Description: get Order details 
Author:Ila Anmol Verma
--------------------------------------------------------*/
    @AuraEnabled
    public static csord__Order__c getOrder(Id orderId) {
        return [SELECT Name FROM csord__Order__c WHERE Id = :orderId];
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getAllSubscriptions 
Description: get Subscriptions details 
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<String> getAllSubscriptions(Id orderId){
        system.debug('In subscrption');
        List<String> subList = new List<String>();
        try{
            Set<Id> setSubscriptionIds = new Set<Id>();
            map<id,csord__Subscription__c> mapSubscription = new map<id,csord__Subscription__c>([SELECT id FROM csord__Subscription__c WHERE csord__Order__c = :orderId]);
            /*for(csord__Subscription__c sub : [SELECT id FROM csord__Subscription__c WHERE csord__Order__r.csord__Primary_Order__c = :orderId]){
setSubscriptionIds.add(sub.id);
}*/
            //for(csord__Subscription__c sub : [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :orderID]){
            for(csord__Service__c serv : [SELECT id, Appointment_Required__c,csord__Subscription__c FROM csord__Service__c WHERE csord__Subscription__c IN: mapSubscription.keyset()]){
                if(serv.Appointment_Required__c == 'true'){
                    subList.add(''+serv.csord__Subscription__c);
                }
            }
            return subList;
        }catch(Exception e){
            system.debug('Exception in getAllSubscriptions ' + e);
            return subList;
        }
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getSubsList 
Description: get Subscriptions wrapper 
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<SiteAppointmentWrapper> getSubsList(Id orderId){
        List<SiteAppointmentWrapper> wrapperList = new List<SiteAppointmentWrapper>();
        
        Map<string, Appointment__c> parentDataMap= new Map<string, Appointment__c>();
        List<SubscriptionAppointmentWrapper> subApptWrapperLst = new List<SubscriptionAppointmentWrapper>();
        List<String> subIDList = getAllSubscriptions(orderId);
        List<Required_Appointment__c> apptNotReq = [select id,required_AppointmentCount__c,Generate_Appointment_Subscription__c,Generate_Appointment_Order__c,Appointment_BOM_ID__c from Required_Appointment__c
                                                    where Generate_Appointment_Subscription__c in :subIDList  and required_AppointmentCount__c=0];
        Set<id> subIdSet = new Set<Id>();
        for(Required_Appointment__c req :apptNotReq){
            subIdSet.add(req.Generate_Appointment_Subscription__c);
        }
        
        List<csord__Subscription__c> subcrList = [SELECT id,csord__Order__r.id,Name, Site__r.Display_Name__c,Site__r.Name,Site__r.Id,(SELECT SlotId__c,Parent_Appt_ID__c,
                                                                                                                                      StartDate__c,EndDate__c,Status__c,CreatedDate, Reschdeule_required__c,
                                                                                                                                      Suggested_Start_Date__c,Category__c FROM Appointments__r 
                                                                                                                                      order by CreatedDate DESC),(SELECT id,Appointment_Category__c,required_AppointmentCount__c FROM Required_Appointments__r where Appointment_Category__c !=null and isactive__c=true) FROM csord__Subscription__c 
                                                  WHERE id in : subIDList AND Site__r.Display_Name__c != null];
        
        system.debug('subList+' +subcrList);
        //EDGE-99890
        
        Map<String,csord__Subscription__c> subMap= new Map<String,csord__Subscription__c>();
        
        for(csord__Subscription__c sub :subcrList){
            Boolean isSiteAdded = false;
            if(sub.Required_Appointments__r.size()>0 && sub.Appointments__r.size() == 0)
            {         
                String siteInfo=sub.Required_Appointments__r[0].required_AppointmentCount__c+''+sub.Site__r.Display_Name__c+''+sub.Site__r.Id;
                subMap.put(siteInfo,sub);
                isSiteAdded = true;
                system.debug(subMap);
            }  
            if(sub.Appointments__r.size()>0)
            {
                String siteInfo=sub.Appointments__r.size()+''+sub.Site__r.Display_Name__c+''+sub.Site__r.Id;
                subMap.put(siteInfo,sub);
                isSiteAdded = true;
                system.debug(subMap);
                
            }
            if( isSiteAdded == false){
                String siteInfo=sub.Site__r.Display_Name__c+''+sub.Site__r.Id;
                subMap.put(siteInfo,sub);
                system.debug(subMap);
            }
        }
        
        
        List<String> sortValue= new List<String>(subMap.keyset());
        sortValue.sort();
        system.debug('sorted=='+sortValue);
        
        List<csord__Subscription__c> subList  = new List<csord__Subscription__c>();
        for(Integer i=0; i<sortValue.size() ;i++)
        {
            subList.add(subMap.get(sortValue[i]));
            system.debug(subMap.get(sortValue[i]));
        }
        system.debug('descValue'+subList);  
        
        //List<AggregateResult> lstAppt=[SELECT count(id) recCount,category__c,Subscription__c FROM Appointment__c WHERE Subscription__c = :subList group by category__c, Subscription__c ];
        //system.debug('lstAppt==>'+lstAppt);
        for(csord__Subscription__c sub : subList){
            SiteAppointmentWrapper wrapper = new SiteAppointmentWrapper();
            wrapper.orderId = sub.csord__Order__r.id;
            wrapper.Address = '' + sub.Site__r.Display_Name__c;
            wrapper.SubscriptionId = sub.Id;
            wrapper.appointmentCount =0;
            wrapper.reqAppCount = 0;
            if(sub.Required_Appointments__r!=null && !sub.Required_Appointments__r.isEmpty()){
                Integer cntAppt = sub.Required_Appointments__r.size();
                if(cntAppt>2){
                    wrapper.reqAppCount = 2;
                }
                else{
                    wrapper.reqAppCount = cntAppt;
                }
                
            }
            //EDGE-99890
            if(sub.Appointments__r!=null && !sub.Appointments__r.isEmpty())
            {
                Integer cntAppt = sub.Appointments__r.size();
                if(cntAppt>2){
                    wrapper.reqAppCount = 2;
                }
                else{
                    wrapper.reqAppCount = cntAppt;
                }
            }
            
            wrapper.subscriptionName= sub.Name;
            
            
            
            if (subIdSet.contains(sub.id))
            {
                wrapper.appNotRequired=true;
            }
            else {wrapper.appNotRequired=false;
                 }
            Set<String> appCategory = new Set<String>();
            Integer cnt=0;
            for(Appointment__c app :sub.Appointments__r){
                appCategory.add(app.Category__c);
            }
            if(sub.Appointments__r!=null && sub.Appointments__r.size()>0){
                /* wrapper.appointmentCount = sub.Appointments__r.size();
if(sub.Appointments__r.size()>2)
{
wrapper.appointmentCount = 2;
}*/
                
                wrapper.appointmentCount = appCategory.size();
                for(Appointment__c appt : sub.Appointments__r){
                    system.debug('appt+' +appt);
                    system.debug('sub.Appointments__r+' +sub.Appointments__r);
                    SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                    if(appt.Status__c =='Partial Complete'){
                        //parentAppointmentID = true;
                    }
                    if(appt.StartDate__c != null){
                        subApptWrapper.ApptDate = appt.StartDate__c.format('dd/MM/yyyy'); 
                        subApptWrapper.apptDay =  appt.StartDate__c.format('dd/MM/yyyy') +', ' + appt.StartDate__c.format('EEEE') ;
                        subApptWrapper.ApptDateDT=appt.StartDate__c.Date();
                        system.debug('in date');
                    }else{
                        subApptWrapper.ApptDate = '';
                        system.debug('in date2');
                    }
                    if(appt.EndDate__c!=null){
                        subApptWrapper.ApptTime = appt.StartDate__c.format('hh:mm a')+ '-' + appt.EndDate__c.format('hh:mm a');
                        
                    }else{
                        subApptWrapper.ApptTime = '';
                    }
                    system.debug('in here');
                    subApptWrapper.Status = '' + appt.Status__c;
                    system.debug('appt.SlotId__c++' +appt.SlotId__c);
                    subApptWrapper.AppointmentID = appt.SlotId__c;
                    subApptWrapper.Category=appt.Category__c;
                    subApptWrapper.SubsId=sub.id;
                    subApptWrapper.isScheduled=true;
                    subApptWrapper.isSelected=false;
                    //subApptWrapper.iteratorFlag= dummyFlag;
                    system.debug('subApptWrapper++' +subApptWrapper);
                    if(appt.Reschdeule_required__c != null && appt.Reschdeule_required__c){
                        subApptWrapper.isRescheduleRequired= appt.Reschdeule_required__c;
                        Integer d = appt.Suggested_Start_Date__c.day();
                        Integer mo = appt.Suggested_Start_Date__c.month();
                        Integer yr = appt.Suggested_Start_Date__c.year();
                        subApptWrapper.ApptDateDT=appt.Suggested_Start_Date__c;
                        subApptWrapper.suggestedRescheduleDate= DateTime.newInstance(yr, mo, d).format('dd/MM/yyyy');  
                        //isAllRescheduled=false;
                    }
                    else{
                        subApptWrapper.isRescheduleRequired=false;
                    }
                    subApptWrapper.ParentApptID=appt.Parent_Appt_ID__c;
                    if(appt.Parent_Appt_ID__c!= null && appt.Parent_Appt_ID__c!='')
                    {
                        parentDataMap.put(appt.Parent_Appt_ID__c,appt);
                    }
                    system.debug('adding '+subApptWrapper.Category);
                    subApptWrapperLst.add(subApptWrapper);
                    
                }
            }
            else{
                SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                //subApptWrapper.iteratorFlag= true;
                subApptWrapper.Category= '';
                subApptWrapper.SubsId=sub.Id;
                subApptWrapper.isScheduled=false;
                system.debug('adding '+subApptWrapper.Category);
                subApptWrapperLst.add(subApptWrapper);
            }
            
            Integer nbnCount=0;
            Integer telstraCount=0;
            for(Appointment__c app :sub.Appointments__r){
                //appCategory.add(app.Category__c);
                if(app.Category__c == 'NBN')
                    nbnCount++;
                if(app.Category__c == 'TELSTRA')
                    telstraCount++;
            }
            system.debug('telstraCount=='+telstraCount);
            system.debug('nbnCount=='+nbnCount);
            //List<AggregateResult> lstAppt = [SELECT count(id) recCount,category__c FROM Appointment__c WHERE Subscription__c = :sub.Id group by category__c ]; 
            //system.debug('lstAppt'+lstAppt);    
            
            /*if(lstAppt!= null && lstAppt.size()>0)
{                               
for (AggregateResult ag: lstAppt)
{  
//if(string.valueof(ag.get('Subscription__c'))==sub.Id)
//{
Integer count= integer.valueof(ag.get('recCount'));
system.debug('count=='+count);
String apptCategory= string.valueof(ag.get('category__c'));
system.debug('apptCategory=='+apptCategory);
if(apptCategory=='NBN')
{
nbnCount=count;
system.debug('nbnCount=='+nbnCount);
}
if(apptCategory=='TELSTRA')
{
telstraCount=count;
system.debug('telstraCount=='+telstraCount);
}          
//}                 
}*/
            
            if(telstraCount==0)
            {
                SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                system.debug('adding TELSTRA');
                subApptWrapper.Category='TELSTRA';
                subApptWrapper.SubsId=sub.Id;
                subApptWrapper.isScheduled=false;
                subApptWrapperLst.add(subApptWrapper);
            }
            if(nbnCount==0){
                SubscriptionAppointmentWrapper subApptWrapper = new SubscriptionAppointmentWrapper();
                system.debug('adding NBN');
                subApptWrapper.Category='NBN';
                subApptWrapper.SubsId=sub.Id;
                subApptWrapper.isScheduled=false;
                subApptWrapperLst.add(subApptWrapper);
            }
            //}
            /*Set<String> lstSubAppWrapper = new Set<String>();
for(SubscriptionAppointmentWrapper subApptWrap : subApptWrapperLst){
lstSubAppWrapper.add(subApptWrap.Category);
}*/
            
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
            
            system.debug('wrapper.subApptWrapperList+' +wrapper.subApptWrapperList);
            wrapperList.add(wrapper); 
        }
        
        return wrapperList;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getReqAppList 
Description: get Required Appointment wrapper 
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<requiredAppointmentWrapper> getReqAppList(Id orderId)
    {
        system.debug('in reqapp');
        
        List<Required_Appointment__c> reqAppList= [SELECT id,isActive__c,Suggested_StartDate__c,Generate_Appointment_Subscription__c,Generate_Appointment_Subscription__r.id,Appointment_BOM_ID__c,Appointment_Category__c,Generate_Appointment_Order__c,required_AppointmentCount__c, Sequence_of_Appointment__c,LeadTime_Days__c,(select id from Appointments__r) FROM Required_Appointment__c  WHERE Generate_Appointment_Order__c =:orderId and Appointment_Category__c != null order by Sequence_of_Appointment__c];
        system.debug('reqAppList size'+ reqAppList.size());
        List<requiredAppointmentWrapper> reqWrapList = new List<requiredAppointmentWrapper>();
        if(!reqAppList.isEmpty())
        {
            List<Id> SubsId= new List<id>();
            for (Required_Appointment__c reqApp : reqAppList)
            {
                SubsId.add(reqApp.Generate_Appointment_Subscription__c);
            }
            
            List<Appointment__c>  appSubsList = [SELECT id,status__c,Category__c,Subscription__c FROM Appointment__c WHERE Subscription__c in :SubsId ];
            
            for (Required_Appointment__c reqApp : reqAppList)
            {
                
                if(reqApp.Appointments__r.size()>0 || reqApp.isActive__c)
                { 
                    
                    requiredAppointmentWrapper reqWrap= new requiredAppointmentWrapper();
                    reqWrap.SubscriptionId=reqApp.Generate_Appointment_Subscription__c;
                    reqWrap.appointmentID=reqApp.Appointment_BOM_ID__c;
                    reqWrap.CategoryName=reqApp.Appointment_Category__c.toUpperCase('en');  
                    reqWrap.Count=reqAppList.Size(); 
                    reqWrap.leadTime = '(+'+String.valueOf(reqApp.LeadTime_Days__c)+' days after NBN Appointment)';
                    if(reqApp.Suggested_StartDate__c!=null){
                        reqWrap.fromDate = reqApp.Suggested_StartDate__c.Date()  ; 
                    }
                    if(reqWrap.CategoryName=='TELSTRA'  && reqApp.Sequence_of_Appointment__c == '2')
                    {
                        List<Appointment__c>  appList = new List<Appointment__c>();//[SELECT id,status__c,Category__c FROM Appointment__c WHERE Subscription__c = :reqApp.Generate_Appointment_Subscription__c ];
                        for(Appointment__c app: appSubsList)
                        {
                            if(app.Subscription__c==reqApp.Generate_Appointment_Subscription__c)
                            {
                                appList.add(app);
                            }                                       
                        }
                        reqWrap.disable = appList.isEmpty() ?true:false;
                        /*if(appList.isEmpty() && appList.size()<1)
                        {
                            reqWrap.disable = true;
                        } else
                        {
                            reqWrap.disable = false;
                        } */                   
                    }
                    else
                    {
                        //reqWrap.appointmentCategory=reqApp.Appointment_Category__c+ ' Appointment';
                        //reqAppCount = 1;
                        reqWrap.disable = false;
                    }
                    reqWrapList.add(reqWrap);
                }
            }
        }
        system.debug('reqWrapLis'+ reqWrapList);
        return reqWrapList;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: SearchAppointmentSlots 
Description: get Search callout results
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<SlotWrapper> SearchAppointmentSlots(SearchReserveWrapper searchObj)
    {
        system.debug('searchObj==>'+searchObj);
        Date sugDate = date.today();
        Date toDate = date.today();
        List<SlotWrapper> finalSlotWrapperList = new List<SlotWrapper>();
        map<id,id> ordermap =new map<id,id>();
        map<id,id> sitevalue =new map<id,id>();
        csord__Subscription__c Subscription =[SELECT id,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c, csord__Order__r.csord__Order_Number__c,Site__r.id from csord__Subscription__c where id= :searchObj.subsID];
        ordermap.put(Subscription.csord__order__r.id,Subscription.csord__order__r.id);
        sitevalue.put(Subscription.Site__r.id,Subscription.Site__r.id);
        cscrm__Site__c  site = [SELECT id,name,AdborID__c FROM cscrm__Site__c WHERE id IN: sitevalue.keyset()];
        string orderNumber = Subscription.csord__order__r.id ;
        string subscriptionId = Subscription.id;
        Required_Appointment__c reqAppointment= new Required_Appointment__c();
        
        List<Required_Appointment__c> lstReqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c FROM Required_Appointment__c WHERE Generate_Appointment_Order__c =: Subscription.csord__order__r.id AND Generate_Appointment_Subscription__c =: Subscription.id AND Appointment_Category__c =: searchObj.Category order by createdDate DESC ]; 
        
        if(lstReqAppointment!= null && lstReqAppointment.size()>0)
            reqAppointment=lstReqAppointment[0];
        
        if(searchObj.endDate!= null && searchObj.endDate!='')
        {
            toDate= Date.valueOf(searchObj.endDate);
        }    
        else{toDate= null;}     
        if(searchObj.startDate!= null && searchObj.startDate!='')
        {
            sugDate= Date.valueOf(searchObj.startDate);
        }
        Datetime fromDateTime = sugDate;
        Datetime toDateTime = toDate;
        if(searchObj.operation.contains('Schedule')){
            AppointmentSearchRequestDTO slotRequestDTO = new AppointmentSearchRequestDTO();
            AppointmentSearchRequestDTO.Data appointReq  = new AppointmentSearchRequestDTO.Data();
            AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
            AppointmentSearchRequestDTO.Place place  = new AppointmentSearchRequestDTO.Place();
            appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            if(toDate==null){
                appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');    
            }else{
                appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            }
            appointReq.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c; 
            appointReq.bomID=reqAppointment.Appointment_BOM_ID__c;
            slotRequestDTO.correlationId = EDISSingleManager.getUID();
            
            if(searchObj.Category=='TELSTRA'){
                appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
                place.id = site.AdborID__c;
                place.type = 'ADBOR_ID';
                appoint.Place=place;
            }
            if(searchObj.Category =='NBN'){
                appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
                List<Service_Qualification__c> lstServiceQualification = [SELECT id,name,Location_ID__c from Service_Qualification__c where Site__c =: site.id ];
                if(lstServiceQualification != null && lstServiceQualification.size()>0)
                {
                    place.id = lstServiceQualification[0].Location_ID__c;
                }
                
                place.type = 'NBN_LOCATION_ID';
                appoint.Place=place;
            }
            
            appoint.appointmentType = reqAppointment.Appointment_Type__c;
            appoint.appointmentSubType = reqAppointment.Appointment_SubType__c;
            appoint.priority ='STANDARD';
            appointReq.Appointment =appoint;
            slotRequestDTO.data = appointReq ;
            system.debug('Schedule RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
            detailsList=BOMAppointmentService.searchAppointment(slotRequestDTO);
            
        }
        else if(searchObj.operation=='Rebook'){  
            AppointmentBOMRebookSearchRequestDTO slotRequestDTO = new AppointmentBOMRebookSearchRequestDTO();
            AppointmentBOMRebookSearchRequestDTO.Data appointReq  = new AppointmentBOMRebookSearchRequestDTO.Data();
            AppointmentBOMRebookSearchRequestDTO.Appointment appoint  = new AppointmentBOMRebookSearchRequestDTO.Appointment();
            AppointmentBOMRebookSearchRequestDTO.Reason reason= new AppointmentBOMRebookSearchRequestDTO.Reason();
            
            appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            if(toDate==null){
                appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');   
            }else{
                appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            }
            
            appointReq.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c;
            slotRequestDTO.correlationId = EDISSingleManager.getUID();
            string appointmentCat = reqAppointment.Appointment_Category__c;
            
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c;  
            reason.rebookReasonCode = '99';
            reason.note = 'Customer was not happy to open the cabinet at that time';
            appointReq.Reason=reason;
            
            appoint.priority ='STANDARD';
            appointReq.Appointment =appoint;
            slotRequestDTO.data = appointReq ;
            
            system.debug('Rebook FollowOn RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
            detailsList=BOMAppointmentService.searchRebookAppointment(slotRequestDTO,searchObj.parentApptId);
        }
        else if(searchObj.operation=='Reschedule'){           
            AppointmentSearchRequestDTO slotRequestDTO = new AppointmentSearchRequestDTO();
            AppointmentSearchRequestDTO.Data appointReq  = new AppointmentSearchRequestDTO.Data();
            AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
            AppointmentSearchRequestDTO.Reason reason= new AppointmentSearchRequestDTO.Reason();
            List<EWOMRescheduleAppointment__c> ewomCS = EWOMRescheduleAppointment__c.getall().values();
            
            appoint.searchStartDate = fromDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            if(toDate==null){
                appoint.searchEndDate = (fromDateTime.addDays(180)).format('yyyy-MM-dd\'T\'HH:mm:ss');   
            }else{
                appoint.searchEndDate = toDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            }
            appointReq.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c; 
            slotRequestDTO.correlationId = EDISSingleManager.getUID();
            
            string appointmentCat = reqAppointment.Appointment_Category__c;
            
            //reason.rescheduleReasonCode = searchObj.selectedRescheduleReason;
            for(EWOMRescheduleAppointment__c rec: ewomCS){
                if(searchObj.selectedRescheduleReason == rec.RescheduleReason__c){
                    reason.note = rec.RescheduleReason__c;
                    reason.rescheduleReasonCode = rec.RescheduleReasonCode__c;
                    System.debug('reason: '+reason);
                }
            }
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c; 
            appointReq.Reason=reason;                   
            appoint.priority ='STANDARD';
            appointReq.Appointment = appoint;
            slotRequestDTO.data = appointReq;   
            system.debug('Rebook FollowOn RequestAppointmentPayload '+JSON.serialize(slotRequestDTO));
            
            detailsList=BOMAppointmentService.searchReschedAppointment(slotRequestDTO,searchObj.parentApptId);
            
        }
        system.debug('detailsList+' +detailsList);
        finalSlotWrapperList = populateSlotWrapper(detailsList);
        system.debug('finalSlotWrapperList==>>'+finalSlotWrapperList);
        return finalSlotWrapperList;
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471 
Method: SearchAppointmentSlots 
Description: get Search callout results
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    
    public static List<SlotWrapper> populateSlotWrapper(AppointmentSearchResponseDTO responseDTO){
        System.debug('Response DTO '+responseDTO);
        String causeEventReason = null;
        AppointmentSearchResponseDTO.Data data = responseDTO.data;
        List<SlotWrapper> finalSlotWrapperList = new List<SlotWrapper>();
        
        
        
        List<SlotWrapper> slotWrapperList = new List<SlotWrapper>();
        try{
            
            for(AppointmentSearchResponseDTO.AvailableSlots availableSlot : data.availableSlots){
                SlotWrapper slot = new SlotWrapper();
                Datetime dt1 = Datetime.valueOf(availableSlot.startDate.replace('T', ' '));
                slot.startDate =  dt1.format('dd/MM/yyyy') +', ' + dt1.format('EEEE') ;
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
                Set<String> keyList =new Set<String>();
                SlotWrapper resultSlot = new SlotWrapper();
                String startDate = slot.startDate;
                resultSlot.startDate = slot.startDate;
                resultSlot.slotDetail = new Map<String,String>();
                String slotId = slot.slotDetail.keySet()+'';
                for(String key : slot.slotDetail.keySet()){
                    resultSlot.slotDetail.put(key,slot.slotDetail.get(key));
                    System.debug('key'+key);
                    keyList.add(key);
                    //resultSlot.keySetList=keyList;
                    //System.debug('keyListup'+keyList);
                    // keyList.clear();
                }
                for(SlotWrapper innerSlot : slotWrapperList){
                    
                    String innerSlotId = innerSlot.slotDetail.keySet()+'';
                    if(innerSlot.startDate == startDate && innerSlotId!=slotId){
                        for(String key : innerSlot.slotDetail.keySet()){
                            resultSlot.slotDetail.put(key,innerSlot.slotDetail.get(key));
                            System.debug('innerSlotkey'+key);
                            keyList.add(key);
                            
                        }
                        System.debug('keyList'+keyList);
                        //resultSlot.keySetList=keyList;
                        //keyList.clear();
                    }
                    
                }
                resultSlot.keySetList=keyList;
                
                System.debug('resultSlot.keySetList'+resultSlot.keySetList);
                Boolean flag = true;
                for(SlotWrapper slotWrapperFinal : finalSlotWrapperList){
                    if(startDate.equals(slotWrapperFinal.startDate)){
                        flag = false;
                        break;
                    }
                }
                if(flag){
                    finalSlotWrapperList.add(resultSlot);   
                    for(SlotWrapper sw:finalSlotWrapperList)
                    {
                        sw.availableSlots=sw.slotDetail.size();
                    }   
                }
                //keyList.clear();
            }
            checkCauseEvent(responseDTO,causeEventReason);
            system.debug('finalSlotWrapperList'+finalSlotWrapperList);
            
            return finalSlotWrapperList;
        }catch(Exception e){
            system.debug('Exception in populateSlotWrapper ' + e);
            return finalSlotWrapperList;
        }
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: SearchAppointmentSlots 
Description: check if the response received has any Cause Event block. If yes, populate the fields on the controller
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    
    public static void checkCauseEvent(AppointmentSearchResponseDTO responseDTO, String causeEventReason){
        try{
            if(responseDTO!= null && responseDTO.data!=null && responseDTO.data.causeEvent!=null){
                AppointmentSearchResponseDTO.CauseEvent causeEvent = responseDTO.data.causeEvent;
                if(causeEvent.eventReason!= null && causeEvent.eventReason!= ''){
                    causeEventReason = causeEvent.eventReason;
                }
            }
        }catch(Exception e){
            system.debug('Exception in checkCauseEvent ' + e);
        }
        
    }
    
    
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: SearchAppointmentSlots 
Description: create Appointment Record once BOM sends 200/201 response for Schedule Reserve operation
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    
    public static String createAppointmentRecord(String notes, String slotId, String appointmentID,String appointmentCat,String subID,String appointmentOperation,String startDateText, String endDateText,String appID){
        try{
            system.debug('In createAppointmentRecord');
            String apptId;
            csord__Subscription__c Subscription =[SELECT id,name,csordtelcoa__Change_Type__c,csord__order__r.id,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c,Site__r.id FROM csord__Subscription__c WHERE id= :subID];
            
            List<Appointment__c> appList = new List<Appointment__c>();
            if(appointmentOperation == 'Rebook'){
                appList  = [SELECT SlotId__c,Status__c,Category__c FROM Appointment__c WHERE Subscription__c =: subID  AND Category__c =:appointmentCat order by CreatedDate DESC limit 1];
            }
            system.debug('Exception in updateAppointmentRecord ' + appList);
            Appointment__c apptRecord = new Appointment__c();
            apptRecord.Category__c=appointmentCat;
            /*system.debug('create Appt startDate'+ startDate);
system.debug('create Appt endDate'+ endDate);*/
            apptRecord.requiredAppointment__c=appId;
            
            //EDGE-104529 fix
            DateTime startDate = DateTime.parse(startDateText);
            DateTime endDate = DateTime.parse(endDateText);
            if(startDate!=null){
                apptRecord.StartDate__c = startDate;
                apptRecord.StartDateText__c=startDate.format('yyyy-MM-dd\'T\'HH:mm:ss'); //EDGE-104529
            }
            if(endDate!=null){
                apptRecord.EndDate__c = endDate;
                apptRecord.EndDateText__c = endDate.format('yyyy-MM-dd\'T\'HH:mm:ss');  //EDGE-104529
            }
            apptRecord.SlotId__c = appointmentID;
            
            apptRecord.Notes__c = notes;
            apptRecord.Subscription__c = subID;
            if(appointmentOperation == 'Rebook'){
                if(appList!=null && !appList.isEmpty()){
                    apptRecord.Parent_Appt_ID__c = appList[0].SlotId__c;
                }
                
            }
            
            insert apptRecord;
            apptId = apptRecord.id;
            return apptId;
        }catch(Exception e){
            system.debug('Exception in createAppointmentRecord '+ e.getStackTraceString());
            return null;
        }
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: SearchAppointmentSlots 
Description: updateAppointmentRecord once BOM sends 200/201 response for Schedule Reserve operation
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static List<Appointment__c>  updateAppointmentRecord(String selectedSlotId,String category,String subscriptionID,String notes,String startDateText,String endDateText ){
        //String category = Categoryapp.substringbefore('+');
        List<Appointment__c> updateApptList=null;
        try{
            system.debug('Update the Appointment Record after Reschedule Operation');
            
            updateApptList = new List<Appointment__c>();
            //edge-66476: added Reschdeule_required__c,Suggested_Start_Date__c in the query.
            //EDGE-90059 fix, Kalashree Borgaonkar 
            for(Appointment__c apptRecord: [SELECT Reschdeule_required__c,Suggested_Start_Date__c,SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c,StartDate__c,EndDate__c,StartDateText__c,EndDateText__c,Status__c,Category__c  from Appointment__c where Subscription__c = : subscriptionID and Category__c =: category AND status__c IN ('RESCHEDULED','SCHEDULED') order by SlotId__c Desc LIMIT 1 ]){
                apptRecord.Notes__c = notes; // modify this line to appt.Notes__c = appt.Notes__c + notes; if we want to append the new notes to previous notes for tracking
                //EDGE-104529 fix
                DateTime startDate = DateTime.parse(startDateText);
                DateTime endDate = DateTime.parse(endDateText);
                if(startDate!=null){
                    apptRecord.StartDate__c = startDate;
                    apptRecord.StartDateText__c=startDate.format('yyyy-MM-dd\'T\'HH:mm:ss'); //EDGE-104529
                }
                if(endDate!=null){
                    apptRecord.EndDate__c = endDate;
                    apptRecord.EndDateText__c = endDate.format('yyyy-MM-dd\'T\'HH:mm:ss'); //EDGE-104529
                }
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
            
        }catch(Exception e){
            system.debug('Exception in updateAppointmentRecord ' + e);
            
        }
        return updateApptList;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: checkDependencyAppt 
Description: checkDependencyAppt once BOM sends 200/201 response for  Reserve operation
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static void checkDependencyAppt( AppointmentBOMReserveResponseDTO resDTO, Id SubId, boolean mockEnabled)
    {
        if(resDTO.data.dependencies!= null)
        {
            List<AppointmentBOMReserveResponseDTO.Dependencies> depArray= new List<AppointmentBOMReserveResponseDTO.Dependencies>();
            depArray=resDTO.data.dependencies;
            List<Appointment__C> lstAppt= new List<Appointment__C>();
            List<String> resApptIds= new List<String>();
            for(AppointmentBOMReserveResponseDTO.Dependencies dep:depArray)
            {
                system.debug('dep.appointmentID+' +dep.appointmentID);
                resApptIds.add(dep.appointmentID);
            }
            List<Appointment__C> apptlist= new List<Appointment__C> ();
            apptlist=[SELECT id,Reschdeule_required__c,Suggested_Start_Date__c,SlotId__c FROM Appointment__C WHERE SlotId__c in :resApptIds AND Subscription__c=:SubId];
            
            for(Appointment__C app :apptlist)
            {
                Appointment__C appt=new Appointment__C();
                if(apptlist!= null && apptlist.size()>0)
                {
                    appt.id=app.id;
                    appt.SlotId__c=app.SlotId__c;
                }else{  
                    appt.SlotId__c=depArray[0].appointmentID;
                }
                
                appt.Reschdeule_required__c= true;
                appt.Suggested_Start_Date__c=Date.valueof(depArray[0].suggestedStartDate);
                appt.Category__c=depArray[0].appointmentCategory;
                appt.EndDate__c=Date.valueOf(depArray[0].currentSlotEndDate);                   
                appt.StartDate__c=Date.valueOf(depArray[0].currentSlotStartDate);                   
                lstAppt.add(appt);
                
            }
            upsert lstAppt;
        }
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getRescheduleInitiator 
Description: Populate reason picklist on UI
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<string> getRescheduleInitiator()
    {
        List<String> rescheduleApptSet = new List<String>();
        for(EWOMRescheduleAppointment__c apt : [SELECT name, Initiated_By__c from EWOMRescheduleAppointment__c order by Initiated_By__c asc]){
            rescheduleApptSet.add(apt.Initiated_By__c);
        }
        List<String> rescheduleInitiators = new List<String>();
        rescheduleInitiators.add('--None--');
        for(String reschInit :  rescheduleApptSet){
            if(!rescheduleInitiators.contains(reschInit))
                rescheduleInitiators.add(reschInit);
        }
        return rescheduleInitiators;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getRescheduleReason 
Description: Populate reason picklist on UI
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static List<string> getRescheduleReason( string initiatedBY)
    {
        List<String> rescheduleApptSet = new List<String>();
        rescheduleApptSet.add('--None--');
        for(EWOMRescheduleAppointment__c apt : [SELECT name, Initiated_By__c from EWOMRescheduleAppointment__c where Initiated_By__c=:initiatedBY order by name asc]){
            rescheduleApptSet.add(apt.name);
        }
        
        return rescheduleApptSet;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: reserveAppointment 
Description: reserveAppointment callout
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static ConfirmResponseWrapper reserveAppointment(SearchReserveWrapper searchObj){
        ConfirmResponseWrapper wrap = new ConfirmResponseWrapper();
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        String appId='';
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        //List<AppointmentBOMReserveRequestDTO.RelatedParty > relatedPartyList = null;
        AppointmentBOMReserveRequestDTO.RelatedParty relatedParty = new AppointmentBOMReserveRequestDTO.RelatedParty();
        AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note();
        csord__Subscription__c Subscription =[SELECT id,name,csordtelcoa__Change_Type__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__order__r.id,csord__Order__r.csord__Order_Number__c,Site__r.id,Site__r.Display_Name__c from csord__Subscription__c where id= :searchObj.subsID];
        try{
            if(searchObj.operation=='Schedule'){
                
                
                system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
                system.debug('Subscription Id -->>>>'+Subscription.id);
                //String subscriptionID=Subscription.id;
                data.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c; 
                Required_Appointment__c reqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c FROM Required_Appointment__c WHERE Generate_Appointment_Order__c =: Subscription.csord__order__r.id AND Generate_Appointment_Subscription__c =: Subscription.id AND Appointment_Category__c = :searchObj.Category order by createdDate DESC limit 1]; 
                
                
                if(searchObj.subsID !=null && searchObj.subsID !=''){
                    system.debug('Inside if');
                    List<csord__Subscription__c> subList = [SELECT id, csord__Account__c,csord__Account__r.RecordType.Name, csord__Account__r.name,csord__Account__r.Type FROM csord__Subscription__c WHERE id =:searchObj.subsID];
                    
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
                appoint.contacts = populateContactForReserveAppointmentAPV2(searchObj.subsID);
                note.text = searchObj.notes;
                appoint.note =note;
                data.appointment=appoint;
                reserveDTO.correlationId = EDISSingleManager.getUID();
                reserveDTO.data = data;
                appId=reqAppointment.Id;
                system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
                reserveResponse = BOMAppointmentService.reserveAppointment(reserveDTO, searchObj.slotId);
            }
            if(reserveResponse!=null && reserveResponse.data !=null ){
                //String appointmentIDLocation='TAPT001529399876SVEU';
                String appointmentIDLocation=reserveResponse.data.appointmentID; //uncomment this before deployment
                // String appointmentIDLocation=reserveResponse.data.appointmentID+'*'+String.valueof(DateTime.now().getTime());//Temp change for EDGE-66476. Comment this before deployment
                //String appointmentIDLocation = urlSplit[urlSplit.size()];
                String appointmentCat=reserveResponse.data.appointmentCategory;
                String apptId = null;
                /*DateTime startDate = DateTime.parse(searchObj.startDate);
DateTime endDate = DateTime.parse(searchObj.endDate);*/
                if(searchObj.operation=='Schedule'){
                    
                    apptId = createAppointmentRecord(searchObj.notes,searchObj.slotId,appointmentIDLocation,appointmentCat,searchObj.subsID,searchObj.operation,searchObj.startDate,searchObj.endDate,appid);
                    if(apptId!=null){
                        
                        Appointment__c app = [SELECT id,EndDate__c,StartDate__c,SlotId__c FROM Appointment__c WHERE  id =:apptId];
                        CPEDeliveryDateHelper.modifyCPEDeliveryDate(searchObj.subsID);
                        
                        createTaskRecords(apptId,searchObj); //EDGE - 75002 
                        
                        getAppoinmentDetails(searchObj.subsID);
                        
                        wrap.address = Subscription.Site__r.Display_Name__c;
                        wrap.subscriptionName = Subscription.name;
                        wrap.apptDate = app.StartDate__c.format('dd/MM/yyyy')+', ' +app.StartDate__c.format('EEEE') ;
                        
                        wrap.apptTime = app.StartDate__c.format('hh:mma')+'-'+app.EndDate__c.format('hh:mma');
                        wrap.apptId = app.SlotId__c;
                        wrap.code=null;
                        System.debug('responsewrap: '+wrap);
                    }else{
                        
                        wrap.code = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);
                        
                    }
                }
            }else{
                
                wrap.code = Label.AppointmentRescheduleError;
            }
            
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e);
            wrap.code = Label.AppointmentRescheduleError;
            
        }
        System.debug('responsewrap: '+wrap);
        return wrap;
        
    }
    
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: populateContactForReserveAppointmentAPV2 
Description: populate contact related payload
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static List<AppointmentBOMReserveRequestDTO.Contacts> populateContactForReserveAppointmentAPV2(String subscriptionID){
        List<AppointmentBOMReserveRequestDTO.Contacts> contactList = new List<AppointmentBOMReserveRequestDTO.Contacts>();
        //AppointmentBOMReserveRequestDTO.Data.appointment.contacts con = new AppointmentBOMReserveRequestDTO.Data.appointment.contacts();
        try{
            
            Map<Id,String> roleMap = new Map<Id,String>();
            Map<Id,String> roleMapTech = new Map<Id,String>();
            Set<Id> contactIdSet = new Set<Id>();
            
            for(csord__service__c servObj : [SELECT Id, Primary_Contact__c, Technical_Contact__c,After_Hours_Site_Contact__c, csordtelcoa__Main_Contact__c,Order_Primary_Contact__c,Site_Delivery_Contact__c,TenancyPrimaryContact__c,Project_Contact__c FROM csord__service__c WHERE csord__Subscription__c =: subscriptionID AND csord__service__c = null]){
                if(servObj.Primary_Contact__c!=null){
                    contactIdSet.add(servObj.Primary_Contact__c);
                    roleMap.put(servObj.Primary_Contact__c, 'PRIMARY');
                }
                if(servObj.Technical_Contact__c!=null){
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
            Map<Id, Contact> contactMap= new Map<Id, Contact>([SELECT Id, Name, Phone, MobilePhone FROM Contact WHERE Id IN: contactIdSet]);
            
            
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
            }
            return contactList;
        }catch(Exception e){
            system.debug('Exception in populateContactForReserveAppointment ' + e);
            return contactList;
        }
    }
    
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: createTaskRecords 
Description: createTaskRecords after successful schedule reserve
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    
    public static void createTaskRecords(String apptId, SearchReserveWrapper searchObj){
        lIst<BaseRuleWrapper> wrapperList ;
        Task__c appTask ;
        List<Task__c> tasksList = new List<Task__c> ();
        Appointment__c appointment = [SELECT Subscription__c,Subscription__r.csord__Order__r.csord__Primary_Order__c,Subscription__r.csord__Order__c FROM Appointment__c WHERE id = :apptId];
        System.debug('appointment'+appointment);
        List<Required_Appointment__c> reqAppointmentList ;
        List<String> baseRuleProdList = new List<String>();
        //String Catstring = Categoryapp.substringbefore('+');
        if(appointment.Subscription__r.csord__Order__c!=null){
            reqAppointmentList = [SELECT id,baseRuleProducts__c FROM Required_Appointment__c WHERE Generate_Appointment_Subscription__c = :appointment.Subscription__c AND Generate_Appointment_Order__c=:appointment.Subscription__r.csord__Order__c AND Appointment_Category__c =: searchObj.Category ORDER BY createdDate DESC LIMIT 1];
            System.debug('reqAppointmentList'+reqAppointmentList);
            if(reqAppointmentList!=null && !reqAppointmentList.isEmpty()){
                for(Required_Appointment__c reqApp : reqAppointmentList){
                    if(reqApp.baseRuleProducts__c!=null){
                        //baseRuleProdList.add(reqApp.baseRuleProducts__c);
                        //EDGE-101122 , Kalashree Borgaonkar - Fix to create task records
                        wrapperList = (List<BaseRuleWrapper>)JSON.deserialize(reqApp.baseRuleProducts__c,List<BaseRuleWrapper>.class);
                        for(BaseRuleWrapper wrapper:wrapperList){
                            baseRuleProdList.add(wrapper.productInstanceID);
                        }
                    }
                }
            }
        }
        if(baseRuleProdList!=null && !baseRuleProdList.isEmpty()){
            
            if(baseRuleProdList!=null && !baseRuleProdList.isEmpty()){
                for(String instanceid : baseRuleProdList){
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
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: rebookAppointment 
Description: rebookAppointment
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static ConfirmResponseWrapper rebookAppointment(SearchReserveWrapper searchObj)
    {
        ConfirmResponseWrapper wrap = new ConfirmResponseWrapper();
        String appId='';
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        try
        {
            csord__Subscription__c Subscription =[SELECT id,name,csordtelcoa__Change_Type__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__order__r.id,csord__Order__r.csord__Order_Number__c,Site__r.id,Site__r.Display_Name__c from csord__Subscription__c where id= :searchObj.subsID];
            system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
            system.debug('Subscription Id -->>>>'+Subscription.id);
            data.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c;
            //String Catstring = Categoryapp.substringbefore('+');
            Required_Appointment__c reqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c FROM Required_Appointment__c WHERE Generate_Appointment_Order__c =: Subscription.csord__order__r.id AND Generate_Appointment_Subscription__c =: Subscription.id AND Appointment_Category__c =: searchObj.Category order by createdDate DESC limit 1]; 
            
            
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
            appId=reqAppointment.id;
            //note.text = notes;
            data.appointment=appoint;
            reserveDTO.correlationId = EDISSingleManager.getUID();
            reserveDTO.data = data;
            
            List<Appointment__c> apptList= [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__C ,status__c FROM Appointment__c WHERE Subscription__c = : searchObj.subsID AND Category__c =: searchObj.Category ORDER BY createdDate DESC LIMIT 1];
            if(apptList != NULL && apptList.size()>0){
                parentApptId = apptList[0].SlotId__c; //comment Before Deployment
                // parentApptId = apptList[0].SlotId__c; //Uncomment Before Deployment
            }
            system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
            reserveResponse = BOMAppointmentService.rebookAppointment(reserveDTO,searchObj.slotId,parentApptId);
            if(reserveResponse.status==200 && reserveResponse.data !=null ){
                String appointmentIDLocation=reserveResponse.data.appointmentID; //uncomment this before deployment
                //String appointmentIDLocation=reserveResponse.data.appointmentID+'*'+String.valueof(DateTime.now().getTime());//Temp change for EDGE-66476. Comment this before deployment
                String appointmentCat=reserveResponse.data.appointmentCategory;
                
                system.debug('appointmentIDLocation++' +appointmentIDLocation);
                String apptId = null;
                
                //EDGE-104529 fix
                /*DateTime startDate;
DateTime endDate;
if(searchObj.startDate!=null){
startDate = DateTime.parse(searchObj.startDate);
}
if(searchObj.endDate!=null){
endDate = DateTime.parse(searchObj.endDate);
}*/
                // EDGE-104529 fix
                apptId = createAppointmentRecord(searchObj.notes,searchObj.slotId,appointmentIDLocation,appointmentCat,searchObj.subsID,searchObj.operation,searchObj.startDate,searchObj.endDate,appId);
                if(apptId!=null){
                    Appointment__c app = [SELECT id,EndDate__c,StartDate__c,SlotId__c FROM Appointment__c WHERE  id =:apptId];
                    system.debug('appointmentIDLocation' +appointmentIDLocation);
                    if(!apptList.isEmpty()){
                        updateParentApptStatus(apptList[0]);//Kalashree EDGE-66474,EDGE-66451 AC5
                    }
                    
                    CPEDeliveryDateHelper.modifyCPEDeliveryDate(searchObj.subsID);
                    
                    getAppoinmentDetails(searchObj.subsID);
                    
                    //EDGE-66476- Mahima                     
                    
                    checkDependencyAppt(reserveResponse, searchObj.subsID, false);//Actual API
                    // checkDependencyAppt(reserveResponse, searchObj.subsID, true);//Mock enabled. comment before deployment.
                    System.debug('appointmentIDLocationtest::'+appointmentIDLocation);
                    
                    wrap.address = Subscription.Site__r.Display_Name__c;
                    wrap.subscriptionName = Subscription.name;
                    wrap.apptDate = app.StartDate__c.format('dd/MM/yyyy')+', ' +app.StartDate__c.format('EEEE') ;
                    
                    wrap.apptTime = app.StartDate__c.format('hh:mma')+'-'+app.EndDate__c.format('hh:mma');
                    wrap.apptId = app.SlotId__c;
                    wrap.code=null;
                }else{
                    wrap.code = Label.AppointmentConfirmation.replace('<SlotId>', appointmentIDLocation);   
                }
                
            }else{
                wrap.code = Label.AppointmentRescheduleError;
                //display:Functionality currently unavailable and try again after sometime
            }      
        }
        catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e.getStackTraceString());
            wrap.code = Label.AppointmentRescheduleError;
        }
        System.debug('ResponseWrap: '+wrap);
        return wrap;
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: updateParentApptStatus 
Description: update Parent Appointment Status
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static void updateParentApptStatus(Appointment__c appt){
        appt.status__c  = 'REBOOKED';
        update appt;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: rescheduleAppointment 
Description: rescheduleAppointment
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static ConfirmResponseWrapper rescheduleAppointment(SearchReserveWrapper searchObj){ //remove static later
        ConfirmResponseWrapper wrap = new ConfirmResponseWrapper();
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        AppointmentBOMReserveResponseDTO rescheduleResponse;
        //AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note(); //uncomment make changes after Rashmi confirms
        try{
            //EDGE-84675 , added Primary_Order__r.id in the SQOL
            csord__Subscription__c Subscription =[SELECT name,Site__r.Display_Name__c,csord__Order__r.csord__Primary_Order__c,Primary_Order__r.id,Primary_Order__r.csord__Order_Number__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where id= :searchObj.subsID];
            system.debug('Order Id --->>>>'+Subscription.csord__order__r.id);//a4b2O0000004TXJQA2
            system.debug('Subscription Id -->>>>'+Subscription.id);
            data.transactionReferenceID = Subscription.csord__order__r.csord__Order_Number__c; 
            //String Catstring = Categoryapp.substringbefore('+');
            
            Required_Appointment__c reqAppointment = [SELECT id,name,Appointment_BOM_ID__c,Appointment_Category__c,createdDate,Appointment_Type__c,Appointment_SubType__c FROM Required_Appointment__c WHERE Generate_Appointment_Order__c =: Subscription.csord__order__r.id AND Generate_Appointment_Subscription__c =: Subscription.id AND Appointment_Category__c =: searchObj.Category order by createdDate DESC limit 1]; 
            
            
            appoint.appointmentCategory =reqAppointment.Appointment_Category__c;
            //note.text = notes; uncomment/make changes
            //appoint.note =note; uncomment/make changes
            data.appointment=appoint;
            reserveDTO.correlationId = EDISSingleManager.getUID();
            reserveDTO.data = data;
            String apptId='';
            for(Appointment__c appt: [SELECT SlotId__c,Parent_Appt_ID__c,Subscription__c, Notes__c from Appointment__c where Subscription__c = : searchObj.subsID and Category__c =: searchObj.Category ]){
                apptId = appt.SlotId__c; //uncomment this bedore deployment
                //apptId = appt.SlotId__c.substringBefore('*');//Temp change for EDGE-66476. Comment this before deployment
                //system.debug('<><><> Enrichstatus ' + isEnriched);
            }
            system.debug('Schedule reserveAppointmentPayload ' + JSON.serialize(reserveDTO));
            rescheduleResponse = BOMAppointmentService.rescheduleAppointment(reserveDTO, searchObj.slotId,apptId); 
            List<Appointment__c> updatedAppList     ;       
            /*DateTime startDate;
DateTime endDate;
if(searchObj.startDate!=null){
startDate = DateTime.parse(searchObj.startDate);
}
if(searchObj.endDate!=null){
endDate = DateTime.parse(searchObj.endDate);
}*/
            
            if(rescheduleResponse!=null ){
                if(rescheduleResponse.status==200 && rescheduleResponse.data!=null){
                    //EDGE-104529 fix
                    updatedAppList = updateAppointmentRecord(searchObj.slotId, searchObj.Category, searchObj.subsID,searchObj.notes,searchObj.startDate,searchObj.endDate);
                    if(updatedAppList!=null && !updatedAppList.isEmpty()){
                        //CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscriptionID);
                        system.debug('Update Appointment Record successful after Reschedule');
                        //isRescheduled = true;
                        getAppoinmentDetails(searchObj.subsID);
                        
                        //EDGE-66476- Mahima                         
                        //checkDependencyAppt(rescheduleResponse,subscriptionID, true);//Mock
                        checkDependencyAppt(rescheduleResponse,searchObj.subsID, false); //Actual
                        wrap.address = Subscription.Site__r.Display_Name__c;
                        wrap.subscriptionName = Subscription.name;
                        wrap.apptDate = updatedAppList[0].StartDate__c.format('dd/MM/yyyy')+', ' +updatedAppList[0].StartDate__c.format('EEEE') ;
                        
                        wrap.apptTime = updatedAppList[0].StartDate__c.format('hh:mma')+'-'+updatedAppList[0].EndDate__c.format('hh:mma');
                        wrap.apptId = updatedAppList[0].SlotId__c;
                        wrap.code=null;
                    }else{
                        system.debug('Update Appointment Record failed after Reschedule');
                        
                        wrap.code = Label.AppointmentRescheduleError;
                    }
                }
                else{
                    if(rescheduleResponse.status!=200 && rescheduleResponse.code=='1111'){
                        //display: This appointment cannot be rescheduled, try rebooking the appointment to change dates
                        
                        wrap.code = Label.AppointmentRebookMessage;                         
                    }
                    else {
                        //display:Functionality currently unavailable and try again after sometime
                        wrap.code = Label.AppointmentRescheduleError;
                    }
                } 
            }     
        }catch(Exception e){
            system.debug('Exception in reserveAppointment ' + e.getStackTraceString());
            wrap.code = Label.AppointmentRescheduleError;
        }
        System.debug('ResponseWrap'+wrap);
        return wrap;
    }
    
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: getAppoinmentDetails 
Description: getAppoinmentDetails
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    public static void getAppoinmentDetails(String subscriptionID)
    {
        
        List<Appointment__c> apptList = [SELECT SlotId__c,Category__c,EndDate__c,StartDate__c,Notes__C ,Subscription__c FROM Appointment__c WHERE Subscription__c = : subscriptionID order by SlotId__c Desc];
        for(Appointment__c appt: apptList){
            Map<String,String> appDetails = new Map<String,String>();
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
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: confirmAppointment 
Description: return wrapper response on UI after reservation callout
Author:Ila Anmol Verma, Kalashree, Mahima
--------------------------------------------------------*/
    @AuraEnabled
    public static ConfirmResponseWrapper confirmAppointment(SearchReserveWrapper searchObj) {
        ConfirmResponseWrapper wrap = new ConfirmResponseWrapper();
        System.debug('searchObj.operation:: '+searchObj.operation);
        if(searchObj.operation.contains('Schedule')){
            wrap = reserveAppointment(searchObj);
        }
        else if(searchObj.operation=='Reschedule'){
            wrap = rescheduleAppointment(searchObj); //EDGE -66470
        }
        else if(searchObj.operation=='Rebook'){
            wrap = rebookAppointment(searchObj);
        }
        System.debug('wrap: '+wrap);
        return wrap;
        
    }
    
    /*-------------------------------------------------------- 
EDGE-EDGE-75207
Method: generateAppointmentForErrorScenario 
Description: Appointment for error scenario
Author: Pradeep
--------------------------------------------------------*/
    @AuraEnabled
    public static void generateAppointmentForErrorScenario(String SubscriptionId)
    {                 
        String ordId;
        List<csord__Subscription__c>  SubrList=[SELECT id,csord__Order__c FROM csord__Subscription__c WHERE id=:SubscriptionId order by createddate DESC LIMIT 1];
        if(!SubrList.isEmpty())
        {
            //ordId=SubrList[0].csord__Order__r.csord__Primary_Order__c;
            ordId=SubrList[0].csord__Order__c;
            
        }
        system.debug('invoked lightining for order'+ordId);
        system.debug('invoked lightining for Subscription'+SubscriptionId);
        AppointmentServiceCallout apc = new AppointmentServiceCallout();
        apc.generateAppointmentForErrorScenario(ordId,SubscriptionId);
        
    }   
    /*-------------------------------------------------------- 

Method: showSaveProgressButton 
Description: Show or hide save progress button in appointment screen
Author: Dheeraj Bhatt
--------------------------------------------------------*/
    @AuraEnabled
    public static boolean showSaveProgressButton(String orderId){
        Boolean showProgressButton=False;
        Try{
            
            List<String> subIDList = getAllSubscriptions(orderId);
            List<Appointment__c> apptList;
            List<Required_Appointment__c>requiredApptList;
            List<Appointment__c> newAppList=new List<Appointment__c>();
            if(subIDList.size()>0){
                requiredApptList=new List<Required_Appointment__c>([SELECT id,Generate_Appointment_Subscription__c,Appointment_Category__c FROM Required_Appointment__c WHERE Generate_Appointment_Subscription__c = :subIDList and Appointment_Category__c!=NULL]);
                if(requiredApptList.size()>0){
                    apptList=new List<Appointment__c>([SELECT id,Subscription__c,category__c FROM Appointment__c WHERE Subscription__c = :subIDList and category__c!=NULL]);
                    for(Required_Appointment__c reqApp:requiredApptList){
                        For(Appointment__c app:apptList){
                            if(reqApp.Appointment_Category__c==app.category__c && reqApp.Generate_Appointment_Subscription__c ==app.Subscription__c){
                                newAppList.add(app);
                                break;
                            }
                        }
                        
                    }
                   if(requiredApptList.size() <=newAppList.size()){
                        showProgressButton=True;
                    }
                }
                
            }
            List<csord__Order__c> listList = [SELECT id, name,csord__Status2__c FROM csord__Order__c WHERE id = :orderId];
            if(listList.size()>0){
                if(listList[0].csord__Status2__c == 'In Progress' || listList[0].csord__Status2__c == 'Submitting' || listList[0].csord__Status2__c == 'Completed' ){
                    return false;
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception occured in AppointmentBOMBaseCtrl class at line number'+ex.getLineNumber()+'due to'+ex.getMessage());  
        }
        return showProgressButton;
    }
    /*-------------------------------------------------------- 
Method: changeOrderStatus 
Description: Change the recordType of order once user click on save and progress button.
Author: Dheeraj Bhatt
--------------------------------------------------------*/
    @AuraEnabled   public static void changeOrderStatus(String orderId){
        AppointmentServiceCallout.nextOrderStatus(orderId);
    }     
    
}
/************************************************************
Class Name : ManageOrderServiceUtilityHelper
Test Class : ManageOrderServiceUtilityTest
Author : Vimal Verma 
Description : EDGE-1145 - Manage Order interface structure component 
History : Initial Version Mon Oct 16 09:56:44 2017 
===============================================================================================================================
    Change.No.    Developer Name          Date          Story Description    
    1.            Ashish A.        29/11/2019    EDGE-92547 - add block for removed numbers to be sent as CEASE
  2.        Gnana             30/03/2020    EDGE-138020 - Added MobilePhone in SOQL and in ternary condition
	3.				Harsh P.			26/05/2020		Added HandlingType in ordCharMap (code overwritten) 
***********************************************************/

public with sharing class ManageOrderServiceUtilityHelper
{
    //Method to Initialize ManageOrderDataObject.CharacteristicDataObject from ordersData     
    public static List<ManageOrderDataObject.CharacteristicDataObject> getOrderCharacteristics(csord__Order__c order)
    {
        List<ManageOrderDataObject.CharacteristicDataObject> charObjectList = new List<ManageOrderDataObject.CharacteristicDataObject>();
        ManageOrderDataObject.CharacteristicDataObject charObject;
        List<cscrm__Account_Address_Relationship__c> accAddr=[select cscrm__Address__r.Address_ID__c from cscrm__Account_Address_Relationship__c where cscrm__Address_Type__c = 'Primary Address' and cscrm__Active__c=true and cscrm__Account__c =:order.csord__Account__c];
        Map<String,String> ordCharMap = new Map<String,String>();
        if(order.PM_Required__c == True){
            ordCharMap.put('Project_ID',order.Project_ID__c==null?'':order.Project_ID__c);
            ordCharMap.put('Project_Manager_Required',String.valueOf(order.PM_Required__c));
            ordCharMap.put('Project_Manager_ID',order.Project_Manager_User_ID__c==null?'':order.Project_Manager_User_ID__c);
            ordCharMap.put('Project_Manager_phoneNumber',order.Project_Manager_Contact_Number__c==null?'':order.Project_Manager_Contact_Number__c);
            ordCharMap.put('Project_Manager_emailId',order.Project_Manager_Email__c==null?'':order.Project_Manager_Email__c);
        }
        ordCharMap.put('ModuleChange',String.valueOf(order.ModelChange__c));
        ordCharMap.put('orderCreationDate',String.valueOf(order.createdDate.formatGmt('yyyy-MM-dd\'T\'HH:mm')+'TZD'));
        ordCharMap.put('orderComplexity',order.Project_Complexity__c==null?'':order.Project_Complexity__c);
        ordCharMap.put('customerBusinessUnit',order.csord__Account__r.Business_Unit__c==null?'':order.csord__Account__r.Business_Unit__c);
        if(!accAddr.isEmpty()){
        ordCharMap.put('customerAddressId',accAddr[0].cscrm__Address__r.Address_ID__c==null?'':accAddr[0].cscrm__Address__r.Address_ID__c); //EDGE-109527 sfdc id was mapped
        }
        
        //Start : Changes for EDGE-80798
        /*
        ordCharMap.put('SalesUserId',order.csordtelcoa__Opportunity__r.Owner.FederationIdentifier);
        ordCharMap.put('SalesUserFirstName',order.csordtelcoa__Opportunity__r.Owner.FirstName);
        ordCharMap.put('SalesUserLastName',order.csordtelcoa__Opportunity__r.Owner.LastName);
        ordCharMap.put('SalesUserContactNumber',order.csordtelcoa__Opportunity__r.Owner.Phone);
        ordCharMap.put('SalesUserEmailId',order.csordtelcoa__Opportunity__r.Owner.Email);
        */
        
        User orderOwner = [Select FederationIdentifier, FirstName, LastName, Phone, Email, MobilePhone from User where id =: order.OwnerId]; // Added MobilePhone column as part of EDGE-138020
        ordCharMap.put('SalesUserId',orderOwner.FederationIdentifier==null ? '':orderOwner.FederationIdentifier);
        ordCharMap.put('SalesUserFirstName',orderOwner.FirstName==null ? '':orderOwner.FirstName);
        ordCharMap.put('SalesUserLastName',orderOwner.LastName == null ? '':orderOwner.LastName);
        //ordCharMap.put('SalesUserContactNumber',orderOwner.Phone == null ? '':orderOwner.Phone); Commented this line as part of EDGE-138020
        // Added below line as part of EDGE-138020
        ordCharMap.put('SalesUserContactNumber',orderOwner.MobilePhone != null ? orderOwner.MobilePhone : orderOwner.Phone != null ? orderOwner.Phone : '');
        ordCharMap.put('SalesUserEmailId',orderOwner.Email == null ? '' : orderOwner.Email);
        //End : Changes for EDGE-80798
        System.debug('ordCharMap...'+ordCharMap.values());
        System.debug('Other Parameters '+ order.Functional_Contact_Roles__r);
        if(order.Functional_Contact_Roles__r != null && order.Functional_Contact_Roles__r.size()>0 ){
            ordCharMap.put('TenancyAdminFirstName',order.Functional_Contact_Roles__r[0].ContactID__r.FirstName);
            ordCharMap.put('TenancyAdminLastName',order.Functional_Contact_Roles__r[0].ContactID__r.LastName);
            if(order.Functional_Contact_Roles__r[0].ContactID__r.MobilePhone != null && order.Functional_Contact_Roles__r[0].ContactID__r.MobilePhone != '')
                ordCharMap.put('TenancyAdminPhoneNumber',order.Functional_Contact_Roles__r[0].ContactID__r.MobilePhone);
            else
                ordCharMap.put('TenancyAdminPhoneNumber',order.Functional_Contact_Roles__r[0].ContactID__r.Phone);
            ordCharMap.put('TenancyAdminEmailId',order.Functional_Contact_Roles__r[0].ContactID__r.Email);
        }
        //Added for code overwritten for HandlingType for Tactical Transition Type
        if(order.Tactical_Handling_Type__c!=null && order.Tactical_Handling_Type__c!='')
            ordCharMap.put('handling_type',order.Tactical_Handling_Type__c);
        for(String charObj : ordCharMap.keySet()){
            charObject = new ManageOrderDataObject.CharacteristicDataObject();
            charObject.name = charObj;
            charObject.value = ordCharMap.get(charObj);
            charObjectList.add(charObject);
        }
        return charObjectList;
    }
    
    //Method to Initialize ManageOrderDataObject.AppointmentDataObject from ServiceSpecifications
    public static ManageOrderDataObject.AppointmentDataObject getAppointment(Map<String, Task__c> taskAppointmentMap,Map<String, CS_SpecificationDTO.ServiceSpecification> serviceEDMMap, String ProdId, 
                                                                             Map<String, List<String>> ProdChildConfigIds){
                                                                                 boolean checkchildAppt = false;
                                                                                 string childId='';
                                                                                 system.debug('ProdId=='+ProdId);
                                                                                 //system.debug('ProdId+'+serviceEDMMap.get(ProdId).productConfigurationId);
                                                                                 ManageOrderDataObject.AppointmentDataObject appoint = new ManageOrderDataObject.AppointmentDataObject();
                                                                                 if(taskAppointmentMap.get(ProdId) != null){
                                                                                     Task__c appointAttrib = taskAppointmentMap.get(ProdId);
                                                                                     appoint.id = appointAttrib.Appointment__r.SlotId__c;
                                                                                     appoint.category =  appointAttrib.Appointment__r.Category__c;
                                                                                     // please don't change for these 2 lines
                                                                                     appoint.startDate = appointAttrib.Appointment__r.StartDateText__c; 
                                                                                     appoint.endDate = appointAttrib.Appointment__r.EndDateText__c;

                                                                                     /*    
Datetime startDate = datetime.valueOf(appointAttrib.Appointment__r.StartDate__c);
appoint.startDate =  String.valueOf(startDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')+'+'+ManageOrderServiceUtilityHelper.getTimeZone(startDate));
//appoint.endDate = String.valueof(appointAttrib.Appointment__r.StartDate__c);
//appoint.startDate = String.valueof(appointAttrib.Appointment__r.EndDate__c);
Datetime endDate = datetime.valueOf(appointAttrib.Appointment__r.EndDate__c);
appoint.endDate =  String.valueOf(endDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')+'+'+ManageOrderServiceUtilityHelper.getTimeZone(endDate));
*/
                                                                                 }
                                                                                 else{
                                                                                     if(ProdChildConfigIds.get(ProdId) != null){
                                                                                         for( String childIds: ProdChildConfigIds.get(ProdId)){
                                                                                             system.debug(childIds);
                                                                                             system.debug(taskAppointmentMap);
                                                                                             
                                                                                             if(taskAppointmentMap.get(childIds) != null){
                                                                                                 checkchildAppt=true;
                                                                                                 childId=childIds;
                                                                                                 break;
                                                                                             }
                                                                                         }
                                                                                         if(checkchildAppt){
                                                                                             Task__c appointAttrib = taskAppointmentMap.get(childId);
                                                                                             appoint.id = appointAttrib.Appointment__r.SlotId__c;
                                                                                             appoint.category =  appointAttrib.Appointment__r.Category__c;
                                                                                             // please don't change for these 2 lines
                                                                                             appoint.startDate = appointAttrib.Appointment__r.StartDateText__c;
                                                                                             appoint.endDate = appointAttrib.Appointment__r.EndDateText__c;

                                                                                             /*
Datetime startDate = datetime.valueOf(appointAttrib.Appointment__r.StartDate__c);
appoint.startDate =  String.valueOf(startDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')+'+'+ManageOrderServiceUtilityHelper.getTimeZone(startDate));
//appoint.endDate = String.valueof(appointAttrib.Appointment__r.StartDate__c);
//appoint.startDate = String.valueof(appointAttrib.Appointment__r.EndDate__c);
Datetime endDate = datetime.valueOf(appointAttrib.Appointment__r.EndDate__c);
appoint.endDate =  String.valueOf(endDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')+'+'+ManageOrderServiceUtilityHelper.getTimeZone(endDate));
*/
                                                                                         }
                                                                                     }
                                                                                 }
                                                                                 return appoint;
                                                                             }
    
    Public static string getTimeZone(dateTime dt){
        TimeZone tz = UserInfo.getTimeZone();
        string hrMin;
        integer inMinut=integer.valueOf(tz.getOffset(dt)/(1000*60));
        integer intHour=InMinut/60;
        integer intMinutes=math.mod(InMinut,60);
        if(string.valueof(intMinutes).length() == 1){
            String stringMin = '0'+intMinutes;
            hrMin= string.valueOf(intHour+':'+stringMin);
        }
        else{
            hrMin= string.valueOf(intHour+':'+intMinutes);
        }
        return hrMin;
    }
    
    public static String translateContactType(String sfdcContactType){
        //String interfaceContactType;
        if(String.isEmpty(sfdcContactType)){
            return sfdcContactType;
        } else if(String.isNotEmpty(ManageOrderServiceUtility.contactDataMap.get(sfdcContactType))){
            return ManageOrderServiceUtility.contactDataMap.get(sfdcContactType);
        } else 
            return sfdcContactType;
    }
    
    
    public static void transformNumbertToProductCharacteristic(CS_SpecificationDTO.ServiceSpecification serviceSpecs, ManageOrderDataObject.ProductDataObject prod){
        Map<String, ManageOrderDataObject.CharacteristicDataObject> prodCharacteristicMap = new Map<String, ManageOrderDataObject.CharacteristicDataObject>();
        Boolean notActive = false;
        String statusNum = '';
        String rangeTo='';
        String rangeFrom ='';
        List<String> allNumberMap=null;
        List<ManageOrderServiceUtilityHelper.NumberProductCharacteristic> listOfNumChars = new List<ManageOrderServiceUtilityHelper.NumberProductCharacteristic>();
        ManageOrderServiceUtilityHelper.NumberProductCharacteristic numberChar = null;
        ManageOrderServiceUtilityHelper.NumberProductCharacteristic number1 = null;
        ManageOrderDataObject.CharacteristicDataObject numberAttributes = new ManageOrderDataObject.CharacteristicDataObject();
        Map<String,ManageOrderDataObject.CharacteristicDataObject> numberAttributesMap = new Map<String,ManageOrderDataObject.CharacteristicDataObject>();
        Map<String,String> simpleAttributesMapper = null;
        
        List<csord__Service__c> serviceList = [Select id,name,toBeCancelled__c from csord__Service__c where id =: serviceSpecs.serviceId];
        Boolean toBeCancel= false;
        if(serviceList!=null){
            for(csord__Service__c srv : serviceList){
                if(srv.toBeCancelled__c =='true'){
                    toBeCancel=true;
                }
                
            }
            
        }
        System.debug('FirstLoop::'+serviceSpecs.complexAttributes.values());    
        for(List<CS_SpecificationDTO.ComplexAttributes> listAttr :serviceSpecs.complexAttributes.values()){
            System.debug('SecondLoop::'+listAttr);
            for(CS_SpecificationDTO.ComplexAttributes attr:listAttr){
                System.debug('ThirdLoop::'+attr.simpleAttributes);
                simpleAttributesMapper = new Map<String,String>();
                for(CS_SpecificationDTO.SimpleAttributes mapAttr:attr.simpleAttributes){
                    simpleAttributesMapper.put(mapAttr.name,mapAttr.value);
                }
                if(toBeCancel && simpleAttributesMapper.get('status')=='ACTIVE'){
                    numberAttributes = new ManageOrderDataObject.CharacteristicDataObject();
                    number1 = new ManageOrderServiceUtilityHelper.NumberProductCharacteristic();
                    
                    if(simpleAttributesMapper.get('rangeTo') != null && simpleAttributesMapper.get('rangeTo') != ''){
                        rangeTo = simpleAttributesMapper.get('rangeTo');
                        rangeFrom= simpleAttributesMapper.get('rangeFrom');
                        number1.range = rangeFrom+':'+rangeTo;
                    }else{
                        number1.numbers = simpleAttributesMapper.get('FNN');
                    }
                    number1.action = 'CEASE';
                    listOfNumChars.add(number1);
                    
                }
                System.debug('simpleAttributesMapper::'+simpleAttributesMapper);
                if(simpleAttributesMapper.get('status') == 'RESERVED' || simpleAttributesMapper.get('status') == 'IN TRANSITION' || simpleAttributesMapper.get('status') == 'DISCONNECT PENDING' ){
                    numberAttributes = new ManageOrderDataObject.CharacteristicDataObject();
                    //numberAttributes.name ='number';
                    numberChar = new ManageOrderServiceUtilityHelper.NumberProductCharacteristic();
                    System.debug('simpleAttributesMapper Inside'+simpleAttributesMapper);
                    if(simpleAttributesMapper.get('status') == 'RESERVED'){
                        numberChar.numbers = simpleAttributesMapper.get('FNN');
                        numberChar.action = 'ADD';
                    }
                    else if(simpleAttributesMapper.get('status') == 'IN TRANSITION'){
                        numberChar.action  = 'TRANSITION';
                        if(simpleAttributesMapper.get('rangeTo') != null && simpleAttributesMapper.get('rangeTo') != ''){
                            rangeTo = simpleAttributesMapper.get('rangeTo');
                            rangeFrom= simpleAttributesMapper.get('rangeFrom');
                            numberChar.range = rangeFrom+':'+rangeTo;
                        }else{
                            numberChar.numbers = simpleAttributesMapper.get('FNN');
                        }

                    }//add block for removed numbers to be sent as CEASE ---- EDGE-92547
                    else if(simpleAttributesMapper.get('status') == 'DISCONNECT PENDING'){
                        numberChar.action  = 'CEASE';
                        if(simpleAttributesMapper.get('rangeTo') != null && simpleAttributesMapper.get('rangeTo') != ''){
                            rangeTo = simpleAttributesMapper.get('rangeTo');
                            rangeFrom= simpleAttributesMapper.get('rangeFrom');
                            numberChar.range = rangeFrom+':'+rangeTo;
                        }else{
                            numberChar.numbers = simpleAttributesMapper.get('FNN');
                        }
                    }
                    
                    listOfNumChars.add(numberChar);
                }
                
            }
            numberAttributes.name = 'Number';
            String SerialisedString = JSON.serialize(listOfNumChars);
            // System.debug('Serailised '+SerialisedString);
            // String sortedString = String.valueOf(listOfNumChars).replace('NumberProductCharacteristic:','').replace('[','{').replace(']','}').replace('(','[').replace(')',']').replace('=',':');
            numberAttributes.value = SerialisedString;
            System.debug('Serialised Numbs '+numberAttributes);
            prod.productCharacteristic.add(numberAttributes);
        }
        
    }
    public class NumberProductCharacteristic{
        public string numbers;
        public string action;
        public string Range;
    }
    public static Map<String,String> getRequestedServiceCancellationDate(List<String> orderId){
        Map<String,String> serviceCancelDateMap = new Map<String,String>();
        for(csord__Service__c services :[Select id,csord__Order__c,csordtelcoa__Service_Number__c,Cust_Req_Disconn_Date__c from csord__Service__c where csord__Order__c in :orderId]){
            Datetime reqDate = services.Cust_Req_Disconn_Date__c;
            if(reqDate != null)
                serviceCancelDateMap.put(services.csordtelcoa__Service_Number__c,String.valueOf(reqDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS')));
        }
        return serviceCancelDateMap;
    }
    
    // added for 65707 :: 19.4 :: 14/3/2019 :: 
    //Start
    public static Map<String,Contact> getDeliveryContactsForMobility (List<String> orderId){
        Map<String,Contact> serviceWithDeliveryContacts = new Map<String,Contact>();
        try{
            system.debug('orderId-65707:'+orderId);
            for(csord__Service__c rootServices : [Select id,Site_Delivery_Contact__r.id,Site_Delivery_Contact__r.Title, Site_Delivery_Contact__r.FirstName, Site_Delivery_Contact__r.LastName, Site_Delivery_Contact__r.Email, Site_Delivery_Contact__r.Phone, Site_Delivery_Contact__r.MobilePhone,csord__Order__c, Site_Delivery_Contact__c, csordtelcoa__Service_Number__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Service__c where csord__Order__c in : orderId]){
                system.debug('rootServices:'+rootServices+':::rootServices.Site_Delivery_Contact__c'+rootServices.Site_Delivery_Contact__c);
                
                //EDGE-92043 :: Modified
                if(rootServices.Site_Delivery_Contact__c != null)
                {
                    
                    serviceWithDeliveryContacts.put(rootServices.csordtelcoa__Service_Number__c, rootServices.Site_Delivery_Contact__r);
                }
            }
        }
        catch(Exception e){
            System.debug('Exception:'+ e.getTypeName() + ',' + e.getMessage() +','+  e.getLineNumber());
        }
        system.debug('map:'+serviceWithDeliveryContacts);
        return serviceWithDeliveryContacts;
    }
    //End
    
    /*********************************************************************************************************************************
* Method Name      :   getTransientDTOJSON
*Return            :   Returns Map<String,String> with transient attribute name value pair
*Story             :   EDGE-71655
**********************************************************************************************************************************/
    public static Map<String,String> getTransientDTOJSON(List<ID> priOrderID){
        Map<String,String> transientDTOJSON = new Map<String,String>(); 
        //Map<Id,String> orderAttMap  = new Map<>();
        
        String attachmentStr = '';
        try{
            for(Attachment att: [Select id,name,body,parentId from Attachment where name ='TransientDataDetails.json' AND parentId IN : priOrderID]){
                transientDTOJSON.put(att.parentId,att.body.toString());
            }
            return transientDTOJSON;
        }catch(Exception ex){
            return transientDTOJSON;
        }
        
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getTransientAttributesMap
*Return            :   Returns Map<String,Map<String,String>> with transient attribute name value pair
*Story             :   EDGE-71655
**********************************************************************************************************************************/
    public static Map<String,Map<String,String>> getTransientAttributesMap(String attachmentStr){
        System.debug('attachmentStr==>'+attachmentStr);
        String newAttStr = '{ "dataDTOList":'+attachmentStr+'}';
        System.debug('newAttStr==>'+newAttStr);
        Map<String,Map<String,String>> guidTransientAttrMap = new Map<String,Map<String,String>>();
        
        try{
            if(attachmentStr != null){ 
                TransientDataDTO transientDTOList =TransientDataDTO.unParse(newAttStr);
                List<TransientDataDTO.DataDTO> transDataDTOList = transientDTOList.dataDTOList;
                
                for(TransientDataDTO.DataDTO dataDTO : transDataDTOList){
                    for(TransientDataDTO.TransientAttribute tranAttr : dataDTO.attributes){
                        if(!guidTransientAttrMap.containsKey(dataDTO.specGUID)){
                            guidTransientAttrMap.put(dataDTO.specGUID, new Map<String, String>());
                        }
            if(dataDTO.specGUID != null && guidTransientAttrMap.get(dataDTO.specGUID) != null)
                        {guidTransientAttrMap.get(dataDTO.specGUID).put(tranAttr.name, tranAttr.value);}
                    }
                }
            }
            return  guidTransientAttrMap;
        }catch(Exception ex){
            System.debug('guidTransientAttrMap==>'+guidTransientAttrMap);
            return guidTransientAttrMap;
        }
        
    }
}
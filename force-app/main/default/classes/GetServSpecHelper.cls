/********************************************************
Class Name : GetServSpecHelper
Test Class : GetServSpecHelperTest
===============================================================================================================================
Change.No. Developer Name        	 Date   		Story        Description
1.         Pradeep Kumar    		17/10/2018  
2.	   		Shreya					22/11/2019		EDGE-117980 added calling Plans to R2R payload
3.         Vaibhav Deshpande        17/12/2019      INC000091511257 - R2R null check prod. Fix 
4.         Vaibhav Deshpande        20/12/2019      EDGE-98388     Changed logic to populate fixed numbers from number object
5. 	       Manish Jha                               Prod incident fix
6.         Vaibhav Deshpande        12/03/2020      EDGE-140203 fix
7.		   Pawan Singh				12/05/2021      EDGE-214615 added Error logging framework
8          Arun Selvan              05-Aug-2021     DIGI-9672 - Added GUID Tag for Mobile Numbers not for Fixed Numbers
9.         Mahima                   26-08-2021      DIGU-13335 -Fix for spec status in Product details API
**********************************************************
*/
global with sharing class GetServSpecHelper {
    
    /*public class ListingFNNWrapper {
        public String fnn {get;set;}
        public String range {get;set;}
    }*/
    private static final String CONST_INTERFACENAME = 'GetServSpecHelper';
    //EDGE-98388 created DTO class for maintaing number object values
    public class Numbers {   
        public String numbers {get;set;}
        public String isPartofRange {get;set;}
        public String startRange {get;set;}
        public String endRange {get;set;}
        public String status {get;set;}
        public String GUID {get;set;} // DIGI-9672
    }
    
    
    public static ServiceSpecDetailsResponseDTO ServiceSpecDetails(String correlationID){
        
        String servNum= correlationID.substringBefore(':');
        String guid= correlationID.substringAfter(':');
        String ucNumData='';
       // String ucNumbers='';
        String nums='';    //EDGE-98388 Start
        String numsFormat='';
        String numsFormats='';
        String numsFormatFinal='';//EDGE-98388 End
        List<Object> ucNumbers= new List<Object>();
        List<String> ucNumbersList= new List<String>();
        Map<String,String> attrMap = new Map<String,String>();
        String repStr;
        String repStrNew;
        
        List<CS_SpecificationDTO.ServiceSpecification> specList = new List<CS_SpecificationDTO.ServiceSpecification>();
        ServiceSpecDetailsResponseDTO finaldto = new ServiceSpecDetailsResponseDTO();
        ServiceSpecDetailsResponseDTO.DataDTO datadto = new ServiceSpecDetailsResponseDTO.DataDTO();
        ServiceSpecDetailsResponseDTO.Specification dtospec = new  ServiceSpecDetailsResponseDTO.Specification();
        
        List<ServiceSpecDetailsResponseDTO.Attributes> attributesSet = new List<ServiceSpecDetailsResponseDTO.Attributes>();
        List<ServiceSpecDetailsResponseDTO.Attributes> attributeslist = new List<ServiceSpecDetailsResponseDTO.Attributes>();
        
        try
        {
            List <csord__Service__c> serviceList;//EDGE-99311 added International_Direct_Dial__c and Mobility_Plan__c in service SOQL
            //EDGE-117980 Plan queried
            serviceList = [select id,name,csord__Subscription__c,modelChange__c,csordtelcoa__Service_Number__c,International_Direct_Dial__c,Mobility_Plan__c, Plan__c FROM csord__service__c where csordtelcoa__Service_Number__c=:servNum order by CreatedDate desc LIMIT 1];
            
          //*******************************EDGE-98388 Start*****************************************************  
           List<Number__c> ucNumList=[Select id,Service_Id__c,Service_Number__c,Status__c,is_Part_of_Range__c,Start_Range__c,End_range__c,Mobile__c,External_Id__c,Pattern_Type__c From Number__c Where Service_Id__c=:servNum AND (Mobile__c='Fixed' OR (Mobile__c='Mobile' AND Number_Group__r.Pattern_Type__c='Number'))];
            Numbers numDto=new Numbers();
            List<Numbers> numDtoList=new List<Numbers>();          
            for(Number__c num:ucNumList)
            {
                numDto=new Numbers();//added as part of EDGE-140203 - reinitializing DTO
                numDto.numbers=(String)num.Service_Number__c;
                if(num.is_Part_of_Range__c==true)
                { 
                    numDto.isPartofRange='Y';
                }else if(num.is_Part_of_Range__c==false)
                {
                     numDto.isPartofRange='N';
                }
               
                numDto.startRange=num.Start_Range__c;
                numDto.endRange=num.End_range__c;
                numDto.status=num.Status__c;
				if(num.Mobile__c=='Mobile' && num.Pattern_Type__c == 'Number')  // Added as part of DIGI-9672
               { 
                numDto.GUID=num.External_Id__c;
               }
                numDtoList.add(numDto);
            }
            for(integer i=0;i<numDtoList.size();i++)
            {
                if(i == 0){
                    ucNumbers.add(numDtoList[i]);
                }
                if (i > 0){
                    ucNumbers.add(numDtoList[i]); 
                }
            }
           // nums=ucNumbers.replace('=',':');
            //numsFormat=nums.replace('Numbers:[','');
            //numsFormats=numsFormat.replace(']','');
           // numsFormatFinal=numsFormats.replace('numbers','number');
            
            //*******************************EDGE-98388 End*****************************************************
            
            ServiceSpecDetailsResponseDTO.Attributes attribute;
            
            //EDGE-96894 Code refactor for SOQL inside loops
            List<Id> subsIdList=new List<Id>();
            Map<Id,csord__Subscription__c> subsMap=new Map<Id,csord__Subscription__c>();
            for(csord__Service__c service : serviceList){
                subsIdList.add(service.csord__Subscription__c);
            }
            List<csord__Subscription__c> subList=[select id,csordtelcoa__Subscription_Number__c,Suspension_reason__c FROM csord__Subscription__c where id IN :subsIdList];
            for(csord__Subscription__c sub:subList){
                subsMap.put(sub.Id,sub);
            }
            //End of Refactoring Changes
            //
            for(csord__Service__c serv : serviceList)
            { 
                List<CS_SpecificationDTO.ServiceSpecification> srvAssuranceSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'ASSURANCE');
                List<CS_SpecificationDTO.ServiceSpecification> srvTechnicalSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'SOMOpenAir'); //EDGE-116372
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
                if(srvAssuranceSpecList!=null && srvAssuranceSpecList.size()>0 && srvSpecList!= null){
                    srvSpecList.addAll(srvAssuranceSpecList);    
                }
                if(srvTechnicalSpecList !=null && !srvTechnicalSpecList.isEmpty() && srvSpecList!= null){ //EDGE-116372
                    srvSpecList.addAll(srvTechnicalSpecList);
                }
                
                for (CS_SpecificationDTO.ServiceSpecification specs: srvspecList){
                    
                    if(specs.guid.equals(guid))
                    {
                        specList.add(specs);
                        system.debug('spec list'+specList);
                        csord__Subscription__c subscr=subsMap.get(serv.csord__Subscription__c);
                        
                        for (CS_SpecificationDTO.ServiceSpecification guidspec: specList)
                        {
                            
                            datadto.subscriptionId = subscr.id;
                            datadto.subscriptionNumber=subscr.csordtelcoa__Subscription_Number__c ;
                            datadto.correlationID=correlationID;
                            
                            datadto.transactionID=IntegrationRecordHandlerUtil.getUUID();
                            datadto.transactionTime=Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX')+'';
                            datadto.serviceNumber = servNum;
                            
                            dtospec.version= guidspec.version;
                            dtospec.specExternalID = correlationID;
                            //Commented for DIGI-13335- Start
							/*if(subscr.Suspension_reason__c!=null){
								dtospec.status = Label.subscription_Suspended_Status;
							}
							else{*/
                                //Commented for DIGI-13335- end
                            dtospec.status = guidspec.status;
                            //}
                            dtospec.startDate = guidspec.startDate;
                            dtospec.serviceId = guidspec.serviceId;
                            if(guidspec.productConfigurationId!=null){ //INC000091511257 - R2R null check prod. Fix
                                dtospec.productConfigurationId = guidspec.productConfigurationId;
                            }
                            
                            String SpecName = guidspec.name;
                            dtospec.name= guidspec.description.substringBeforeLast('_'); 
                            if (dtospec.status != 'Connected' && serv.modelChange__c == true)
                            dtospec.modelChange=String.valueOf(serv.modelChange__c);
                            else
                            dtospec.modelChange='false'; 
                            dtospec.guid = guidspec.guid;
                            dtospec.endDate = guidspec.endDate;
                            dtospec.description = guidspec.description;
                            String SpecCode = guidspec.code;
                            //Changes for EDGE-96894
                            //dtospec.description = SpecCode.substringBeforeLast('_');                        
                            dtospec.code = guidspec.code;
                            //End of Changes for EDGE-96894
                            attributeslist = new List<ServiceSpecDetailsResponseDTO.Attributes>();
                          //EDGE-117980 adding plan to the attribute block of payload
                            attrMap.put('callingPlans',serv.Plan__c);//EDGE-117980
                            attrMap.put('internationalDirectDial',serv.International_Direct_Dial__c);//EDGE-99311
                            attrMap.put('mobilityPlan',serv.Mobility_Plan__c);//EDGE-99311
                            System.debug('attrMap'+attrMap);
                            for(CS_SpecificationDTO.SimpleAttributes attrsimple :guidspec.simpleAttributes)
                            {
                                attrMap.put(attrsimple.name,attrsimple.value);
                            }   
                            for(CS_SpecificationDTO.SimpleAttributes attrsimple :guidspec.additionalAttributes)
                            {
                                attrMap.put(attrsimple.name,attrsimple.value);
                            }
                            
                           /* if(guidspec.code==Label.specCodeUC || guidspec.code==Label.specCodeNGUC)
                            {
                                for(List<CS_SpecificationDTO.ComplexAttributes> complexChars :guidspec.complexAttributes.values())
                                {
                                    for(CS_SpecificationDTO.ComplexAttributes complexChar :complexChars){ 
                                        ucNumData= fetchUCNumbers(complexChar.SimpleAttributes);  
                                        ucNumbersList.add(ucNumData);
                                    }                                   
                                    
                              }
                                
                                for(integer i=0;i<ucNumbersList.size();i++)
                                {
                                    if(i == 0){
                                        ucNumbers ='{'+ucNumbersList[i]+'}';
                                    }
                                    if (i > 0){
                                        ucNumbers = ucNumbers+','+'{'+ucNumbersList[i]+'}';  
                                    }
                                }
                                ucNumbers = '['+ucNumbers +']';
                                attrMap.put('Number',ucNumbers);             
                            }*/
                            repStr=JSON.serialize(numDtoList,true);
                           repStrNew=repStr.replace('numbers','number');
                
                            system.debug('repStrNew '+repStrNew);
                           system.debug('numDtoList'+numDtoList);
                            attrMap.put('numbers',repStrNew); //EDGE-98388 - adding numbers block in Attibutes map
                            system.debug('attrMap '+attrMap);
                            for(String attr : attrMap.keySet())
                            {
                                attribute = new ServiceSpecDetailsResponseDTO.Attributes();
                                attribute.Name = attr;
                                if(attribute.Name == 'numbers'){
                            System.debug('Numbers2:::'+attrMap);
                        attribute.value= JSON.deserializeUntyped(attrMap.get(attr)) ;
                        System.debug('Numbers3:::'+attrMap);
                    }else{
                    attribute.value= attrMap.get(attr);
                    }                  
                                attributeslist.add(attribute);
                            }                            
                        }                     
                        
                        dtospec.attributes=attributeslist;  
                        datadto.specification=dtospec;    
                    }
                    system.debug(datadto);
                    
                }
            }
            finaldto.data=datadto;
           
        }
        
        catch(Exception e){
            //Logger.getLogger(GetServSpecHelper.class).debug(e); Logger.exitLogger();
            logException('ServiceSpecDetails', '', '', e.getMessage(), 'Exception occured '); //EDGE-214615
        }
        
        
        return finaldto;    
    }
   //EDGE-98388 Commenting fetchUCNumbers method as we are fetching UC numbers from number object
   /*public static String fetchUCNumbers(List<CS_SpecificationDTO.SimpleAttributes> simpleChars){
        
        Integer rangeTo=0;
        Integer rangeFrom=0;
        String fetchNumbers='';
        ListingFNNWrapper fnnWrapper = new ListingFNNWrapper();
        List<ListingFNNWrapper> fnnWrapList = new List<ListingFNNWrapper>();
        try{
        if(!simpleChars.isEmpty()){
            
            for(CS_SpecificationDTO.SimpleAttributes simpleAttr: simpleChars){
                
                if(simpleAttr.name.contains('FNN') && simpleAttr.value != null && simpleAttr.value != '' )
                    fnnWrapper.fnn =  simpleAttr.value;
                if((simpleAttr.name.contains('rangeTo')) && simpleAttr.value != null && simpleAttr.value != '') {
                    
                    rangeTo= integer.valueOf(simpleAttr.value);
                }
                if((simpleAttr.name.contains('rangeFrom'))&& simpleAttr.value != null && simpleAttr.value != '') {
                    rangeFrom= integer.valueOf(simpleAttr.value);
                }
                if(rangeTo != null && rangeFrom != null && rangeTo>0 && rangeFrom>0){
                    {
                        fnnWrapper.range= rangeFrom+':'+rangeTo;                    
                    }
                }
            }
        }
        fnnWrapList.add(fnnWrapper);
        for (ListingFNNWrapper fnnvalues : fnnWrapList )
        {
            if (fnnvalues.FNN != null)
            {
                fetchNumbers= fnnvalues.FNN;
            }
            if(fnnvalues.range != null)
            {
                fetchNumbers = fnnvalues.range;
            }
        }
        }
        
        catch(Exception e){
            Logger.getLogger(GetServSpecHelper.class).debug(e);
            Logger.exitLogger();
        }
        
        return fetchNumbers ;
    } */
        
    
    public static ServiceSpecDetailsResponseDTO BadRequestdto(String correlationID){
        ServiceSpecDetailsResponseDTO errdto = new ServiceSpecDetailsResponseDTO();
        List<ServiceSpecDetailsResponseDTO.error> errorbad = new List<ServiceSpecDetailsResponseDTO.error>();
        ServiceSpecDetailsResponseDTO.error err = new ServiceSpecDetailsResponseDTO.error();
        ServiceSpecDetailsResponseDTO.DataDTO datadto = new ServiceSpecDetailsResponseDTO.DataDTO();
        
        err.status='Bad Request';
        err.code = 400;
        err.message='Missing or invalid parameters';
        err.correlationID=correlationID;
        errorbad.add(err);
        datadto.error=errorbad;
        errdto.data = datadto;
        system.debug('errdto::'+errdto);
        return errdto;
    }
    
    public static ServiceSpecDetailsResponseDTO InternalErrordto(String correlationID){
        ServiceSpecDetailsResponseDTO errdto = new ServiceSpecDetailsResponseDTO();
        List<ServiceSpecDetailsResponseDTO.error> errorbad = new List<ServiceSpecDetailsResponseDTO.error>();
        ServiceSpecDetailsResponseDTO.error err = new ServiceSpecDetailsResponseDTO.error();
        ServiceSpecDetailsResponseDTO.DataDTO datadto = new ServiceSpecDetailsResponseDTO.DataDTO();
        
        err.status='Internal Error';
        err.code = 502;
        err.message='Error while processing information';
        err.correlationID=correlationID;
        errorbad.add(err);
        datadto.error=errorbad;
        errdto.data = datadto;
        system.debug('errdto::'+errdto);
        return errdto;
    }
     /*===============Error Logging Framework=============== */
     private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME); 
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber); 
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage); 
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }   
}
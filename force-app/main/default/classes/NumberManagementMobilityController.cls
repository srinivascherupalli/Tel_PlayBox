public with sharing class  NumberManagementMobilityController {
    public String isrerendered {get;set;}
    public String successM {get;set;}
    public String basketId {get;set;}
    public String rootConfigId {get; set;}
    public boolean showSearch {get;set;}
    public boolean showSuccess {get;set;}
    public boolean isReserve ;
    public boolean isUnReserve ;
    public boolean doSelect {get;set;}
    public String resrvedNumberQuantity {get;set;}
    public String device {get;set;}
    public String voice {get;set;} 
    public Integer quantity {get;set;}
    public Integer initialQuantity;
    public Integer reqQuantity {get;set;}
    public String reqType {get;set;}
    public String reqPattern {get;set;}
    public String reqSearch {get;set;}
    public Integer totalReserved {get;set;}
    public String totalReservedStr{get;set;}
    public Integer tobeReserved {get;set;}
    Integer lineItemQuantity;
    public String chatterBody {get;set;}
    public Integer size;
    public boolean isEnabled {get;set;}
    String jobid  {get;set;}
    public boolean checkStatus {get;set;}
    public List<MsisdnWrapper> unreserveList  {get;set;}
    public List<MsisdnWrapper> reserveList  {get;set;}
    public List<String> selectedReserve=new List<String>(); 
    public List<String> selectedUnReserve=new List<String>();
    NumberNCSMobilityHelper ncs;
    
    //Changed as part of EDGE-75162
    //public String prodSpecCode = 'DMCAT_ProductSpecification_000420';
    public String prodSpecCode = System.Label.CWPMobilityProductOffering;
    
    public boolean hide {get;set;}
    public boolean isAutoRes {get;set;}
    public boolean isAutoDisable {get;set;}
    public NumberManagementMobilityController(){
    	doSelect=false;
      	String unescapedBasketId = ApexPages.currentPage().getParameters().get('basketId');
        String unescapedConfigId = ApexPages.currentPage().getParameters().get('configId');
        basketId = EncodingUtil.urlEncode(unescapedBasketId,'UTF-8');
        rootConfigId = EncodingUtil.urlEncode(unescapedConfigId,'UTF-8');
        isReserve=false;
        isUnReserve = false;
        isEnabled=true;
        showSuccess=false;
		//basketId = 'a3Q2O0000008bB2';
       	//rootConfigId = 'a3T2O000000HXQ8UAO';
        System.debug('basketId::'+ basketId + '::rootConfigId::' + rootConfigId);
        totalReserved = 0;
        quantity=0;
        hide=true;  
        //setDetails();
        setProductDetails();
        reqType='New';
        //reqQuantity=5;
        lineItemQuantity=quantity;
        ncs = new NumberNCSMobilityHelper();
        System.debug('if note present :'+ncs.checkForExistingNCS(rootConfigId,'MobileNumberManagementv1_schema.json'));
        getUnreserveDetails();
        initialQuantity = totalReserved;
        reqQuantity = tobeReserved = getToBeReservedQty(quantity,totalReserved);
        validateSiteWithUSers();
    }
    /*Method to fectch the details from MobileNumberManagementv1_schema
	  Updated the method to fix the defect EDGE-78142
	*/
    public void getUnreserveDetails(){                                                                                                                                                                                  
        Boolean isFNNReserve = ncs.checkForExistingNCS(rootConfigId,'MobileNumberManagementv1_schema.json');
       List<String> reservedNumbers = new List<String>();
        if( isFNNReserve){
            reservedNumbers = ncs.getNumbersFromNCS(rootConfigId);
            
        }
        if(reservedNumbers!=null && !reservedNumbers.isEmpty()){
            totalReserved = getTotalReservedQty(reservedNumbers.size());	
           
        }
		//Defect  EDGE-78142 fix 
        else{
			
		 totalReserved = getTotalReservedQty(0);
		 
        }
          getUnreserveNumbers(reservedNumbers);
        
       
        
    }
    public PageReference  checkjobStatus(){
        AsyncApexJob jobstatus = [SELECT Id,JobItemsProcessed,JobType,NumberOfErrors,Status FROM AsyncApexJob where id =:jobid];
        if(jobstatus.Status=='Completed' ){
            system.debug('Job completed');
            isEnabled=false;
            hide=true;
            isAutoRes=false;
            isAutoDisable=false;
           
           
        }
        return null;
    }
    
    public void setProductDetails(){
        System.debug('::rootConfigId::' + rootConfigId);
        List<cscfga__Attribute__c> detailsList = [SELECT cscfga__Value__c,name  FROM cscfga__Attribute__c where cscfga__Product_Configuration__c=:rootConfigId and name IN ('DeviceModelDisplay','VoiceToText','PlanQuantiy')]; 
        System.debug('detailsList: '+detailsList);
        if(detailsList!=null){
            for(cscfga__Attribute__c detail: detailsList){
                if(detail.name == 'DeviceModelDisplay'){ //Changed the device attribute as DeviceModelDisplay
                    device = detail.cscfga__Value__c;
                }
                else if(detail.name == 'VoiceToText'){
                    voice = detail.cscfga__Value__c;
                }

                else if(detail.name == 'PlanQuantiy'){
                    if(detail.cscfga__Value__c!=null){
                        quantity =  Integer.valueOf(detail.cscfga__Value__c);
                    }
                    else{
                        quantity = 0;//remove this
                    }
                }
            }
        }
        
        
        
    }
    
    
    public List<SelectOption> getSearchTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('RANDOM','RANDOM'));
        options.add(new SelectOption('CONTINUOUS','CONTINUOUS'));
        return options;
    }  
       
    public void  doSearch() {
        showSuccess=false;
        String pat='(^[0-9]+[0-9]+%)|(^[0-9]+[0-9]+[*]|^[0-9]+[0-9])';

        System.debug(' reqSearch'+reqSearch+' pattern'+reqPattern+ 'quant'+reqQuantity);
        if(reqQuantity== null || reqQuantity==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_number_quantity_required));
            reqQuantity=lineItemQuantity;
            showSearch = false;
        }else if(reqQuantity <= 0 ||  reqQuantity > 50){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_number_quantity_validation));
            reqQuantity=lineItemQuantity;
            showSearch = false;
        } 
        else if( tobeReserved == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, totalReserved + ' '+Label.Reserved_number_validation));
        } 
        else if(reqQuantity > tobeReserved){
            String error=String.valueOf(tobeReserved)+' '+Label.Reserve_number_to_reserved_validation;
            //X number(s) to be reserved. Please enter the correct Quantity for search and reserve
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error));
            showSearch = false;
        }
        else if(reqSearch !='RANDOM' && reqPattern!=null &&  (System.Pattern.matches(pat, reqPattern)==false)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_number_pattern_validation));
            showSearch = false;
        }
        
        else{
            List<String> msisdnList ;
            msisdnList=searchMSISDN();
            if(msisdnList.size()!=0){
                createReserveWrap(msisdnList);
                showSearch = true;
            } 
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_numbers_not_found));
                 showSearch = false;
            }
        }  
    }
    public void clearAll() {
        system.debug('In clear all');
        reqQuantity =tobeReserved;
        reqSearch='RANDOM';
        reqPattern='';
        if(chatterBody==null){
            showSuccess=false;
        }
        showSearch = false;
    }
    public integer getToBeReservedQty(Integer quantity,Integer totalReservedQty) {
        System.debug(quantity+' '+totalReservedQty);
        if(quantity!=0){
            return (quantity-totalReservedQty);
        }
        else{
            return 0;
        }
    }
    public integer getTotalReservedQty(Integer totalReservedQty) {
        return totalReservedQty;
    }
    public class reserveList{
        Boolean isSelected;
        String msisdn;
    }   
    public class MsisdnWrapper{
        public Boolean isSelected {get;set;}
        public String msisdn {get;set;}
        MsisdnWrapper(String msisdn){
            this.isSelected = false;
            this.msisdn = msisdn;
        } 
    }   
    
    
    public void unreserveSelected(){
        showSuccess=false;
        isReserve=false;
        isUnReserve = true;
        isAutoDisable=true;
        System.debug('isReserve unreserve' +isReserve );
        selectedUnReserve.clear();
        List<String> unReserveLst= new  List<String>();
        for(MsisdnWrapper wrap:unreserveList){
            if(wrap.isSelected==true){
                unReserveLst.add(wrap.msisdn);
            }           
        }
        System.debug('unReserveList: '+unReserveLst);
        //call unreserve method here
        selectedUnReserve.addAll(unReserveLst);
        size = unReserveLst.size();
        if(size <= 0 || size>50){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_number_quantity_validation));
        }
        else{
            checkStatus=true;
            isEnabled=true;
            jobid = unReserveMSISDN(unReserveLst);
            if(jobid!=null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,Label.Number_un_reservation_in_progress));
            }
        }
    }
    public void reserveSelected(){
        showSuccess=false;
        isReserve=true;
        isUnReserve = false;
        
        System.debug('isReserve reserve' +isReserve );
        List<String> reserveLst= new  List<String>();
        for(MsisdnWrapper wrap:reserveList){
            if(wrap.isSelected==true){
                reserveLst.add(wrap.msisdn);
            }           
        }
        System.debug('ReserveList: '+reserveLst);
        //call reserve method here
        selectedReserve.addAll(reserveLst);
         size =  reserveLst.size();
        if(size <= 0 || size >50){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Reserve_number_quantity_validation));
        }
        
        else{
            isrerendered='true';
            checkStatus=true;
            isEnabled=true;
            jobid = reserveMSISDN(reserveLst);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,Label.Number_reservation_in_progress));
        }
        
    }
   //---Method to Add numbers in the the unreserveList--
    public List<MsisdnWrapper> getUnreserveNumbers(List<String> reservedNumbers) {
        //getnumbersFromNCShelper
        unreserveList = new List<MsisdnWrapper>();
        if(reservedNumbers!=null && !reservedNumbers.isEmpty()){
			for(String num : reservedNumbers){
            	MsisdnWrapper unRev = new MsisdnWrapper( num);
            	unreserveList.add(unRev);
        	}            
        }
		//Defect  EDGE-78142 fix 
        else{     	
		 	 unreserveList.clear();	
			 //
		 	 doSelect = false;
        } 
        System.debug(unreserveList);
        return unreserveList;
    }
    
   
    
    public List<MsisdnWrapper> createReserveWrap(list<String> msisdnList) {
        reserveList = new List<MsisdnWrapper>();
        for(String msisdn : msisdnList){
            MsisdnWrapper unRev = new MsisdnWrapper( msisdn);
            reserveList.add(unRev);
        }
        System.debug(reserveList);
        return reserveList;
    }
    
    //----- Search MSISDN Numbers -----//
    public List<String> searchMSISDN(){
        System.debug('in search');
        List<String> msisdnList = new List<String>();
        FNNDTO fnnDto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
        List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
        cto.value = 'Regular';
        ctoList.add(cto);
       	fdo.quantity = reqQuantity;
        
        fdo.searchType = reqSearch;
		if( fdo.searchType == 'CONTINUOUS')
		{
		fdo.pattern = '614'+ reqPattern;
		}
        
        fdo.poolName = 'Postpaid';
        fdo.activityName = 'SEARCH';
        fdo.categoryType = ctoList;
        fdo.searchStatus = 'AVAILABLE';
        fnnDto.data = fdo;
        FNNResponseDTO fnnResponse = MSISDNService.searchMSISDN(fnnDto);
        
        if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
            for(FNNResponseDTO.ResourcesDataObject res : fnnResponse.data.resources){
                msisdnList.add(res.resourceId);
            }
        }
        System.debug('msisdnList::' + msisdnList);
        return msisdnList;
    }
    
    /*Description:Method to Implement Auto Reserve MSISDN Numbers
      Updated method as a part of defect fix
     */
    public void doAutoReserve(){
        System.debug('isAutoRes: '+isAutoRes);
        if( (quantity-totalReserved) == 0 || (quantity-totalReserved) < 0 || quantity >50){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, totalReserved + ' '+Label.Reserved_number_validation));
            
                        isAutoDisable=false;
            			isAutoRes=false;
            //Defect EDGE:78142 fix
            			doSelect=false;
            			for(MsisdnWrapper wrap:unreserveList){
            			wrap.isSelected=false;
                        }
            //Defcet EDGE:78142 Implementation ends 				
        }
        else if(isAutoRes){
            hide=false; 
           autoReserveMSISDN(); 
        } 
            
                
            
                       
    }
  
    //------Auto Reserve MSISDN Numbers---//
    public void autoReserveMSISDN()
    {
        showSuccess=false;
        isReserve=true;
         isAutoDisable=true;
        checkStatus=true;
         isEnabled=true;
            jobid=reserveMSISDN(null);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,Label.Number_reservation_in_progress));
            getUnreserveDetails();
        System.debug('In AutoReserve::'+ totalReserved);
        
        
        
       
        
    }
    //----- Reserve MSISDN Numbers -----//
     public String reserveMSISDN(List<String> fnnListToReserve){
        String jobId1;
        System.debug('In Reserve::'+ quantity);
        if (((quantity-totalReserved) != NULL && (quantity-totalReserved) > 0) && fnnListToReserve==NULL)
        {
            
            Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
            FNNDTO dto = new FNNDTO();
            FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
            FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
            List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
            cto.value = 'Regular';
            cto.value = 'Telstra Numbers';
            ctoList.add(cto);
            fdo.poolName = 'Postpaid';
            fdo.activityName = 'DIRECT HOLD';
            fdo.categoryType = ctoList;
            fdo.searchStatus = 'AVAILABLE';
            dto.data = fdo;
            for(integer i = 0; i< (quantity-totalReserved) ; i++){
                fnnMap.put(String.valueOf(i),dto);
            }
            system.debug('fnnmap'+fnnMap);
            jobId1 = System.enqueueJob(new MSISDNService(fnnMap,'SearchReserveMSISDNHandler',basketId,rootConfigId));
            System.debug('AutoreserveJobId::' + jobId1);
                    

            
        }
        else{
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        for(String fnn : fnnListToReserve){
            FNNDTO dto = new FNNDTO();
            FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
            FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
            List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
            cto.value = 'Regular';
            cto.value = 'Telstra Numbers';
            ctoList.add(cto);
            fdo.poolName = 'Postpaid';
            fdo.activityName = 'DIRECT HOLD';
            fdo.categoryType = ctoList;
            fdo.searchStatus = 'AVAILABLE';
            dto.data = fdo;
            fnnMap.put(fnn,dto);
        }
        
        jobId1 = System.enqueueJob(new MSISDNService(fnnMap,'ReserveMSISDNHandler',basketId,rootConfigId));
        System.debug('reserveJobId::' + jobId1);
        
        }
        return jobId1;
        
    }
    
    public void sendChatterNotification(){
        
        System.debug('in sendChatterNotification');
        string numbers ='';
        chatterBody ='';
        Integer cnt=0;
        getUnreserveDetails();
        System.debug('isReserve send not'+isReserve );
        if(isReserve){
            if(totalReserved!=initialQuantity || totalReserved==quantity){
                chatterBody = 'Number reservation request is complete, '+totalReserved + ' '+Label.Chatter_reserve_message;
                successM = 'Number reservation is complete, you requested '+totalReserved+' numbers, '+totalReserved+' '+Label.Chatter_reserve_message;
                
            }
            else{
                chatterBody=null;
                showSuccess=false;
            } 
        }
        else{
        System.debug(totalReserved+' '+initialQuantity);
            if(totalReserved<=initialQuantity){
                chatterBody = 'Number un-reservation request is complete, '+size+ ' '+Label.Chatter_unreserve_message;
                successM = 'Number un-reservation is complete, you requested '+size+' numbers, '+size+' '+Label.Chatter_unreserve_message;
            }
            else{
                chatterBody=null;
                showSuccess=false;
            }
        }
        System.debug('chatterBody: '+chatterBody);
        if(chatterBody!=null){
            FeedItem post = new FeedItem();
            post.ParentId = UserInfo.getUserId() ;
            post.Body = chatterBody ;
            showSuccess=true;
            insert post;
        }
        showSuccess=true;
        System.debug(numbers);
        tobeReserved = getToBeReservedQty(quantity,totalReserved);
        if(reserveList!=null && reserveList.size()!=0){
            reserveList.clear();
        }
       
        //checkStatus=false;
        initialQuantity = totalReserved;
        clearAll();
        validateSiteWithUSers();
         System.debug('showSuccess: '+showSuccess);
    }
    
    //----- Un-Reserve MSISDN Numbers -----//
    public String unReserveMSISDN(List<String> fnnListToUnReserve){
        //String basketId ='a3Q2O00000087VQUAY';
        //String rootConfigId = 'a3T2O000000GGDqUAO';
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        for(String fnn : fnnListToUnReserve){
            fnnMap.put(fnn,new FNNDTO());
        }
        String jobId = System.enqueueJob(new MSISDNService(fnnMap,'UnReserveMSISDNHandler',basketId,rootConfigId));
        System.debug('unReserveJobId::' + jobId);
        return jobId;
    }
     public void validateSiteWithUSers(){

            if(quantity==totalReserved){
                system.debug('quantity: '+quantity+'totalReserved '+totalReserved);
                resrvedNumberQuantity = 'true';
            }else{
                resrvedNumberQuantity = 'false';
            }
            totalReservedStr = String.valueOf(totalReserved);
            System.debug('resrvedNumberQuantity: '+resrvedNumberQuantity);
     }
}
/*************************************************************************************************
Name : PortInController
Description : Used to check port in numbers for MAC and new order
Author: Kalashree Borgaonkar
Story: EDGE-80749,EDGE-89257,EDGE-89299
***************************************************************************************************/
public with sharing class PortInController {
    /*-------------------------------------------------------- 
EDGE-80749
Method: saveMsisdnSQresults
Description: Method to save SQ response for MSISDN list
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @AuraEnabled
    public static String saveMsisdnSQresults(String msisdnList,String basketid){
        System.debug('msisdnList'+msisdnList);
        //basketid='a3Q2O0000008VZj';
        List<NumberWrapper> msisdnDetailsList = null;
        String saveStatus='';
        try{
            msisdnDetailsList = (List<NumberWrapper>)System.JSON.deserialize(msisdnList, List<NumberWrapper>.Class);
            system.debug('msisdnDetailsList+' +msisdnDetailsList);
            saveStatus = SQCheckMSISDNCtrl.saveMsisdn(msisdnDetailsList,basketid); //EDGE - 80745
        }
        catch(Exception e){
            System.debug('Exception in saveMsisdnSQresults'+e.getStackTraceString());
        }
        return saveStatus;
    }
    /*-------------------------------------------------------- 
EDGE-107149
Method: getQualifyResponse
Description: Method to get qualify response
Author:Aishwarya
--------------------------------------------------------*/   
    @AuraEnabled
    public static List<NumberWrapper>  getMultipleQualifyResponse( String msisdnList,String basketid){
        System.debug('msisdnList'+msisdnList);
        List<NumberWrapper> msisdnDetailsList = null;
        msisdnDetailsList = (List<NumberWrapper>)System.JSON.deserialize(msisdnList, List<NumberWrapper>.Class);
        System.debug('msisdnDetailsList'+msisdnDetailsList);
        List<NumberWrapper> wrapList=new List<NumberWrapper> ();
        NumberWrapper wrapper=Null;
        List<String> numList=new List<String>();
        List<cscfga__Product_Basket__c> bsktAcc = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        system.debug('bsktAcc*' +bsktAcc);
        List<Service_Qualification__c> sqImportedList = ConstantMetadataUtility.getserviceQualification(bsktAcc[0].csbb__Account__c,basketid);//EDGE-147324,DIGI-864. Added basketid param
        for(NumberWrapper portnum :msisdnDetailsList){
            if(portnum.isSelect== true){
                String msisdn='614'+portnum.num;
                numList.add(msisdn);
            }
        }
        System.debug('numList'+numList);
        SQCheckMobileRequestDTO sqRequest=SQCheckMSISDNCtrl.createPayload(numList);
        SQCheckMobileResponseDTO sqResponse = SQCheckMSISDNCtrl.calloutToSQCheck(sqRequest);
        Map<String,SQCheckMobileResponseDTO.NumberDetails> mapMsisdnToQualify =  new Map<String,SQCheckMobileResponseDTO.NumberDetails>();
        System.debug(sqResponse);
        if(sqResponse!=null && sqResponse.data!=null && sqResponse.data.numberDetails!=null && !sqResponse.data.numberDetails.isEmpty()){
            for(SQCheckMobileResponseDTO.NumberDetails numDetails : sqResponse.data.numberDetails){
                mapMsisdnToQualify.put(numDetails.mobileNumber.substringafter('614'), numDetails);
            }
            System.debug('mapMsisdnToQualify' +mapMsisdnToQualify);
            if(!mapMsisdnToQualify.keyset().isempty()){
                for(NumberWrapper wrap :msisdnDetailsList){
                    System.debug('wrap++' +wrap);
                    String msisdnNum=wrap.num;
                    if(mapMsisdnToQualify.keyset().contains(msisdnNum)){
                        //wrap = new NumberWrapper();
                        //wrap.num=wrap.num;
                        //wrap.accountNumber=msisdnDetailsList[0].accountNumber;
                        wrap.reason=mapMsisdnToQualify.get(msisdnNum).reason;
                        wrap.isSelect=false;
                        wrap.code=mapMsisdnToQualify.get(msisdnNum).code;
                        wrap.indicator=mapMsisdnToQualify.get(msisdnNum).mobileNumberPortabilityIndicator;
                        for(Service_Qualification__c sq:sqImportedList){
                            if(sq.Service_Number__c == mapMsisdnToQualify.get(msisdnNum).mobileNumber && sq.UniqueBasketMSISDN__c!=null)
                                wrap.uniqueBakset=sq.UniqueBasketMSISDN__c;
                        }
                        //msisdnDetailsList.add(wrap);
                        System.debug('wrap++' +wrap);
                    }
                }
            }
        }
        if(sqResponse!=null && sqResponse.status!=200 && sqResponse.status!=201){
            if(sqResponse.status==429){
                wrapper = new NumberWrapper();
                wrapper.message = sqResponse.message;
                msisdnDetailsList.clear();//EDGE-151027 - Kalashree Borgaonkar. Clear list if error
            }
            else{
                if(sqResponse.errors!=null && sqResponse.errors.errorDetails!=null && !sqResponse.errors.errorDetails.isEmpty()){
                    System.debug('sqResponse.errors.errorDetails:'+sqResponse.errors.errorDetails); 
                    wrapper = new NumberWrapper();
                    wrapper.isSelect = false;
                    wrapper.message = sqResponse.errors.errorDetails[0].message;
                    msisdnDetailsList.clear();//EDGE-151027 - Kalashree Borgaonkar. Clear list if error
                } 
            }
            msisdnDetailsList.add(wrapper);
        }
        return msisdnDetailsList;
    }
    /*-------------------------------------------------------- 
EDGE-89257,EDGE-88795
Method: saveMsisdnSQresults
Description: AC3 Method to get qualified MSISDN
Author:Kalashree Borgaonkar,Ila
--------------------------------------------------------*/
    @AuraEnabled
    public static List<QualifiedNumbers>   getQualifiedMsisdn(String basketid){
        //basketid='a3Q2O0000008VZj';
        /********************************************
EDGE-88795: Populate Account on SQ for PortIn
Author:Ila
*********************************************/
        List<cscfga__Product_Basket__c> bsktAcc = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        QualifiedNumbers qualifiedNum=null;
        List<QualifiedNumbers> qualifiedNumList = null;
        List<Service_Qualification__c> qualifiedSQList = null;
        List<Service_Qualification__c> sqList = null;
        Set<String> servNum = new set<String>();
        set<ID> sqIds= new set<Id>();
        if(!bsktAcc.isEmpty()){
            qualifiedNumList = new  List<QualifiedNumbers>();
            List<Number__c> numList = [SELECT id,Service_Number__c from Number__c where basket__c=: basketid AND  type__C='Port In']; 
            for(Number__c num: numList){
                servNum.add(num.Service_Number__c);
                system.debug('number in Pool for current account== ' +servNum);
            } 
            //EDGE-130044 Query modified to get value of Added_to_CA_form__c
            qualifiedSQList=[SELECT id,Service_number__c,Added_to_CA_form__c,Account__c,
                             (SELECT id,Basket__c from Numbers__r where (Basket__c=: basketid and  Product_Configuration__c=null) 
                              or (Basket__c!=: basketid and  Product_Configuration__c!=null))  
                             from Service_Qualification__C where Account__c=:bsktAcc[0].csbb__Account__c 
                             and Service_number__c  NOT IN :servNum and Portability_Code__c!=null ]; 
            system.debug('qualifiedSQList=='+qualifiedSQList.size());
            system.debug('qualifiedSQList++' +qualifiedSQList);
            for(Service_Qualification__c sq :qualifiedSQList){
                if(sq.Numbers__r.size()==0){
                    //EDGE-130044 Mapped Added to CA form value to UI checkbox
                    qualifiedNum = new QualifiedNumbers(sq.Added_to_CA_form__c,sq.Service_Number__c);
                    system.debug('qualifiedNum+' +qualifiedNum);
                    qualifiedNumList.add(qualifiedNum);
                } 
            }
        }
        system.debug('qualifiedNumList+' +qualifiedNumList);
        return qualifiedNumList;
    }
    /*-------------------------------------------------------- 
EDGE-89257,EDGE-88795
Method: saveToReservationPool
Description: AC3 Method to Save MSISDNs to Number__c object
Author:Kalashree Borgaonkar,Ila
--------------------------------------------------------*/
    @AuraEnabled
    public static String  saveToReservationPool(String msisdnList,String basketid){
        /********************************************
EDGE-88795: Populate Account on SQ for PortIn
Author:Ila
*********************************************/
        List<cscfga__Product_Basket__c> bsktAcc = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        List<Service_Qualification__c> sqList = ConstantMetadataUtility.getserviceQualification(bsktAcc[0].csbb__Account__c,basketId);//EDGE-147324,DIGI-867
        system.debug('sqList++' +sqList);
        Map<String, Id> sqMap = new Map<String, Id>();
        for(Service_Qualification__c sq: sqList){
            sqMap.put(sq.Service_Number__c,sq.Id);
        }
        system.debug('sqMap+' +sqMap);
        System.debug('msisdnList: '+msisdnList);
        // basketid='a3Q2O0000008VZj';
        String status=null;
        Number__c msisdn = null;
        List<Number__c> msisdnListToSave = null;
        List<String> msisdnLst =null;
        try{
            if(msisdnList!=null ){
                List<QualifiedNumbers> msisdnDetailsList = (List<QualifiedNumbers>)System.JSON.deserialize(msisdnList, List<QualifiedNumbers>.Class);
                System.debug('msisdnDetailsList: '+msisdnDetailsList);
                msisdnListToSave = new List<Number__c>();
                msisdnLst = new List<String>();
                for(QualifiedNumbers msisdns : msisdnDetailsList){
                    if(msisdns.isSelected==true){
                        msisdn = new Number__c();
                        msisdn.Service_Number__c = msisdns.qualifiedMsisdn;
                        msisdn.Basket__c = basketid;
                        msisdn.Type__c = 'Port In';
                        //EDGE-108230. Kalashree Borgaonkar start
                        msisdn.Mobile__c='Mobile';
                        msisdn.Account__c = !bsktAcc.isEmpty()? bsktAcc[0].csbb__Account__c : null;
                        //EDGE-108230. Kalashree Borgaonkar end
                        if(sqMap.containsKey(msisdns.qualifiedMsisdn))
                        {
                            msisdn.Service_Qualification__c=sqMap.get(msisdns.qualifiedMsisdn);
                        }
                        msisdnListToSave.add(msisdn);
                        msisdnLst.add(msisdns.qualifiedMsisdn);
                    }
                }
                if(msisdnListToSave!=null && !msisdnListToSave.isEmpty()){
                    insert msisdnListToSave ;
                    //updateServiceQualification(msisdnLst,basketid);
                    status = 'Moved to Reservation Pool';
                } 
            }
            else{
                status = 'SaveError';
            }
        }
        catch(Exception e){
            status = 'SaveError';
            System.debug('Exception in saveToReservationPool'+e.getStackTraceString());
        } 
        return status;
    }
    /*---------------------------------------------------------------------------
EDGE-90327
Method:checkActiveCAF
Description:  Method to check if Active CAF is there for the basket
Author:Kalashree Borgaonkar
------------------------------------------------------------------------------*/
    @AuraEnabled
    public static CafDetails checkActiveCAF(String basketid){
        CafDetails details=null;
        List<cscfga__Product_Basket__c> basketList = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        Boolean isDisable=true;
        String basketStage=basketList[0].csordtelcoa__Basket_Stage__c;
        List<Customer_Authority_Form__c> caf= [SELECT Id,status__c FROM Customer_Authority_Form__c 
                                               WHERE Opportunity__c =:basketList[0].cscfga__Opportunity__c AND Is_active__c=TRUE];
        //EDGE-97393,If basket stage is not contract accepted then disable the button
        System.debug('caf::'+caf);
        if(basketStage != 'Contract Accepted' && caf.isEmpty() ){
            //isDisable = true;
            details=new CafDetails(true,true);
        }
        else if(!caf.isEmpty() ){
            // isDisable = false;
            details=new CafDetails(false,'Success'.equalsIgnoreCase(caf[0].status__c)?true:false);
        }
        else{
            details=new CafDetails(true,true);
        }
        System.debug('Deatisl::'+details);
        return details;
    }
    /*---------------------------------------------------------------------------
EDGE-89299
Method:getBasketId
Description:  Method to check if Active CAF is there for the basket
Author:Aishwarya Yeware
------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getBasketId(String basketid)
    {
        //List<String> basketName = Null;
        String basketName=null;
        system.debug('basketid: '+basketid);
        //List<cscfga__Product_Basket__c> basketList= [SELECT Name FROM cscfga__Product_Basket__c WHERE id =:basketid];
        List<cscfga__Product_Basket__c> basketList = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        if(!basketList.isEmpty()){
            basketName =  basketList[0].name;
        }
        system.debug('basketName' + basketName);
        return basketName;     
    }
    /*---------------------------------------------------------------------------
EDGE-89299,EDGE-88795
Method:CheckCAF
Description:  Method to check if Active CAF is there for the basket
Author:Aishwarya Yeware,Ila
------------------------------------------------------------------------------*/
    //
    @AuraEnabled
    public static boolean checkCAF(String basketid)
    {
        //List<cscfga__Product_Basket__c> accOppo= [SELECT csbb__Account__c,cscfga__Opportunity__c 
        //FROM cscfga__Product_Basket__c where id =:basketid ];
        List<cscfga__Product_Basket__c> accOppo = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        Boolean activeCAF=false;
        Integer numberofActiveCAF = [SELECT count() FROM Customer_Authority_Form__c 
                                     WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c AND Is_active__c=TRUE];
        if(numberofActiveCAF > 0)
        {
            activeCAF=true;
        }
        return activeCAF;
    }
    /*---------------------------------------------------------------------------
EDGE-89299
Method:createLink
Description:  Method to create document link with new CA form
Author:Aishwarya Yeware
------------------------------------------------------------------------------*/
    @AuraEnabled
    public static ID createLink(String fileName, String base64Data, String contentType,String basketid,Date cafDate)  {
        List<cscfga__Product_Basket__c> accOppo = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        ID caflinkId=null;
        Customer_Authority_Form__c caf=new Customer_Authority_Form__c();
        caf.Account__c=accOppo[0].csbb__Account__c;
        caf.Opportunity__c=accOppo[0].cscfga__Opportunity__c;
        caf.Customer_Authorised_date__c=cafDate;
        caf.Is_active__c=true;
        try{
            upsert caf;
            caflinkId=saveTheFile(caf.ID, fileName, base64Data,contentType);
            System.debug('caflinkId' +caflinkId);
            System.debug('Inserted' +caf);
            List<Customer_Authority_Form__c> cafList= [SELECT id,Is_active__c 
                                                       FROM Customer_Authority_Form__c 
                                                       WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c 
                                                       AND is_active__c=true order by createdDate DESC OFFSET 1];
            System.debug('cafList:'+cafList);
            List<Customer_Authority_Form__c> cafupdateList = new List<Customer_Authority_Form__c>();
            for(Customer_Authority_Form__c ca:cafList)
            {
                if(ca.Is_active__c==true){
                    ca.Is_active__c=false;
                    cafupdateList.add(ca);
                }  
            }
            if(!cafupdateList.isEmpty()){
                System.debug('cafupdateList');
                update cafupdateList;
            }
        }
        catch(Exception e){
            system.debug('EXception in createLink'+e.getStackTraceString());
        }   
        return caflinkId;
    }
    /*---------------------------------------------------------------------------
EDGE-89299
Method:saveTheFile
Description:  Method to save file on CAF object
Author:Aishwarya Yeware
------------------------------------------------------------------------------*/
    @AuraEnabled // EDGE-147324
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType)  
    { 
        ContentVersion uploadFileVersion = new ContentVersion();
        system.debug('Saving chatter files '+fileName + ' '+ contentType+' '+base64Data);
        try{
            uploadFileVersion = ConstantMetadataUtility.uploadFile(parentId, fileName, base64Data, contentType);
        }
        catch(Exception e){
            system.debug('EXception in saveTheFile'+e.getStackTraceString());
        }
        system.debug('uploadFileVersion.id');
        return uploadFileVersion.id;
    }      
    //Wrapper to display values on UI
    public class NumberWrapper{
        @AuraEnabled
        public String num {get;set;}
        @AuraEnabled
        public String accountNumber {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String reason {get;set;} 
        @AuraEnabled
        public String indicator {get;set;} 
        @AuraEnabled
        public String message {get;set;} 
        @AuraEnabled
        public String carrier {get;set;}
        @AuraEnabled
        public String uniqueBakset {get;set;}
        @AuraEnabled
        public Boolean isSelect {get;set;}
    }
    //EDGE-89257 Wrapper to display values on Port in selection UI
    //Author: Kalashree Borgaonkar
    public class QualifiedNumbers{
        @AuraEnabled
        public Boolean isSelected ;
        @AuraEnabled
        public String isIncluded ;//EDGE-14414. Kalashree. Added this to show values on UI
        @AuraEnabled
        public String qualifiedMsisdn ;
        public QualifiedNumbers(Boolean isSelected ,String qualifiedMsisdn){
            this.isSelected = isSelected;
            this.qualifiedMsisdn =qualifiedMsisdn;
            this.isIncluded = isSelected?'Yes':'No'; //EDGE-14414. Kalashree. Added this to show values on UI
        }
    }
    //Wrapper to get active CAF details
    public class CafDetails{
        @AuraEnabled
        public Boolean isActive ;
        @AuraEnabled
        public Boolean isVerified ;
        public CafDetails(Boolean isActive ,Boolean isVerified){
            this.isActive = isActive; 
            this.isVerified =isVerified;
        }
    }
    //Wrapper to display ppv details
    public class PpvDetails{
        @AuraEnabled
        public String custAuth;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String expiry;
        @AuraEnabled
        public String approver;
        @AuraEnabled
        public String mobile;
         //EDGE-131832 Added to fix the defect
        @AuraEnabled
        public String cafId;
        public PpvDetails(String custAuth ,String status,String expiry ,String approver,String mobile,String cafId){
            this.custAuth = custAuth; 
            this.status =status;
            this.expiry = expiry; 
            this.approver =approver;
            this.mobile =mobile;
            this.cafId =cafId;
    }
    }
    /*---------------------------------------------------------------------------
EDGE-90327, AC1
Method:getPpvDetails
Description:  Method to PPV details
Author:Kalashree Borgaonkar
------------------------------------------------------------------------------*/ 
   @AuraEnabled
    public static PpvDetails getPpvDetails(String basketid){
        String currentUrl=URL.getCurrentRequestUrl().toExternalForm();
        system.debug('currentUrl+' +currentUrl);
         String url =   URL.getSalesforceBaseURL().toExternalForm();
        system.debug('url+' +url);
        PpvDetails ppvDetail = null;
        String custAuth;
        List<String> statusList=new List<String>{'Pending','Authorised','Not Sent'};
            List<Customer_Authority_Form__c> cafList = null;
        String expiryDate=null;
        List<cscfga__Product_Basket__c> accOppo = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        if(!accOppo.isEmpty()){
            cafList = [SELECT id,Customer_Authority_Form__c,Customer_Authority_Form__r.Customer_Authorised_date__c,
                       Customer_Authority_Form__r.ppv_status__c,contact__r.name,MSISDN__c,ppv_status__c 
                       FROM Customer_Authority_Form__c  WHERE Type__c='PPV' AND Opportunity__c =:accOppo[0].cscfga__Opportunity__c 
                       AND Customer_Authority_Form__r.is_active__c=true order by createdDate DESC LIMIT 1 ];                  
            System.debug('cafList: '+cafList);
            if(!cafList.isEmpty()){
                //EDGE-111382 start
                if(statusList.contains(cafList[0].ppv_status__c)){
                    expiryDate=cafList[0].Customer_Authority_Form__r.Customer_Authorised_date__c!=null?cafList[0].Customer_Authority_Form__r.Customer_Authorised_date__c.addDays(30).format():'';//EDGE-110600 . KAlashree Borgoankar: fix for expiry date
                }
                 //EDGE-131832 Added fix to enable access to PRM users
                 if(currentUrl.contains('partners')){
                       custAuth = url + '/partners/s/detail/' + cafList[0].Customer_Authority_Form__c;
                    }
                    else{
                custAuth= url + '/' + cafList[0].Customer_Authority_Form__c;
                    }
                //EDGE-117585 Kalashree Borgaonkar, Show CAF record 
                ppvDetail = new PpvDetails(custAuth,
                                           cafList[0].ppv_status__c,
                                           expiryDate,
                                           cafList[0].contact__r.name,
                                           cafList[0].MSISDN__c,
                                          cafList[0].Customer_Authority_Form__c);
            }
            else{
                List<Customer_Authority_Form__c> caf = [SELECT id FROM Customer_Authority_Form__c 
                                                        WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c 
                                                        AND is_active__c=true order by createdDate DESC LIMIT 1];
                List<OpportunityContactRole> oppContactlst =[SELECT Id,contact.name 
                                                             FROM OpportunityContactRole opp 
                                                             where opportunityid=:accOppo[0].cscfga__Opportunity__c];
                if(!oppContactlst.isEmpty()){
                      //EDGE-131832 Added fix to enable access to PRM users
                    if(currentUrl.contains('partners')){
                       custAuth = url + '/partners/s/detail/' + caf[0].id;
                    }
                    else{
                custAuth= url + '/' + caf[0].id;
                    }
                    //EDGE-117585 Kalashree Borgaonkar, Show CAF record 
                    ppvDetail = new PpvDetails(!caf.isEmpty()?custAuth:null,
                                               null,
                                               null,
                                               oppContactlst[0].contact.name,
                                               null,
                                              !caf.isEmpty()?caf[0].id:null);
                }                
            }
            //EDGE-111382 end
        }
        return ppvDetail;
    }
    /*-------------------------------------------------------- 
EDGE-80751
Method: getImportedData
Description:  Method to get Data imported from wizard- dormant as it is 19.11 story
Author:Ila
--------------------------------------------------------*/
    @AuraEnabled
    public static List<NumberWrapper> getImportedData(String basketid){
        NumberWrapper wrapSQ = null;
        List<NumberWrapper> sqWrapList = new List<NumberWrapper>();
        List<cscfga__Product_Basket__c> bsktAcc = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        system.debug('bsktAcc*' +bsktAcc);
        List<Service_Qualification__c> sqImportedList = ConstantMetadataUtility.getserviceQualification(bsktAcc[0].csbb__Account__c,basketid);//EDGE-147324, DIGI-867
        system.debug('sqImportedList*' +sqImportedList);
        for(Service_Qualification__c sq:sqImportedList){
            if(sq.Portability_Code__c==null){
                wrapSQ = new NumberWrapper();
                wrapSQ.num=sq.Service_Number__c.substringafter('614');
                wrapSQ.accountNumber=sq.Incumbent_Account_Number__c;
                wrapSQ.carrier=sq.Incumbent_Carrier__c;
                system.debug('wrapSQ*' +wrapSQ);
                sqWrapList.add(wrapSQ);
            }
        }
        system.debug('sqWrapList+' +sqWrapList);
        return sqWrapList;
    }
      /*-------------------------------------------------------- 
EDGE-89299
Method: isPortInValid
Description:check for validity of CA form
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isPortInValid(String basketid){ //EDGE-89299 check for validity of CA form
        Boolean isValid = false;
        List<Customer_Authority_Form__c> caFormLst = [SELECT Id, Customer_Authorised_date__c FROM 
                                                      Customer_Authority_Form__c WHERE Is_active__c = TRUE 
                                                      AND Opportunity__c IN(SELECT cscfga__Opportunity__c 
													FROM cscfga__Product_Basket__c WHERE id =:basketid) order by createdDate DESC LIMIT 1];
        if(caFormLst != null && caFormLst.size()>0){
            if(caFormLst[0].Customer_Authorised_date__c != null && (Date.today()).daysBetween(caFormLst[0].Customer_Authorised_date__c.addDays(30)) < Integer.valueOf(Label.PortInCAFormValidity))
                isValid = true;
        }
        return isValid;
    }
/*-------------------------------------------------------- 
EDGE-130044
Method: updateServiceQualification
Description:Update service qualification record on basis of added to CA form value
Author:Aishwarya
--------------------------------------------------------*/
     @AuraEnabled 
    public static boolean updateServiceQualification(String msisdnList,String basketid ){
         system.debug('msisdnList++' +msisdnList);
        system.debug('basketid++' +basketid);
      Boolean isUpdated=false;
        List<QualifiedNumbers> msisdnDetailsList=null;
         List<Service_Qualification__c> squpdateList = new List<Service_Qualification__c>();
          List<String> msisdnLst =new List<String>();
          if(msisdnList!=null ){
                msisdnDetailsList = (List<QualifiedNumbers>)System.JSON.deserialize(msisdnList, List<QualifiedNumbers>.Class);
          }
         system.debug('msisdnDetailsList++' +msisdnDetailsList);
        for(QualifiedNumbers msisdn:msisdnDetailsList){
             system.debug('qualifiedMsisdn++' +msisdn.qualifiedMsisdn);
            msisdnLst.add(msisdn.qualifiedMsisdn);
}
        List<cscfga__Product_Basket__c> bsktAcc = ConstantMetadataUtility.getbasketdetails(basketId);//EDGE-147324
        List<Service_Qualification__c> sqList = ConstantMetadataUtility.getserviceQualification(bsktAcc[0].csbb__Account__c,basketId);//EDGE-147324, DIGI-867
        
        system.debug('sqList++' +sqList);
        if(!sqList.isEmpty()){
        	for(Service_Qualification__c sq:sqList){
                if(msisdnLst.contains(sq.Service_Number__c)){
            for(QualifiedNumbers msisdn:msisdnDetailsList){
                if(sq.Service_Number__c == msisdn.qualifiedMsisdn){
                    sq.Added_to_CA_form__c=msisdn.isSelected;
                }
            }
            squpdateList.add(sq);
        }
    }
        }
         System.debug('**squpdateList'+squpdateList);
		 if(!squpdateList.isEmpty()){
                System.debug('squpdateList');
                update squpdateList;
             	isUpdated=true;
            }
         return isUpdated;
    }
}
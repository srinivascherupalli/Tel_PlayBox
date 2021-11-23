/*------------------------------------------------
EDGE        -88791
Class       -MobilePortinController
Test Class  -MobilePortinControllerTest
Description -UI enhancement to support customer authorization and pre-port verification for mobile portin
Author      -Aishwarya,Kalashree
--------------------------------------------------*/

public with sharing class MobilePortinController {
    public final static String CAF_Query='CAFqueryMobile';
    public final static String SQ_Query='SQNumberDataMobile';
    public final static String TEMPLATE='CAFtemplateMobile';
    
    
    public class QualifiedNumbers{
        @AuraEnabled
        public Boolean isSelected ;
        @AuraEnabled
        public String qualifiedMsisdn ;
        @AuraEnabled
        public String isIncluded ;
        //DIGI-14124
        @AuraEnabled
        public String ppvStatus;
           
        public QualifiedNumbers(Boolean isSelected ,String qualifiedMsisdn, String ppvStatus){
            this.isSelected = isSelected;
            this.qualifiedMsisdn =qualifiedMsisdn;
            this.isIncluded =isSelected?'Yes':'No';
            this.ppvStatus = ppvStatus;//DIGI-14124
        }
    }
    /*-------------------------------------------------------- 
EDGE        -88791,144140
Description -Wrapper for showing Port in status
Author      -Kalashree Borgaonkar 
--------------------------------------------------------*/  
    public class PortinStatusWrapper{
        @AuraEnabled
        public String cafid;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String ppvExpiration;
        @AuraEnabled
        public String ppvApprover;
        @AuraEnabled
        public String ppvMobile;
        @AuraEnabled
        public String cafidLink;
        @AuraEnabled
        public String cafRecordId;
        
    }
    public class BasketDetailsWrapper{
        @AuraEnabled
        public String basketNumber;
        @AuraEnabled
        public String basketStatus;//
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String accountid;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String status;
        @AuraEnabled 
        public PortinStatusWrapper caStatus;
        public BasketDetailsWrapper( String basketNumber , String accountName,String accountid, String oppId){
            this.basketNumber =basketNumber;
            this.accountName = accountName;
            this.accountid = accountid;
            this.oppId = oppId;
            this.basketStatus = '';
        } 
    }
    
    
    /*-------------------------------------------------------- 
EDGE-88791
Method: getDetails
Description: Method to get details using baskeid
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static  BasketDetailsWrapper getAllDetails(String basketid){
        BasketDetailsWrapper detailWrapper  = null;
        System.debug('basketid: '+basketid);
        //Used ConstantMetadataUtility class
        List<cscfga__Product_Basket__c> basketDetail =ConstantMetadataUtility.getbasketdetails(basketid); 
        if(!basketDetail.isEmpty()){
            detailWrapper = new BasketDetailsWrapper(basketDetail[0].Name,basketDetail[0].csbb__Account__r.name,
                                                     basketDetail[0].csbb__Account__c,basketDetail[0].cscfga__Opportunity__c);  
            detailWrapper.caStatus = getPortinSatusDetails(basketDetail[0].cscfga__Opportunity__c);
            detailwrapper.basketStatus =basketDetail[0].csordtelcoa__Basket_Stage__c; //EDGE-198888
            System.debug('detailWrapper: '+detailWrapper);
        }   
        return detailWrapper;
    }
    
    public static PortinStatusWrapper getPortinSatusDetails(String oppid){
        String currentUrl=URL.getCurrentRequestUrl().toExternalForm();
        String url =   URL.getSalesforceBaseURL().toExternalForm();
        PortinStatusWrapper portinStatus = new PortinStatusWrapper();
        String custAuth;
        List<Customer_Authority_Form__c> cafList = null;
        cafList =   [SELECT id,Name,ppv_status__c,Status__c,MSISDN__c,Contact__r.name,CA_Expiry_Date__c
                     FROM Customer_Authority_Form__c  
                     WHERE Opportunity__c =:oppid AND is_active__c=true 
                     ORDER BY createdDate DESC LIMIT 1 ];                  
        System.debug('cafList: '+cafList);
        if(!cafList.isEmpty()){
            if(cafList[0].CA_Expiry_Date__c!=null){
                portinStatus.ppvExpiration=cafList[0].CA_Expiry_Date__c.format();
            }
            else{
                portinStatus.ppvExpiration = '-';
            }
            if(currentUrl.contains('partners')){
                
                portinStatus.cafidLink = url + '/partners/s/detail/' + cafList[0].id;
                
            }
            else{
                portinStatus.cafidLink = url + '/' + cafList[0].id;
            }
            portinStatus.cafRecordId = cafList[0].id;
            portinStatus.cafid = cafList[0].name;
            portinStatus.status=   cafList[0].ppv_status__c;
            portinStatus.ppvApprover=   cafList[0].contact__r.name;
            portinStatus.ppvMobile=   cafList[0].MSISDN__c;
        }
        else{
            portinStatus.ppvExpiration = '-';
            portinStatus.cafid='-';
            portinStatus.ppvApprover=   '-';
            portinStatus.ppvMobile=   '-';
            portinStatus.status=   '-';
        }  
        return portinStatus;
    }

  /*-------------------------------------------------------- 
EDGE-201557 /EDGE - 201557
Method: getContactsForSearch
Description: Method to return contacts in search input
Author:Nikhil
--------------------------------------------------------*/     

    @AuraEnabled
    public static List<Contact> getContactsForSearch(String accountId,String oppId,String searchText){
        List<Contact> contactsList = null;  
        contactsList = getAuthorisedContacts(accountId,oppId,searchText);
        return contactsList;
    }
    /*-------------------------------------------------------- 
EDGE-88791
Method: getAuthorisedContacts
Description: Method to populate contacts in search input
Author:Aishwarya
--------------------------------------------------------*/ 
    public static List<Contact> getAuthorisedContacts(String accountId,String oppId,String searchText){
        String searchKey = searchText + '%';
        System.debug('searchKey'+searchKey);
        
        List<Contact> conList = null;      
        List<String> roleList=  Label.ACR_Roles.split(',');
        
            if(searchKey == '%'){
            conList = [SELECT Id,name FROM Contact WHERE Authority__c IN :roleList AND accountid=:accountId];
            }
            else{
            conList = [SELECT Id,name FROM Contact WHERE Authority__c IN :roleList AND name LIKE :searchKey AND accountid=:accountId]; 
            }
        System.debug('conList@@@ '+conList);
        
        return conList;   
    }
    /*-------------------------------------------------------- 
EDGE-88791
Method: getPortInMsisdns
Description: Method to populate MSISDNs in search input
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static List<Service_Qualification__c> getPortInMsisdns(String accountId,String oppId,String searchText){
        List<Service_Qualification__c> sqList = null;
        //EDGE-130044 Starts here
        List<String> numberList=new List<String>();
        List<cscfga__Product_Basket__c> bsktAcc= [SELECT id,csordtelcoa__Basket_Stage__c,csbb__Account__c,cscfga__Opportunity__c 
                                                  FROM cscfga__Product_Basket__c where cscfga__Opportunity__c =:oppId ];
        
        System.debug(accountId + ' '+searchText);
        String searchKey = searchText + '%';
        if(searchKey == '%'){
            //Query change as a part of EDGE-130044:To retrieve list of SQ's which are  qualified,added in CA and not Reserved 
            sqList= [SELECT Service_Number__c FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Account__c = :accountId   ];
        }
        else{
            sqList= [SELECT Service_Number__c FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' 
                     AND Account__c = :accountId AND Service_Number__c LIKE :searchKey    ];
        }
        System.debug('sqList:'+sqList);
        return sqList;
    }
    /*-------------------------------------------------------------------------------------------------------
EDGE        -132716
Method      -initiateCAF
Description -UI to support capturing of numbers to generate Customer Authority form.
Author      -Kalashree Borgaonkar
----------------------------------------------------------------------------------------------------------*/  
    
    @AuraEnabled
    public static String initiateCAF(InputWrapper input){
        System.debug('input: '+input);
        String result='Failure';
        List<String> queryNameList = new  List<String>{CAF_Query,SQ_Query};
            try{
                List<APXTConga4__Conga_Merge_Query__c> queryList = [SELECT id,APXTConga4__Name__c 
                                                                    FROM APXTConga4__Conga_Merge_Query__c 
                                                                    WHERE APXTConga4__Name__c IN :queryNameList];
                System.debug('queryList'+queryList);
                List<APXTConga4__Conga_Template__c> templateList = [SELECT id FROM APXTConga4__Conga_Template__c 
                                                                    WHERE APXTConga4__Name__c=:TEMPLATE];
                String serviceNumbers = '';
                for(String serviceNum : input.lstServiceNumber){
                    serviceNumbers =  '\''+ serviceNum+ '\'\\|' +serviceNumbers; 
                }
                serviceNumbers = serviceNumbers.removeEnd('|').remove('\\').trim();
                String queryId ='';
                String sqQueryId = '';
                for(APXTConga4__Conga_Merge_Query__c congaQuery : queryList){
                    if(congaQuery.APXTConga4__Name__c==CAF_Query){
                        queryId = congaQuery.id;
                    }
                    if(congaQuery.APXTConga4__Name__c==SQ_Query){
                        sqQueryId = congaQuery.id;
                    }
                }
                //EDGE-137874. Kalashree Borgaonkar. Added outputfile param
                String outputFileName = 'CAF_Mobile_'+input.name+'_'+Date.Today().format().replace('/','_');
                String templateid= !templateList.isEmpty()?templateList[0].id:'';
                Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
                caf.Account__c = input.accountId;
                caf.MSISDN__c = input.portNumber;
                caf.Type__c='Mobile';
                caf.Is_active__c=true;
                caf.Opportunity__c = input.oppid;
                caf.contact__c = input.signatoryContactid;
                caf.PPV_Approver_Contact__c = input.Contactid;
                caf.PPV_status__c = 'Pending CA Approval';
                caf.PPV_Initiation_date__c = System.today();//DIGI-783
                caf.status__c = 'New';
                //TED-383 Start
                String eSignCAFTemplateid = null;
                List<echosign_dev1__Agreement_Template__c> eSignTemplateids = GetEchosignAgreementTemplate.getEchoSignAgreementTemplateIds();
                for(echosign_dev1__Agreement_Template__c echoSigntemplate:eSignTemplateids){
                    if(echoSigntemplate.name == Label.CAF_eSign_Template_name && !eSignTemplateids.isEmpty()){
                        eSignCAFTemplateid = echoSigntemplate.id;
                    }
                }
                if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                    caf.Conga_URL__c='&Id=cafid&QueryId=['+CAF_Query+']'+queryId+',['+SQ_Query+']'+sqQueryId+'?pv0='+caf.Account__c+'~pv1='+serviceNumbers+'&TemplateId='+
                    +templateid+'&AttachmentParentId=cafid&QMode=EchoSign&ESVisible=1&SC0=1&SC1=SalesforceFile&OFN='+outputFileName+'&DefaultPDF=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignCAFTemplateid;
                }
                else{
                caf.Conga_URL__c='&Id=cafid&QueryId=['+CAF_Query+']'+queryId+',['+SQ_Query+']'+sqQueryId+'?pv0='+caf.Account__c+'~pv1='+serviceNumbers+'&TemplateId='+
                    +templateid+'&AttachmentParentId=cafid&QMode=DocuSign&DocuSignVisible=1&DocuSignR1Id='+input.signatoryContactid+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&SC0=1&SC1=SalesforceFile&DocuSignEndpoint='+Label.DocusignEndpoint+'&OFN='+outputFileName+'&DefaultPDF=1';
                }
                //TED-383 End
                insert caf;
                System.debug('cafid: '+caf.id + ' '+caf.name);
                result = 'Success';
                
                
            }
        catch(Exception e){
            result = 'Failure';
            System.debug('Exception in initiateCAF: '+e.getStackTraceString()+' '+e.getMessage());
        }
        return result;
    } 
    
    @AuraEnabled
    public static void updateCongaURL(String  basketId){
        System.debug('basketId'+basketId);
        try{
            List<cscfga__Product_Basket__c> accOppo =ConstantMetadataUtility.getbasketdetails(basketId); 
            
            //List<cscfga__Product_Basket__c> accOppo= [SELECT cscfga__Opportunity__c FROM cscfga__Product_Basket__c where id =:basketid ];
            List<Customer_Authority_Form__c> activeCAF = [SELECT id,Conga_URL__c,CA_requested__c FROM Customer_Authority_Form__c WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c AND Is_active__c=TRUE AND Type__c =: 'Mobile' limit 1];  
            System.debug('activeCAF'+activeCAF);
            
            if(!activeCAF.isEmpty()){
                activeCAF[0].Conga_URL__c=activeCAF[0].Conga_URL__c.replace('cafid',activeCAF[0].id);
                activeCAF[0].CA_requested__c = true;
                update activeCAF[0];
            } 
            System.debug('activeCAF: '+activeCAF);
        }
        Catch(Exception e){
            System.debug('Exception in updateCongaURL: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }   
    //EDGE-145845    Kalashree Borgaonkar. Production incident
    public static void removeAddtoCAF(String accountid){
        List<Service_Qualification__c> updateAddedToCAF = [SELECT Service_Number__c  FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Added_to_CA_form__c=true AND Account__c = :accountId];
        for(Service_Qualification__c sq: updateAddedToCAF){
            sq.Added_to_CA_form__c = false;
        }
        if(!updateAddedToCAF.isEmpty()){
            update updateAddedToCAF;
        }
    }
    
    /*-------------------------------------------------------- 
EDGE        -88791,144140
Method      -saveCAF
Description -Method to save CAF
Author      -Aishwarya, 
Update      -Kalashree Borgaonkar
--------------------------------------------------------*/
    
    @AuraEnabled public static String saveCAF(String inputString,Boolean regenerateCA){
        InputWrapper input = (InputWrapper)System.JSON.deserialize(inputString, InputWrapper.Class);
        System.debug('input: saveCAF '+input);
        Boolean flag=false;
        String result=null;
        List<QualifiedNumbers> msisdnDetailsList=null;
        List<String> msisdnLst =new List<String>();
        Map<String, QualifiedNumbers> portinNumMap=new Map<String, QualifiedNumbers>();
        //Kalashree Borgaonkar. Production incident
        if(!regenerateCA){
            removeAddtoCAF(input.accountId);}
        if(input.qualifiedNumList!=null ){
            msisdnDetailsList = (List<QualifiedNumbers>)System.JSON.deserialize(input.qualifiedNumList, List<QualifiedNumbers>.Class);
        }
        system.debug('msisdnDetailsList++' +msisdnDetailsList);
        for(QualifiedNumbers msisdn:msisdnDetailsList){
            msisdnLst.add(msisdn.qualifiedMsisdn);
        }
        input.lstServiceNumber = msisdnLst;
        Contact con=[select id,Name,Birthdate,Email from Contact where id=:input.signatoryContactid];
        if(con !=null){
            if(con.Email == Null || con.Email == ''){
                result=Label.CAFContactEmail;
                flag=true;
            }
            else if(con.Birthdate == Null ){
                result=Label.CAFContactDOB;
                flag=true;
            } 
        }
        /*if(!msisdnLst.contains(input.portNumber)){
            result=Label.CAFAddedNum;
            flag=true;  
        }*/
        if(flag== false){
            Try{
                List<cscfga__Product_Basket__c> cscfgaProductBasketList =ConstantMetadataUtility.getbasketdetails(input.basketId); 
                List<Customer_Authority_Form__c> customerAuthorityFormList = [select Id ,Is_active__c,MSISDN__c,Account__c,Type__c from Customer_Authority_Form__c 
                                                                              where Account__c =:cscfgaProductBasketList[0].csbb__Account__c AND
                                                                              Opportunity__c =: cscfgaProductBasketList[0].cscfga__Opportunity__c AND
                                                                              Type__c =: 'Mobile' AND Is_active__c=true];
                
                if(!customerAuthorityFormList.isEmpty()){
                    customerAuthorityFormList[0].Is_active__c=false;
                }
                update customerAuthorityFormList;
                //EDGE-137874. Kalashree Borgaonkar. Added outputfile param
                input.oppid=cscfgaProductBasketList[0].cscfga__Opportunity__c;
                input.name = cscfgaProductBasketList[0].name;
                result=initiateCAF(input);
                
                if(result == 'Success'){
                    for(QualifiedNumbers msisdn:msisdnDetailsList){
                        system.debug('qualifiedMsisdn++' +msisdn.qualifiedMsisdn);
                        portinNumMap.put(msisdn.qualifiedMsisdn,msisdn);
                    }
                    
                    system.debug('portinNumMap++' +portinNumMap);
                    List<Service_Qualification__c> squpdateList = new List<Service_Qualification__c>();
                    List<Service_Qualification__c> sqList= [Select id,Basket_id__c,Account__c,Added_to_CA_form__c,Service_Number__c
                                                            from Service_Qualification__c where Account__c= :cscfgaProductBasketList[0].csbb__Account__c AND Service_Number__c IN:portinNumMap.keyset()];
                    system.debug('sqList++' +sqList);
                    if(!sqList.isEmpty() && !portinNumMap.keyset().isempty()){
                        for(Service_Qualification__c sq:sqList){
                            if(portinNumMap.keyset().contains(sq.Service_Number__c)){
                                sq.Added_to_CA_form__c=true;
                            }
                            squpdateList.add(sq);
                        } 
                    }
                    
                    System.debug('**squpdateList'+squpdateList);
                    if(!squpdateList.isEmpty()){
                        System.debug('squpdateList');
                        update squpdateList;  
                    }
                } 
            }
            Catch(Exception ex){
                result = 'Failure';
                System.debug('Exception Occured at line no '+ex.getLineNumber()+' due to '+ex.getMessage());   
            }
        }
        return result;
    }
    /*-------------------------------------------------------- 
EDGE-88791
Method: checkCAF
Description: Method to check if any active CAF exist
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static List<Customer_Authority_Form__c> checkCAF(String basketid){
        
        List<cscfga__Product_Basket__c> accOppo =ConstantMetadataUtility.getbasketdetails(basketid);        
        
        List<Customer_Authority_Form__c> numberofActiveCAF = [SELECT id,Is_active__c FROM Customer_Authority_Form__c WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c AND Is_active__c=TRUE AND Type__c =: 'Mobile' limit 1];
        System.debug('numberofActiveCAF'+numberofActiveCAF);
        
        if(!numberofActiveCAF.isEmpty())
        {
            return numberofActiveCAF;
        }
        
        
        return numberofActiveCAF;
    }
    /*-------------------------------------------------------- 
EDGE        -144140
Method      -getAllQualifiedMsisdn
Description -Method to get qualifed Sq using baskeid irrespective of Numbers being in Reservation pool
Author      -Kalashree
--------------------------------------------------------*/
    @AuraEnabled
    public static List<QualifiedNumbers>   getAllQualifiedMsisdn(String basketid){
        List<QualifiedNumbers> qualifiedNumberList = new List<QualifiedNumbers>();
        List<cscfga__Product_Basket__c> bsktAcc =ConstantMetadataUtility.getbasketdetails(basketid);
        List<Service_Qualification__c> qualifiedSQList ;
        
        if(!bsktAcc.isEmpty()){
            //DIGI-867 Extended condition for basket id
            qualifiedSQList = [SELECT id,Service_number__c,Added_to_CA_form__c,PPV_status__c
                               FROM Service_Qualification__C 
                               WHERE Account__c=:bsktAcc[0].csbb__Account__c  
                               AND Portability_Status__c='Y' AND basket_id__c=:basketid ORDER BY Added_to_CA_form__c desc];
        }
        System.debug('qualifiedSQList: '+qualifiedSQList);
        //List<Service_Qualification__c> qualifiedSQList = 
        if(!qualifiedSQList.isEmpty()){
            for(Service_Qualification__C sq:qualifiedSQList){
                QualifiedNumbers qualifiedNum = new QualifiedNumbers(sq.Added_to_CA_form__c,sq.Service_Number__c,sq.PPV_status__c);
                qualifiedNumberList.add(qualifiedNum);
            }  
        }
        return qualifiedNumberList;
    }
    /*-------------------------------------------------------- 
EDGE        -149395
Method      -reInitiatePPV
Description -Method to re-initiate ppv callout.
Author      -Kalashree
--------------------------------------------------------*/
    @AuraEnabled
    public static String  reInitiatePPV(String inputString){
        InputWrapper input = (InputWrapper)System.JSON.deserialize(inputString, InputWrapper.Class);
        System.debug('input: reInitiatePPV '+input);
        String result=Label.PpvSmsSuccessful;
        List<cscfga__Product_Basket__c> accOppo =ConstantMetadataUtility.getbasketdetails(input.basketid);
        if(!accOppo.isEmpty()){
           List<Customer_Authority_Form__c> parentCAF = [SELECT id FROM Customer_Authority_Form__c 
                                                      WHERE Opportunity__c =:accOppo[0].cscfga__Opportunity__c 
                                                      AND Is_active__c=TRUE AND Type__c =: 'Mobile' limit 1];
        //EDGE-154648. Kalashree Borgaonkar. Fix to check if SQ is added to CAF
        List<Service_Qualification__c> activeSqList = [SELECT Service_Number__c 
                                                       FROM Service_Qualification__c 
                                                       WHERE Account__c = :accOppo[0].csbb__Account__c
                                                       AND Added_to_CA_form__c = true ];
        System.debug('activeSqList: '+activeSqList);
        List<String> msisdnAddedToCAF = new List<String>();
        for(Service_Qualification__c sq :  activeSqList){
            msisdnAddedToCAF.add(sq.Service_Number__c);
        }
        try{
            if(!msisdnAddedToCAF.isEmpty()){
               // if(msisdnAddedToCAF.contains(input.msisdn)){ //EDGE-172365:Commenting check as mobilenumer is not part of CA added list.
                    if(!parentCAF.isEmpty()){
                        String caid = PpvCallout.createResendPPVrecord(parentCAF[0].id,input.msisdn,input.contactid);
                        PpvCallout.ppvCalloutFromTrigger(parentCAF[0].id);
                    }
                    else{
                        result='No Parent CAF';
                    }
                /*}
                else{
                    result=Label.CAFAddedNum; 
                }*/
            }
        }
        catch(Exception e){
            result='Failure';
            System.debug('Exception in initiateCAF: '+e.getStackTraceString()+' '+e.getMessage());
        } 
        }
        
        return result;
    }
    public class InputWrapper{
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String contactid;
        @AuraEnabled
        public String signatoryContactid;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String signatoryContactName;
        @AuraEnabled
        public String msisdn;
        @AuraEnabled
        public String oppid;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String basketid;
        @AuraEnabled
        public List<String> lstServiceNumber;
        @AuraEnabled
        public String portNumber;
        @AuraEnabled
        public String qualifiedNumList;
    }
    /*-------------------------------------------------------- 
EDGE        -149259
Method      -saveRengeneratedCAF
Description -Method to save regenerate CA form details
Author      -Aishwarya
Revised 	-Kalashree. DIGI-864. Added basketid param
--------------------------------------------------------*/
    @AuraEnabled
    public static String  saveRengeneratedCAF(String inputString,Boolean regenerateCA,String basketid){
        InputWrapper input = (InputWrapper)System.JSON.deserialize(inputString, InputWrapper.Class);
        String result=null;
        System.debug('input: reInitiatePPV '+input);
        List<QualifiedNumbers> qualifiedNumberList = new List<QualifiedNumbers>();
        
        List<String> qualifiedNumList=new List<String>();
        List<Service_Qualification__C> msisdnLst=ConstantMetadataUtility.getserviceQualification(input.accountId,basketid);
        if(!msisdnLst.isEmpty()){
            for(Service_Qualification__C sq:msisdnLst){
                if(sq.Portability_Status__c=='Y' && sq.Added_to_CA_form__c==true){ 
                    QualifiedNumbers qualifiedNum = new QualifiedNumbers(sq.Added_to_CA_form__c,sq.Service_Number__c,sq.PPV_status__c);
                    qualifiedNumberList.add(qualifiedNum);
                }
            }  
            input.qualifiedNumList = Json.serialize(qualifiedNumberList);
            String inputDetails = Json.serialize(input);
            result=saveCAF(inputDetails,regenerateCA);
        }
        return result;
    }
        /*-------------------------------------------------------- 
EDGE        -172365
Method      -fetchMobileNumber
Description -Method to save fetch mobile number for given contact id
Author      -Aishwarya
--------------------------------------------------------*/
     @AuraEnabled
    public static String fetchMobileNumber(String contactId){
        String mobileNumber=null;
        Contact con= [SELECT MobilePhone FROM Contact WHERE id =: contactId];
        if(con.MobilePhone !=null){
        mobileNumber='61'+ String.valueOf(Con.MobilePhone).substringAfter('0');
        }
       return mobileNumber;
    }




/*-------------------------------------------------------- 
DIGI        -779
Method      -sendSMS
Description -Method to call sendSMS API
Author      -Irfan Inamdar
--------------------------------------------------------*/
    @AuraEnabled
    public static String sendSMS(String conNumber, String basketId){

        List<Customer_Authority_Form__c> cafList = new List<Customer_Authority_Form__c>();
        List<cscfga__Product_Basket__c> bList = new List<cscfga__Product_Basket__c>();

        bList = [Select Id,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where id =: basketId WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('**bList'+bList);

        Id oppId  = bList[0].cscfga__Opportunity__c;

        cafList = [Select Id, Contact__c,Opportunity__c ,Is_active__c,PPV_status__c, PPV_Initiation_date__c from Customer_Authority_Form__c where (Opportunity__c =: oppId) AND (Is_active__c = True) WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('**cafList'+cafList);

        List<PRM_PPV_CreateVerificationRequest.FlowInputParameter> fipList = new List<PRM_PPV_CreateVerificationRequest.FlowInputParameter>();
        PRM_PPV_CreateVerificationRequest.FlowInputParameter  fip = new PRM_PPV_CreateVerificationRequest.FlowInputParameter();
        fip.custAuthRepDetails = conNumber;
        fip.verificationMethod = 'AuthRepSMS';

        fipList.add(fip);

        List<PRM_PPV_CreateVerificationRequest.FlowoutputParameter> fipoutputList = new List<PRM_PPV_CreateVerificationRequest.FlowoutputParameter>();
        fipoutputList = PRM_PPV_CreateVerificationRequest.sendVerificationRequest(fipList);


        System.debug('***fipoutputList****'+fipoutputList);
        PRM_PPV_CreateVerificationRequest.FlowoutputParameter  outparam = fipoutputList[0];
        System.debug('****outparam**'+outparam);

        if(outparam.isResultSuccess){
            cafList[0].PPV_status__c = 'Pending OTP Verification';
            update cafList;

            
            return 'Success';
        }
        else{
            
            return outparam.errorMessage;

        }
  
    }


/*-------------------------------------------------------- 
DIGI        -779
Method      -verifyOTP
Description -Method to call verifyOTP API
Author      -Irfan Inamdar
--------------------------------------------------------*/
@AuraEnabled
public static String verifyOTP(String conNumber, String basketId, String oppId, String otpInput, List<String> numPort){

        
        List<Customer_Authority_Form__c> cafList = new List<Customer_Authority_Form__c>();
        List<cscfga__Product_Basket__c> bList = new List<cscfga__Product_Basket__c>();
        List<Service_Qualification__c> sqnewList  = new List<Service_Qualification__c>();
        List<Service_Qualification__c> updatenewSQList  = new List<Service_Qualification__c>();
        Map<String,String> stagingRecMap = new Map<String,String>();

        bList = [Select Id,csbb__Account__c, cscfga__Opportunity__c, cscfga__Opportunity__r.OwnerId,csbb__Account__r.OwnerId from cscfga__Product_Basket__c where id =: basketId WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('**bListverifyOTP'+bList);

        oppId  = bList[0].cscfga__Opportunity__c;
        Id oppOwnerId = bList[0].cscfga__Opportunity__r.OwnerId;
        Id accId = bList[0].csbb__Account__r.OwnerId;
        System.debug('**oppId'+oppId);
        System.debug('**oppOwnerId'+oppOwnerId);
        System.debug('**accId'+accId);

        cafList = [Select Id, Contact__c, Is_active__c,Opportunity__c ,PPV_status__c from Customer_Authority_Form__c where (Opportunity__c =: oppId) AND (Is_active__c = True) WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('**cafListverifyOTP'+cafList);
        
        List<QualifiedNumbers> qList = MobilePortinController.getAllQualifiedMsisdn(basketId);

        for(QualifiedNumbers qNum : qList){
            if(qNum.isIncluded=='Yes'){
                numPort.add(qNum.qualifiedMsisdn);
            }
            
        }
        List<PRM_PPV_VerifyCode_Request.FlowInputParameter> fipOTPList = new List<PRM_PPV_VerifyCode_Request.FlowInputParameter>();
        PRM_PPV_VerifyCode_Request.FlowInputParameter  fipOTP = new PRM_PPV_VerifyCode_Request.FlowInputParameter();

            fipOTP.numbers_for_porting = numPort;
            fipOTP.custAuthRepDetails = conNumber;
            fipOTP.OTP_input = otpInput;
            fipOTP.opportunity_ID = oppId;
            fipOTP.verificationMethod = 'AuthRepSMS';
            fipOTP.basket_ID = basketId;
            fipOTPList.add(fipOTP);

    System.debug('***fipOTPList****verifyOTP'+fipOTPList);

        List<PRM_PPV_VerifyCode_Request.FlowoutputParameter> fipoutputOTPList = new List<PRM_PPV_VerifyCode_Request.FlowoutputParameter>();
            fipoutputOTPList = PRM_PPV_VerifyCode_Request.verifyOTPCode(fipOTPList);

    System.debug('***fipoutputOTPList****verifyOTP'+fipoutputOTPList);

        PRM_PPV_VerifyCode_Request.FlowoutputParameter  outparamOTP = fipoutputOTPList[0];

        if(outparamOTP.isResultSuccess){

            
        System.debug('***outparamOTP****verifyOTP'+outparamOTP);
        System.debug('***outparamOTP.stagingRecords****verifyOTP'+outparamOTP.stagingRecords);
        Database.insert(outparamOTP.stagingRecords);
        System.debug('****outparamOTP.ppvData'+outparamOTP.ppvData.mobileNumber);

            cafList[0].PPV_status__c = 'Pairing Port-In numbers';
            update cafList;


            

            
        PRMPrePortVerificationBatch mybatch = new PRMPrePortVerificationBatch(oppId,basketId,cafList[0].id);
        ID batchprocessid = Database.executeBatch(mybatch);
        System.debug('***mybatch'+mybatch);
        System.debug('***batchprocessid'+batchprocessid);

        
      
        
       
            return 'Success';
        }
        else{
			//DIGI-14124 observation fix---START
            sqnewList = [SELECT id,Service_number__c,Added_to_CA_form__c,PPV_status__c
                               FROM Service_Qualification__C Where Added_to_CA_form__c = true AND Portability_Status__c='Y' AND basket_id__c=:basketID];

            if(sqnewList.size()>0){
                for(Service_Qualification__C sqrecord:sqnewList){
                    stagingRecMap.put(sqrecord.Service_number__c, sqrecord.PPV_status__c);
                }
            }
            if(sqnewList.size()>0){

            for(Service_Qualification__C sqRecord : sqnewList){
                if(stagingRecMap.containsKey(sqrecord.Service_number__c)){
                    sqRecord.PPV_status__c = 'Pending';
                }
                //DIGI-14124 observation fix---END    
                    updatenewSQList.add(sqRecord);
                
                
            }
        }

            
            Database.update(updatenewSQList);
          

            cafList[0].PPV_status__c = 'OTP Invalid';
            update cafList;
            return outparamOTP.errorMessage;
        }

}

/*-------------------------------------------------------- 
DIGI        -14124
Method      -processPPVData
Description -future method to process PPV data
Author      -Irfan Inamdar
--------------------------------------------------------*/

public static void processPPVData(String basketID, String oppID, Id cafID, List<PRM_PPVCheck_Staging__c> stagingRecList,List<Service_Qualification__c> sqList){

    List<Customer_Authority_Form__c> cafList = new List<Customer_Authority_Form__c>();
    Customer_Authority_Form__c cafRec = new Customer_Authority_Form__c();
    cafRec.Id = cafID;
    cafList.add(cafRec);
    
    
    List<Service_Qualification__c> updateSQList  = new List<Service_Qualification__c>();
    Map<String,String> stagingRecMap = new Map<String,String>();
    
    
    

        System.debug('***stagingRecList***'+stagingRecList);
        
        Boolean allSuccess = true;
        if(stagingRecList.size()>0){
            for(PRM_PPVCheck_Staging__c ppvstage:stagingRecList){
                if(ppvstage.Secondary_number_PPV_Status__c!='Success'){
                    allSuccess = false;
                    break;
                }
            }
        }

        if(stagingRecList.size()>0){
            for(PRM_PPVCheck_Staging__c ppvstage:stagingRecList){
                stagingRecMap.put(ppvstage.Secondary_numbers__c, ppvstage.Secondary_number_PPV_Status__c);
            }
        }
        System.debug('***stagingRecMap***'+stagingRecMap);
        

        System.debug('***sqList***'+sqList);
        if(sqList.size()>0){

            for(Service_Qualification__C sqRecord : sqList){
                sqRecord.PPV_status__c = stagingRecMap.get(sqRecord.Service_Number__c);
                updateSQList.add(sqRecord);
            }
            System.debug('***updateSQList***'+updateSQList);
            Database.update(updateSQList);
            System.debug('***updateSQList***'+updateSQList);
        }
        
        
        if(allSuccess){
            //cafList[0].PPV_status__c = 'PPV Completed';
            cafList[0].Status__c = 'success';
        }else{
            //cafList[0].PPV_status__c = 'PPV Incomplete';
            cafList[0].Status__c = 'failed';
        }
        update cafList;
   
}
}
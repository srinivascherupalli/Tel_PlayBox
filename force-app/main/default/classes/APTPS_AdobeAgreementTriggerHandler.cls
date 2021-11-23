/**========================================================================================
* @Author :      Tejasvi K S, Charan
* @Description : This Class is defined to filter the Data and pass to Helper to for applying the base Logic
* @CreatedDate : 10/1/2021
* @Last Modified : Lokesh Thathuru - Date:10/1/2021 - Created the afterInsert and afterUpdate methods 
* @Last Modified : Lokesh Thathuru - Date :10/11/2021 - Created a new Method to update the Customer Authority Form object When the status is Singed
============================================================================================*/
public class APTPS_AdobeAgreementTriggerHandler {
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to handle the After Insert Logic
    * @CreatedDate : 10/1/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> newRecordsList
    * @Param : Map<Id,echosign_dev1__SIGN_Agreement__c> newRecordsMap
    *===========================================================================================*/
    public static void  afterInsert(List<echosign_dev1__SIGN_Agreement__c> newRecordsList,Map<Id,echosign_dev1__SIGN_Agreement__c> newRecordsMap){
        
        //Filtered data will be stored in the below collection to pass to help methods.        
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsCreated=new  List<echosign_dev1__SIGN_Agreement__c>();
        Set<Id> setOfContractJunctionIdsToSetStatusAsInitiated=new Set<Id>();
        //Iterating on New Data
        for(echosign_dev1__SIGN_Agreement__c adobeAgreementInstance:newRecordsList){
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED && adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null){
                listOfEchoSignDev1SingAgreementsWithStatusAsCreated.add(adobeAgreementInstance);
            }
             if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED && adobeAgreementInstance.Contractjunction__c!=null){
                setOfContractJunctionIdsToSetStatusAsInitiated.add(adobeAgreementInstance.Contractjunction__c);
            }
        }
        
        //Calling the helper method to apply the base Logic
        if(listOfEchoSignDev1SingAgreementsWithStatusAsCreated.size()>0){
            updateContractJunctionOnSIGNAgreementStatusAsInitiated(listOfEchoSignDev1SingAgreementsWithStatusAsCreated);
        }
        
        if(!setOfContractJunctionIdsToSetStatusAsInitiated.isEmpty()){
            updateRespectiveStatusToContractJunction(setOfContractJunctionIdsToSetStatusAsInitiated, APTPS_Constants.CONTRACTJUNCTION_STATUS_INITIATED);
        }
        
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to handle the After update Logic
    * @CreatedDate : 10/1/2021
    * @Param : Map<Id,echosign_dev1__SIGN_Agreement__c>  newRecordsMap
    * @Param : Map<Id,echosign_dev1__SIGN_Agreement__c>  oldRecordsMap
    *============================================================================================*/
    public static void   afterUpdate(Map<Id,echosign_dev1__SIGN_Agreement__c> newRecordsMap,Map<Id,echosign_dev1__SIGN_Agreement__c> oldRecordsMap){
        
        //Filtered data will be stored in the below collection to pass to help methods.        
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature=new  List<echosign_dev1__SIGN_Agreement__c>();
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature=new  List<echosign_dev1__SIGN_Agreement__c>();
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned=new  List<echosign_dev1__SIGN_Agreement__c>();
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3=new  List<echosign_dev1__SIGN_Agreement__c>();
        list<Id> adobeAgrId = new list<Id>();
        list<Id> apttusAgrId2 = new list<Id>();
        List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned3=new  List<echosign_dev1__SIGN_Agreement__c>(); // Added 10/11/2021
        //
        Set<Id> setOfContractJunctionIdsToSetStatusAsPendingApproval=new Set<Id>();
        Set<Id> setOfContractJunctionIdsToSetStatusAsCustomerReview=new Set<Id>();
        Set<Id> setOfContractJunctionIdsToSetStatusAsContractAccepted=new Set<Id>();
        Set<id> setOfCjToVoidStatus = new set<id>();
        //Iterating on New Data Change
        for(echosign_dev1__SIGN_Agreement__c adobeAgreementInstance:newRecordsMap.values()){
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_CANCELLED && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && (adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null || adobeAgreementInstance.Contractjunction__c!=null)){
                system.debug('when adobe agreement cancelled-----'+ adobeAgreementInstance.Id);
                adobeAgrId.add(adobeAgreementInstance.Id);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_EXPIRED && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null){
                apttusAgrId2.add(adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED*/){
                listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature.add(adobeAgreementInstance);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE  && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE*/){
                listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature.add(adobeAgreementInstance);
            }
            
            /*if((adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE  && adobeAgreementInstance?.echosign_dev1__Status__c==oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c)
               && (adobeAgreementInstance.Sum_of_Order_Number__c!=oldRecordsMap.get(adobeAgreementInstance.Id).Sum_of_Order_Number__c && adobeAgreementInstance.Sum_of_Order_Number__c > 3)){
                   listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3.add(adobeAgreementInstance);
               }*/
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED  && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Apttus_Echosign__Apttus_Agreement__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE*/){
                listOfEchoSignDev1SingAgreementsWithStatusAsSigned.add(adobeAgreementInstance);
            }
            
            //Defect fix - Feature Enhancement - Start
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Contractjunction__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_CREATED*/){
                setOfContractJunctionIdsToSetStatusAsPendingApproval.add(adobeAgreementInstance.Contractjunction__c);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE  && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Contractjunction__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE*/){
                setOfContractJunctionIdsToSetStatusAsCustomerReview.add(adobeAgreementInstance.Contractjunction__c);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED  && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Contractjunction__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE*/){
                setOfContractJunctionIdsToSetStatusAsContractAccepted.add(adobeAgreementInstance.Contractjunction__c);
            }
            
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_EXPIRED && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Contractjunction__c!=null){
                setOfCjToVoidStatus.add(adobeAgreementInstance.Contractjunction__c);
            }
            //Defect fix  - Feature Enhancement - End
            
            //added by :Lokesh Thathuru 10/11/2021 start
            if(adobeAgreementInstance?.echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_SIGNED  && adobeAgreementInstance?.echosign_dev1__Status__c!=oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c && adobeAgreementInstance.Customer_Authority_Form__c!=null /*&& oldRecordsMap.get(adobeAgreementInstance.Id).echosign_dev1__Status__c==APTPS_Constants.SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE*/){
                System.debug('--->001'+adobeAgreementInstance);
                listOfEchoSignDev1SingAgreementsWithStatusAsSigned3.add(adobeAgreementInstance);
                System.debug('--->002'+listOfEchoSignDev1SingAgreementsWithStatusAsSigned3);
            }
            //added by :Lokesh Thathuru 10/11/2021 end
        }
        
        //Calling the helper method to apply the base Logic
        if(adobeAgrId.size()>0){
            updateStatusOfCJToCancelledDeclined(adobeAgrId);
        }
        if(setOfCjToVoidStatus.size()>0){
            updateRespectiveStatusToContractJunction(setOfCjToVoidStatus,APTPS_Constants.CONTRACTJUNCTION_STATUS_VOID);
        }
        if(apttusAgrId2.size()>0){
            set<id> cjIds = new set<id>();
            for(Apttus__APTS_Agreement__c agg : [SELECT id,Related_Contract__c FROM Apttus__APTS_Agreement__c WHERE id IN: apttusAgrId2 AND Related_Contract__c!=null]){
                cjIds.add(agg.Related_Contract__c);
            }
            updateRespectiveStatusToContractJunction(cjIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_VOID);
            updateApttusAgrToCancel(apttusAgrId2);
        }
        
        if(listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature.size()>0){
            updateContractJunctionOnSIGNAgreementStatusAsPendingApproval(listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature);
        }
        
        if(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature.size()>0){
            updateContractJunctionOnSIGNAgreementStatusAsCustomerReview(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature);
        }
        
        if(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3.size()>0){
           // updateContractJunctionOnSIGNAgreementStatusAsPendingCountersign(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3);
        }
        
        if(listOfEchoSignDev1SingAgreementsWithStatusAsSigned.size()>0){
            updateContractJunctionOnSIGNAgreementStatusAsContractAccepted(listOfEchoSignDev1SingAgreementsWithStatusAsSigned);
            updateProductBasketOnSIGNAgreementStatusAsContractAccepted(listOfEchoSignDev1SingAgreementsWithStatusAsSigned);
        }
        
        //Added the New Logic to Update the Cutomer Authority Form Lokesh Thathuru - (10/11/2021) - Start
        if(!listOfEchoSignDev1SingAgreementsWithStatusAsSigned3.isEmpty()){
            System.debug('==>'+listOfEchoSignDev1SingAgreementsWithStatusAsSigned3);
            updateCustomerAuthorityFormCADateAndCAStatus(listOfEchoSignDev1SingAgreementsWithStatusAsSigned3);
        }
        //End (10/11/2021)    
        //Defect Fix - Feature Enhancement - Start
        if(!setOfContractJunctionIdsToSetStatusAsPendingApproval.isEmpty()){
            updateRespectiveStatusToContractJunction(setOfContractJunctionIdsToSetStatusAsPendingApproval, APTPS_Constants.CONTRACTJUNCTION_STATUS_PENDING_APPROVAL);
        }
        if(!setOfContractJunctionIdsToSetStatusAsCustomerReview.isEmpty()){
            updateRespectiveStatusToContractJunction(setOfContractJunctionIdsToSetStatusAsCustomerReview, APTPS_Constants.CONTRACTJUNCTION_STATUS_CUSTOMER_REVIEW);
        }
        if(!setOfContractJunctionIdsToSetStatusAsContractAccepted.isEmpty()){
            updateRespectiveStatusToContractJunction(setOfContractJunctionIdsToSetStatusAsContractAccepted, APTPS_Constants.CONTRACTJUNCTION_STATUS_CONTRACT_ACCEPTED);
            updateProductBasketBasedOnContractJunction(setOfContractJunctionIdsToSetStatusAsContractAccepted);
        }
        //Defect Fix - Feature Enhancement - End
    }
    
     /**
     * @Author   :   Charan
     * @Date     :   10/22/2021
     * @Desc     :   To update the apttus agreement to cancel when it's expired 
     * @Param    :   list<id> apttusAgrId
    * */
    public static void updateApttusAgrToCancel(list<id> apttusAgrId2){
        list<Apttus__APTS_Agreement__c> agreeToUpdate = new list<Apttus__APTS_Agreement__c>();
        map<id,Apttus__APTS_Agreement__c> mapofchildagr = new map<id,Apttus__APTS_Agreement__c>();
        system.debug('inside updateApttusAgrToCancel----');
        
        for(Apttus__APTS_Agreement__c childAgr:[select id,Apttus__Parent_Agreement__c,Apttus__Status__c,Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c IN:apttusAgrId2 order by CreatedDate desc]){
       if(!mapofchildagr.containskey(childAgr.Apttus__Parent_Agreement__c)){
       mapofchildagr.put(childAgr.Apttus__Parent_Agreement__c,childAgr);
       }
     }

        for(Apttus__APTS_Agreement__c agree : [select id,Apttus__Status_Category__c,Apttus__Status__c from Apttus__APTS_Agreement__c where id IN:mapofchildagr.values()]){
          
      agree.Apttus__Status__c = APTPS_Constants.CANCELLEDREQUEST;
        agree.Apttus__Status_Category__c=APTPS_Constants.CANCELLED_STATUS_CATEGORY;
        agreeToUpdate.add(agree);
    }
        try{
            if(!agreeToUpdate.isEmpty())
                update agreeToUpdate;
        }
        catch(Exception ex){
            String methodName = 'updateApttusAgrToCancel';
            String referenceNumber = '';
            if(agreeToUpdate != null)
                referenceNumber = (agreeToUpdate.size()>0 && agreeToUpdate[0].Id!=null) ? String.valueOf(agreeToUpdate[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
    }
    }     
    
    /**
     * @Author   :   Charan
     * @Date     :   10/05/2021
     * @Desc     :   Conract junction records updation to Cancelled/Declined 
     * @Param    :   list<id> apttusAgrId
    * */
    public static void updateStatusOfCJToCancelledDeclined(list<id> adobeAgrId){
        system.debug('inside updateStatusOfCJToCancelledDeclined method-----');
        ContractJunction__c cJInstance;
        list<ContractJunction__c> cJListToUpdate = new list<ContractJunction__c>();
        Map<Id,echosign_dev1__SIGN_AgreementEvent__c> mapOfagrs=new Map<id,echosign_dev1__SIGN_AgreementEvent__c>();
        try{
            List<echosign_dev1__SIGN_AgreementEvent__c> listOfSignAgrs =[select Id, echosign_dev1__Event_Type__c, echosign_dev1__SIGN_Agreement__c, echosign_dev1__SIGN_Agreement__r.Apttus_Echosign__Apttus_Agreement__c, CreatedDate from echosign_dev1__SIGN_AgreementEvent__c where echosign_dev1__SIGN_Agreement__c IN:adobeAgrId AND echosign_dev1__Event_Type__c!=null order by CreatedDate desc];
            System.debug(listOfSignAgrs); 
            for(echosign_dev1__SIGN_AgreementEvent__c agrevnt:listOfSignAgrs){
                if(!mapOfagrs.containskey(agrevnt.echosign_dev1__SIGN_Agreement__c)){
                    mapOfagrs.put(agrevnt.echosign_dev1__SIGN_Agreement__c,agrevnt);
                }
            }
            for(echosign_dev1__SIGN_Agreement__c parentAgr : [select id,Contractjunction__c,Apttus_Echosign__Apttus_Agreement__c,Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c from echosign_dev1__SIGN_Agreement__c where id IN:adobeAgrId]){
                if(parentAgr.Contractjunction__c!=null){
                if(mapOfagrs.get(parentAgr.id).echosign_dev1__Event_Type__c == 'RECALLED'){
                    cJInstance = new ContractJunction__c();
                    cJInstance.Id = parentAgr.Contractjunction__c;
                    cJInstance.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_CANCELLED;
                    cJListToUpdate.add(cJInstance);
                }
                if(mapOfagrs.get(parentAgr.id).echosign_dev1__Event_Type__c == 'REJECTED'){
                    cJInstance = new ContractJunction__c();
                    cJInstance.Id = parentAgr.Contractjunction__c;
                    cJInstance.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_SIGNATURE_DECLINED;
                    cJListToUpdate.add(cJInstance);
                }
              }
                if(parentAgr.Apttus_Echosign__Apttus_Agreement__c!=null){
                    if(mapOfagrs.get(parentAgr.id).echosign_dev1__Event_Type__c == 'RECALLED'){
                    cJInstance = new ContractJunction__c();
                    cJInstance.Id = parentAgr.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c;
                    cJInstance.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_CANCELLED;
                    cJListToUpdate.add(cJInstance);
                }
                if(mapOfagrs.get(parentAgr.id).echosign_dev1__Event_Type__c == 'REJECTED'){
                    cJInstance = new ContractJunction__c();
                    cJInstance.Id = parentAgr.Apttus_Echosign__Apttus_Agreement__r.Related_Contract__c;
                    cJInstance.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_SIGNATURE_DECLINED;
                    cJListToUpdate.add(cJInstance);
                }
                }
                
            }
            
            if(cJListToUpdate.size()>0)
                update cJListToUpdate;
        }catch(Exception ex){
            String methodName = 'updateStatusOfCJToCancelledDeclined';
            String referenceNumber = '';
            if(cJListToUpdate != null)
                referenceNumber = String.valueOf(cJListToUpdate[0].Id);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = ' Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
       
    
      /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsInitiated 
    * @CreatedDate : 10/1/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsCreated
    *===========================================================================================*/
    public static void updateContractJunctionOnSIGNAgreementStatusAsInitiated(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsCreated){

        Set<Id> setOfContractJunctionIds=new Set<Id>();
        try{
            setOfContractJunctionIds=getSetOfContractJunctionIds(listOfEchoSignDev1SingAgreementsWithStatusAsCreated);
            
            if(setOfContractJunctionIds.size()>0){
                updateRespectiveStatusToContractJunction(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_INITIATED);
            }
        }catch(Exception ex){
            String methodName = 'updateContractJunctionOnSIGNAgreementStatusAsInitiated';
            String referenceNumber = '';
            if(listOfEchoSignDev1SingAgreementsWithStatusAsCreated != null)
                referenceNumber = (listOfEchoSignDev1SingAgreementsWithStatusAsCreated.size()>0 && listOfEchoSignDev1SingAgreementsWithStatusAsCreated[0].Id!=null) ? String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsCreated[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsPendingApproval 
    * @CreatedDate : 10/4/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature
    *===========================================================================================*/
    public static void updateContractJunctionOnSIGNAgreementStatusAsPendingApproval(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature){
        
        Set<Id> setOfContractJunctionIds=new Set<Id>();
        try{
            setOfContractJunctionIds=getSetOfContractJunctionIds(listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature);
            
            if(setOfContractJunctionIds.size()>0){
                updateRespectiveStatusToContractJunction(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_PENDING_APPROVAL);
            }
        }catch(Exception ex){
            String methodName = 'updateContractJunctionOnSIGNAgreementStatusAsPendingApproval';
            String referenceNumber = '';
            if(listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature != null)
                referenceNumber = (listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature.size()>0 && listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature[0].Id!=null) ? String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsOutForSignature[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsCustomerReview 
    * @CreatedDate : 10/4/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature
    *===========================================================================================*/
    public static void updateContractJunctionOnSIGNAgreementStatusAsCustomerReview(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature){

        Set<Id> setOfContractJunctionIds=new Set<Id>();
        try{
            setOfContractJunctionIds=getSetOfContractJunctionIds(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature);
            
            if(setOfContractJunctionIds.size()>0){
                updateRespectiveStatusToContractJunction(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_CUSTOMER_REVIEW);
            }
        }catch(Exception ex){
            String methodName = 'updateContractJunctionOnSIGNAgreementStatusAsCustomerReview';
            String referenceNumber = '';
            if(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature != null)
                referenceNumber = (listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature.size()>0 && listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature[0].Id!=null) ? String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignature[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3 
    * @CreatedDate : 10/5/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3
    *===========================================================================================*/
    /*public static void updateContractJunctionOnSIGNAgreementStatusAsPendingCountersign(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3){

        Set<Id> setOfContractJunctionIds=new Set<Id>();
			try{
                setOfContractJunctionIds=getSetOfContractJunctionIds(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3);
                
                if(setOfContractJunctionIds.size()>0){
                    updateRespectiveStatusToContractJunction(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_PENDING_COUNTERSIGN);
                }
             }catch(Exception ex){
                        String methodName = 'updateContractJunctionOnSIGNAgreementStatusAsPendingCountersign';
                        String referenceNumber = '';
                        if(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3 != null)
                            referenceNumber = String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsWaitingforCounterSignatur3[0].Id);
                        String errorMessage =  ex.getMessage();
                        String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
                        AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
                        throw agEx; 
                    }
        }*/
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionOnSIGNAgreementStatusAsContractAccepted 
    * @CreatedDate : 10/4/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned
    *===========================================================================================*/
    public static void updateContractJunctionOnSIGNAgreementStatusAsContractAccepted(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned){
        
        Set<Id> setOfContractJunctionIds=new Set<Id>();
        try{
            setOfContractJunctionIds=getSetOfContractJunctionIds(listOfEchoSignDev1SingAgreementsWithStatusAsSigned);
            
            if(setOfContractJunctionIds.size()>0){
                updateRespectiveStatusToContractJunction(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_CONTRACT_ACCEPTED);
            }
        }catch(Exception ex){
            String methodName = 'updateContractJunctionOnSIGNAgreementStatusAsContractAccepted';
            String referenceNumber = '';
            if(listOfEchoSignDev1SingAgreementsWithStatusAsSigned != null)
                referenceNumber =  (listOfEchoSignDev1SingAgreementsWithStatusAsSigned.size()>0 && listOfEchoSignDev1SingAgreementsWithStatusAsSigned[0].Id!=null) ? String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsSigned[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
   
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateRespectiveStatusToContractJunction 
    * @CreatedDate : 10/4/2021
    * @Param : Set<Id> setOfContractJunctionIds
    * @Param : String statusValue
    *===========================================================================================*/
    @testVisible  // This is Added to access the method to the test class 
    private static void updateRespectiveStatusToContractJunction(Set<Id> setOfContractJunctionIds,String statusValue){
        
        List<ContractJunction__c> listOfcontractJunctions=new List<ContractJunction__c>();
        try{ 
            for(Id contractJunctionId:setOfContractJunctionIds){
                ContractJunction__c contractJunctionInstance=new ContractJunction__c();
                contractJunctionInstance.Id=contractJunctionId;
                contractJunctionInstance.Status__c=statusValue;
                listOfcontractJunctions.add(contractJunctionInstance);
            }
            
            if(listOfcontractJunctions.size()>0){
                update listOfcontractJunctions;
            }
        }catch(Exception ex){
            String methodName = 'updateRespectiveStatusToContractJunction';
            String referenceNumber = '';
            if(listOfcontractJunctions != null)
                referenceNumber = (listOfcontractJunctions.size()>0 && listOfcontractJunctions[0].Id!=null) ? String.valueOf(listOfcontractJunctions[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to QuerySelector for Apttus__APTS_Agreement__c
    * @CreatedDate : 10/5/2021
    * @Param : Set<Id> setOfApttusAgreemetIds
    *===========================================================================================*/
    private static List<Apttus__APTS_Agreement__c> getApttusAPTSAgreements(Set<Id> setOfApttusAgreemetIds){
        List<Apttus__APTS_Agreement__c> listOfApttusAgreements=new  List<Apttus__APTS_Agreement__c>();
        listOfApttusAgreements=[SELECT id,Related_Contract__c,Related_Basket__c FROM Apttus__APTS_Agreement__c WHERE id IN: setOfApttusAgreemetIds AND Related_Contract__c!=null];
        return listOfApttusAgreements;
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to QuerySelector for Apttus__APTS_Agreement__c
    * @CreatedDate : 10/5/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned
    *===========================================================================================*/
    private static Set<Id> getSetOfContractJunctionIds(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsToSetContractStatus){
        Set<Id> setOfApttusAgreemetIds=new Set<Id>();
        Set<Id> setOfContractJunctionIds=new Set<Id>();
        
        for(echosign_dev1__SIGN_Agreement__c signAgreementInstance:listOfEchoSignDev1SingAgreementsToSetContractStatus){
            setOfApttusAgreemetIds.add(signAgreementInstance.Apttus_Echosign__Apttus_Agreement__c);
        }
        
        List<Apttus__APTS_Agreement__c> listOfApttusAgreements=new List<Apttus__APTS_Agreement__c>();
        if(setOfApttusAgreemetIds.size()>0){
            listOfApttusAgreements=getApttusAPTSAgreements(setOfApttusAgreemetIds);
        }
        
        if(listOfApttusAgreements!=null && listOfApttusAgreements.size()>0){
            for(Apttus__APTS_Agreement__c apttusAgreementInstance:listOfApttusAgreements){
                setOfContractJunctionIds.add(apttusAgreementInstance.Related_Contract__c);
            }
        }
        
        return setOfContractJunctionIds;
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This Method helps to Update the Customer Authority Form - Customer Authorised date to System.today()  and CA status to Completed
    * @CreatedDate : 10/11/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned
    *===========================================================================================*/
    public static void updateCustomerAuthorityFormCADateAndCAStatus(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned3){
        
        Map<Id,Customer_Authority_Form__c> mapOfCustomer_Authority_Forms=new Map<Id,Customer_Authority_Form__c>();
        try{
            System.debug(listOfEchoSignDev1SingAgreementsWithStatusAsSigned3);
            for(echosign_dev1__SIGN_Agreement__c signAgreementInstance:listOfEchoSignDev1SingAgreementsWithStatusAsSigned3){
                if(!mapOfCustomer_Authority_Forms.containsKey(signAgreementInstance?.Customer_Authority_Form__c)){
                    Customer_Authority_Form__c customerAuthorutyFormInstance=new Customer_Authority_Form__c();
                    System.debug(customerAuthorutyFormInstance);
                    customerAuthorutyFormInstance.Id=signAgreementInstance.Customer_Authority_Form__c;
                    customerAuthorutyFormInstance.Customer_Authorised_date__c=System.today();
                    customerAuthorutyFormInstance.CA_status__c=APTPS_Constants.CUSTOMRE_AUTHORITY_FORM_STATUS_COMPLETED;
                    System.debug('01---->'+customerAuthorutyFormInstance);
                    mapOfCustomer_Authority_Forms.put(signAgreementInstance.Customer_Authority_Form__c,customerAuthorutyFormInstance);
                }
            }
            
            if(!mapOfCustomer_Authority_Forms.isEmpty() && mapOfCustomer_Authority_Forms.values().size()>0){
                update mapOfCustomer_Authority_Forms.values();
            }
        }catch(Exception ex){
            String methodName = 'updateCustomerAuthorityFormCADateAndCAStatus';
            String referenceNumber = '';
            if(mapOfCustomer_Authority_Forms.values() != null)
                referenceNumber = (mapOfCustomer_Authority_Forms.values().size()>0 && mapOfCustomer_Authority_Forms.values()[0].Id!=null) ? String.valueOf(mapOfCustomer_Authority_Forms.values()[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to QuerySelector for ContractJunction__c
    * @CreatedDate : 10/26/2021
    * @Param : Set<Id> setOfContractJunctionIds
    *===========================================================================================*/
    private static List<ContractJunction__c> getContractJunctions(Set<Id> setOfContractJunctionIds){
        List<ContractJunction__c> listOfContractJunctions=new  List<ContractJunction__c>();
        listOfContractJunctions=[SELECT id,Related_Basket__c FROM ContractJunction__c WHERE id IN: setOfContractJunctionIds AND Related_Basket__c!=null];
        return listOfContractJunctions;
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateProductBasketBasedOnContractJunction
    * @CreatedDate : 10/26/2021
    * @Param : Set<Id> setOfContractJunctionIds
    *===========================================================================================*/
    private static void updateProductBasketBasedOnContractJunction(Set<Id> setOfContractJunctionIds){
        Set<Id> setOfProductBasketids=new Set<Id>();
        for(ContractJunction__c contractJunctionInstance:getContractJunctions(setOfContractJunctionIds)){
            setOfProductBasketids.add(contractJunctionInstance.Related_Basket__c);
        }
        if(!setOfProductBasketids.isEmpty()){
            updateRespectiveStatusToProductBasket(setOfProductBasketids,APTPS_Constants.Product_Basket_Status_Contract_Accepted );
        }
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateProductBasketOnSIGNAgreementStatusAsContractAccepted 
    * @CreatedDate : 10/26/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned
    *===========================================================================================*/
    public static void updateProductBasketOnSIGNAgreementStatusAsContractAccepted(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned){
        
        Set<Id> setOfContractJunctionIds=new Set<Id>();
        try{
            setOfContractJunctionIds=getSetOfProductBasketIds(listOfEchoSignDev1SingAgreementsWithStatusAsSigned);
            
            if(setOfContractJunctionIds.size()>0){
                updateRespectiveStatusToProductBasket(setOfContractJunctionIds,APTPS_Constants.CONTRACTJUNCTION_STATUS_CONTRACT_ACCEPTED);
            }
        }catch(Exception ex){
            String methodName = 'updateProductBasketOnSIGNAgreementStatusAsContractAccepted';
            String referenceNumber = '';
            if(listOfEchoSignDev1SingAgreementsWithStatusAsSigned != null)
                referenceNumber =  (listOfEchoSignDev1SingAgreementsWithStatusAsSigned.size()>0 && listOfEchoSignDev1SingAgreementsWithStatusAsSigned[0].Id!=null) ? String.valueOf(listOfEchoSignDev1SingAgreementsWithStatusAsSigned[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to QuerySelector for Product BasketIds
    * @CreatedDate : 10/26/2021
    * @Param : List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsWithStatusAsSigned
    *===========================================================================================*/
    private static Set<Id> getSetOfProductBasketIds(List<echosign_dev1__SIGN_Agreement__c> listOfEchoSignDev1SingAgreementsToSetContractStatus){
        Set<Id> setOfApttusAgreemetIds=new Set<Id>();
        Set<Id> setOfProductBasketIds=new Set<Id>();
        
        for(echosign_dev1__SIGN_Agreement__c signAgreementInstance:listOfEchoSignDev1SingAgreementsToSetContractStatus){
            setOfApttusAgreemetIds.add(signAgreementInstance.Apttus_Echosign__Apttus_Agreement__c);
        }
        
        List<Apttus__APTS_Agreement__c> listOfApttusAgreements=new List<Apttus__APTS_Agreement__c>();
        if(setOfApttusAgreemetIds.size()>0){
            listOfApttusAgreements=getApttusAPTSAgreements(setOfApttusAgreemetIds);
        }
        
        if(listOfApttusAgreements!=null && listOfApttusAgreements.size()>0){
            for(Apttus__APTS_Agreement__c apttusAgreementInstance:listOfApttusAgreements){
                setOfProductBasketIds.add(apttusAgreementInstance.Related_Basket__c);
            }
        }
        
        return setOfProductBasketIds;
    }
    
      /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateRespectiveStatusToProductBasket 
    * @CreatedDate : 10/26/2021
    * @Param : Set<Id> setOfProductBasketIds
    * @Param : String statusValue
    *===========================================================================================*/
    @testVisible  // This is Added to access the method to the test class 
    private static void updateRespectiveStatusToProductBasket(Set<Id> setOfProductBasketIds,String statusValue){
        
        List<cscfga__Product_Basket__c> listOfProductBaskets=new List<cscfga__Product_Basket__c>();
        try{ 
            for(Id productbasketId:setOfProductBasketIds){
                cscfga__Product_Basket__c productbasketInstance=new cscfga__Product_Basket__c();
                productbasketInstance.Id=productbasketId;
                productbasketInstance.csordtelcoa__Basket_Stage__c=statusValue;
                listOfProductBaskets.add(productbasketInstance);
            }
            
            if(listOfProductBaskets.size()>0){
                update listOfProductBaskets;
            }
        }catch(Exception ex){
            String methodName = 'updateRespectiveStatusToProductBasket';
            String referenceNumber = '';
            if(listOfProductBaskets != null)
                referenceNumber = (listOfProductBaskets.size()>0 && listOfProductBaskets[0].Id!=null) ? String.valueOf(listOfProductBaskets[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = '  Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
}
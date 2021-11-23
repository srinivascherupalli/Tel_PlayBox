/*****************************************************************************************
* ModifiedBy     ModifiedDate     Edge          Description
* Manish Berad   18/02/2021       EDGE-201623   Auto creation of Deal opportunity for FA Revision on click of FA create new revision button on FA screen.
* Devanshu Bansal 04/06/2021      EDGE-219168   Effective End Date should be updated as per the Max. Contract term from Products
************************************************************************************************************************************************/
public without sharing class CreateDealOppAndOppContact {
    //CreateDealOppAndOppContact.ValidateInitiateContractAction();
    private static final string AgreementSourceInternalDigital='Internal Digital';
    private static final Set<String> setOfAgreementCategory= new Set<String>{'Digital Services', 'Business Services'};
    //EDGE-201623
    public static String updateFARevisionFields(Id faID){
        WrappNewFrameAggrement newFaWrapp=new WrappNewFrameAggrement();

        Boolean isPartnerUserFlag = FeatureManagement.checkPermission('Partner_User');

        try{
            csconta__Frame_Agreement__c newFA=[Select Id,csconta__replaced_frame_agreement__c,csconta__replaced_frame_agreement__r.csconta__Agreement_Name__c,
                                               csconta__replaced_frame_agreement__r.Opportunity__r.RecordType.Name,csconta__replaced_frame_agreement__r.Opportunity__r.Product_Type__c,
                                               csconta__replaced_frame_agreement__r.Opportunity__r.Contract_Type__c,
                                               csconta__replaced_frame_agreement__r.Opportunity__r.Pricing_Method__c,csconta__replaced_frame_agreement__r.csconta__effective_end_date__c,
                                               csconta__replaced_frame_agreement__r.Opportunity__c,csconta__Account__c,Opportunity__c
                                               From csconta__Frame_Agreement__c Where Id=:faID limit 1];
            if(newFA!=null && newFA.csconta__replaced_frame_agreement__c!=null 
               && newFA.csconta__replaced_frame_agreement__r.Opportunity__c!=null){

                   

                   String LongDate1 = ' ';
                   Datetime cDT1 = System.now();
                   LongDate1 = cDT1.format('yyyy-MM-dd_HH:mm:ss');
                   
                   Opportunity newDealOpp = new Opportunity();
                   newDealOpp.AccountId=newFA.csconta__Account__c;
                   newDealOpp.Name=newFA.csconta__replaced_frame_agreement__r.csconta__Agreement_Name__c + '_'+ LongDate1;
                   newDealOpp.RecordTypeID=newFA.csconta__replaced_frame_agreement__r.Opportunity__r.RecordTypeId;
                   newDealOpp.StageName='Define';
                   newDealOpp.Start_Date__c= Date.today();
                   newDealOpp.CloseDate=Date.today().addMonths(1);
                   newDealOpp.Contract_Type__c=newFA.csconta__replaced_frame_agreement__r.Opportunity__r.Contract_Type__c;//Defect fix DIGI-33233
                   newDealOpp.Product_Type__c=newFA.csconta__replaced_frame_agreement__r.Opportunity__r.Product_Type__c;
                   newDealOpp.Pricing_Method__c=newFA.csconta__replaced_frame_agreement__r.Opportunity__r.Pricing_Method__c;
                   DateTime dT = System.now();
                   Date todaysDate = date.newinstance(dT.year(), dT.month(), dT.day());
                   DateTime effectiveEndDate=newFA.csconta__replaced_frame_agreement__r.csconta__effective_end_date__c;
                   Date endDate = date.newinstance(effectiveEndDate.year(), effectiveEndDate.month(), effectiveEndDate.day());

                   //Integer monthDiff = endDate.monthsBetween(todaysDate);
                   Integer monthDiff = todaysDate.monthsBetween(endDate);//EDGE-206817

                   if(endDate.day() > todaysDate.day()){
                       monthDiff++;
                   }
                   newDealOpp.Contract_Term__c=monthDiff;   

                   if(isPartnerUserFlag==true){
                       newDealOpp.Partner_Opportunity_Verification__c='Approved';
                   }   

                   insert newDealOpp;   
                   
                   List<OpportunityContactRole> primaryOpptyContactRole =[select id,ContactId,IsPrimary,Contact.Email,Contact.FirstName,
                                                                          Contact.LastName,OpportunityId,Role 
                                                                          From OpportunityContactRole 
                                                                          Where OpportunityId =:newFA.csconta__replaced_frame_agreement__r.Opportunity__c
                                                                          AND IsPrimary=true];
                   if(!primaryOpptyContactRole.isEmpty()){
                       OpportunityContactRole newOCR=new OpportunityContactRole();
                       newOCR.ContactId=primaryOpptyContactRole[0].ContactId;
                       newOCR.OpportunityId=newDealOpp.ID;
                       newOCR.isPrimary=primaryOpptyContactRole[0].isPrimary;
                       newOCR.Role=primaryOpptyContactRole[0].Role;
                       insert newOCR;
                   }   
                   
                   //update New OpportunityId on New FA
                   String LongDate = ' ';
                   Datetime cDT = System.now();
                   LongDate = cDT.format('yyyy-MM-dd_HH:mm:ss');
                   

                 

                   newFA.Opportunity__c=newDealOpp.Id;
                   newFA.Final_Delegation_Outcome__c=null;
                   newFA.Delegated_Pricing_Request__c = null;
                   newFA.Deal_Approver__c=null;
                   newFA.Description__c=null;
                   newFA.Contract_Acceptance_Date__c=null;
                   newFA.csconta__effective_start_date__c=null;
                   //EDGE-219168
                   newFA.csconta__effective_end_date__c = newFA.csconta__replaced_frame_agreement__r.csconta__effective_end_date__c;
                   newFA.csconta__Agreement_Name__c = newFA.csconta__replaced_frame_agreement__r.csconta__Agreement_Name__c + '_Var_'+LongDate;
                   newFA.Mark_as_Variation__c = true;
                   update newFA;
                   
                   newFaWrapp.acountId=newFA.csconta__Account__c;
                   newFaWrapp.newOpportunityId=newDealOpp.Id;
                   newFaWrapp.newFrameAggrementId=newFA.Id;
               }    
        }catch(Exception e){
            newFaWrapp.errorMessage=e.getMessage();
        }
        return JSON.serialize(newFaWrapp);
    }
    
    public class WrappNewFrameAggrement{
        public string acountId;
        public string newOpportunityId;
        public string newFrameAggrementId;
        public string errorMessage;
        public WrappNewFrameAggrement(){
            acountId='';
            newOpportunityId='';
            newFrameAggrementId='';
            errorMessage='';
        }
    }
    
     /*----------------------------------------------------------------------------------------------------
    EDGE        - DIGI-9984
    Method      - ValidateInitiateContractAction
    Description - As a Sales or Partner user, I would like the system to warn me 
    if one of the companies cannot be added to the related BSA so that I adhere to the business rules
    Author      - Manish Berad
    --------------------------------------------------------------------------------------------------------*/
    public static string ValidateInitiateContractAction(String FrameId){
        Set<String> relatedAccId=new Set<String>();
        Set<String> allAccId=new Set<String>();
        Set<String> setofRelatedCompanyName=new Set<String>();
        Map<string,string> returnMap = new Map<string,string>{'message'=>'success','warning'=>'success'};
            string msg = Label.initiate_contract_warning_messages;
        Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
        if(Ted_115){
            Map<String, Object> deserializedeWarningMsg= (Map<String, Object>)json.deserializeUntyped(msg);
            csconta__Frame_Agreement__c FArecord=[SELECT Id,csconta__Account__c,csconta__Account__r.Name,csconta__Status__c, Opportunity__c,
                                                  Delegated_Pricing_Request__c,Opportunity__r.Contract_Type__c
                                                  FROM csconta__Frame_Agreement__c 
                                                  WHERE Id = :FrameId];
            allAccId.add(FArecord.csconta__Account__c);
            List<csconta__Account_Frame_Agreement_Association__c> accountFAassociation=[Select Id, csconta__Account__c,csconta__Account__r.Name,csconta__Frame_Agreement__c 
                                                                                        From csconta__Account_Frame_Agreement_Association__c
                                                                                        Where csconta__Frame_Agreement__c=:FArecord.Id];  
            if(accountFAassociation.size()>0){
                for(csconta__Account_Frame_Agreement_Association__c faAssociation:accountFAassociation){
                    relatedAccId.add(faAssociation.csconta__Account__c);
                    allAccId.add(faAssociation.csconta__Account__c);
                    setofRelatedCompanyName.add(faAssociation.csconta__Account__r.Name);
                }
            }
            
            //DIGI-16170...start
            set<string> accStatus=new set<string>{'Active','Acquired'};
                List<Account> InActiveRelatedAccList=[select ID,Name,Customer_Status__c 
                                                      From Account WHERE ID IN:relatedAccId
                                                      AND Customer_Status__c NOT IN:accStatus];
            if(InActiveRelatedAccList.size()>0 && FArecord.Opportunity__r.Contract_Type__c =='BSA' && accountFAassociation.size()>0){
                for(Account acc:InActiveRelatedAccList){
                    returnMap.put('warning','true');
                    returnMap.put('message',(String)deserializedeWarningMsg.get('CustomerStatusNotInActiveOrAcquired') +' '+acc.Name);
                    return JSON.serialize(returnMap);
                }
            } 
            //DIGI-16170...end
            If(FArecord.Opportunity__r.Contract_Type__c == 'DSA' && accountFAassociation.size()>0){
                returnMap.put('warning','true');
                returnMap.put('message',(String)deserializedeWarningMsg.get('OpptyContractTypeNotDSA'));
                return JSON.serialize(returnMap);
            }
            List<Apttus__APTS_Agreement__c> listOfBSADSAAgreement=[select ID,Apttus__Agreement_Category__c,Apttus__Account__c,Apttus__Account__r.Name 
                                                                   From Apttus__APTS_Agreement__c 
                                                                   WHERE Apttus__Status_Category__c = 'In Effect' 
                                                                   AND Apttus__Account__c IN:allAccId
                                                                   AND RecordType.Developername = 'SA'
                                                                   AND Apttus__Agreement_Category__c IN:setOfAgreementCategory
                                                                   AND Apttus__Source__c =:AgreementSourceInternalDigital];
            
            
            //DIGI-33172..Error msg is not coming on click of Initiate Contract when
            // related company is already associated to another primary account
            List<APTPS_Related_Companies__c> lstOfRelatedCmp=[SELECT id, APTPS_Agreement__c,APTPS_Account__r.Name, APTPS_Agreement__r.Apttus__Parent_Agreement__c, APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Account__c 
                                                              FROM APTPS_Related_Companies__c 
                                                              WHERE APTPS_Account__c IN:allAccId 
                                                              AND (APTPS_Agreement__r.Apttus__Status_Category__c = 'In Effect' OR APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Status_Category__c = 'In Effect') 
                                                              AND APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c in ('Business Services')
                                                              AND APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Source__c = 'Internal Digital'];
            
            Set<String> relatedAccNamewithDSABSA=new Set<String>();  
            if(listOfBSADSAAgreement.size()>0){
                for(Apttus__APTS_Agreement__c agg:listOfBSADSAAgreement){
                    if(agg.Apttus__Account__c!=FArecord.csconta__Account__c ){
                        relatedAccNamewithDSABSA.add(agg.Apttus__Account__r.Name);
                    }
                }
            }
            if(lstOfRelatedCmp.size()>0){
                for(APTPS_Related_Companies__c agg:lstOfRelatedCmp){
                    if(agg.APTPS_Account__r.Name!=null){
                        relatedAccNamewithDSABSA.add(agg.APTPS_Account__r.Name);
                    }
                }
            }
            String relatedCompanyStr;
            List<String> lstRCName=new List<String>();
            if(setofRelatedCompanyName!=null){
                for(String str:setofRelatedCompanyName){
                    if(relatedAccNamewithDSABSA.contains(str)){
                        lstRCName.add(str);
                    }
                }
                relatedCompanyStr=String.join(lstRCName,',');
            }
            String primaryAccAgreementId;
            if(listOfBSADSAAgreement.size()>0){
                for(Apttus__APTS_Agreement__c agreement:listOfBSADSAAgreement){
                    if(agreement.Apttus__Account__c==FArecord.csconta__Account__c ){
                        primaryAccAgreementId=agreement.Id;
                    }
                    
                    if(agreement.Apttus__Account__c==FArecord.csconta__Account__c 
                       && agreement.Apttus__Agreement_Category__c=='Digital Services' && FArecord.Opportunity__r.Contract_Type__c =='BSA' ){
                           
                           returnMap.put('warning','true');
                           returnMap.put('message',(String)deserializedeWarningMsg.get('primaryAccounthasActiveDSA') +' '+FArecord.csconta__Account__r.Name);
                           return JSON.serialize(returnMap);
                       }
                    if((relatedAccId.contains(agreement.Apttus__Account__c) && FArecord.Opportunity__r.Contract_Type__c =='BSA')){
                        returnMap.put('warning','true');
                        returnMap.put('message',(String)deserializedeWarningMsg.get('relatedAccounthasActiveDSA_BSA')+' '+relatedCompanyStr);
                        return JSON.serialize(returnMap);
                    }
                } 
            }
            if(lstOfRelatedCmp.size()>0){
                String relatedCompanyStrBSA='';
                List<String> lstRCACCName=new List<String>();
                for(APTPS_Related_Companies__c rc:lstOfRelatedCmp){
                    if(rc.APTPS_Agreement__r.Apttus__Parent_Agreement__c!=primaryAccAgreementId){
                        lstRCACCName.add(rc.APTPS_Account__r.Name);
                    }
                }
                relatedCompanyStrBSA=String.join(lstRCACCName,',');
                if(relatedCompanyStrBSA!=''){
                    returnMap.put('warning','true');
                    returnMap.put('message',(String)deserializedeWarningMsg.get('relatedAccounthasActiveDSA_BSA')+' '+relatedCompanyStrBSA);
                    return JSON.serialize(returnMap);
                }
            }
        }
        system.debug('returnMap'+returnMap); 
        return JSON.serialize(returnMap);
    }    
}
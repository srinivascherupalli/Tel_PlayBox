global with sharing class BeforeCreateFrameAgreementHandler {
    
    //EDGE-188476
    public static String validationOnBeforeCreateFA(String opportunityId) {
        WrappOnBeforeCreateFA wrappOCRole=new WrappOnBeforeCreateFA();
        try{
            Opportunity OppObj =[Select Id,Name,AccountID,StageName,Pricing_Method__c,Partner_Opportunity_Verification__c  
                                 FROM Opportunity 
                                 WHERE Id = :opportunityId  LIMIT 1];
            wrappOCRole.oppRecord=OppObj;
            //EDGE-199307
            List<OpportunityContactRole> lstPrimaryOCRoles =[select ID FROM OpportunityContactRole
                                                             WHERE OpportunityId=:OppObj.Id AND IsPrimary=true];
            if(!lstPrimaryOCRoles.isEmpty()){
                wrappOCRole.isOppContactRole=true;
            }
            //EDGE-203284
            List<csconta__Frame_Agreement__c> activeFA =[SELECT Id, Name, csconta__Agreement_Name__c,csconta__replaced_frame_agreement__c 
                                                         FROM csconta__Frame_Agreement__c
                                                         WHERE csconta__Status__c = 'Active' 

                                                         AND csconta__Account__c = :OppObj.AccountId];
                                                        
            if(OppObj.Pricing_Method__c=='Delegated Pricing' && !activeFA.isEmpty()){
                wrappOCRole.isFAactive=true;
                wrappOCRole.activeFAMessage=Label.Active_Frame_Agreement_Message +'  '+ activeFA[0].csconta__Agreement_Name__c;

            }
            
        }catch(Exception e){
            wrappOCRole.errorMessage=e.getMessage();
        }
        return JSON.serialize(wrappOCRole);
    }
    ////EDGE-199307
    public class WrappOnBeforeCreateFA{
        public Opportunity oppRecord;
        public boolean isOppContactRole;
        public boolean isFAactive;
        public string errorMessage;
        public string activeFAMessage;
        public WrappOnBeforeCreateFA(){
            oppRecord=new Opportunity();
            isOppContactRole=false;
            isFAactive=false;
            activeFAMessage='';
            errorMessage='';
        }
    }
}
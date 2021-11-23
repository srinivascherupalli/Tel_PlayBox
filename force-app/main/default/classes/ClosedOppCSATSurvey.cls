/****************************************************************************
@Name				: ClosedOppCSATSurvey
@Author				: SFO/Sri, Mounika
@CreateDate			: 31/10/2019
@Sprint 			: 19.15[P2OB-2999]
@Description		: This Class is for ClosedOppCSATSurvey - P2OB-2999, to get the 
test coverage using the class ClosedOppCSATSurveyTest
@Last Modified Date	: 10/03/2020 as part of P2OB-5238 Sprint 20.04
@Last Modified By	: padma pallavi
@Last Modified      : 07/01/2021 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*****************************************************************************/
public without sharing class ClosedOppCSATSurvey {
    /****************************************************************************
@Method Name			: getSurveyRelatedInfo
@Author					: SFO/Sri ,Mounika
@CreateDate				: 31/10/2019
@Sprint 				: 19.15[P2OB-2999]
@Description			: This Method is triggered/invoked from Process builder 
named 'Update Opportunity Owner'
******************************************************************************/ 
    @invocableMethod
    public static void getSurveyRelatedInfo(List<Opportunity> lstOpps){
        final String SURVEY_PARENT_OBJNAME = 'Opportunity';
        if(lstOpps.size()>0){
            List<Id> oppsIds=new List<Id>();
            //for - loop start
            for(Opportunity opp:lstOpps){
                oppsIds.add(opp.Id);
            }//for - loop end            
            createOppSurveyInvitations(oppsIds, Label.OppSurveyName, SURVEY_PARENT_OBJNAME, Label.OppSurveyType);  
            
        }
    }
    
    /****************************************************************************
@Method Name			: createOppSurveyInvitations
@Author					: SFO/Sri ,Mounika
@CreateDate				: 31/10/2019
@Sprint 				: 19.15[P2OB-2999]
@Description			: This Method is called from getSurveyRelatedInfo
******************************************************************************/ 
    @future
    public static void createOppSurveyInvitations(List<Id> oppsIds, String surveyName, String surveyParentObjName, String surveyType){
        final String SURVEY_INVITATION = 'Survey Invitation - ';
        final String CSAT_SURVEY = 'CSAT Survey';
        
        //Map<String, Set<String>> mapOfRoleToListOfContactDetails = new Map<String, Set<String>>();
        Map<String, list<OppContactWrapper>> mapOfRoleToListOfContactDetails = new Map<String, list<OppContactWrapper>>();
        Map<Id, Boolean> mapOfContactToACR = new Map<Id, Boolean>();
        Set<Id> setOfContacts = new Set<Id>();
        set<string> setToCheckDuplicateEmails = new set<string>();
        Map<String, String> mapToCheckDuplicateOppRole = new Map<String, String>();
        
        if(oppsIDs.size()>0){
            
            //Retrieve all the contactroles related to list of opps
            List<OpportunityContactRole> oppContactRoleList=[Select Id, Role, OpportunityId, ContactId, Contact.Email,Contact.FirstName,Contact.Surveys_Opt_Out__c from OpportunityContactRole where OpportunityId  IN :oppsIds];// Added Survey opt out field as part of P2OB-5238 Sprint 20.04
            if(oppContactRoleList.size()>0){
                
                //for - loop start
                for(OpportunityContactRole ocr	: oppContactRoleList){
                  
                        if(String.isNotBlank(ocr.Contact.Email) && ocr.Contact.Surveys_Opt_Out__c !=TRUE){ // Added Survey opt out field as part of P2OB-5238 Sprint 20.04
                            //preparing the map of roles and opportunity contact information
                            if(mapOfRoleToListOfContactDetails.get(ocr.Role) == null){
                                mapOfRoleToListOfContactDetails.put(ocr.Role, new list<OppContactWrapper>());
                            }
                            //mapOfRoleToListOfContactDetails.get(ocr.Role).add(ocr.OpportunityId + ':' + ocr.ContactId + ':' + ocr.Contact.Email + ':' + ocr.Contact.Name); 
                            mapOfRoleToListOfContactDetails.get(ocr.Role).add(new OppContactWrapper(ocr.OpportunityId,ocr.ContactId , ocr.Contact.Email, ocr.Contact.FirstName)); 
                        } 
                } // for-loop End
            }
        }        
        if(mapOfRoleToListOfContactDetails.size()>0){
            List<string> roleOrderList = new List<string>();
            Survey_Invitation_Setting__mdt sis; 
            //Retreive roles from the custom metadata 
            sis = [Select Allow_Guest_User__c, Network_Id__c, Survey_Record_Id__c from Survey_Invitation_Setting__mdt where Survey_Name__c = :surveyName 
                   AND Survey_Parent_Object__c = :surveyParentObjName AND Survey_Type__c = :surveyType LIMIT 1];
            // Survey Invitation Setting metadata null check
            if(sis!=null && String.isNotBlank(sis.Network_Id__c) && String.isNotBlank(sis.Survey_Record_Id__c)){
                //Retrieve Opportunity Contacts based on Role priority to create Survey Invitations
                for(OppConRoleOrderPriority__mdt role : [Select Priority__c,Role__c from OppConRoleOrderPriority__mdt order by priority__c asc])
                {
                    roleOrderList.add(role.Role__c);
                }
                List<SurveyInvitation> surveyInvitationList = new List<SurveyInvitation>();   
                if(!roleOrderList.isEmpty()) {
                    //for - loop start
                    for(string role : roleOrderList){
                        list<OppContactWrapper> setContactDetails = mapOfRoleToListOfContactDetails.get(role);
                        if(setContactDetails != null && !setContactDetails.isEmpty() && setContactDetails.size()>0){
                            //for loop start
                            for(OppContactWrapper con : setContactDetails){
                                //conditions to check when survey invitations to be created for contact roles of different opportunities
                                if(mapToCheckDuplicateOppRole.get(con.oppId) == null){
                                    mapToCheckDuplicateOppRole.put(con.oppId, role);
                                }
                                else if(mapToCheckDuplicateOppRole.get(con.oppId) <> role){
                                    break;
                                }                        
                                // Creating the Survey Inviations for the Opportunity Contacts 
                                SurveyInvitation si = new SurveyInvitation();
                                si.CommunityId = sis.Network_Id__c;
                                si.Name = surveyParentObjName + '-' + con.oppId + CSAT_SURVEY;
                                si.Opportunity__c = con.oppId;
                                si.OptionsAllowGuestUserResponse = sis.Allow_Guest_User__c;
                                si.ParticipantId = con.conId;
                                si.Contact_Email__c = con.conEmail;
                                si.Contact_Name__c = con.conName;
                                si.SurveyId = sis.Survey_Record_Id__c;
                                si.InviteExpiryDateTime = System.now().addDays(30);
                                // set to check duplicate emails on opportunity contact roles
                                if(!setToCheckDuplicateEmails.contains(si.Opportunity__c+si.Contact_Email__c)){                            
                                    surveyInvitationList.add(si);
                                    setToCheckDuplicateEmails.add(si.Opportunity__c+si.Contact_Email__c);
                                }
                            }// for-loop end
                            if(!surveyInvitationList.isEmpty() && oppsIDs.size() == 1){
                                break;                            
                            }                    
                        }
                    }//for - loop end
                }
                if(!surveyInvitationList.isEmpty() && surveyInvitationList.size()>0){
                    //To Create 'Survey Subject' records Need to Insert 'Survey Invitations' 
                    insert surveyInvitationList;
                    
                    List<SurveySubject> surveySubjectList = new List<SurveySubject>(); 
                    //for-loop Start
                    for(SurveyInvitation si : surveyInvitationList){
                        SurveySubject ss = new SurveySubject();
                        ss.Name = SURVEY_INVITATION + si.Id;
                        ss.ParentId = si.Id;
                        ss.SubjectId = si.Opportunity__c;  
                        surveySubjectList.add(ss);
                    }//for - loop End
                    
                    if(!surveySubjectList.isEmpty() && surveySubjectList.size()>0){           
                        insert surveySubjectList;    
                    }
                }
            }
        }
    }
    /****************************************************************************
@Name				: OppContactWrapper
@Author				: SFO/Sri, Mounika
@CreateDate			: 31/10/2019
@Sprint 			: 19.15[P2OB-2999]
@Description		: This Class is to provide OppId and Contact information
*****************************************************************************/
    public class OppContactWrapper{
        public Id oppId {get;set;}
        public Id conId {get;set;}
        public String conEmail {get;set;}
        public String conName {get;set;}
        
        public OppContactWrapper(Id oppId,Id conId,String conEmail,String conName){
            this.oppId = oppId;               
            this.conId = conId;
            this.conEmail = conEmail;
            this.conName = conName;
        }
    }
}
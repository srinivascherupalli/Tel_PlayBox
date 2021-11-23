/* Still under development 
@Author: SFO
User Story: EDGE-37935
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*/
Public without sharing class CampaignInfluenceTriggerHandler{
    public static boolean isRec=false;
    List<Opportunity> oppLst = new List<Opportunity>();
    Map<Id, Id> CampInfluMap = new Map<Id, Id>();
    Set<Id> camInfOppIdset=new Set<Id>();
    List<CampaignInfluence> campinfLst = new List<CampaignInfluence>();

    
    Public void UpdateInfluencepercentage(List<CampaignInfluence> campinfList){ 
        try{
            if(isRec!=true){
            List<CampaignInfluence> updateCampinfList = new List<CampaignInfluence>();   
            if(campinfList.size()>0){
                for(CampaignInfluence ci : campinfList){
                    camInfOppIdset.add(ci.opportunityid);
                }        
                if(camInfOppIdset.size()>0){
                    campinfLst =[Select id,Influence,Opportunityid,Campaignid,Modelid,ContactId from CampaignInfluence where Opportunityid IN:camInfOppIdset];
                }
                Map<Id,List<CampaignInfluence>> oppCamInfMap=new  Map<Id,List<CampaignInfluence>>();
                for(Id oppIDd : camInfOppIdset){
                    for(CampaignInfluence ci : campinfLst){
                        if((!String.isEmpty(ci.Opportunityid)&& ci.Opportunityid!=null) &&(ci.Opportunityid==oppIDd) && ci.Modelid==System.Label.SecondaryCampaignSourceModel){
                            List<CampaignInfluence> cminflist=oppCamInfMap.get(ci.Opportunityid);
                            if(null==cminflist){
                                cminflist=new List<CampaignInfluence>();
                                oppCamInfMap.put(ci.Opportunityid,cminflist);
                            }
                            cminflist.add(ci);
                        }                      
                    }
                }
                if(campinfLst.size()>0 && oppCamInfMap.size()>0){
                    set<CampaignInfluence> cmInf=null;//new set<CampaignInfluence>();
                    for(Id oppId : oppCamInfMap.keyset()){
                        cmInf=new set<CampaignInfluence>();
                        cmInf.addAll(oppCamInfMap.get(oppId));
                        for(CampaignInfluence ci : cmInf){      
                            ci.Influence=(100.00/cmInf.size());
                            updateCampinfList.add(ci);
                        }
                    }
                    if(updateCampinfList.size()>0){
                        Update updateCampinfList;
                    }
                }
            }
               isRec=true; 
            }
        }catch(Exception Ex){
            system.debug('Exception:--->CampaignInfluenceTriggerHandler Class,UpdateInfluencepercentage Method'+ Ex.getMessage());
        }
    }
    
    public void deleteInfluence(Map<Id,CampaignInfluence> OldCamInfluence){
        if(!OldCamInfluence.isEmpty() && OldCamInfluence.size()>0){            
            UpdateInfluencepercentage(OldCamInfluence.values());            
        }
    }
    
}
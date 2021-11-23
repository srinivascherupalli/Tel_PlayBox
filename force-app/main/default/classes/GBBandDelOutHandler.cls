/********************************************************************
EDGE        : 118371, 114439
Controller  : GBBandDelOutHandler
Test Class  : PlatformEventPOCtest
Description : GBB Scale and Delegation outcome button
Author      : Rishabh Dhamu
===============================================================================================================================
* ModifiedBy     ModifiedDate     Edge          Description
* Vishal Arbune  15/12/2020       EDGE-186881   Changes to Deal escalation flow for Partner user for Frame Agreement as per Final Delegation outcome
* Manuga Kale    12/18/2020       EDGE-188476   partner user should be able to create a Frame Agreement and make a Deal Score Call 
* Vishal Arbune  10/03/2021       EDGE-203940   <FA Delegation> As a Deal Approver I should be able to Re-score a Deal
* Shivaprasad Patil 15/06/2021    EDGE-219478/EDGE-219744 PRE Console UI support for multiple product families
* Ankush Rana    19/07/2021       DIGI-720     Logic change to stop deriving User.Delegation_role__c based on Profile.Name = ‘Pricing Admin’, instead populate DelegationRole__c = Customized Pricing for every ‘Pricing Admin’ user
*********************************************************************************************************************************************/
public without sharing class GBBandDelOutHandler {
    
    /*  Start of EDGE:118371
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch DPR offer values which are used to create the GBB Scale.
*/ 
    //DIGI-720 Wrapper class to get and set profileName,DelegationRole and FinalDelgation Outcome
    public class WrapDelegationRoleAndOutcome{
        String profileName; 
        String delegationRole;
        String finalDelegationOutcome;
    }
    //DIGI-720 Method to fetch UserRole    
    public static WrapDelegationRoleAndOutcome fetchDelegationRoleOfUser(String dprID) {
        
        Delegated_Pricing_Request__c dpr = [select id, 
                                            Deal_Status__c, CreatedById,
                                            Final_Delegation_Outcome__c
                                            from Delegated_Pricing_Request__c
                                            where id =: dprID];
        User user = [select id, Profile.Name, Delegation_Role__c 
                     FROM User Where id =: userInfo.getUserId()];      
        
        WrapDelegationRoleAndOutcome wrapDelegationOutcome = new WrapDelegationRoleAndOutcome();
        wrapDelegationOutcome.profileName = user.Profile.Name;
        wrapDelegationOutcome.delegationRole = user.Delegation_Role__c;
        wrapDelegationOutcome.finalDelegationOutcome = dpr.Final_Delegation_Outcome__c;
        
        return wrapDelegationOutcome;
    }
    //DIGI-720 Method to get Hierarchy Map
    public static Map<String,Integer> getDelegationHierarchyMap(){
        
        Map<String,Integer> delegationHierarchy = new Map<String,Integer>();
        delegationHierarchy.put('Partner',0);   
        delegationHierarchy.put('Account Executive',1);
        delegationHierarchy.put('Sales Specialist',2);
        delegationHierarchy.put('Sales Manager',3);
        delegationHierarchy.put('Sales General Manager',4);
        delegationHierarchy.put('Customized Pricing',5);
        delegationHierarchy.put('No Discount Offerable',6);//Not Offerable
        
        return delegationHierarchy;
    }
        
    @Auraenabled  
    public static DPR_Offer__c getDPROfferDetails(String dprId)
    {
        
        DPR_Offer__c dprOfferList = [select id, 
                                     ActualOfferPrice__c, 
                                     PoorMinimalValue__c, 
                                     MinimalMarginalValue__c, 
                                     MarginalGoodValue__c,
                                     GoodBetterValue__c,
                                     BetterBestValue__c,
                                     BestMaxValue__c,                                     
                                     LastModifiedDate from DPR_Offer__c where Delegated_Pricing_Request__c=:dprId];
        return dprOfferList;
    }
    
    // EDGE-219478 EDGE-219744 team Napier - Start - Shivaprasad
    @Auraenabled  
    public static DPR_Offer__c getDPROfferLevelDetails(String dprId, String offerName)
    {
        DPR_Offer__c dprOfferList = [select id, Product_Family__c,
                                     ActualOfferPrice__c, 
                                     PoorMinimalValue__c, 
                                     MinimalMarginalValue__c, 
                                     MarginalGoodValue__c,
                                     GoodBetterValue__c,
                                     BetterBestValue__c,
                                     BestMaxValue__c from DPR_Offer__c where Delegated_Pricing_Request__c =:dprId and Product_Family__c =:offerName];
        system.debug('dprOfferList:::'+dprOfferList);
        return dprOfferList;
    }
    // EDGE-219478 EDGE-219744 team Napier - END - Shivaprasad
    
    /*  Start of EDGE:114439
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch Delegation Outcome button colour and Final Delegation Outcome value 
to be displayed on the button.
*/
    @AuraEnabled
    public static List<String> getFinalDelegationOutcome(String dprID) {
        List<String> finalDelegationOutcomeList = new List<String>();
        Integer userDelegationRole;
        Integer finalDelegationOutcome;
        
        //DIGI-720 Changes start
        Map<String,Integer> delegationHierarchy = getDelegationHierarchyMap();
        
        WrapDelegationRoleAndOutcome wrapRoleAndOutcome = fetchDelegationRoleOfUser(dprID);
        String up = wrapRoleAndOutcome.profileName;
        String udr = wrapRoleAndOutcome.delegationRole;
        String fdo = wrapRoleAndOutcome.finalDelegationOutcome;
        //DIGI-720 Changes End
        if(fdo!=null){
            finalDelegationOutcomeList.add(fdo);
        }
        if(fdo==null){
            finalDelegationOutcomeList.add('null'); 
        }
        
        //FDO-partner button green EDGE-188476
        if('Partner' == fdo){
            String colour = 'success';
            finalDelegationOutcomeList.add(colour);
        }
        
        //FDO-NO button red
        if('No Discount Offerable' == fdo){
            String colour = 'destructive';
            finalDelegationOutcomeList.add(colour);
        }
        //DIGI-720 Condition Change
        //if UDR empty consider UDR as AE       
        if(udr == null){
            udr = 'Account Executive';
        }        
                
        //iterate through map to get hierarchy values
        for(String delOut : delegationHierarchy.keySet()){
            if(delOut == fdo){
                finalDelegationOutcome = delegationHierarchy.get(delOut);
            }
            if(delOut == udr){
                userDelegationRole = delegationHierarchy.get(delOut);
            }
        }
        
        //if FDO>UDR button will be red
        if(finalDelegationOutcome > userDelegationRole){
            String colour = 'destructive';
            finalDelegationOutcomeList.add(colour);
        }
        
        //if FDO<=UDR button will be green
        if(finalDelegationOutcome <= userDelegationRole){
            String colour = 'success';
            finalDelegationOutcomeList.add(colour);
        }
        
        //for debug
        finalDelegationOutcomeList.add(up);
        
        //EDGE-203940 : Removed below code as taken care from Process builder: FA Deal Approver Assignment
        //Id loggedInUserId = userInfo.getUserId();
        //Id dprCreatedById = dpr.CreatedById;
        /*csconta__frame_agreement__c  associatedFA = [select id, is_deal_escalated__c
from csconta__frame_agreement__c where Delegated_Pricing_Request__c =:dprID];*/
        
        //new change for auto Approval start
        //new check introduced as is_deal_escalated__c == 'false'
        /*String delegationColour = finalDelegationOutcomeList[1];
Boolean chk_is_deal_escalated = true;
if (associatedFA != null) {
chk_is_deal_escalated = associatedFA.is_deal_escalated__c;
}

if('success' == delegationColour && chk_is_deal_escalated == false && dpr.Deal_Status__c != 'Active'){
dpr.Deal_Status__c = 'Approved';
update dpr; 
}*/
        //new change for auto Approval end
        
        return finalDelegationOutcomeList;
        
    }
    
    /*  Start of EDGE:114439
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch Delegation Outcome display pop up table values list.
*/
    @AuraEnabled
    public static List<DPR_Delegation_Outcome__c> getDelegationOutcomeTable(String dprID) {
        List<DPR_Delegation_Outcome__c> modifiedDelOutList = new List<DPR_Delegation_Outcome__c>();
        List<DPR_Delegation_Outcome__c> delOutList = new List<DPR_Delegation_Outcome__c>();
        Integer userDelegationRole;
        Integer finalDelegationOutcome;
        //DIGI-720 Changes
        Map<String,Integer> delegationHierarchy = getDelegationHierarchyMap();
        
        delOutList = [select id, 
                      Category__c, 
                      Label_Name__c, 
                      Actual_Display__c, 
                      Delegation_Required__c,
                      AE_Expected_Display__c,
                      SS_Expected_Display__c,
                      SM_Expected_Display__c,
                      SGM_Expected_Display__c,
                      Pricing_Expected_Display__c,
                      P_Expected_Display__c
                      from DPR_Delegation_Outcome__c
                      where Delegated_Pricing_Request__c =: dprID ORDER BY Sort_Order__c ASC];
        //DIGI-720 Changes start
        WrapDelegationRoleAndOutcome wrapRoleAndOutcome = fetchDelegationRoleOfUser(dprID);        
        String up = wrapRoleAndOutcome.profileName;
        String udr = wrapRoleAndOutcome.delegationRole;
        String fdo = wrapRoleAndOutcome.finalDelegationOutcome;
        
        //if UDR empty consider UDR as AE       
        if(udr == null){
            udr = 'Account Executive';
        }        
        //DIGI-720 Changes end
                
        //iterate through map to get hierarchy values
        for(String delOut : delegationHierarchy.keySet()){
            if(delOut == fdo){
                finalDelegationOutcome = delegationHierarchy.get(delOut);
            }
            if(delOut == udr){
                userDelegationRole = delegationHierarchy.get(delOut);
            }
        }
        
        //if final delegation outcome is Not offerable return whole delOutList
        if(fdo=='No Discount Offerable'){
            for(DPR_Delegation_Outcome__c delOut: delOutList){
                
                if(userDelegationRole==1){//EDGE-188476
                    delOut.P_Expected_Display__c = delOut.AE_Expected_Display__c;
                }
                if(userDelegationRole==2){
                    delOut.P_Expected_Display__c = delOut.SS_Expected_Display__c;
                }
                if(userDelegationRole==3){
                    delOut.P_Expected_Display__c = delOut.SM_Expected_Display__c;
                }
                if(userDelegationRole==4){
                    delOut.P_Expected_Display__c = delOut.SGM_Expected_Display__c;
                }
                if(userDelegationRole==5){
                    delOut.P_Expected_Display__c = delOut.Pricing_Expected_Display__c;
                }
                
                modifiedDelOutList.add(delOut);
            }          
        }
        
        //if final delegation outcome is not equal to Not offerable return modifiedDelOutList
        if(fdo!='No Discount Offerable' && finalDelegationOutcome > userDelegationRole){
            
            //if final delegation outcome > user delegation role
            //if(finalDelegationOutcome > userDelegationRole){
            for(DPR_Delegation_Outcome__c delOut: delOutList){
                for(String delHierarchy : delegationHierarchy.keySet()){
                    String delReq = delOut.Delegation_Required__c;
                    Integer delReqValue;
                    if(delHierarchy == delReq){
                        delReqValue = delegationHierarchy.get(delHierarchy);
                    }
                    if(delReqValue > userDelegationRole){
                        
                        switch on userDelegationRole { //EDGE-188476
                            when 1 {
                                delOut.P_Expected_Display__c = delOut.AE_Expected_Display__c;
                            }
                        }
                        switch on userDelegationRole {
                            when 2 {
                                delOut.P_Expected_Display__c = delOut.SS_Expected_Display__c;
                            }
                            when 3 {
                                delOut.P_Expected_Display__c = delOut.SM_Expected_Display__c;
                            }
                            when 4 {
                                delOut.P_Expected_Display__c = delOut.SGM_Expected_Display__c;
                            }
                            when 5 {
                                delOut.P_Expected_Display__c = delOut.Pricing_Expected_Display__c;
                            }                                                           
                        }                      
                        modifiedDelOutList.add(delOut);                         
                    }
                }
            }
        }
        return modifiedDelOutList;
    }
    
    /*  
@Added by: Shivaprasad
@team : Napier
@edge : EDGE-219478 EDGE-219744
@Description: This method is used to fetch Delegation Outcome display pop up table values for DPR Offer list.
*/
    @AuraEnabled
    public static Map<String, List<DPR_Delegation_Outcome__c>> getDPRDelegationOutcomeTable(String dprID) {
        List<DPR_Delegation_Outcome__c> modifiedDelOutList = new List<DPR_Delegation_Outcome__c>();
        List<DPR_Delegation_Outcome__c> delOutList = new List<DPR_Delegation_Outcome__c>();
        Integer userDelegationRole;
        Integer finalDelegationOutcome;
        
        Map<String, List<DPR_Delegation_Outcome__c>> mapOfProductFamilyDO = new  Map<String, List<DPR_Delegation_Outcome__c>>();
        
        Map<String,Integer> delegationHierarchy = getDelegationHierarchyMap();
        
        List<DPR_Offer__c> dprList = [select id, 
                                      Product_Family__c,
                                      Final_Delegation_Outcome__c
                                      from DPR_Offer__c
                                      where Delegated_Pricing_Request__c =: dprID];
        
        system.debug('dprList::'+dprList);
        
        //DIGI-720 Changes start
        WrapDelegationRoleAndOutcome wrapRoleAndOutcome = fetchDelegationRoleOfUser(dprID);        
        String up = wrapRoleAndOutcome.profileName;
        String udr = wrapRoleAndOutcome.delegationRole;
        //String fdo = wrapRoleAndOutcome.finalDelegationOutcome;
        //String fdo = dpr.Final_Delegation_Outcome__c;
        //DIGI-720 Changes end
        
        for(DPR_Offer__c dpr: dprList){
            String fdo = dpr.Final_Delegation_Outcome__c;
            system.debug('fdo:::'+fdo);
            
            
            delOutList = [select id, 
                          Category__c, 
                          Label_Name__c, 
                          Actual_Display__c, 
                          Delegation_Required__c,
                          AE_Expected_Display__c,
                          SS_Expected_Display__c,
                          SM_Expected_Display__c,
                          SGM_Expected_Display__c,
                          Pricing_Expected_Display__c,
                          P_Expected_Display__c
                          from DPR_Delegation_Outcome__c
                          where DPR_Offer__c =: dpr.id ORDER BY Sort_Order__c ASC];
            
            system.debug('delOutList::'+delOutList);
            //DIGI-720 Changes in if condition
            //if UDR empty consider UDR as AE       
            if(udr == null){
                udr = 'Account Executive';
            }            
                        
            //iterate through map to get hierarchy values
            for(String delOut : delegationHierarchy.keySet()){
                if(delOut == fdo){
                    finalDelegationOutcome = delegationHierarchy.get(delOut);
                }
                if(delOut == udr){
                    userDelegationRole = delegationHierarchy.get(delOut);
                }
            }
            
            //if final delegation outcome is Not offerable return whole delOutList
            if(fdo=='No Discount Offerable'){
                for(DPR_Delegation_Outcome__c delOut: delOutList){
                    
                    if(userDelegationRole==1){//EDGE-188476
                        delOut.P_Expected_Display__c = delOut.AE_Expected_Display__c;
                    }
                    if(userDelegationRole==2){
                        delOut.P_Expected_Display__c = delOut.SS_Expected_Display__c;
                    }
                    if(userDelegationRole==3){
                        delOut.P_Expected_Display__c = delOut.SM_Expected_Display__c;
                    }
                    if(userDelegationRole==4){
                        delOut.P_Expected_Display__c = delOut.SGM_Expected_Display__c;
                    }
                    if(userDelegationRole==5){
                        delOut.P_Expected_Display__c = delOut.Pricing_Expected_Display__c;
                    }
                    
                    //modifiedDelOutList.add(delOut);
                    if(!mapOfProductFamilyDO.containsKey(dpr.Product_Family__c)){
                        mapOfProductFamilyDO.put(dpr.Product_Family__c, new List<DPR_Delegation_Outcome__c> {delOut});
                    }
                    else{
                        mapOfProductFamilyDO.get(dpr.Product_Family__c).add(delOut); 
                    }
                }          
            }
            
            //if final delegation outcome is not equal to Not offerable return modifiedDelOutList
            if(fdo!= null && fdo!='No Discount Offerable' && finalDelegationOutcome > userDelegationRole){
                
                //if final delegation outcome > user delegation role
                //if(finalDelegationOutcome > userDelegationRole){
                
                for(DPR_Delegation_Outcome__c delOut: delOutList){
                    
                    for(String delHierarchy : delegationHierarchy.keySet()){
                        String delReq = delOut.Delegation_Required__c;
                        Integer delReqValue;
                        if(delHierarchy == delReq){
                            delReqValue = delegationHierarchy.get(delHierarchy);
                        }
                        if(delReqValue > userDelegationRole){
                            
                            switch on userDelegationRole { //EDGE-188476
                                when 1 {
                                    delOut.P_Expected_Display__c = delOut.AE_Expected_Display__c;
                                }
                            }
                            switch on userDelegationRole {
                                when 2 {
                                    delOut.P_Expected_Display__c = delOut.SS_Expected_Display__c;
                                }
                                when 3 {
                                    delOut.P_Expected_Display__c = delOut.SM_Expected_Display__c;
                                }
                                when 4 {
                                    delOut.P_Expected_Display__c = delOut.SGM_Expected_Display__c;
                                }
                                when 5 {
                                    delOut.P_Expected_Display__c = delOut.Pricing_Expected_Display__c;
                                }                                                           
                            }     
                            system.debug('Pfamily:::'+dpr.Product_Family__c);
                            
                            //modifiedDelOutList.add(delOut);  
                            if(!mapOfProductFamilyDO.containsKey(dpr.Product_Family__c)){
                                mapOfProductFamilyDO.put(dpr.Product_Family__c, new List<DPR_Delegation_Outcome__c> {delOut});
                            }
                            else{
                                mapOfProductFamilyDO.get(dpr.Product_Family__c).add(delOut); 
                            }
                            
                        }
                    }
                }
            }
        }
        
        system.debug('mapOfProductFamilyDO::'+mapOfProductFamilyDO);
        return mapOfProductFamilyDO;
    }
    // EDGE-219478 EDGE-219744 team Napier - End - Shivaprasad
    
    /*  Start of EDGE:118631
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch a list of users to whome we can escalate the deal.
*/
    @AuraEnabled
    public static List<User> getDelegationUserList(String dprID) {
        List<User> DelegationUserList = new List<User>();
        List<String> UserDelegationRoleList = new List<String>();
        Integer userDelegationRole;
        Integer finalDelegationOutcome;
        
        //DIGI-720 Changes start
        Map<String,Integer> delegationHierarchy = getDelegationHierarchyMap();
        
        WrapDelegationRoleAndOutcome wrapRoleAndOutcome = fetchDelegationRoleOfUser(dprID);        
        String up = wrapRoleAndOutcome.profileName;
        String udr = wrapRoleAndOutcome.delegationRole;
        String fdo = wrapRoleAndOutcome.finalDelegationOutcome;
            
        //if UDR empty consider UDR as AE       
        if(udr == null){
            udr = 'Account Executive';
        }        
        //DIGI-720 Changes end
               
        //iterate through map to get hierarchy values
        for(String delOut : delegationHierarchy.keySet()){
            if(delOut == fdo){
                finalDelegationOutcome = delegationHierarchy.get(delOut);
            }
            if(delOut == udr){
                userDelegationRole = delegationHierarchy.get(delOut);
            }
        }
        
        //Added '0' as a part of EDGE-186881
        if(finalDelegationOutcome != null && finalDelegationOutcome != 0 && finalDelegationOutcome != 6){
            
            DelegationUserList = [Select Id, Name from User where Delegation_Role__c=:fdo]; 
        }
        return DelegationUserList;
    }
    
    /*  Start of EDGE:118631
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch user delegation role and final delegation outcome in integer form.
*/
    @AuraEnabled
    public static List<Integer> getDelegationUserListHirerchy(ID DPRId) {
        List<Integer> listOfIntegers = new List<Integer>();
        Integer userDelegationRole;
        Integer finalDelegationOutcome;
        
        //DIGI-720 Changes start
        Map<String,Integer> delegationHierarchy = getDelegationHierarchyMap();
        
        WrapDelegationRoleAndOutcome wrapRoleAndOutcome = fetchDelegationRoleOfUser(dprID);        
        String up = wrapRoleAndOutcome.profileName;
        String udr = wrapRoleAndOutcome.delegationRole;
        String fdo = wrapRoleAndOutcome.finalDelegationOutcome;
        
        //if UDR empty consider UDR as AE       
        if(udr == null){
            udr = 'Account Executive';
        }      
        //DIGI-720 Changes end
               
        //iterate through map to get hierarchy values
        for(String delOut : delegationHierarchy.keySet()){
            if(delOut == fdo){
                finalDelegationOutcome = delegationHierarchy.get(delOut);
            }
            if(delOut == udr){
                userDelegationRole = delegationHierarchy.get(delOut);
            }
        }
        listOfIntegers.add(userDelegationRole);
        listOfIntegers.add(finalDelegationOutcome);
        return listOfIntegers;
    }
    
    /* Start of EDGE:118371
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to fetch Plan details for Plan Gbb Scale.
*/ 
    @Auraenabled  
    public static DPR_Offer_Line_Item__c getDPRPlanDetails(String planId)
    {
        
        DPR_Offer_Line_Item__c dprPlan = [select id, 
                                          ActualOfferPrice__c, 
                                          PoorMinimalValue__c, 
                                          MinimalMarginalValue__c, 
                                          MarginalGoodValue__c,
                                          GoodBetterValue__c,
                                          BetterBestValue__c,
                                          BestMaxValue__c,
                                          LastModifiedDate from DPR_Offer_Line_Item__c where id =:planId];
        
        return dprPlan;
    }
    
    /* Start of EDGE:123727
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to create new discount level and discount association records for a given Account
*/ 
    @Auraenabled  
    public static void acceptContract(String dprId)
    {
        List<Delegated_Pricing_Request__c> dprList = [select id, Name, Opportunity__c, Deal_Status__c
                                                      from Delegated_Pricing_Request__c
                                                      where id =: dprId];
        Id oppId = dprList[0].Opportunity__c;
        
        List<Opportunity> oppList = [select id, Name, Contract_Terms__c, Account.Id from Opportunity where id =: oppId];
        
        Id accId = oppList[0].Account.Id;
        Integer contractTerms = Integer.ValueOf(oppList[0].Contract_Terms__c);
        
        List<DPR_Offer__c> dprOffer = [select id,Name,Data_Pack_Plan__c from DPR_Offer__c where Delegated_Pricing_Request__c =: dprId];
        
        List<DPR_Offer_Line_Item__c> dprOLIList = [select id, Name,
                                                   cspmb_Price_Item__c,
                                                   cspmb_Price_Item__r.Plan__c,
                                                   cspmb_Add_On_Price_Item__c,
                                                   DPR_Offer_Line_Item_Value__c,
                                                   DPR_Offer_Line_Item_Unit_Type__c,
                                                   DPR_Offer__r.Data_Pack_Plan_Name__c,
                                                   Parent_DPR_Offer_Line_Item_Id__r.Name
                                                   from DPR_Offer_Line_Item__c
                                                   where Delegated_Pricing_Request__c =: dprId
                                                   and DPR_Offer_Line_Item_Type__c = 'Discount'];
        
        Set<Id> cspmbPIIdSet = new Set<Id>();
        Set<String> planName = new Set<String>();
        Set<String> dprOLINameSet = new Set<String>();
        Set<String> dprOLIPlanNameSet = new Set<String>();
        String dprOLIDatPackPlanName = null;
        
        for(DPR_Offer_Line_Item__c dprOLI: dprOLIList){
            cspmbPIIdSet.add(dprOLI.cspmb_Price_Item__c);
            planName.add(dprOLI.cspmb_Price_Item__r.Plan__c);
            dprOLINameSet.add(dprOLI.Name);
            dprOLIDatPackPlanName = dprOLI.DPR_Offer__r.Data_Pack_Plan_Name__c;
            if(dprOLI.Parent_DPR_Offer_Line_Item_Id__r.Name != null){
                dprOLIPlanNameSet.add(dprOLI.Parent_DPR_Offer_Line_Item_Id__r.Name);
            }
        }
        
        List<cspmb__Discount_Association__c> discAssList = [select id, cspmb__Discount_Level__c
                                                            from cspmb__Discount_Association__c
                                                            where
                                                            (cspmb__Price_Item__c in: cspmbPIIdSet
                                                             and cspmb__Discount_Level__r.Name in: dprOLINameSet
                                                             and cspmb__Discount_Level__r.Account__c =: accId)
                                                            OR
                                                            (cspmb__Discount_Level__r.Plan__c in: planName
                                                             and cspmb__Discount_Level__r.Name in: dprOLINameSet
                                                             and cspmb__Discount_Level__r.Account__c =: accId)];
        
        if(discAssList.Size() > 0){
            Set<Id> disLevelId = new Set<Id>();
            
            for(cspmb__Discount_Association__c discAss: discAssList){
                disLevelId.add(discAss.cspmb__Discount_Level__c);
            }
            
            List<cspmb__Discount_Level__c> disLevelList = [select Id, Name, Effective_End_Date__c
                                                           from cspmb__Discount_Level__c
                                                           where Id in: disLevelId];
            
            delete discAssList;
            delete disLevelList;
        }
        
        Map<String,cspmb__Discount_Level__c> disLevelIdandObjectMap = new Map<String,cspmb__Discount_Level__c>();
        LIst<cspmb__Discount_Level__c> newDisLevelList = new List<cspmb__Discount_Level__c>();
        LIst<cspmb__Discount_Association__c> newDisAssocList = new List<cspmb__Discount_Association__c>();
        List<cspmb__Discount_Level__c> cspmbDisLevelList = [select Id, Name,
                                                            Business_ID__c,
                                                            cspmb__Charge_Type__c,
                                                            Data_Pack_Plan__c,
                                                            discountClass__c,
                                                            Discount_Application_Point__c,
                                                            cspmb__Discount_Increment__c,
                                                            cspmb__Discount_Level_Code__c,
                                                            cspmb__Discount_Type__c,
                                                            cspmb__Discount_Values__c,
                                                            cspmb__duration__c,
                                                            Is_Delegated__c,
                                                            is_Unlimited__c,
                                                            cspmb__Maximum_Discount_Value__c,
                                                            cspmb__Minimum_Discount_Value__c,
                                                            Discount_Identifier__c,
                                                            Description__c,
                                                            Plan__c from cspmb__Discount_Level__c
                                                            where 
                                                            (Name in: dprOLINameSet
                                                             and Account__c = null
                                                             and Is_Delegated__c = true
                                                             and Check_todays_date__c = true
                                                             and Plan__c in: dprOLIPlanNameSet
                                                             and Data_Pack_Plan__c = :dprOLIDatPackPlanName)
                                                            OR
                                                            (Name in: dprOLINameSet
                                                             and Account__c = null
                                                             and Is_Delegated__c = true
                                                             and Check_todays_date__c = true
                                                             and Plan__c in: dprOLIPlanNameSet
                                                             and Data_Pack_Plan__c = null)];
        
        for(cspmb__Discount_Level__c cspmbDisLevel: cspmbDisLevelList){
            String disAndPlanNameKey = cspmbDisLevel.Name+cspmbDisLevel.Plan__c;
            disLevelIdandObjectMap.put(disAndPlanNameKey, cspmbDisLevel);
        }
        
        for(DPR_Offer_Line_Item__c dprOLI: dprOLIList){
            String disAndPlanNameKey = dprOLI.Name+dprOLI.Parent_DPR_Offer_Line_Item_Id__r.Name;
            cspmb__Discount_Level__c cspmbDisLevel = disLevelIdandObjectMap.get(disAndPlanNameKey);
            cspmb__Discount_Level__c newDisLevel = new cspmb__Discount_Level__c();
            Double discountValue;
            
            if('Credit Months' == dprOLI.DPR_Offer_Line_Item_Unit_Type__c){
                newDisLevel.cspmb__duration__c = dprOLI.DPR_Offer_Line_Item_Value__c;
                discountValue = decimal.valueOf(cspmbDisLevel.cspmb__Discount_Values__c);
            }else{
                discountValue = dprOLI.DPR_Offer_Line_Item_Value__c;
                newDisLevel.cspmb__duration__c = cspmbDisLevel.cspmb__duration__c;
            }
            
            if('MMC Discount' == cspmbDisLevel.Name){
                decimal val = discountValue/1.1;
                discountValue = val.setScale(2);
            }
            
            newDisLevel.Name = cspmbDisLevel.Name;
            newDisLevel.Account__c = accId;
            newDisLevel.Business_ID__c = cspmbDisLevel.Business_ID__c;
            newDisLevel.cspmb__Charge_Type__c = cspmbDisLevel.cspmb__Charge_Type__c;
            newDisLevel.Data_Pack_Plan__c = dprOLI.DPR_Offer__r.Data_Pack_Plan_Name__c;
            newDisLevel.cspmb__Discount__c = discountValue;
            newDisLevel.Discount_Application_Point__c = cspmbDisLevel.Discount_Application_Point__c;
            newDisLevel.cspmb__Discount_Increment__c = cspmbDisLevel.cspmb__Discount_Increment__c;
            newDisLevel.cspmb__Discount_Level_Code__c = cspmbDisLevel.cspmb__Discount_Level_Code__c;
            newDisLevel.cspmb__Discount_Type__c = cspmbDisLevel.cspmb__Discount_Type__c;
            newDisLevel.cspmb__Discount_Values__c = cspmbDisLevel.cspmb__Discount_Values__c;
            newDisLevel.Effective_Start_Date__c = Date.today();
            newDisLevel.Effective_End_Date__c = Date.today().addMonths(contractTerms);
            newDisLevel.Is_Delegated__c = cspmbDisLevel.Is_Delegated__c;
            newDisLevel.is_Unlimited__c = cspmbDisLevel.is_Unlimited__c;
            newDisLevel.cspmb__Maximum_Discount_Value__c = cspmbDisLevel.cspmb__Maximum_Discount_Value__c;  
            newDisLevel.cspmb__Minimum_Discount_Value__c = cspmbDisLevel.cspmb__Minimum_Discount_Value__c;
            newDisLevel.Plan__c = cspmbDisLevel.Plan__c;
            newDisLevel.Discount_Identifier__c = cspmbDisLevel.Discount_Identifier__c;
            newDisLevel.Description__c = cspmbDisLevel.Description__c;    
            newDisLevel.discountClass__c = cspmbDisLevel.discountClass__c;
            newDisLevelList.add(newDisLevel);
            
            cspmb__Discount_Association__c  newDisAssocistion = new cspmb__Discount_Association__c();
            if('IDD Call Pack Discount' != dprOLI.Name){
                newDisAssocistion.cspmb__Price_Item__c = dprOLI.cspmb_Price_Item__c;
            }
            if('IDD Call Pack Discount' == dprOLI.Name){
                newDisAssocistion.cspmb__Add_On_Price_Item__c = dprOLI.cspmb_Add_On_Price_Item__c;  
            }
            
            newDisAssocList.add(newDisAssocistion);
            
        }
        
        insert newDisLevelList;
        
        for(Integer i=0; i<newDisLevelList.Size(); i++){
            newDisAssocList[i].cspmb__Discount_Level__c = newDisLevelList[i].Id;
        } 
        
        insert newDisAssocList;
        
        dprList[0].Deal_Status__c = 'Active';
        dprList[0].Account__c = accId;
        dprList[0].Synchronise_With_Opportunity__c = true;
        dprList[0].isPrimary__c = true;
        dprList[0].Contract_Acceptance_Date__c = DateTime.Now();
        update dprList;
        
        List<Delegated_Pricing_Request__c> allRelatedDPRList = [select id, Name, Opportunity__c, Deal_Status__c
                                                                from Delegated_Pricing_Request__c
                                                                where Opportunity__c =: oppId
                                                                and Id !=: dprId];
        
        List<Delegated_Pricing_Request__c> cancelledDPRList = new List<Delegated_Pricing_Request__c>();
        
        for(Delegated_Pricing_Request__c dpr: allRelatedDPRList){
            dpr.Deal_Status__c = 'Cancelled';
            dpr.Synchronise_With_Opportunity__c = false;
            dpr.isPrimary__c = false;    
            cancelledDPRList.add(dpr);
        }
        if(cancelledDPRList.size() > 0){
            update cancelledDPRList;
        }
        
        List<ContractJunction__c> contJunc = [select id, Status__c from ContractJunction__c
                                              where Related_Deal__c =: dprId];
        if(!contJunc.isEmpty()){
            contJunc[0].Status__c = 'In Effect';
            Update contJunc;
        }
        
    }
    
    /* Start of EDGE:117699
@Modified/updatedBy: 
@team : Napier
@Description: This method is used to clone a DPR
*/ 
    @Auraenabled  
    public static String dprClone(String dprId){
        Delegated_Pricing_Request__c currentDPR = [select Id, Opportunity__c, CreatedById, Parent_DPR__c
                                                   from Delegated_Pricing_Request__c
                                                   where Id =: dprId];
        List<DPR_Offer__c> currentDPROffer = [select Id, Name, Hardware_Option__c, Marketable_Offer__c,
                                              Data_Pack_Plan__c, Data_Pack_Plan_Name__c, Data_Pack_Plan_List_Price__c
                                              from DPR_Offer__c where Delegated_Pricing_Request__c =: dprId];
        LIst<DPR_Offer_Line_Item__c> currDPROliList = [select Id, Name, Unique_Key_to_Update__c,Marketable_Offer__c, Offer_Type_Name__c,
                                                       offer_Type__c, DPR_Offer__c,cspmb_Price_Item__c, DPR_Offer_Line_Item_Type__c,
                                                       DPR_Offer_Line_Item_Unit_Type__c, List_Price__c,
                                                       Total_Recurring_Charge__c, Quantity__c, Recontracting_Quantity__c,
                                                       Parent_DPR_Offer_Line_Item_Id__c, cspmb_Add_On_Price_Item__c,
                                                       DPR_Offer_Line_Item_Value__c,MMC_Discount_GST_Exc_Value__c
                                                       from DPR_Offer_Line_Item__c
                                                       where Delegated_Pricing_Request__c =: dprId];
        Map<Id,String> planIdAndNameMap = new Map<ID,String>();
        Map<String,Id> planChildAndIdMap = new Map<String,Id>();
        Map<String,String> planAndChildNameMap = new Map<String,String>();
        Map<String,Id> planNameAndNewIdMap = new Map<String,Id>();
        
        Delegated_Pricing_Request__c newDPR = new Delegated_Pricing_Request__c();
        newDPR.Deal_Status__c = 'Draft';
        newDPR.Opportunity__c = currentDPR.Opportunity__c;
        newDPR.CreatedById = currentDPR.CreatedById;
        newDPR.Parent_DPR__c = currentDPR.Parent_DPR__c;
        insert newDPR;
        
        String newDPRId = newDPR.Id;
        
        DPR_Offer__c newDPROffer = new DPR_Offer__c();
        if(currentDPROffer.size() > 0){
            newDPROffer.Name = currentDPROffer[0].Name;
            newDPROffer.Hardware_Option__c = currentDPROffer[0].Hardware_Option__c;
            newDPROffer.Marketable_Offer__c = currentDPROffer[0].Marketable_Offer__c;
            newDPROffer.Data_Pack_Plan__c = currentDPROffer[0].Data_Pack_Plan__c;
            newDPROffer.Data_Pack_Plan_Name__c = currentDPROffer[0].Data_Pack_Plan_Name__c;    
            newDPROffer.Data_Pack_Plan_List_Price__c = currentDPROffer[0].Data_Pack_Plan_List_Price__c;
            newDPROffer.Delegated_Pricing_Request__c = newDPR.Id;
            insert newDPROffer;
        }    
        
        
        
        List<DPR_Offer_Line_Item__c> insertNewPLanList = new List<DPR_Offer_Line_Item__c>();
        if(currDPROliList.size() > 0){
            for(DPR_Offer_Line_Item__c dprOLI: currDPROliList){
                if(dprOLI.DPR_Offer_Line_Item_Type__c == 'Plan'){
                    String oldKey=dprOLI.Unique_Key_to_Update__c;
                    String keytoUpdate = oldKey.replace(dprOLI.DPR_Offer__c, newDPROffer.Id);
                    planIdAndNameMap.put(dprOLI.Id,dprOLI.Name);
                    DPR_Offer_Line_Item__c newOLIPlan = new DPR_Offer_Line_Item__c();
                    newOLIPlan.Unique_Key_to_Update__c=keytoUpdate;
                    newOLIPlan.Name = dprOLI.Name;
                    newOLIPlan.Marketable_Offer__c = dprOLI.Marketable_Offer__c;
                    newOLIPlan.Offer_Type_Name__c = dprOLI.Offer_Type_Name__c;
                    newOLIPlan.Offer_Type__c = dprOLI.Offer_Type__c;
                    newOLIPlan.cspmb_Price_Item__c = dprOLI.cspmb_Price_Item__c;
                    newOLIPlan.DPR_Offer_Line_Item_Type__c = dprOLI.DPR_Offer_Line_Item_Type__c;
                    newOLIPlan.DPR_Offer_Line_Item_Unit_Type__c = dprOLI.DPR_Offer_Line_Item_Unit_Type__c;
                    newOLIPlan.List_Price__c = dprOLI.List_Price__c;
                    newOLIPlan.Total_Recurring_Charge__c = dprOLI.Total_Recurring_Charge__c;
                    newOLIPlan.Quantity__c = dprOLI.Quantity__c;
                    newOLIPlan.Recontracting_Quantity__c = dprOLI.Recontracting_Quantity__c;
                    newOLIPlan.DPR_Offer__c = newDPROffer.Id;
                    newOLIPlan.Delegated_Pricing_Request__c = newDPR.Id;
                    insertNewPLanList.add(newOLIPlan);
                }
                else{
                    planChildAndIdMap.put(dprOLI.Name,dprOLI.Parent_DPR_Offer_Line_Item_Id__c);
                }
            }
            insert insertNewPLanList;    
        }
        
        for(DPR_Offer_Line_Item__c dprOLIPlan: insertNewPLanList){
            planNameAndNewIdMap.put(dprOLIPlan.Name,dprOLIPlan.Id);
        }
        
        for(String childName: planChildAndIdMap.keySet()){
            ID planId = planChildAndIdMap.get(childName);
            String planName = planIdAndNameMap.get(planId);
            planAndChildNameMap.put(childName,planName);
        }
        
        List<DPR_Offer_Line_Item__c> insertNewChildList = new List<DPR_Offer_Line_Item__c>();
        if(currDPROliList.size() > 0){
            for(DPR_Offer_Line_Item__c dprOLI: currDPROliList){
                if(dprOLI.DPR_Offer_Line_Item_Type__c != 'Plan'){
                    String oldKey=dprOLI.Unique_Key_to_Update__c;
                    String keytoUpdate = oldKey.replace(dprOLI.DPR_Offer__c, newDPROffer.Id);
                    DPR_Offer_Line_Item__c newOLIChild = new DPR_Offer_Line_Item__c();
                    newOLIChild.Unique_Key_to_Update__c=keytoUpdate;
                    newOLIChild.Name = dprOLI.Name;
                    newOLIChild.Marketable_Offer__c = dprOLI.Marketable_Offer__c;
                    newOLIChild.Offer_Type_Name__c = dprOLI.Offer_Type_Name__c;
                    newOLIChild.Offer_Type__c = dprOLI.Offer_Type__c;
                    newOLIChild.cspmb_Price_Item__c = dprOLI.cspmb_Price_Item__c;
                    newOLIChild.DPR_Offer_Line_Item_Type__c = dprOLI.DPR_Offer_Line_Item_Type__c;
                    newOLIChild.DPR_Offer_Line_Item_Unit_Type__c = dprOLI.DPR_Offer_Line_Item_Unit_Type__c;
                    newOLIChild.List_Price__c = dprOLI.List_Price__c;
                    newOLIChild.Total_Recurring_Charge__c = dprOLI.Total_Recurring_Charge__c;
                    newOLIChild.Quantity__c = dprOLI.Quantity__c;
                    newOLIChild.Recontracting_Quantity__c = dprOLI.Recontracting_Quantity__c;
                    newOLIChild.cspmb_Add_On_Price_Item__c = dprOLI.cspmb_Add_On_Price_Item__c;
                    newOLIChild.DPR_Offer_Line_Item_Value__c = dprOLI.DPR_Offer_Line_Item_Value__c;
                    newOLIChild.DPR_Offer__c = newDPROffer.Id;
                    newOLIChild.Delegated_Pricing_Request__c = newDPR.Id;
                    newOLIChild.MMC_Discount_GST_Exc_Value__c = dprOLI.MMC_Discount_GST_Exc_Value__c;
                    
                    String parentPlanName = planAndChildNameMap.get(dprOLI.Name);
                    Id parentPlanId = planNameAndNewIdMap.get(parentPlanName);
                    
                    newOLIChild.Parent_DPR_Offer_Line_Item_Id__c = parentPlanId;
                    
                    insertNewChildList.add(newOLIChild);
                }
            }
            insert insertNewChildList;
        }
        DelegatedPricingController.performDPPriceCalculation(insertNewPLanList);
        return newDPRId;
        
    }
    
}
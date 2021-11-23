/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code and updating API version to 50.

@Last Modified      : 05/02/2021 21.02 by Vivian, Team Hawaii
            as part of P2OB-11658 adding after insert handler and updating parameters for after update

@Last Modified      : 15/10/2021 21.13 by Chhaveel, Team SFO
                      as part of DIGI-5740, removing vantageLeadOwnerAssignment() method call from before insert
                      01/11/2021 21.15 by pallavi B,Team SFO 
                      as part of DIGI-34437
                      09/11/2021 21.15 by pallavi b,team sfo as part of DIGI-11413 (Bug) 
*******************************************************************************/
trigger LeadTrigger on Lead (before insert,after insert,before Update,after Update) {
  /* Last Modified : 20:17
  Below logic used to stop to execute trigger logic when no Trigger option in Environment Configurations(custom setting)
   for specific user
   */
   if(EnvironmentalSettings.isTriggerDisabled('LeadTrigger')){
      return;
  } 
  
  LeadTriggerHelper lth = new LeadTriggerHelper();
  if((trigger.isBefore && Trigger.isInsert)){
      LeadTriggerHelper.mapCountryAndRegion(trigger.new);
      //Commented as part of DIGI-33489  S21.15 as this method needs to work in both insert/update
      //lth.customLeadRouting(trigger.new);//Added as part of DIGI-5740 S21.13
  }
  // P2OB-11658 adding after insert handler
  if((trigger.isAfter && Trigger.isInsert)){
    lth.proessBulkEmailDuringInsert(trigger.newMap);
  }
  
   if(trigger.isAfter && Trigger.isUpdate){

     lth.createCamInflOnLeadconvert(Trigger.new);
     lth.proessBulkEmailDuringUpdate(Trigger.new, Trigger.oldMap); // P2OB-11658 sending oldMap parameter
     lth.ErrorsOnLeadConversion(Trigger.newMap,trigger.oldMap);//Added as part of DIGI-34437 S21.15
    
   }
  // This is a part of EDGE-70949 EDGE-68196 To Update Account And Tier Value in Lead
  if((trigger.isBefore && Trigger.isInsert) ||(Trigger.isBefore && Trigger.isUpdate)){
      // Modified as part of P2OB-6755 Sprint 20.08 
      // Modified as part of DIGI-5740 to remove the call of vantageLeadOwnerAssignment() method
      //lth.vantageLeadOwnerAssignment(trigger.new,trigger.oldmap);
      lth.updateCustomerContactName(trigger.new,trigger.oldmap);
      lth.assignAccTeamMemToOwnerId(trigger.new,trigger.oldmap);//Added as part of DIGI-3187 S21.12
      lth.customLeadRouting(trigger.new,trigger.oldmap); //Added as part of DIGI-33489 S21.15
      lth.FirstBillTaskOnUpdate(trigger.new,trigger.oldmap);//Added as part of DIGI-34437 S21.15
  }
  

}
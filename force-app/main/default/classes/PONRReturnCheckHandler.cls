/*******************************************************************************************************************
Name : PONRReturnCheckHandler
Description : To Update the values to Heroku.
Sr.No.    Developer Name                     Date                  Story Description
1.         Arunkumar V                    25/01/2021               EDGE-199064  
2.         Martand Atrey                  08/02/2021               EDGE-201336 
3.         Vamsi Krishna Vaddipalli       17/feb/2021              EDGE-199772
3.        Arunkumar V             15/02/2021               EDGE-201334 - Stop performing PONR updates to Heroku during basket journey                     
4.        Pallavi D                       10.05.2021               EDGE-217693
********************************************************************************************************************/
public class PONRReturnCheckHandler {

    public Boolean updateOrderService(String orderNumber, List<String> orderItems){
        Boolean showError = false; //EDGE-199064
        set<String> serviceNumberSet = new set<String>(); //EDGE-199064
       cscfga__Product_Basket__c productBasketToCheck = PONRUtilityClass.productBasketToCheck;//EDGE-217693
        if(Test.isRunningTest()){
            productBasketToCheck = PONROrderItemHandlerTest.productBasketToCheck;
        }
            System.debug('productBasketToCheck '+productBasketToCheck.id);
        for(String str : orderItems){
            serviceNumberSet.add(str.split('\\|')[1].trim());
        }
        system.debug('serviceNumberSet '+serviceNumberSet);
        if((serviceNumberSet != null && !serviceNumberSet.isEmpty())|| orderNumber != null ){  //DIGI-31954


            //Modified from list to map to be used to push to Heroku EDGE-195759
            //get pcs for the rollback remediation
            Map<String,cscfga__Product_Configuration__c> mapAllPc = new Map<String,cscfga__Product_Configuration__c>();
            for(cscfga__Product_Configuration__c pc : [select id,Name, csordtelcoa__Replaced_Product_Configuration__c,
                                                       subType__c
                                                       from cscfga__Product_Configuration__c 
                                                       where cscfga__Product_Basket__c =: productBasketToCheck.id and csordtelcoa__Replaced_Product_Configuration__c != null]) {
                mapAllPc.put(pc.csordtelcoa__Replaced_Product_Configuration__c,pc);//EDGE-217693
            }

            Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT  Id,Name,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.configGUID__c,
                                                                                         csordtelcoa__Point_of_No_Return_Reached__c,csordtelcoa__Service_Number__c,cancel_Point_of_No_Return_Reached__c,
                                                                                         csordtelcoa__Product_Configuration__r.ConfigurationType1__c,cssdm__solution_association__c,
                                                                                         csordtelcoa__Replaced_Service__c,csordtelcoa__Product_Configuration__r.subType__c,
                                                                                         csord__Order__r.csord__Status2__c,csord__Order__r.Fulfilment_Order_Version__c,
                                                                                         csord__Subscription__r.orderversion__c,Action_Type__c,csordtelcoa__Cancelled_By_Change_Process__c,csord__Service__c  
                                                                                     FROM csord__Service__c 
                                                                                     WHERE csordtelcoa__Service_Number__c IN :serviceNumberSet 
                                                                                     OR (csordtelcoa__Replaced_Service__c != null 
                                                                                         AND csord__Order__r.csord__Order_Number__c = :orderNumber) ]); //EDGE-199064 Changed the conditio//Added by Vamsi for EDGE-199772 on 17FEB2021i
            System.debug('servicesMap '+servicesMap);
            for(csord__Service__c currentRecord : servicesMap.values()){
              System.debug('mapAllPc '+mapAllPc);
              
                if((mapAllPc != null &&  
                    mapAllPc.containsKey(currentRecord.csordtelcoa__Product_Configuration__c) && 
                    mapAllPc.get(currentRecord.csordtelcoa__Product_Configuration__c).subType__c != null &&
                    mapAllPc.get(currentRecord.csordtelcoa__Product_Configuration__c).subType__c.startsWith('Rollback'))
                   /* currentRecord.csordtelcoa__Product_Configuration__r.subType__c.startsWith('Rollback'))*/ &&
                    currentRecord.csord__Order__r.csord__Status2__c == Label.AmendRejectStatus){// EDGE-217693 ignore the PONR check for Rollback services
                    currentRecord.csordtelcoa__Point_of_No_Return_Reached__c = false;
                    currentRecord.cancel_Point_of_No_Return_Reached__c = false;
                } // amending else if for main solution as per DIGI-25047
                else if((currentRecord.csordtelcoa__Replaced_Service__c != null && String.isNotBlank(currentRecord.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) && !currentRecord.csordtelcoa__Product_Configuration__r.ConfigurationType1__c.equalsIgnoreCase('SolutionComponent')) || ServiceNumberSet.contains(currentRecord.csordtelcoa__Service_Number__c) ){
                    currentRecord.csordtelcoa__Point_of_No_Return_Reached__c = true;
                    currentRecord.cancel_Point_of_No_Return_Reached__c = true;
                    showError = true; //If any single service true it will be treated as true  
                }
                
                 //Added by Vamsi for EDGE-199772 on 17FEB2021 starts
                if( currentRecord.csord__Service__c == null && String.isNOTBlank(currentRecord.Action_Type__c) && currentRecord.Action_Type__c.equalsIgnoreCase('Inflight Cancel') &&  currentRecord.csord__Order__r.csord__Status2__c == 'Amend Rejected'  )
                {
                    if( currentRecord.csord__Order__r.Fulfilment_Order_Version__c != null && currentRecord.csord__Subscription__r.orderversion__c != null && currentRecord.csord__Order__r.Fulfilment_Order_Version__c == currentRecord.csord__Subscription__r.orderversion__c)
                   currentRecord.csordtelcoa__Cancelled_By_Change_Process__c = false; 
                }
                //Added by Vamsi for EDGE-199772 on 17FEB2021 ends
            }
            System.debug('Final Value:' + showError);
            if(servicesMap.size() > 0){
                try{
                    //Push the configs to Heroku EDGE-195759
                    System.debug('inside pushConfigurationstoHeroku call');
                    update servicesMap.values();
                    if ( CustomButtonQuoteRF.callingSource == '' ){                 
                    Id jobID = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'SaveJobId'), 1);   //EDGE-201336 push the configurations to herou via batch
                    System.debug('pushConfigurationstoHeroku jobId: ' + jobID);
                    }
                    SubscriptionUpdateHandler.UpdateSubsOrderPONRFlags(servicesMap.keyset());
                }catch(Exception ex){
                    System.debug('Exception:' + ex.getMessage() + ' Stack: ' + ex.getStackTraceString() );
                }
            }
        }
        return showError; //EDGE-199064
    }
}
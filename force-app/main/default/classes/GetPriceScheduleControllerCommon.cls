/*
* @Author : Shubhi
* @Date : 12 March 2020
* @Desc : GetPriceScheduleController (new Component)
* @Jira : Edge-143527
* @testclass : GetPriceScheduleControllerCommonTest...
===============================================================================================================================
Sr.No.    Developer Name      Date             Story Description 
1.        Gnana               30-apr-2020      EDGE-140967-Enabling Redemption as Discount for Device Payout on EM
2.        Shubhi				10/6/2020		EDGE-148662
3.        Shubhi               1-09-2020       EDGE-170938
===============================================================================================================================
*/
global class GetPriceScheduleControllerCommon {

    public static String correlationId {get; set;}
    
    public static String DiscountApplicableStatus1 {get; set;}
    public static String DiscountApplicableStatus {get; set;}
    // EDGE-140967-Enabling Redemption as Discount for Device Payout on EM by gnana || start
    public static Set<String> notApplicableGuidList {get; set;}
    public static Set<String> ApplicableGuidList {get; set;}
     // EDGE-140967-Enabling Redemption as Discount for Device Payout on EM by gnana || End

/*
--------------------------------------------------------------------------------------------------
# method to publish event, create cli and Dli specific to the solution which is calling it baed on solution name
# Edge-143527
# Author: shubhi
-------------------------------------------------------------------------------------------------- */
    @RemoteAction
    global static Map<String,Object> onLoadMethod(Object mapJsonString,String basketId,String accountId,String solutionId,String IsDiscountCheckNeeded,String solutionName,String basketNum,String IsRedeemFundCheckNeeded) {// Added IsRedeemFundCheckNeeded by gnana Edge-140967
        Map<String,Object> returnMap =new Map<String,Object>();
        DiscountApplicableStatus ='Initial';        
        system.debug('@@@@@@@@@@mapJsonString@@@@@@@'+mapJsonString);
        if(mapJsonString!=null){
            try{
                //EDGE-170938 start
                Id eighteenDigit = basketId; 
        		basketId= String.valueOf(eighteenDigit);
                //EDGE-170938 end
                Map<String,Map<String,SolutionDTO.Attributes>>  guidToAttmapOfMap = (Map<String,Map<String,SolutionDTO.Attributes>>)JSON.deserialize(String.valueOf(mapJsonString), Map<String,Map<String,SolutionDTO.Attributes>>.class);
                system.debug('@@@@@@@@@@guidToAttmapOfMap@@@@@@@'+guidToAttmapOfMap);
                DiscountApplicableStatus1 ='Initial';
                notApplicableGuidList=new Set<String>();
                boolean containsTieredCharge=false;
                correlationId=GetPriceSchedulevirtualClass.getCorrelationIdForMS();
                if(solutionName==DiscountConstants.mobilitySolutionName){ // call the controller of mobility
                    GetPriceScheduleController gps=new GetPriceScheduleController();
                    gps.onLoadMethod(guidToAttmapOfMap,basketId, accountId, solutionId, IsDiscountCheckNeeded, solutionName, basketNum, correlationId);
                    notApplicableGuidList=gps.notApplicableGuidList;
                    DiscountApplicableStatus1 =gps.DiscountApplicableStatus;
                    notApplicableGuidList=gps.notApplicableGuidList;
                    DiscountApplicableStatus =gps.DiscountApplicableStatus;
                    system.debug('DiscountApplicableStatus-->'+DiscountApplicableStatus);
                    containsTieredCharge=true;
                    returnMap.put('CorrelationId',correlationId);
                    returnMap.put('DiscountApplicableStatus',DiscountApplicableStatus);
                    returnMap.put('notApplicableGuidList',notApplicableGuidList);
                    if(DiscountApplicableStatus=='No discount applicable'){
                     returnMap.put('IsDiscountCheckNeeded','false');
                     }else{
                      returnMap.put('IsDiscountCheckNeeded',IsDiscountCheckNeeded);
                     }
                    // EDGE-140967-Enabling Redemption  by gnana
                    returnMap.put('IsRedeemFundCheckNeeded ',IsRedeemFundCheckNeeded); // EDGE-140967-Enabling Redemption  by gnana  
                }else if(solutionName==DiscountConstants.deviceSolutionName){ // call the Controller of NGUC device
                    GetPriceScheduleControllerNGUC nguc=new GetPriceScheduleControllerNGUC();
                    nguc.onLoadMethod(guidToAttmapOfMap,basketId, accountId, solutionId, IsDiscountCheckNeeded, solutionName, basketNum, correlationId);
                    notApplicableGuidList=nguc.notApplicableGuidList;
                    DiscountApplicableStatus1 =nguc.DiscountApplicableStatus;
                    notApplicableGuidList=nguc.notApplicableGuidList;
                    DiscountApplicableStatus =nguc.DiscountApplicableStatus;
                    system.debug('DiscountApplicableStatus-->'+DiscountApplicableStatus);
                    containsTieredCharge=true;
                    returnMap.put('CorrelationId',correlationId);
                    returnMap.put('DiscountApplicableStatus',DiscountApplicableStatus);
                    returnMap.put('notApplicableGuidList',notApplicableGuidList);
                    // EDGE-140967-Enabling Redemption  by gnana || strat
                     if(DiscountApplicableStatus=='No discount applicable'){
                     returnMap.put('IsDiscountCheckNeeded','false');
                     }else{
                      returnMap.put('IsDiscountCheckNeeded',IsDiscountCheckNeeded);
                     } 
                    returnMap.put('IsRedeemFundCheckNeeded ',IsRedeemFundCheckNeeded);  
                     // EDGE-140967-Enabling Redemption  by gnana || end
                }else if(SolutionName==DiscountConstants.voiceSolutionName){ // call the Controller of NGUC device
                    GetPriceScheduleControllerNGUCVoice ngucVoice=new GetPriceScheduleControllerNGUCVoice();
                    ngucVoice.onLoadMethod(guidToAttmapOfMap,basketId, accountId, solutionId, IsDiscountCheckNeeded, solutionName, basketNum, correlationId);
                    notApplicableGuidList=ngucVoice.notApplicableGuidList;
                    DiscountApplicableStatus =ngucVoice.DiscountApplicableStatus;
                    system.debug('DiscountApplicableStatus-->'+DiscountApplicableStatus);
                    containsTieredCharge=true;
                    returnMap.put('CorrelationId',correlationId);
                    returnMap.put('DiscountApplicableStatus',DiscountApplicableStatus);
                    returnMap.put('notApplicableGuidList',notApplicableGuidList);
                    // EDGE-140967-Enabling Redemption  by gnana ||strat
                    if(DiscountApplicableStatus=='No discount applicable'){
                     returnMap.put('IsDiscountCheckNeeded','false');
                     }else{
                      returnMap.put('IsDiscountCheckNeeded',IsDiscountCheckNeeded);
                     } 
                    returnMap.put('IsRedeemFundCheckNeeded ',IsRedeemFundCheckNeeded); 
                     // EDGE-140967-Enabling Redemption  by gnana || end       
                }
             // EDGE-140967-Enabling Redemption as Discount for Device Payout on EM by gnana || start
             	 List<String> onlyPosApplicableProdList = Label.onlyPosApplicableProdList.split(',');
                 if(IsRedeemFundCheckNeeded == 'true'){
                    System.debug('SolutionName....'+SolutionName);
                    GetPriceScheduleControllerRedemption redeemController=new GetPriceScheduleControllerRedemption();
                    redeemController.onLoadMethod(guidToAttmapOfMap,basketId, accountId, solutionId, IsRedeemFundCheckNeeded, solutionName, basketNum, correlationId);
                    DiscountApplicableStatus =redeemController.DiscountApplicableStatus;
                    ApplicableGuidList =redeemController.ApplicableGuidList;
                    returnMap.put('CorrelationId',correlationId);
                    returnMap.put('DiscountApplicableStatus',DiscountApplicableStatus); 
                    if(!returnMap.containsKey('IsDiscountCheckNeeded')){
                        returnMap.put('IsDiscountCheckNeeded',IsDiscountCheckNeeded);
                    }
                    returnMap.put('IsRedeemFundCheckNeeded ',IsRedeemFundCheckNeeded);
                    returnMap.put('ApplicableGuid',ApplicableGuidList );              
                }
                else if(IsRedeemFundCheckNeeded == 'false'&& (onlyPosApplicableProdList!=null && onlyPosApplicableProdList.contains(SolutionName))){//EDGE-148662
                    returnMap.put('CorrelationId',correlationId);
                    returnMap.put('DiscountApplicableStatus','Already triggered'); 
                }
                // EDGE-140967-Enabling Redemption as Discount for Device Payout on EM by gnana|| End
            }catch(Exception e) {
                System.debug('The following exception has occurred: ' + e.getMessage() + e.getCause()  + e.getStackTraceString());
            }
        }
        system.debug('Return Map--->'+returnMap);
        return returnMap;
    }

}
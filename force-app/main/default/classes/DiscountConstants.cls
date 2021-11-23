/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ComplexChargeDiscountFactory  
* @Jira : //Edge-135837
1. shubhi/Gnana  Edge-133963 NGUC voice constant data
2.  Edge-133882 added constants for Voice UI
3.  modified by shubhi for Edge-143527
4. modified  by shubhi for Edge-120919
5. modified by romil for EDGE-144161
5. Modified By ankit for Edge-14097
6. Modified by Ila for DPG-1513
7. shubhi EDGE-146184
8. Gokul.    7/12/2020 		Edge-184545
*/
public class DiscountConstants {
    
    //Edge-121376 added by Gnana
    public static Set<String> VoicePromoBUSINESSIDset = new Set<String>{'DMCAT_Discount_000899'};
    public static String CLI_CHARGETYPE = 'Tiered Recurring';//Edge-133963
    //Edge-133882 added by Shubhi start
    public static String Voice_Code = 'DMCAT_RecurringCharge_000814';

    //Edge-140968 : Charge Id (Business Id) for Mobile Subscription
    public static String MS_Charge_Id = 'DMCAT_NonRecurringCharge_000751';
    public static String mobileDeviceCompName='Mobile Device';
    //// modified by shubhi for Edge-143527 start
    public static String mobilitySolutionName='Mobile Subscription';
    public static String deviceSolutionName='Unified Communication Device';
    public static String voiceSolutionName='Business Calling';//Edge-120919
    public static String accessorySolutionName='Accessory';//added by romil EDGE-144161
   // Ila - Added as part of story : DPG-1513 Story
    public static String cwpSolutionName='CWP Mobile Subscription';

    //// modified by shubhi for Edge-143527end
    public static Map<String,String> getRateCardNameMap(){
        Map<String,String> ConstantsMap = new  Map<String,String>();
        ConstantsMap.put('DMCAT_RecurringCharge_000808','Phone Number');
        ConstantsMap.put('DMCAT_RecurringCharge_000811','Hunt Group');
        ConstantsMap.put('DMCAT_RecurringCharge_000816','Feature Pack');
        ConstantsMap.put('DMCAT_RecurringCharge_000814','Voice Line');
        ConstantsMap.put('DMCAT_RecurringCharge_000813','Cloud User');
        ConstantsMap.put('DMCAT_RecurringCharge_000810','Auto Attendant');
        return ConstantsMap;
    }
    //Edge-133882 added by Shubhi start end 
    //Edge-133963 added by Gnana
    public static List<String> getChargeIdentifier(){
        //Edge-120919 changged map to list
        List<String> chargeIdentifierList=new List<String>();
        //chargeIdentifierList.add('DMCAT_RecurringCharge_000808');// commented for EDGE-146184
        chargeIdentifierList.add('DMCAT_RecurringCharge_000811');
        chargeIdentifierList.add('DMCAT_RecurringCharge_000816');
        chargeIdentifierList.add('DMCAT_RecurringCharge_000814');
        chargeIdentifierList.add('DMCAT_RecurringCharge_000813');
        chargeIdentifierList.add('DMCAT_RecurringCharge_000810');
        chargeIdentifierList.add('DMCAT_RecurringCharge_000808');//EDGE - 184545
        return chargeIdentifierList;
    }
    //Edge-133963 added by Gnana
    public static Map<String,String> getDiscountConstForNGUCVoice(String chargeIdentifier){
        Map<String,String> ConstantsMap = new  Map<String,String>();
        if(chargeIdentifier=='DMCAT_RecurringCharge_000808'){
            ConstantsMap.put('commercialProductIdentifier','PriceItemIdforPhoneNumber');
            ConstantsMap.put('contractTermIdentifier','ContractTerm'); 
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIDforPhoneNumber'); 
            ConstantsMap.put('unitPrice_Identifier','RecurringChargePerNumber');
            ConstantsMap.put('shadowTCVIdentifier','PhoneNumberShadowRCTCV'); 
            ConstantsMap.put('quantityIdentifier','NumberofPhoneNumbers');
        }
        if(chargeIdentifier=='DMCAT_RecurringCharge_000811'){
            ConstantsMap.put('commercialProductIdentifier','PriceitemIDforHuntGroup');
            ConstantsMap.put('contractTermIdentifier','ContractTerm'); 
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIDforHuntGroup');
            ConstantsMap.put('unitPrice_Identifier','TotalRecurringChargeforHuntGroup');
            ConstantsMap.put('shadowTCVIdentifier','HuntGroupShadowRCTCV');
            ConstantsMap.put('quantityIdentifier','HuntGroupQuantity');         
        }
        if(chargeIdentifier=='DMCAT_RecurringCharge_000816'){
            ConstantsMap.put('commercialProductIdentifier','PriceitemIDforHostedUC');
            ConstantsMap.put('contractTermIdentifier','ContractTerm'); 
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIDforHostedUC'); 
            ConstantsMap.put('unitPrice_Identifier','TotalRecurringChargeforHostedUC');
            ConstantsMap.put('shadowTCVIdentifier','HostedUCShadowRCTCV');
            ConstantsMap.put('quantityIdentifier','HostedUCQuantity');
        }
        if(chargeIdentifier=='DMCAT_RecurringCharge_000814'){
            ConstantsMap.put('commercialProductIdentifier','PriceItemIdforVoiceLines');
            ConstantsMap.put('contractTermIdentifier','ContractTerm');
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIdforVoiceLines'); 
            ConstantsMap.put('unitPrice_Identifier','Recurring Charge');
            ConstantsMap.put('shadowTCVIdentifier','VoiceLinesShadowRCTCV');
            ConstantsMap.put('quantityIdentifier','concurrencyLimit');
        }
        if(chargeIdentifier=='DMCAT_RecurringCharge_000813'){
            ConstantsMap.put('commercialProductIdentifier','PriceitemIDforUser');
            ConstantsMap.put('contractTermIdentifier','ContractTerm'); 
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIDforUser'); 
            ConstantsMap.put('unitPrice_Identifier','TotalRecurringChargeforUser');
            ConstantsMap.put('shadowTCVIdentifier','UserShadowRCTCV'); 
            ConstantsMap.put('quantityIdentifier','UCUserQuantity');
        }
        if(chargeIdentifier=='DMCAT_RecurringCharge_000810'){
            ConstantsMap.put('commercialProductIdentifier','PriceitemIDforAutoAttendant');
            ConstantsMap.put('contractTermIdentifier','ContractTerm'); 
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessIDforAutoAttendant'); 
            ConstantsMap.put('unitPrice_Identifier','TotalRecurringChargeforAutoAttendant');
            ConstantsMap.put('shadowTCVIdentifier','AutoAttendantShadowRCTCV'); 
            ConstantsMap.put('quantityIdentifier','AutoAttendantQuantity');
        }
      
        return ConstantsMap;
    }   
    //Edge-135837 added by shubhi
    //solution in case of mobile subs and nguc deviceS //businessID in case of voice
    public static Map<String,String> GetDiscountConstBasedonSolName(String Solutionname){
        Map<String,String> ConstantsMap = new  Map<String,String>();
        if(Solutionname=='Unified Communication Device'){
            ConstantsMap.put('commercialProductIdentifier','ContractType');
            ConstantsMap.put('contractTermIdentifier','ContractTerm');
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessId_Device');
            ConstantsMap.put('unitPrice_Identifier','RC');
            ConstantsMap.put('shadowTCVIdentifier','deviceShadowTCV');
            ConstantsMap.put('quantityIdentifier','Quantity');
            //chargeTypeMap.put('SolutionName','Devices');
            //chargeTypeMap.put('','Flat Recurring');
                   
       }
        if(Solutionname=='Mobile Subscription'){
            ConstantsMap.put('commercialProductIdentifier','Select Plan');
            ConstantsMap.put('AddOnIdentifier','IDD ChargeLookup');
            ConstantsMap.put('contractTermIdentifier','RemainingTerm');
            ConstantsMap.put('CliBusinessIdIdentifier','BussinessId_Device');
            ConstantsMap.put('AddonBusinessIdIdentifier','BussinessId_Device');
            ConstantsMap.put('unitPrice_Identifier','RC');
            ConstantsMap.put('IDDUnitprice_Identifier','IDD Charge');
            ConstantsMap.put('shadowTCVIdentifier','PlanShadowTCV');
            ConstantsMap.put('AddonshadowTCVIdentifier','IDDShadowTCV');
            //chargeTypeMap.put('SolutionName','Devices');
            //chargeTypeMap.put('','Flat Recurring');          
       }
        if(Solutionname=='Outright Device Purchase'){
            ConstantsMap.put('commercialProductIdentifier','MobileHandsetColour');
            ConstantsMap.put('unitPrice_Identifier','oneOffPrice');
            ConstantsMap.put('shadowTCVIdentifier','totalContractValue');
            ConstantsMap.put('quantityIdentifier','Quantity');
            ConstantsMap.put('BusinessIdIdentifier','BussinessId');
        }
        return ConstantsMap;
    }   
    //Added by Aman Soni as a part of EDGE-123575 || Start
    public static Map<String,String> getChargeAttributeNameMap(String componentName){
    Map<String,String> returnMap = new  Map<String,String>();
        if(componentName!=null){
        system.debug('componentName:::::::::::'+componentName);
            switch on componentName{
                when 'Mobile Subscription'{
                    returnMap.put('DMCAT_RecurringCharge_000654','PlanShadowTCV');
                    returnMap.put('DMCAT_RecurringCharge_000669','IDDShadowTCV');
                    returnMap.put('DMCAT_RecurringCharge_000497','MessageBankShadowTCV');   

                    returnMap.put('DMCAT_NonRecurringCharge_000751','DeviceShadowTCV');   // Edge-14097 by ankit

                }
                when 'Unified Communication Device'{
                    returnMap.put('DMCAT_RecurringCharge_000856','deviceShadowRCTCV');//Edge-135837 by shubhi
                    returnMap.put('DMCAT_RecurringCharge_000857','deviceShadowRCTCV');//Edge-135837 by shubhi
                    returnMap.put('DMCAT_NonRecurringCharge_000788','DeviceShadowTCV');// Edge-14097 by ankit

                }when 'Business Calling'{//Edge-120919
                    returnMap.put('DMCAT_RecurringCharge_000808','PhoneNumberShadowRCTCV');
                    returnMap.put('DMCAT_RecurringCharge_000810','AutoAttendantShadowRCTCV');
                    returnMap.put('DMCAT_RecurringCharge_000813','UserShadowRCTCV');
                    returnMap.put('DMCAT_RecurringCharge_000816','HostedUCShadowRCTCV');
                    returnMap.put('DMCAT_RecurringCharge_000811','HuntGroupShadowRCTCV');
                    returnMap.put('DMCAT_RecurringCharge_000814','VoiceLinesShadowRCTCV');
                }
                // Ila - Added as part of story : DPG-1513 Story
                when 'CWP Mobile Subscription' {
                    returnMap.put('DMCAT_RecurringCharge_000654','PlanShadowTCV');
                    returnMap.put('DMCAT_RecurringCharge_000669','IDDShadowTCV');
                    returnMap.put('DMCAT_RecurringCharge_000497','MessageBankShadowTCV');
            returnMap.put('DMCAT_NonRecurringCharge_000751','DeviceShadowTCV');
                
                }when 'Mobile Device'{
                    returnMap.put('DMCAT_NonRecurringCharge_000511','DeviceShadowTCV'); // Edge-14097 by ankit
                }when 'Accessory'{
                     returnMap.put('DMCAT_NonRecurringCharge_000794','DeviceShadowTCV');// Edge-14097 by ankit
                }
                
            }            
        }
        return returnMap;
    }
    //Added by Aman Soni as a part of EDGE-123575 || End
    
    
     //Added by Laxmi Rahate  as a part of EDGE-132685 || Start - this method returns the charge type based on the DMCAT ID
    public static String getChargeType(String dmcatID){
        String chargeType = '';
        Map<String,String> chargeTypeMap = new  Map<String,String>();
        {
            chargeTypeMap.put('DMCAT_RecurringCharge_000654','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000669','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000497','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000856','Flat Recurring');//Edge-135837 added by shubhi
            chargeTypeMap.put('DMCAT_RecurringCharge_000857','Flat Recurring');//Edge-135837 added by shubhi        
            //chargeTypeMap.put('DMCAT_NEEDTOCHECKWITHSHUBHI','Tiered Recurring');//Edge-133963 added by Gnana
        }
        chargeType = chargeTypeMap.get (dmcatID);
        if (chargeType == null )
            {
                chargeType = '';
            }
 
        return chargeType;
    }
    //Added by Laxmi Rahate  as a part of EDGE-132685  || End  
}
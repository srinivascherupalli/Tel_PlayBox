public class StaticUtilForRecursion {
    private static boolean checkBeforeUpdatePCR = true;
    private static boolean checkAfterInsertPCR = true;
    @TestVisible  private static boolean checkAfterUpdateBasket = true;
    public static boolean autoSyncRunFlag = true;
    public static boolean CheckAfterUpdateConractRole = true;
    public static boolean CheckAfterUpdateUserRole= true;
	public static boolean CheckOfferReferenceFlag = true;
    public static boolean updateChargeLineItemWithPCFlag = true;
    public static boolean updateOpportunityDetailsInsertUpdateFlag = true;
    public static boolean deleteOLIsProductDetailsAfterUpdateFlag = true;
	public static boolean updateOpportunityDetailsFlag = true;
    public static boolean checkInflightSync = false;    //Added Pooja => 21.02 EDGE-192806:To disable trigger during InflightSyncBatchExecution
    
    public static boolean runOnceContactRoleupdate(){
        if(CheckAfterUpdateConractRole){
            CheckAfterUpdateConractRole = false;
            return true;
        }
        else
            return CheckAfterUpdateConractRole;
    }
    
    public static boolean runOnceBeforeUpdatePCR(){
        if(checkBeforeUpdatePCR){
            checkBeforeUpdatePCR = false;
            return true;
        }
        else
            return checkBeforeUpdatePCR;
    }

    public static boolean runOnceAfterInsertPCR(){
        if(checkAfterInsertPCR){
            checkAfterInsertPCR = false;
            return true;
        }
        else
            return checkAfterInsertPCR;
    }

    public static boolean runOnceAfterUpdateBasket(){
        if(checkAfterUpdateBasket){
            checkAfterUpdateBasket = false;
            return true;
        }
        else
            return checkAfterUpdateBasket;
    }

    public static boolean runAutoSyncOnce(){
        if(autoSyncRunFlag)
            return true;
        else
            return autoSyncRunFlag;
    }
    
    public static boolean runOnceUserRoleupdate(){
        if(CheckAfterUpdateUserRole){
            CheckAfterUpdateUserRole = false;
            return true;
        }
        else
            return CheckAfterUpdateUserRole;
    }
    
    public static boolean runOnceCheckOfferReference(){
        if(CheckOfferReferenceFlag){
            CheckOfferReferenceFlag = false;
            return true;
        }
        else
            return CheckOfferReferenceFlag;
    }
    
    public static boolean runUpdateChargeLineItemWithPC(){
        if(updateChargeLineItemWithPCFlag){
            updateChargeLineItemWithPCFlag = false;
            return true;
        }
        else
            return updateChargeLineItemWithPCFlag;
    }
    
    public static boolean updateOpportunityDetailsInsertUpdate(){
        if(updateOpportunityDetailsInsertUpdateFlag){
            updateOpportunityDetailsInsertUpdateFlag = false;
            return true;
        }
        else
            return updateOpportunityDetailsInsertUpdateFlag;
    }
    
    public static boolean deleteOLIsProductDetailsAfterUpdate(){
        if(deleteOLIsProductDetailsAfterUpdateFlag){
            deleteOLIsProductDetailsAfterUpdateFlag = false;
            return true;
        }
        else
            return deleteOLIsProductDetailsAfterUpdateFlag;
    }
    
    public static boolean updateOpportunityDetails(){
        if(updateOpportunityDetailsFlag){
            updateOpportunityDetailsFlag = false;
            return true;
        }
        else
            return updateOpportunityDetailsFlag;
    }
    
}
/*
  **********************************************************************************************
  * @author       : Resmi Ramakrishnan
  * @date         : 29/11/2016
  * @description  :  This is the controller class of CancelSubscription page.
  **********************************************************************************************
*/


public class CancelSubscriptionController 
{
    private final Account accountObj;
    private final csord__Subscription__c subscriptionObj;
    
    public string objName{get;set;}
    private String currentId;
    private String objectName;
        
    public Boolean varEnableBlock1 {get;set;}
    public Boolean varEnableBlock2 {get;set;}
    public Boolean varBackButtonEnable {get;set;}

    public Integer offset { get; set; }
    public Integer paginationSize {get; set;}
    
    public Set<Id> selectedSubscriptionIDs {get;set;}
    public Set<subscriptionWrapper> allSelectedWrapperSet{get;set;}
               
    public static List<csord__Subscription__c> newSubscriptionList;
    public List<subscriptionWrapper> WrapperList{get;set;}
    public List<subscriptionWrapper>  selectedSubscriptionList;
    
    static {
        newSubscriptionList = new List<csord__Subscription__c>();
    }    
    
    /*
      * @description       This is Constructor of CancelSubscriptionController class.                       
      * @param             NA 
      * @return            NA
      * @throws            NA
    */     
    public CancelSubscriptionController()
    {                
        String envPaginationSize = EnvironmentVariable.get('Cancel_Subscription_Pagination_Size');
        paginationSize =  (envPaginationSize != null && envPaginationSize != '') ? integer.valueof(envPaginationSize) : 25;
        offset = 0;

        varEnableBlock1 = true;
        varEnableBlock2 = false;
        varBackButtonEnable =true;
        
        selectedSubscriptionIDs = new Set<Id>();
        allSelectedWrapperSet = new Set<subscriptionWrapper>();
               
        currentId = ApexPages.currentPage().getParameters().get('id');                        
        if( currentId!= null )
        {
             objectName =  KeyPrefix.GetKeyPrefix( currentId );                                
             if( objectName == 'csord__Subscription__c')
             {
                subscriptionObj = [SELECT Name FROM csord__Subscription__c WHERE Id = :currentId];
                if( subscriptionObj != null )
                {
                    objName = subscriptionObj.Name;   
                }                                       
            }
            else if( objectName == 'Account' )
            {  
               accountObj = [SELECT Name FROM Account WHERE Id = :currentId];
               if( accountObj != null )
               {
                   objName = accountObj.Name;  
               }                                                          
            }
            populateSubscriptionWrapList();
        }                 
    }
    
    
    /*
      * @description       StandardSetController properties.                       
      * @param             NA 
      * @return            NA
      * @throws            NA
    */ 
    public ApexPages.StandardSetController ssc {
        get {
            if(ssc == null) {                
                List<csord__Subscription__c> subList = new List<csord__Subscription__c>( searchForSubscriptions());               
                ssc = new ApexPages.StandardSetController(subList);
                ssc.setPageSize(paginationSize);
            }
            return ssc;
        }
        set;
    } 
   
    
    /*
      * @description       Search all subscription records.                       
      * @param             NA 
      * @return            List<csord__Subscription__c>
      * @throws            NA
    */ 
    public List<csord__Subscription__c> searchForSubscriptions()
    {    System.debug('***searchForSubscriptions***');
        String Qry;
        newSubscriptionList = new List<csord__Subscription__c>();
        if( currentId!= null )
        {                            
             if( objectName == 'csord__Subscription__c')
             {       
                Qry = getQueryString( 'id', currentId );                
            }
            else if( objectName == 'Account' )
            {                           
               Qry = getQueryString( 'csord__Account__c', currentId );               
            }
            if( Qry != null)
            {
               newSubscriptionList = Database.Query( Qry );
            }
        } 
        return newSubscriptionList;               
    } 
   
       
    /*
      * @description       Returns Query String.                       
      * @param             NA 
      * @return            filterID,CurrentID 
      * @throws            NA
    */ 
    public String getQueryString( String filterID, String CurrentID )
    {
      String queryString = 'SELECT id,(SELECT Id,Name,csord__Status__c FROM Subscriptions__r),' +
                     'csordtelcoa__Subscription_Number__c,Name,csord__Status__c,csord__Order__r.csord__Order_Number__c,' +
                     'csord__Order__r.csord__End_Date__c,Site__r.Name,csord__Total_Service_One_Off_Charges__c,' +
                     'csord__Total_Service_Recurring_Charges__c, Reason_for_cancellation__c,Cancellation_Date_of_Effect__c,' +
                     'Customer_Application_Date__c,Hardware_Recovery_Request__c,Parent_TRN__c,Customer_Reference_Number__c,' +
                     'PM_Details__c,PM_ID__c,Project_ID__c,PM_Group__c ' +
                     'FROM csord__Subscription__c ' +
                     'where ';      
      
      String finalString = queryString + filterID + ' = \'' + CurrentID  + '\'' + ' and csord__Status__c != \'' + Constants.subscriptionStatus_Pending + '\' and csord__Status__c != \''+  Constants.subscriptionStatus_Cancel + '\'';
               
      return finalString;
    }
   
        
    /*
      * @description       This function is using to show all subscriptions in list view.                       
      * @param             NA 
      * @return            List<subscriptionWrapper>
      * @throws            NA
    */  
    public void populateSubscriptionWrapList()
    {
        WrapperList = new List<subscriptionWrapper>();
        
        if(ssc != null) 
        {
            for (csord__Subscription__c sub : (List<csord__Subscription__c>)ssc.getRecords())
             {
                if(selectedSubscriptionIDs != null && selectedSubscriptionIDs.contains(sub.Id)) 
                {
                    WrapperList.add(new subscriptionWrapper(sub, true));
                }
                else 
                {
                    WrapperList.add(new subscriptionWrapper(sub, false));
                }
            }
        }       
    }
    
    
    /*
      * @description       This function is using to get selected Record IDs.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */ 
    private void saveSelected()
    {
        System.debug( 'RESMI: Inside SaveSelected function ' );
        if(WrapperList!= null && !WrapperList.isEmpty()) 
        {
            for( subscriptionWrapper subWrap : WrapperList ) 
            {                                       
                csord__Subscription__c sub = subWrap.Wrapsub;
                if(subWrap.selected ) 
                {   
                                   
                    if(!selectedSubscriptionIDs.contains(sub.Id)) 
                    {
                        allSelectedWrapperSet.add(subWrap);
                        selectedSubscriptionIDs.add(sub.Id);
                        System.debug('RESMI:Selected Object details' + sub );
                    }    
                }
                else 
                {
                      
                    if(selectedSubscriptionIDs.contains(sub.Id)) 
                    {
                        allSelectedWrapperSet.remove(subWrap);
                        selectedSubscriptionIDs.remove(sub.Id);
                    }                    
                }                
            }
        }
    }  
    
   /*
      * @description       This function is using to show selected subscriptions in list view.                       
      * @param             NA 
      * @return            List<subscriptionWrapper>
      * @throws            NA
    */  
    public List<subscriptionWrapper> getSelectedSubscriptionList()
    {  
        system.debug('Inside getSelectedSubscriptionList' + allSelectedWrapperSet.size());         
        saveSelected();            
         selectedSubscriptionList =new List<subscriptionWrapper>();        
        try
        {
            if( allSelectedWrapperSet!= null &&   !allSelectedWrapperSet.isEmpty())
            {
                for(subscriptionWrapper subObj:allSelectedWrapperSet)
                {
                   if( subObj != null && subObj.selected == true)
                   {
                      selectedSubscriptionList.add(subObj);

                   }
                }                               
            }       
           system.debug('RRR:selectedSubscriptionList=' + selectedSubscriptionList.size());
           return selectedSubscriptionList;
       }
       catch(Exception ex)
       {
           ApexPages.addMessages(ex);  
       }
       return null;
    }

    
    /*
      * @description       This function is get selected subscription objectlist for creating 
                           orchestration process and also update cancellation details to subscription object.                       
      * @param             NA 
      * @return            List<csord__Subscription__c>
      * @throws            NA
    */  
    public List<csord__Subscription__c> getSelectedSubscriptionSummaryList()
    {
          try
          {
                List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
                Map<String,csord__Subscription__c> allSubscriptionMap = new Map<String,csord__Subscription__c>();                
            
                if( selectedSubscriptionList!= null && !selectedSubscriptionList.isEmpty())
                {
                    for( subscriptionWrapper wrapperObj :selectedSubscriptionList)
                    {
                        wrapperObj.Wrapsub.csord__Status__c = Constants.subscriptionStatus_Pending;
                        for( csord__Subscription__c schild : wrapperObj.Wrapsub.Subscriptions__r)
                        {
                            schild.csord__Status__c = Constants.subscriptionStatus_Pending;
                            schild.Reason_for_cancellation__c = wrapperObj.Wrapsub.Reason_for_cancellation__c;
                            schild.Cancellation_Date_of_Effect__c = wrapperObj.Wrapsub.Cancellation_Date_of_Effect__c;
                            schild.Customer_Application_Date__c = wrapperObj.Wrapsub.Customer_Application_Date__c;
                            schild.Hardware_Recovery_Request__c = wrapperObj.Wrapsub.Hardware_Recovery_Request__c;
                            schild.Parent_TRN__c = wrapperObj.Wrapsub.Parent_TRN__c;
                            schild.Customer_Reference_Number__c = wrapperObj.Wrapsub.Customer_Reference_Number__c;
                            schild.PM_Details__c = wrapperObj.Wrapsub.PM_Details__c;
                            schild.PM_ID__c = wrapperObj.Wrapsub.PM_ID__c;
                            schild.Project_ID__c = wrapperObj.Wrapsub.Project_ID__c;
                            schild.PM_Group__c = wrapperObj.Wrapsub.PM_Group__c;
                            allSubscriptionMap.put(schild.id,schild);
                        } 
                        subscriptionList.add(wrapperObj.Wrapsub);
                        allSubscriptionMap.put(wrapperObj.Wrapsub.id,wrapperObj.Wrapsub);  
                    }
                    update allSubscriptionMap.values();
                }        
                return subscriptionList;
          }
          catch(Exception ex)
          {
             ApexPages.addMessages(ex); 
          }
          return null;
    }
    
    
    /*
      * @description       This function is get called when user clicks back button from first page.                       
      * @param             NA 
      * @return            PageReference 
      * @throws            NA
    */ 
    public PageReference BackToOrder()
    {
         PageReference returnPage = new PageReference( '/' + ApexPages.currentPage().getParameters().get('id'));  
         return returnPage; 
    }
 
    
    /*
      * @description       This function is get called when user clicks continue cancellation button from first page.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */ 
    public void ContinueCancellation()
    {
         varEnableBlock1 = false;
         varEnableBlock2 = true;
    }
 
    
    /*
      * @description       This function is get called when user clicks Back button from second page.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */
    public void BackToSelection()
    {
         varEnableBlock1 = true;
         varEnableBlock2 = false;       
       
    }    
    
    
    /*
      * @description       This function is get called when user clicks continue cancellation button from second page.                       
      * @param             NA 
      * @return            PageReference 
      * @throws            NA
    */
    public PageReference ContinueCancelSubscription()
    {    
         return Page.SelectedCancellationSummary;
    }
 
   
    /*
      * @description       This function is get called when user clicks Back button from summary page.                       
      * @param             NA 
      * @return            PageReference 
      * @throws            NA
    */
    public PageReference BackToCancelProcess()
    {
        varEnableBlock1 = false;
        varEnableBlock2 = true;
        return Page.CancelSubscriptions;   
    }
    
    
    /*
      * @description       This function is get called when user clicks Confirm button from summary page.                       
      * @param             NA 
      * @return            PageReference 
      * @throws            NA
    */
    public PageReference ConfirmCancellation()
    {        
       try
       {
           List<csord__Subscription__c> tempSelectedSubscriptionList = new List<csord__Subscription__c>(getSelectedSubscriptionSummaryList());
           if( CancelSubscriptionOrchestrationProcess.createCancellationOrchProcesses(tempSelectedSubscriptionList))
           {
               System.debug('RESMI: ConfirmCancellation- Entry');
               ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.CONFIRM, Constants.CANCEL_SUBSCRIPTION_CONFIRMATION );
               ApexPages.addMessage(msg); 
               varBackButtonEnable  = false;              
           }            
           return null;        
       }
       catch(Exception ex)
       {
            ApexPages.addMessages(ex);  
       }
       return null;
    }  
    
       
    /*
      * @description       This function is get called when user clicks Exit button from summary page.                       
      * @param             NA 
      * @return            PageReference 
      * @throws            NA
    */    
    public PageReference ExitAction()
    {
        PageReference returnPage = new PageReference( '/' + ApexPages.currentPage().getParameters().get('id'));  
        return returnPage; 
    }
 
    
   /*
      * @description       This function is get called when user clicks First pagination button.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */            
    public void first() 
    {
        saveSelected();
        ssc.save();
        ssc.first();
        populateSubscriptionWrapList();
    } 
    
    
    /*
      * @description       This function is get called when user clicks Next pagination button.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */  
    public void next() 
    {
        saveSelected();
        ssc.save();
        ssc.next();
        populateSubscriptionWrapList();
    } 
    
    
    /*
      * @description       This function is get called when user clicks Previous pagination button.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */    
    public void previous() 
    {
        saveSelected();
        ssc.save();
        ssc.previous();
        populateSubscriptionWrapList();
    }  
    
    /*
      * @description       This function is get called when user clicks last pagination button.                       
      * @param             NA 
      * @return            void
      * @throws            NA
    */   
    public void last() 
    {
        saveSelected(); 
        ssc.save();   
        ssc.last();
        populateSubscriptionWrapList();
    }    
    public Boolean hasNext
    {
       get {
            return ssc.getHasNext();
        }
        set;    
    }
    public Boolean hasPrevious
    {
       get {
            return ssc.getHasPrevious();
        }
        set;
    } 
    
    
    /*
      * @description       This function is using to get page number.                       
      * @param             NA 
      * @return            Integer
      * @throws            NA
    */    
    public Integer getPageNumber() 
    {
        Integer noOfRecs;
        noOfRecs = ssc.getResultSize();
        if( noOfRecs > 0)
        {
           return ssc.getPageNumber();
        }
        else
        {
            return 0;
        }
    } 
    
    
    /*
      * @description       This function is using to get total number of pages.                       
      * @param             NA 
      * @return            Integer
      * @throws            NA
    */   
    public Integer getTotalPages() 
    {
        Integer noOfRecs;
        Integer totalPages ;
        noOfRecs = ssc.getResultSize();
        if( noOfRecs > 0)
        {
           totalPages = Math.MOD(noOfRecs,ssc.getPageSize()) ==0 ? noOfRecs/ssc.getPageSize() : noOfRecs/ssc.getPageSize()+1;
           return totalPages ;
        }
        else
        {
            return 0;
        }
    }
    
        
    /*
      *******************************************************************************
      @description       Wrapper class using for selecting subcriptions from VF page
      *******************************************************************************                             
    */  
    public class subscriptionWrapper
    {
        public csord__Subscription__c Wrapsub {get; set;}
        public Boolean selected {get; set;}
        
        public subscriptionWrapper(csord__Subscription__c sub, Boolean selected)
        {
            Wrapsub = new csord__Subscription__c();
            this.Wrapsub = sub;
            this.selected = selected;
        }
    }
}
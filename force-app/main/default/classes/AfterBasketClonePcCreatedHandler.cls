/* ****************************************************************************
 * Author : Mohammed Zeeshan : EDGE-79405
 * Date : 18 March 2019
 * Description : This observer is triggered for basket close 
 * Revision :  
 * *****************************************************************************/
global with sharing class AfterBasketClonePcCreatedHandler implements csbb.ObserverApi.IObserver{
    

/***********************************************************************
  *Name: AfterBasketClonePcCreatedHandler
  *Description: Constructor 
*******************************************************************/    
    global AfterBasketClonePcCreatedHandler() {
        
    }
    
/*******************************************************************
  * Name: execute
  * Parameters: csordcb.ObserverApi.Observable o, Object arg
  * Return Type: void
  * Description: Method executed when AfterBasketClonePcCreated process is invoked
  *******************************************************************/
    global void execute (csbb.ObserverApi.Observable o, Object arg) {
        boolean callCloneAttachment = true;
        //system.debug('*****>observable ' + o);
        //system.debug('*****>argument ' + arg);
        if(o!=null){
            csbb.ProductConfigurationObservable observable = (csbb.ProductConfigurationObservable) o;
            if(observable!=null){
                cscfga__Product_Configuration__c pc =observable.getProductConfiguration();
                
                //System.debug ('****************Before PC Check-- PC ID -' +pc  );
                //System.debug ('Before PC Check-- PC Name -' +pc.name  );

                if(pc!=null){
                    cscfga__Product_Basket__c basketRecord =[select id,csbb__Account__c,csbb__Account__r.CIDN__c,csbb__Account__r.Enterprise_ID__c from cscfga__Product_Basket__c where id In (select cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id=:pc.id) limit 1];
                    system.debug('------>basketRecord ' + basketRecord);
                    List<csbb__Product_Configuration_Request__c> selectionContext = observable.getSelectionContext();

                    //processSiteSQForBasketClone(basketRecord);   

                    if ((null!=basketRecord.id)&&(callCloneAttachment )){
                      callCloneAttachment  = false;
                      processTransitionDataCloneForClonedPC(basketRecord.id);
                    }
                              
                }
            }
        }
    }
 /*************************************************************************************************
 * Method Name : processSiteSQForBasketClone
 * Description : This method is used to identify list of eligible adborids
 * Test Class  : AfterBasketClonePcCreatedHandlerTest
 * Author      : Mohammed Zeeshan
 * Date        : 06/05/2019      
 * Story       : EDGE-79405 - As a sales / partner user, System to automate the SQ during basket clone for New Order Type.

**************************************************************************************************


    
    public void processSiteSQForBasketClone(cscfga__Product_Basket__c basket){
        List<cscfga__Product_Configuration__c> productbasket = [select id,name,(select id,name,cscfga__Value__c from cscfga__Attributes__r where name ='AdborID') from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basket.id and name='IP Site'];
        set<id> attributeid = new set<id>();
        if(productbasket!=null){
        // Adding the addtibutes to attributeid list for the fetched product configuration records
            for(cscfga__Product_Configuration__c productconfig :productbasket){
                for(cscfga__Attribute__c attribute : productconfig.cscfga__Attributes__r){
                    attributeid.add(attribute.id);
               }     
            }
        }

        //system.debug('------------>attributeid'+attributeid);
        
        List<String> adborId_List = new List<String>();
        List<cscfga__Attribute__c> attributeList = [SELECT id,name,cscfga__Value__c FROM cscfga__Attribute__c WHERE Name = 'AdborID' AND id=:attributeid];
        //System.debug('------->attributeList'+attributeList);

        if(!attributeList.IsEmpty()){
            for(cscfga__Attribute__c attibute : attributeList){
                if(attibute.cscfga__Value__c != null)
                    adborId_List.add(attibute.cscfga__Value__c);
            }
        }

        //System.debug('-------------->'+adborId_List);

        cscfga__Product_Basket__c basket2 = [select id,csbb__Account__r.id from cscfga__Product_Basket__c where id=:basket.id];
        String AccountId = String.valueOf(basket2.csbb__Account__r.id);
        
        //Creating object for SiteSQContractCallout class
        SiteSQContractCallout  SiteContractCallout = new SiteSQContractCallout('BasketClone');
        List<String> AdboridList = SiteContractCallout.getConfigurableAddressIdList(adborId_List,AccountId);
        //System.debug('-------->AdboridList'+AdboridList);
        //return AdboridList;
        
        
        Integer num = AdboridList.size()/50;
        //system.debug('number::'+num);
        Set<Id> QueueIds = new Set<Id>();
        
        if(math.mod(AdboridList.size(),50) != 0){
            num=num+1;
            //system.debug('inside if::'+num);
        }
        //create batches of 50 records 
        for(Integer i=0;i<num;i++){
            Integer counter =0;
            List<String> inputAddressList = new List<String>();
            // add each batch of 50 records to queue
            for(Integer j=0;j<50;j++){
                inputAddressList.add(AdboridList[counter]);
                //system.debug('---->inputAddressList counter'+inputAddressList);
                if(counter == AdboridList.size()-1){
                    counter++;
                    break;
                }
                counter ++;
            }
            //system.debug('---->Outside for inputAddressList counter'+inputAddressList);
            //creating object for  SiteSQBasketQueuable
            SiteSQBasketQueuable AfterBasketJob = new SiteSQBasketQueuable(inputAddressList);
            Id QueueId =  System.enqueueJob(AfterBasketJob);
            QueueIds.add(QueueId);
        }
        //system.debug('JOBID of AfterBasketJob Queue ' + QueueIds);
        

    } 

 */

/*************************************************************************************************
Method Name : processTransitionDataCloneForClonedPC 
Description : This method copies the attachments from the PCRs for IP Site of Original Basket TO the Cloned Basket
Test Class  : AfterBasketClonePcCreatedHandlerTest
Author      : Laxmi Rahate
Date        : 06/05/2019      
Story       : EDGE-75157 - I should be able to view the previously selected checkpoint details in cloned basket and also in the baskets after order is submitted.
**************************************************************************************************/
  public  void processTransitionDataCloneForClonedPC(id clonedBasketID) {
       Map <id,id> mapOrigIDClonedPCID = new Map <id,id>(); // Map which Contains Cloned PC ID & Original PC ID

        Set<Id> prodConfigIDsCloned = new Set<Id>();
        Set<Id> prodConfigIDsOrig = new Set<Id>();
        // Get the list of the PCs for the cloned Basket, as part of this story we are also putting 
        // value of the PC  Id of the Original Basket in field PC_cloned_from_Id__C
       List<cscfga__Product_Configuration__c> productConfigurations = 
           [Select Id,PC_cloned_from_Id__C,cscfga__Product_Basket__c From cscfga__Product_Configuration__c 
            Where cscfga__Product_Basket__c =  :clonedBasketID  and name like '%Site%'];

       for(cscfga__Product_Configuration__c prodConfiguration : productConfigurations)
       {
            mapOrigIDClonedPCID.put(prodConfiguration.PC_cloned_from_Id__C,prodConfiguration.Id);  
            prodConfigIDsCloned.add (prodConfiguration.Id);
           if (null!=prodConfiguration.PC_cloned_from_Id__C||''==prodConfiguration.PC_cloned_from_Id__C) {
            prodConfigIDsOrig.add(prodConfiguration.PC_cloned_from_Id__C);
           }

       }
        System.debug ('Prod Configs for Cloned --- ' +prodConfigIDsCloned + 
                      ' size of prodConfigIDsOrig --' +prodConfigIDsOrig.size());

        if (prodConfigIDsOrig.size()>0) 
        
        {
        //Get the PCRs for the Cloned Basket for IP Site
        Map<ID,id> mapPC_PCRCloned= new Map<ID,id>(); // Map contains PC, PCR for Cloned Basket
        List<csbb__Product_Configuration_Request__c> prodConfigReqCloned = 
            [Select id, csbb__Product_Configuration__c from csbb__Product_Configuration_Request__c where
             csbb__Product_Configuration__c in  :prodConfigIDsCloned] ;
        Set<Id> pcrCloned = new Set<Id>();
        Set<Id> pcrOriginal = new Set<Id>();
        Set <id> pcrClonedOrginal = new Set<id>();
        for(csbb__Product_Configuration_Request__c prodConfigReqCl : prodConfigReqCloned)
        {
            pcrCloned.add(prodConfigReqCl.id);
            mapPC_PCRCloned.put (prodConfigReqCl.csbb__Product_Configuration__c,prodConfigReqCl.id);
            pcrClonedOrginal.add (prodConfigReqCl.id);
        }

        Map<ID,id> mapPC_PCROriginal= new Map<ID,id>(); // Map contains PC, PCR for Original Basket
        
        //Get the PCRs for the Original Basket for IP Site

        List<csbb__Product_Configuration_Request__c> prodConfigReqOriginal = 
            [Select id, csbb__Product_Configuration__c from csbb__Product_Configuration_Request__c 
             where csbb__Product_Configuration__c in  :prodConfigIDsOrig] ;
        
        for(csbb__Product_Configuration_Request__c prodConfigReqOrg : prodConfigReqOriginal)
        {
            pcrOriginal.add(prodConfigReqOrg.id);
            mapPC_PCROriginal.put (prodConfigReqOrg.csbb__Product_Configuration__c,prodConfigReqOrg.id);
            pcrClonedOrginal.add (prodConfigReqOrg.id);
   
        }

        System.debug ('Config Reqs for Original --- ' +pcrOriginal );
        System.debug ('Configs Reqs for Cloned --- ' +pcrCloned + ' size of pcrCloned --' +pcrCloned.size());

        Map<ID,String> mapAttachment= new Map<ID,String>(); 
            // Map contains attachments for cloned and original Basket
        //Get the list of attachments for all the PCRs ( Original + Cloned)
        List <Attachment> atch = [Select ID, name, body, parentId from Attachment 
                                  where parentId in :pcrClonedOrginal and name ='TransitionJSONData.json'];

         for(Attachment at: atch)
        {
            mapAttachment.put (at.parentId,at.body.toString() );

        }
        
         // Code to get the json from Original Basket and Copying in cloned Basket.
                String tmpClonedPCR = null;
                String tmpOriginalPCR = null;
                boolean updateAttchement = false;
        
                List<Attachment> attachmentTobeInserted= new List<Attachment> ();
                Attachment attInsert;  
            if (mapAttachment.size()>0) { // executing the code only when the Map attachment has nay Data!!
                for (id originalPCID : mapOrigIDClonedPCID.keySet())
                {
                    tmpClonedPCR = mapPC_PCRCloned.get(mapOrigIDClonedPCID.get (originalPCID));
                    tmpOriginalPCR = mapPC_PCROriginal.get(originalPCID);
                    System.debug('tmpOriginalPCR'+ tmpOriginalPCR);
                    //System.debug ('mapAttachment for Original PCR ----' + mapAttachment.get (tmpOriginalPCR));
                    if (null!=tmpClonedPCR){
                    if (!mapAttachment.containsKey(tmpClonedPCR))
                    {
                        try {
                        attInsert = new Attachment();
                        attInsert.ParentId=tmpClonedPCR;
                        attInsert.body = Blob.valueof (mapAttachment.get (tmpOriginalPCR)) ;
                        attInsert.name = 'TransitionJSONData.json';
                        System.debug ('attachment doesnt exist!! for PCR --' + tmpClonedPCR 
                                      + ' Copying the attachment from - ' + tmpOriginalPCR);
                        attachmentTobeInserted.add (attInsert);
                        }
                        catch (Exception e){
                        System.debug('AfterBasketClonePcCreatedHandler Error in copying the attachment to Map!!' +
                                     e.getMessage());
              } 

                    }
                    else
                        {
                            System.debug ('attachment already exist!! for PCR --' + tmpClonedPCR);

                        }
                    }else
                    {
                        System.debug ('Cloned PCRs do not exist!!');
                    }
                }
            } else
            {
                System.debug ('There are no attachments for Original Basket!!!');
            }
              try {
                     if(attachmentTobeInserted.size()>0){
                        insert  attachmentTobeInserted;
                        System.debug ('Inserted Records Successfully!!');
                  } 
               
              }
              catch (Exception e){
              System.debug('AfterBasketClonePcCreatedHandler1: processTransitionDataCloneForClonedPC - Error while inserting the Attachments for the Cloned Basket :-' + e.getMessage());
              } 
        }
        else
        {
            System.debug ('Original PC ID are not available !!');
        }
    }
}
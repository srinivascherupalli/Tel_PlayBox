/*******************************************************************************************************************
Class Name : QLIEnrichQueueable
Description :  whenever a case is created with QLI or new QLI are added to an existing case, 
invoke a REST API call to Case Invoice MS to inform them to work on the case and get the necessary 
info from Invoice Manager and populate in Salesforce
====================================================================================================================
Sr.No.    Developer Name           Date            Story Description
1.        Shubhi V                10/05/2021         Edge-212404
2.    	Vamsi Krishna Vaddipalli  2JUN2021           EDGE-219120
2.         Shubhi                 02-06-2021    	 EDGE-216407
====================================================================================================================
********************************************************************************************************************/
public with sharing class QLIEnrichQueueable implements Queueable, Database.AllowsCallouts {
    public static Final Integer MAXCALLOUTS=48;
    string caseId;
    String invoiceNumber='';
	
    Set<String> invoiceSet = new Set<String>();
	Map<String,Set<String>> caseToInvoicenumListMap=new Map<String,Set<String>>(); // added by shubhi for edge-216407

    public QLIEnrichQueueable (String caseId,String invoiceNumber)
    {
        this.invoiceNumber=invoiceNumber;
        this.caseId=caseId;
    }
    //Added By Vamsi for EDGE-219120 on 2JUN2021 starts
     public QLIEnrichQueueable (String caseId,Set<String> invoiceSet) 
    {
        this.caseId=caseId;
        this.invoiceSet = invoiceSet;
    }
    //Added By Vamsi for EDGE-219120 on 2JUN2021 ends
	//edge-216407 added for non assited flow
	public QLIEnrichQueueable (Map<String,Set<String>> caseToInvoicenumListMap)
    {
        this.caseToInvoicenumListMap=caseToInvoicenumListMap;
    }
    
    public void execute(QueueableContext context)
    {        
	
		if(String.isNotBlank(invoiceNumber) && String.isNotBlank(caseId))
            InvoiceCalloutHandler.informMStoEnrichQLI(caseId,invoiceNumber);
        
			//Added By Vamsi for EDGE-219120
		if(invoiceSet != null  &&  !invoiceSet.isEmpty() && String.isNotBlank(caseId))
        {
			executeRetry(invoiceSet,caseId);
        }
		
		////edge-216407 added for non assited flow start---------
		if(caseToInvoicenumListMap!=null && !caseToInvoicenumListMap.isEmpty()){
			executeNonAssitedFlow(caseToInvoicenumListMap);
		}
		////edge-216407 added for non assited flow end---------
    }

	//Added By Vamsi for EDGE-219120 on 03JUN2021 for retry mechanism 
	// counter and countercallouts to handle governor limits for callout from queuable in case if there are more than 50 qlis added by shubhi
	private static void executeRetry(Set<String> invoiceSet,String caseId){
		Integer countcallouts=0;
		Set<String> newinvoiceSet=invoiceSet;
        Set<String> newinvoiceSetFinal=new Set<String>();
        Map<String,Set<String>> caseToInvoicenumListMap=new  Map<String,Set<String>>();
		if(newinvoiceSet!=null && !newinvoiceSet.isEmpty()){
			for(String invoiceNum:invoiceSet)
			{
				newinvoiceSet.remove(invoiceNum);
                newinvoiceSetFinal.add(invoiceNum);
				countcallouts++;
				if(countcallouts==QLIEnrichQueueable.MAXCALLOUTS)
				break;
			}
            if(countcallouts<=QLIEnrichQueueable.MAXCALLOUTS && newinvoiceSetFinal!=null && !newinvoiceSetFinal.isEmpty()){
                caseToInvoicenumListMap.put(caseId,newinvoiceSetFinal);
				InvoiceCalloutHandler.informMStoEnrichQLIBulk(caseToInvoicenumListMap);
			}
			if(countcallouts==QLIEnrichQueueable.MAXCALLOUTS && newinvoiceSet!=null && !newinvoiceSet.isEmpty()){
				ID jobID = System.enqueueJob(new QLIEnrichQueueable(caseId,newinvoiceSet));  
			}
		}
	}

	//added by shubhi for non assited flow  
	// counter and countercallouts to handle governor limits for callout from queuable in case if there are more than 50 qlis 
	private static void executeNonAssitedFlow(Map<String,Set<String>> caseToInvoicenumListMap){
		Integer countcallouts=0;
		Integer counter=0;
		Map<String,Set<String>> caseToInvoicenumListMapNew=caseToInvoicenumListMap;
		Map<String,Set<String>> caseToInvoicenumListMapFinal=new Map<String,Set<String>>();
		if(caseToInvoicenumListMapNew!=null && !caseToInvoicenumListMapNew.isEmpty()){
			for(String caseId:caseToInvoicenumListMap.keyset())
            {
				Set<String> invoiceSet=caseToInvoicenumListMap.get(caseId);
                
				Set<String> invoiceSetFinal=new Set<String>();
				counter=0;
				for(String invoiceNum:caseToInvoicenumListMap.get(caseId)){
                    system.debug('invoice num-->'+invoiceSetFinal.size());
					invoiceSetFinal.add(invoiceNum);
					invoiceSet.remove(invoiceNum);
					caseToInvoicenumListMapNew.put(caseId,invoiceSet);
					//InvoiceCalloutHandler.informMStoEnrichQLI(caseId,invoiceNum);
					//counter++;
					countcallouts++;
					if(countcallouts==QLIEnrichQueueable.MAXCALLOUTS)
						break;
				}
                 system.debug('invoiceSet size->'+invoiceSetFinal.size());
				caseToInvoicenumListMapFinal.put(caseId,invoiceSetFinal);
                
				if(countcallouts==QLIEnrichQueueable.MAXCALLOUTS)
					break;
				caseToInvoicenumListMapNew.remove(caseId);
            }
			if(countcallouts<=QLIEnrichQueueable.MAXCALLOUTS && caseToInvoicenumListMapFinal!=null && !caseToInvoicenumListMapFinal.isEmpty()){				
				InvoiceCalloutHandler.informMStoEnrichQLIBulk(caseToInvoicenumListMapFinal);
			}
            if(countcallouts==QLIEnrichQueueable.MAXCALLOUTS && caseToInvoicenumListMapNew!=null && !caseToInvoicenumListMapNew.isEmpty()){				
				ID jobID = System.enqueueJob(new QLIEnrichQueueable(caseToInvoicenumListMapNew));
			}		
		}

	}

}
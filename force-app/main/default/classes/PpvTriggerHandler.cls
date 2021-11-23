/****************************************************************************
@Author: Aishwarya Yeware
@Story: EDGE-100327
@Description: PpvTriggerHandler
*********************************************************************************/
public without sharing class PpvTriggerHandler {
    public static Map<Id,Customer_Authority_Form__c> ppvMap = new  Map<Id,Customer_Authority_Form__c>();
    public static Map<Id,Customer_Authority_Form__c> ppvMapUnverified = new  Map<Id,Customer_Authority_Form__c>();
    //EDGE-100327 Method to update ppv status to authorised 
    public static void onBeforeUpdate(Map<Id,Customer_Authority_Form__c> newMap,Map<Id,Customer_Authority_Form__c> oldMap){
        List<String> ppvStatusList = new List<String> {Label.ppv_success,Label.ppv_failure};
            map<String,String> mapLabel = getStatusValue(ppvStatusList);
        if(newMap !=null && oldMap !=null){
            for(ID key :newMap.keyset()){
                
                if(newMap.get(key).Status__c != oldMap.get(key).Status__c && newMap.get(key).Status__c == Label.ppv_success){
                    newMap.get(key).PPV_status__c = mapLabel.get(Label.ppv_success); 
                }
                if(newMap.get(key).Status__c != oldMap.get(key).Status__c && newMap.get(key).Status__c == Label.ppv_failure){
                    newMap.get(key).PPV_status__c = mapLabel.get(Label.ppv_failure); 
                }
            }
        }
        
    }
    
    public static void onAfterUpdate(Map<Id,Customer_Authority_Form__c> newMap,Map<Id,Customer_Authority_Form__c> oldMap){
        PpvComponentController.PpvWrapper detailWrapper=new PpvComponentController.PpvWrapper();        
        List<Customer_Authority_Form__c> newcaf=new List<Customer_Authority_Form__c>(); 
        List<Customer_Authority_Form__c> unverify_newcaf=new List<Customer_Authority_Form__c>(); 
        List<Customer_Authority_Form__c> caf=new List<Customer_Authority_Form__c>();  
        for(ID key :newMap.keyset()){
            //Creating method to reduce cyclomatic complexity
            caf.add(newMap.get(key));
        }
        List<Customer_Authority_Form__c> ppvCafList = [select Customer_Authority_Form__c,Account__c,Contact__c,Opportunity__c,MSISDN__c FROM Customer_Authority_Form__c WHERE Customer_Authority_Form__c IN :newMap.keyset() order by createdDate DESC];
        //Kalashree Borgaonkar. Removed SOQL in for loop
        Map<String,List<Customer_Authority_Form__c>> ppvCafMap ;
        if(!ppvCafList.isEmpty()){
            ppvCafMap=getCAFmap(ppvCafList);
        }
        System.debug('ppvCafMap: '+ppvCafMap);
        if(newMap !=null && oldMap !=null && ppvCafMap!=null){
            setPpvMap(newMap,oldMap,ppvCafMap);
            List<String> ppvStatusList = new List<String> {Label.ppv_success,Label.ppv_failure};
                map<String,String> mapLabel = getStatusValue(ppvStatusList);
            List<Customer_Authority_Form__c> cafPpvList=new List<Customer_Authority_Form__c>();
            for(Customer_Authority_Form__c ppvUpdate : ppvMap.values()){
                ppvUpdate.PPV_status__c = mapLabel.get(Label.ppv_success);
                ppvUpdate.Customer_Authorised_Time__c=String.valueOf(System.Now().format('hh:mm a'));//Added as part EDGE-149258
                
                cafPpvList.add(ppvUpdate);
                
            }
            System.debug('ppvMap: '+ppvMap);
            System.debug('ppvMapUnverified: '+ppvMapUnverified);
            for(Customer_Authority_Form__c ppvUpdate : ppvMapUnverified.values()){
                ppvUpdate.PPV_status__c = mapLabel.get(Label.ppv_failure);
                ppvUpdate.Customer_Authorised_Time__c=String.valueOf(System.Now().format('hh:mm a'));//Added as part EDGE-149258
                cafPpvList.add(ppvUpdate);
                
            }
            if(!ppvMap.keyset().isEmpty()){
                newcaf = ppvMap.values();
                if(!newcaf.isEmpty() && !newcaf.isEmpty()){
                    //EDGE-145845 - Kalashree Borgaonkar. Production incicdent
                    PpvComponentController.removePortinFromReservationPool(newcaf[0].Account__c,newcaf[0].Opportunity__c);  //Kalashree Borgaonkar - Fix for Production incident-start
                    detailWrapper=PpvComponentController.addToReservationPool(newcaf[0].Account__c,newcaf[0].Opportunity__c,newcaf[0].MSISDN__c,caf[0].Status__c);
                    postChattertNotification(detailWrapper,newMap,newcaf[0].Contact__c,caf[0].Status__c);
                } 
            }
            if(!ppvMapUnverified.keyset().isEmpty()){
                unverify_newcaf = ppvMapUnverified.values();
                if(!unverify_newcaf.isEmpty() && !unverify_newcaf.isEmpty()){
                    //EDGE-145845 - Kalashree Borgaonkar. Production incicdent 
                    PpvComponentController.removePortinFromReservationPool(unverify_newcaf[0].Account__c,unverify_newcaf[0].Opportunity__c);  //Kalashree Borgaonkar - Fix for Production incident-start
                    detailWrapper=PpvComponentController.addToReservationPool(unverify_newcaf[0].Account__c,unverify_newcaf[0].Opportunity__c,unverify_newcaf[0].MSISDN__c,caf[0].Status__c);
                    postChattertNotification(detailWrapper,newMap,unverify_newcaf[0].Contact__c,caf[0].Status__c);
                }
            }
            System.debug('cafPpvList: '+cafPpvList);
            if(!cafPpvList.isEmpty()){
                update cafPpvList;
            }	  
        }    
    }
    /*-------------------------------------------------------- 
EDGE-132716
Method: onAfterCASigned
Description: Method to trigger PPV callout when signed form is generated
Author:Kalashree Borgaonkar
--------------------------------------------------------*/ 
    public static void onAfterCASigned(Map<Id,Customer_Authority_Form__c> newMap,Map<Id,Customer_Authority_Form__c> oldMap){
        map<id,Customer_Authority_Form__c> cafIds = new map<id,Customer_Authority_Form__c>();
        String oppoId;
        Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        for(ID key :newMap.keyset()){
            if(newMap.get(key).CA_signed__c != oldMap.get(key).CA_signed__c && newMap.get(key).CA_signed__c == true && newMap.get(key).Type__c=='Mobile'){
                cafIds.put(newMap.get(key).id,newMap.get(key));
                oppoId=newMap.get(key).Opportunity__c;
            }  
        }
        
        
        System.debug('cafIds: '+cafIds);
        if(!cafIds.keyset().isEmpty()){
            String cafid;
            String msisdn;
            Date custAuthDate;
            for(String ids: cafIds.keyset()){
                cafid=ids;
                msisdn = cafIds.get(ids).MSISDN__c;
                custAuthDate = cafIds.get(ids).Customer_Authorised_date__c;
                break;
            }
            system.system.debug('custAuthDate=='+custAuthDate);
            List<cscfga__Product_Basket__c> basket = [SELECT id,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c=:oppoId AND Primary_Basket__c=true];
            //EDGE-149259-Aishwarya-Ability to regenerate CA form for port in order.
            if(!basket.isEmpty() && (basket[0].csordtelcoa__Basket_Stage__c =='Enriched' || basket[0].csordtelcoa__Basket_Stage__c =='Submitted')){
                CaFormFileUploadController.updateCaDateInServiceForRegenrateCaForm(basket[0].id,custAuthDate,label.PortinOrder);     
            }
            String caid = PpvCallout.createPPVrecord(cafid,msisdn);
            PpvCallout.ppvCalloutFromTrigger(cafid);
        }
    }
    
    //EDGE-100327 Method to send notification to user
    public static void postChattertNotification( PpvComponentController.PpvWrapper detailWrapper,Map<Id,Customer_Authority_Form__c> newMap,String ContactId,String Status){
        String chatterBody;
        List<Customer_Authority_Form__c> caf=new List<Customer_Authority_Form__c>();
        for(ID key :newMap.keyset()){
            caf.add(newMap.get(key));
        }
        List<cscfga__Product_Basket__c> basket = [SELECT id,Name,cscfga__Opportunity__c ,cscfga__Opportunity__r.OwnerId FROM cscfga__Product_Basket__c WHERE id=:detailWrapper.basketId];
        List<Contact> con = [SELECT id,Name FROM Contact WHERE Id =:ContactId];
        String currentDate=String.valueOf(System.Now().format('yyyy.MM.dd \'at\' hh:mm a'));
        if(!con.isEmpty() && !basket.isEmpty()){
            list<OpportunityTeamMember> lstOTM = new list<OpportunityTeamMember>([SELECT Id, UserId, OpportunityId, User.Name FROM OpportunityTeamMember WHERE OpportunityId =:caf[0].Opportunity__c 
                                                                                 AND User.Profile.Name NOT IN ('PRM Admin - Australia','PRM Community User - Australia')]);
             system.debug('lstOTM' +lstOTM);
            //EDGE-149258:Modified the chatter message.
            if(detailWrapper.isAdded == true && Status==Label.ppv_success){
                chatterBody='Pre-port verification (PPV) was successfully signed by ' + '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ con[0].id+'">'+con[0].Name +'</a>'  + ' on <b>'+ currentDate +'</b>. The requested port-in number(s) have now been added to the reservation pool. You can now proceed to basket '
                    + '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ basket[0].id+'">'+basket[0].Name +'</a>'+', perform enrichment and finalise the order.';
            }
            else if(Status==Label.ppv_failure){
                chatterBody='Pre-port verification (PPV) was either unsuccessful or rejected by ' +'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ con[0].id+'">'+con[0].Name +'</a>' + ' on <b> '+ currentDate +' </b>. Retrigger verification process on Number Management screen for basket '
                    + '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ basket[0].id+'">'+basket[0].Name +'</a>'+', after having conversation with customer.';
            
                
            } 
            //EDGE-149258:Send Chatter notifiaction to opportunity team members
            List<FeedItem> feedItemlist=new List<FeedItem>();
            for(OpportunityTeamMember otm:lstOTM){
                FeedItem post = new FeedItem();
                post.ParentId = otm.UserId;
                post.createdById=otm.UserId;
                post.Body = chatterBody ;
                post.IsRichText=true;
				feedItemlist.add(post);
               
            } 
           
              List<Account> acc = [SELECT Name ,OwnerId FROM Account WHERE Id =:caf[0].Account__c];
            if( basket[0].cscfga__Opportunity__r.OwnerId != acc[0].OwnerId){
                FeedItem accpost = new FeedItem();
                accpost.ParentId = acc[0].OwnerId;
                accpost.createdById=acc[0].OwnerId;
                accpost.Body = chatterBody ;
                accpost.IsRichText=true;
                feedItemlist.add(accpost);
                  
            }
            if(!feedItemlist.isEmpty()){
                 insert feedItemlist;
            }
            
            
            
        } 
    }
    //get map of customer Authority form 
    public static Map<String,List<Customer_Authority_Form__c>> getCAFmap(List<Customer_Authority_Form__c> ppvCafList){
        Map<String,List<Customer_Authority_Form__c>> ppvCafMap = new Map<String,List<Customer_Authority_Form__c>>();
        for(Customer_Authority_Form__c ppvCaf : ppvCafList){
            if(ppvCafMap.containsKey(ppvCaf.Customer_Authority_Form__c)){
                ppvCafMap.get(ppvCaf.Customer_Authority_Form__c).add(ppvCaf); 
            }
            else{
                ppvCafMap.put(ppvCaf.Customer_Authority_Form__c,new List<Customer_Authority_Form__c>{ppvCaf}); 
            }
        }
        return ppvCafMap;
    }
    
    public static void setPpvMap(Map<Id,Customer_Authority_Form__c> newMap,Map<Id,Customer_Authority_Form__c> oldMap,Map<String,List<Customer_Authority_Form__c>> ppvCafMap){
        for(ID key :newMap.keyset()){
            List<Customer_Authority_Form__c> ppv = ppvCafMap.get(key);
            if(newMap.get(key).Status__c != oldMap.get(key).Status__c && Label.ppv_success.equalsIgnoreCase(newMap.get(key).Status__c)){
                ppvMap.put(key,(!ppv.isEmpty())?ppv[0]:null);
            }
            else if(newMap.get(key).Status__c != oldMap.get(key).Status__c && Label.ppv_failure.equalsIgnoreCase(newMap.get(key).Status__c)){
                ppvMapUnverified.put(key,(!ppv.isEmpty())?ppv[0]:null);
            }
        }
    }
    /*-------------------------------------------------------- 
EDGE-90327
Method: getStatusValue
Description: Method to get relevant value from meta data 
Author:Kalashree Borgaonkar
--------------------------------------------------------*/    
    
    public static map<String,String> getStatusValue(List<String> responseCode){
        System.debug('responseCode: '+responseCode);
        map<String,String> mapLabel = new map<String,String> ();
        if(responseCode!=null){
            List<PpvStatus__mdt> statusMdt = [SELECT MapValue__c,PpvToolValue__c FROM PpvStatus__mdt WHERE PpvToolValue__c In :responseCode];
            if(!statusMdt.isEmpty()){
                for(PpvStatus__mdt ppvstatus:statusMdt){
                    mapLabel.put(ppvstatus.PpvToolValue__c,ppvstatus.MapValue__c);
                }
            }  
        } 
        return mapLabel;
    }
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-updateParentStatus
Description	-Method to update parent status
Author		-Kalashree
--------------------------------------------------------*/ 
    public static void updateParentStatus(Map<Id,Customer_Authority_Form__c> newMap,Map<Id,Customer_Authority_Form__c> oldMap){
        List<id> cafIds = new List<id>();
        Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        for(ID key :newMap.keyset()){
            if(newMap.get(key).status__c != oldMap.get(key).status__c  && newMap.get(key).Type__c=='PPV'){
                if(newMap.get(key).Customer_Authority_Form__c!=null){
                    cafIds.add(newMap.get(key).Customer_Authority_Form__c);
                }
            }  
        }
        System.debug('cafIds: '+cafIds);
        Map<id,Customer_Authority_Form__c> parentCaf = new Map<id,Customer_Authority_Form__c>([SELECT id,status__c,ppv_status__c,Customer_Authorised_Time__c FROM Customer_Authority_Form__c WHERE id IN :cafIds]);
        System.debug('parentCaf: '+parentCaf);
        if(!parentCaf.keyset().isEmpty()){
            for(Customer_Authority_Form__c child: newMap.values()){
                Customer_Authority_Form__c parent = parentCaf.get(child.Customer_Authority_Form__c);
                parent.status__c = child.status__c;
                parent.PPV_status__c = child.PPV_status__c;
                parent.msisdn__c = child.msisdn__c;
                //EDGE-149258:Upating ppv approve time on parent
                parent.Customer_Authorised_Time__c = child.Customer_Authorised_Time__c; 
            }
            update parentCaf.values();
        } 
        System.debug('parentCaf.values()'+parentCaf.values());
    }
    
}
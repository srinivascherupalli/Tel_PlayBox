global without sharing class RemainingamountdetailsHelper implements cssmgnt.RemoteActionDataProvider  {
    public class FieldSetMemberWrapperClass{
           
           public String configurationID 					 { get; set; }
           public String DMcatid 						 { get; set; }
        public String Durationremaining 						 { get; set;} 
            public String Chargeremaining 						 { get; set; }
            public String Subscriptionid 					     { get; set; }
    }
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
      Set<String> inputKey = inputMap.keySet();
      String  csvData ='Subscription ID,Instance ID,Status,Message\r\n';
      String basketId = (String)inputMap.get('GetBasket'); 
       List<String> Productspecification = new List<String>{'DMCAT_ProductSpecification_000623','DMCAT_ProductSpecification_001389','DMCAT_ProductSpecification_000420', 'DMCAT_ProductSpecification_001211','DMCAT_ProductSpecification_001455','DMCAT_ProductSpecification_001342','DMCAT_ProductSpecification_000622'};
        list<Orchestration_Technical__c> orch_list=new list<Orchestration_Technical__c>();
        list<Orchestration_Technical__c> orch_list1=new list<Orchestration_Technical__c>();
         list<Orchestration_Technical__c> orch_list2=new list<Orchestration_Technical__c>();
        Map<String, Object> returnMap = new Map<String, Object>();
        //Set<String> inputKey = inputMap.keySet();
        //String basketId = (String)inputMap.get('GetBasket'); 
        system.debug('basket id'+basketId);   
        orch_list=[select id ,Field_17__c,Field_20__c,Field_21__c,Field_24__c,Field_18__c,Field_26__c,Field_29__c from Orchestration_Technical__c where Field_19__c =:basketId and Field_29__c='Chatter sent to User'] ; 
              system.debug('Hi'+orch_list) ; 
        orch_list1=[select id ,Field_17__c,Field_20__c,Field_21__c,Field_24__c,Field_18__c,Field_26__c ,Field_29__c from Orchestration_Technical__c where Field_19__c =:basketId and Field_29__c IN ('Initiated','Accepted','Response Received from BDS')];
        system.debug('Hi'+orch_list1) ;
             if(!orch_list1.isEmpty()  && orch_list1 != Null ){
              String returnvalue=json.serialize('Message1');
              returnMap.put('GetBasket', returnvalue);
              return returnMap;
             }
            if(orch_list1.isEmpty() && orch_list.isEmpty()){
              String returnvalue1=json.serialize('Message2');
              returnMap.put('GetBasket', returnvalue1);
              return returnMap;
            }
        Integer counter =0;
        for(Orchestration_Technical__c rejected :orch_list){
            if(rejected.Field_24__c!='200' && rejected.Field_24__c!= Null){
                if(  rejected.Field_29__c =='Chatter sent to User'){
                csvData +=rejected.Field_17__c +','+rejected.Field_18__c+','+rejected.Field_24__c+','+rejected.Field_26__c+'\r\n';
                counter++;
                }
            }
              }
        if (counter>0){
            cscfga__Product_Basket__c basketdetails =   [ SELECT Id,CreatedById,Bakset_Number_Format__c FROM cscfga__Product_Basket__c WHERE id=:basketId];
     		String currentUserId=basketdetails.CreatedById;
            String Basketnumber =basketdetails.Bakset_Number_Format__c;
            ContentVersion version = new ContentVersion();
    		version.Title='Rejected Subscriptions';
    		version.PathOnClient = 'mahfile.csv';
			//String csvData = 'Subscription Name,Subscription Number,Service ID,Billing Account\r\nHandheld-Epic_1,SN-000235372,61474714986,700000730296\r\nHandheld-Epic_1,SN-000235373,61474714986,700000730297\r\n';
        //String base64Data = JSON.serialize(csvData);
    		version.VersionData = Blob.valueOf(csvData);
    		insert version;

    	// Insert a simple post
    	FeedItem post = new FeedITem();
        String feedMessage=' Failed to update the remaining term(s) and amount(s) in the CHOWN Incoming product basket {0}. Refer to the CSV attached for more details ';
 		List<String> params1 = new List<String>{'{'+Basketnumber+'}'};
		String parameterizedLabel1   =   String.format(feedMessage, params1);
    	post.body = parameterizedLabel1 ;
    	post.ParentID = currentUserId;
    	insert post;

    	// Associate the file with the post
    	FeedAttachment postAttachment = new FeedAttachment();
    	postAttachment.FeedEntityId = post.id;
    	postAttachment.Type = 'Content';
    	postAttachment.RecordId = version.id;
    	insert postAttachment;

      returnMap.put('GetBasket', Null);
           return returnMap;
            }
          list<cscfga__Product_Configuration__c> configu_list= new list<cscfga__Product_Configuration__c>();
          configu_list =[select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketId and cscfga__Product_Definition__r.product_Specification__c IN :Productspecification];
          system.debug('Hi'+configu_list);
          list<cscfga__Product_Configuration__c> configu_list1= new list<cscfga__Product_Configuration__c>();
          configu_list1=[select id,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c ,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c where csordtelcoa__Replaced_Product_Configuration__c =:configu_list ];
          Map <string ,String> subscriton= new Map <string ,String>();
          Map <string ,String> device= new Map <string ,String>();
               for(cscfga__Product_Configuration__c con :configu_list1){
                //for(cscfga__Product_Configuration__c con1 :configu_list){
                 //if(con1.csordtelcoa__Replaced_Product_Configuration__c== con.id){
                   
                  subscriton.put(con.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,con.csordtelcoa__Replaced_Product_Configuration__c);
                 system.debug('subcription'+subscriton);
                  device.put(con.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,con.cscfga__Product_Definition__r.product_Specification__c);
                   system.debug('subcription'+device);
                // }
                //}
              }
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
         Map <string ,FieldSetMemberWrapperClass> sub = new Map <string ,FieldSetMemberWrapperClass>();
        	
                for(Orchestration_Technical__c subrec :orch_list){
     Map<Orchestration_Technical__c,String> demo = new Map <Orchestration_Technical__c,String>();
                  if(subscriton.containsKey(subrec.Field_17__c)){
                    //demo.put(subrec,device.get(subrec.Field_17__c));
                    //system.debug('hi'+demo);
                    //sub.put(subscriton.get(subrec.Field_17__c),demo);
                    //system.debug('hi'+sub);
                   FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
                    //wrapper.configurationID=subscriton.get(subrec.Field_17__c);
                    wrapper.configurationID=subscriton.get(subrec.Field_17__c);
                    wrapper.Subscriptionid=subrec.Field_17__c;
                    wrapper.Durationremaining=subrec.Field_20__c;
                    wrapper.Chargeremaining=subrec.Field_21__c;
                    wrapper.DMcatid=device.get(subrec.Field_17__c);
                    system.debug(wrapper);	
                    sub.put(subscriton.get(subrec.Field_17__c),wrapper);
                    system.debug('hi'+sub);
					wrapperList.add(wrapper);
          system.debug(wrapperList);
          
          
                  }
                   
                }
                String data=json.serialize(wrapperList);      
           returnMap.put('GetBasket', data);
           return returnMap;
    }
    
    }
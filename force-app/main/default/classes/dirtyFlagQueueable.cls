/*********************************************************************************************************************************
 *Class Name      :   dirtyFlagQueueable

Test Class : dirtyFlagQueueabletest
===============================================================================================================================
1      Shubhi Vijayvergia/Ankit		28.07.2020		incident INC000093454566
*********************************************************************************************************************************/
public class dirtyFlagQueueable implements Queueable, Database.AllowsCallouts{
    public final List<Id> solIdList;
	public dirtyFlagQueueable(List<Id> solIdList){
        this.solIdList = solIdList;
    }  
    public void execute(QueueableContext context) {
        // This method will make a REST API call
        //Logger2 log = Logger2.getLogger(handlerName);
       try{
        system.debug('heap check before custom'+limits.getHeapSize());
        if (solIdList != null && solIdList.size()>0) {  
            List<Attachment> listOfAttToUpdate = new List<Attachment>();
            List<Attachment> originalattachmentList = [select id,name,body,BodyLength, ContentType,ParentId  from Attachment where ParentId =:solIdList];
            if(!originalattachmentList.isEmpty()){  
                for(Attachment att : originalattachmentList){ //Added this for..loop as part of EDGE-144681
                    String solutiondetail = att.body.toString();
                    List<Object> productdetailsmap = (List<Object>) JSON.deserializeUntyped(solutiondetail);
                    List<Object> productdetailsmapupdated = new List<Object>();
                    for(Object product : productdetailsmap){
                        Map<String,Object> configlsts = (Map<String,Object>) product;
                        Map<String,Object> configlstsupdated = new Map<String,Object>();
                        //System.debug(configlsts);
                        for(string Solutionlist : configlsts.keyset() ){
                            if(Solutionlist == 'dirty' && configlsts.get(Solutionlist) == true){
                                configlsts.remove((String)Solutionlist);
                                configlsts.put((String)Solutionlist,false);
                            }
                            //System.debug(configlstsupdated);
                            if(Solutionlist =='configurations'){
                                List<Object> configlsts1 = (List<Object>)configlsts.get(Solutionlist);
                                //System.debug(configlsts1);
                                for(Object attr: configlsts1){
                                    //System.debug(attr);
                                    Map<String,Object> config = (Map<String,Object>) attr;
                                    //System.debug(config);
                                    for(string rel : config.keyset()){
                                        //System.debug(rel);
                                        if(rel == 'dirty' && config.get(rel) == true){
                                            config.remove((String)rel);
                                            config.put((String)rel,false);
                                        }
                                        if(rel =='relatedProductList'){
                                            List<Object> config3 = (List<Object>)config.get(rel);
                                            //System.debug(config3);
                                            for(Object reletedAttr: config3){
                                                Map<String,Object> config4 = (Map<String,Object>) reletedAttr;
                                                //System.debug(config4);
                                                for(string rel4 : config4.keyset()){
                                                    //System.debug(rel4);
                                                    if(rel4 =='configuration'){
                                                        //System.debug(config4.get(rel4));
                                                        Map<String,Object> config5 = (Map<String,Object>) config4.get(rel4);
                                                        for(string rel5 : config5.keyset()){
                                                            //System.debug(rel5);
                                                            if(rel5 == 'dirty' && config5.get(rel5) == true){
                                                                config5.remove((String)rel5);
                                                                config5.put((String)rel5,false);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if(configlstsupdated != null){
                                configlstsupdated.put((String)Solutionlist,configlsts.get((String)Solutionlist));
                                //System.debug(configlstsupdated);
                            }
                        }
                        productdetailsmapupdated.add(configlstsupdated);
                    }
                    if(!productdetailsmapupdated.isEmpty()){
                        String solutionjson = JSON.serialize(productdetailsmapupdated);
                        att.Body = Blob.valueOf(solutionjson);
                        listOfAttToUpdate.add(att);  //Added as part of EDGE-144681
                    }
                    productdetailsmap.clear();
                    productdetailsmapupdated.clear();
                    system.debug('heap check before before custom DML'+limits.getHeapSize());
                }
                Update listOfAttToUpdate;  //Added as part of EDGE-144681
            }
        }
       }catch(Exception e){
            system.debug('heap check in the exception'+limits.getHeapSize());
           system.debug('exception---'+e.getMessage());
            //throw new Exception('Error Retrieving Records: '+ e.getMessage());
        }
    }
}
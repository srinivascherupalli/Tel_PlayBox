({
	//On init, get article urlName and read custom-metadata for setting visibility
    doInit : function(component, event, helper) {
        var mdt_record;
        var path =  window.location.pathname;
        var str = path.split("/");
        console.log('split',str); 
        var urlindex = JSON.parse($A.get("$Label.c.PRM_Feedback_Case_Flow_Name")).urlindex;
        component.set("v.articleUrlName",str[urlindex]);
		
        //Added by Team Hawaii for P2OB-9099
        var mailTo = "mailto:" + component.get("v.mailTo");
        component.set("v.mailTo",mailTo);
        
       //Call to apex method to query custom-metadata                                       
       var actionGetCustomMdt = component.get("c.getCustomMdt");
            actionGetCustomMdt.setParams({ urlName : str[urlindex] });
            actionGetCustomMdt.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                   mdt_record = response.getReturnValue();
                   component.set("v.mdt_record",mdt_record);
                   component.set("v.showFeedback",mdt_record.Show_Feedback_Component__c); 
                   component.set("v.showRaiseCase", mdt_record.Show_Raise_a_Case__c); // P2OB-8434 - Raise a Case 
                }
            });
            $A.enqueueAction(actionGetCustomMdt);
    },
    
    
    //Handler for vote-button, invokes screen-flow
    handleVoteButton : function(component, event, helper,voteType) {
        var inputVariables;
        var articleDetail = component.get("v.articleDetail");
        var mdt_record = component.get("v.mdt_record");
        var articleUrlName = component.get("v.articleUrlName");
        console.log('handle vote',articleDetail);
        if(articleUrlName != null && articleUrlName != undefined ){
        inputVariables = [
                                { name : "ArticleCategory1", type : "String", value: articleDetail.category1 != null ? articleDetail.category1 : ""},
								{ name : "ArticleCategory2", type : "String", value: articleDetail.category2 != null ? articleDetail.category2 : ""},
             					{ name : "ArticleURLname"  , type : "String", value: articleUrlName != null ? articleUrlName : ""}, 
        						{ name : "VoteType"  , type : "String", value: voteType != null && voteType > 0 ? "Up" : "Down"},
           						{ name : "WorkRequiredPRM"  , type : "String", value: mdt_record != null ? mdt_record.Value_for_Work_Required_on_case__c : "TPC Feedback"},
           				      ];
         }
            
        //Launch flow
        console.log('***prmKArticleFeedbackController:handleVoteButton:input variables:',inputVariables); 
        component.set("v.launchFlow", true);       
        var flow = component.find("flowData");
        var jsonVar = JSON.parse($A.get("$Label.c.PRM_Feedback_Case_Flow_Name")); 
        var flowName = jsonVar.flowname;
        if(flowName != undefined && flowName !=null && flowName != ''){
            flow.startFlow(flowName,inputVariables);
        }
    },
   
    //Handler to execute for pubSub upon event callback       
    handleEvent: function (component,payload) {
    	component.set("v.articleDetail",payload);
        //P2OB-9099 Added by Team Hawaii
        var categoryObject = component.get("v.articleDetail");
        var category1;
        var category2;    
        if(categoryObject != undefined && categoryObject!= null){
        	category1 = categoryObject.category1 != null ? categoryObject.category1 :'';
        	category2 = categoryObject.category2 != null ? categoryObject.category2 :'';
        }
        
        var categoryLabel = $A.get("$Label.c.PrmArticleCategory");
        var separateLabels=categoryLabel.split(",");
        console.log('label->'+separateLabels);
        
        if(separateLabels.includes(category1) || separateLabels.includes(category2)){
            	component.set("v.isCaseStudyVisible",true);
        }
        
}                    
    
})
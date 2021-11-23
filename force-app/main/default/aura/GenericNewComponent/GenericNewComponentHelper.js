({
    //Method called from click of lightning-button
    launchModal : function(component, event, helper) {
        console.log('GenericNewComponent handleClick called************',event,component,helper);
        var varFlowName = component.get("v.flowName");
        var modalBody;
        $A.createComponents([
            ["c:GenericNewComponentModal", {
                flowName: varFlowName
            }]
        ],
                            function(modalCmps, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    console.log('GenericNewComponent SUCCESS************');
                                    modalBody = modalCmps[0];
                                    component.find('overlayLib').showCustomModal({
                                        body: modalBody,
                                        showCloseButton: true,
                                        cssClass: "cGenericNewComponentModal",
                                        closeCallback: function() {
                                            console.log('modal closed!');
                                            component.set("v.isOpen", false);
                                        }
                                    });
                                } else if (status === "ERROR") {
                                    console.log('GenericNewComponent ERROR************', errorMessage);
                                }
                            }
                           )
    },
    //On init, check value of design parameters
    doInit : function(component, event, helper) {   
        component.set('v.isOpen', true);
        var buttonLabel = component.get("v.buttonLabel");
        console.log('buttonLabel',buttonLabel);
        if(buttonLabel == undefined || buttonLabel == null || buttonLabel == ''){
            var selectCmp = component.get('c.selectFlow');
            $A.enqueueAction(selectCmp);
        }
    },
    //On init, check URL of page from where the component is called
    parseURLhelper : function(component, event, helper) {
        console.log('***GenericNewComponent:parseURLhelper:path:',window.location.pathname);
        //Get Url of current page
        var path = window.location.pathname;
        //Read the regex from custom-label GenericURLRegex
        var urlParser = JSON.parse($A.get("$Label.c.GenericCMPUrlParser"));
        console.log('***GenericNewComponent:parseURLhelper:Regex from label:',urlParser.urlRegex,' ',urlParser.object,' ',urlParser.page);
        //Match path with regex
        var result = path.match(new RegExp(urlParser.urlRegex,'g'));
        console.log('***GenericNewComponent:parseURLhelper:result of URL match:',result);
        if(result == null || result === '') 
            result = 'no match';
        else{ 
            // Save the url-params into objectType and PageType
            var str = path.split('/');
            console.log(str[urlParser.object],str[urlParser.page]);
            component.set("v.objectName",str[urlParser.object]);
            component.set("v.pageType",str[urlParser.page]);
        }
    },
    //Depending on object and page identified fom URL, get flowName from custom-metadata
    selectFlowHelper :function(component, event, helper){
        var cmpName;
        var modalBody;
        //Call the method for identifying the objectName and pageType from URL
        var parseAction = component.get('c.parseURL');
        parseAction.setCallback(this, function(response1) {
            console.log('GenericNewComponent:selectFlowHelper:Object and Page identified'+component.get("v.objectName") ,component.get("v.pageType") );
            //Call to method in apex-class, for querying custom-metadata to get flowName 
            var actionGetCmpName = component.get("c.getCmpNameFromMetadata");
            actionGetCmpName.setParams({ sObjectName : component.get("v.objectName") , pageType : component.get("v.pageType"), keyPrefix : ''});
            actionGetCmpName.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    cmpName = response.getReturnValue();
                    component.set("v.flowName",cmpName);
                    console.log('GenericNewComponent:selectFlowHelper:flowName updated:',cmpName);
                }
            });
            $A.enqueueAction(actionGetCmpName);
        });
        $A.enqueueAction(parseAction);
    }
})
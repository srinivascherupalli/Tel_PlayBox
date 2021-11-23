({
   doInit: function (component, event,helper) {

               var action = component.get("c.init");
       component.set("v.spinner",true);
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                        component.set("v.spinner",false);
                        var result=response.getReturnValue();
                        result= JSON.parse(result);
                console.log('result.status'+result.status);

                if(result.hasBulkTagPermission==true)	{
                                component.set("v.hasBulktagPermission",result.hasBulkTagPermission);

                    }
                else if(result.hasBulkTagPermission==false){
                    helper.showToast("","",result.message);
                }
               
                if(result.status=='Queued' || result.status=='Preparing' || result.status=='Processing'  ){
                            helper.showToast("","",result.message);
                            component.set("v.Submitdisabled",true);
                            component.set("v.Uploaddisabled",true);

                }
            	}          
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }})
        
            $A.enqueueAction(action);

    },
    
    handleUploadFinished: function (cmp, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
    },
    handleFilesChange : function(component, event, helper) {
               component.set("v.spinner",true);
        console.log('Test handleFilesChange');
        var fileName = 'No File Selected..';
        var fileOutput = {};
        if (event.getSource().get("v.files").length > 0) {
            var file = event.getSource().get("v.files")[0];
            fileName = file['name'];
            var reader = new FileReader();

            reader.onload = function(e) {
                var contents = e.target.result;
                //fileOutput = JSON.parse(contents);
                //will display the file text in console
                console.log('test'+contents.split(/\r\n|\n/));
                var allTextLines = contents.split(/\r\n|\n/);
                var headers = allTextLines[0].split(',');
                
                var str=$A.get('$Label.c.PRM_BulkPartnerTaggingfileHeader');
                if(headers != str )
                {
                  helper.showToast("","error",$A.get('$Label.c.Bulk_Partner_Tag_FileNotAccepted'));
                    component.set("v.Submitdisabled",true);
                    component.set('v.filecontent', null);   
                    component.set("v.spinner",false);
                }
                else{
                var lines = [];
                console.log('allTextLines.length'+allTextLines.length);
                for (var i=1; i<allTextLines.length; i++) {
                    var data = allTextLines[i].split(',');
                    console.log('data.length'+data.length);
                    console.log('headers.length'+headers.length);

                    if (data.length == headers.length) {
                        var tarr = [];
                        for (var j=0; j<headers.length; j++) {
                            tarr.push(data[j]);

                        }
                       console.log('tarr'+tarr);

                        lines.push(tarr);
                    }
                }
                console.log('lines'+lines);
                console.log("contents"+contents.toString());

                
                component.set('v.filecontent', lines); 
                component.set('v.jsonFileText', contents.toString()); //JSON.stringify(contents)); 
                component.set("v.fileName", fileName);
                component.set("v.Submitdisabled",false);
                    
                    var cmpTarget = component.find('fileUploadMainSec');
                     var cmpTarget1 = component.find('fileUploadsubSec');
       				$A.util.removeClass(cmpTarget, 'slds-grid');
					$A.util.removeClass(cmpTarget, 'slds-grid_vertical-align-center');
                    $A.util.removeClass(cmpTarget, 'slds-grid_align-center');
                    $A.util.removeClass(cmpTarget1, 'slds-align_absolute-center');
                    $A.util.addClass(cmpTarget1, 'slds-grid');
                    $A.util.addClass(cmpTarget1, 'slds-grid_align-end');
                    $A.util.addClass(cmpTarget1, 'slds-p-right--large');
                    
                           component.set("v.spinner",false);

                    

            }
            }
  
            reader.readAsText(file);
        }
    },
    
    executePartnerTagging: function(component, event, helper) {
        console.log('executePartnerTagging');
        component.set("v.spinner",true);
        var action = component.get("c.readFile");        
        console.log("value"+component.get("v.jsonFileText"));
        action.setParams({ source : component.get("v.jsonFileText") });

            action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response'+response.getReturnValue());
            
             if (state === "SUCCESS") {
                 	component.set("v.spinner",false);
                	console.log(response.getReturnValue());
                    component.set("v.Submitdisabled",true);
                    component.set("v.Uploaddisabled",true);		
          		 	helper.showToast($A.get('$Label.c.Bulk_Partner_Tag_Success'),"success",$A.get('$Label.c.Bulk_Partner_Tag_Success_Instruction'));	
            }
           else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
    
    
})
({
    
    getAgreementSchedules:function(component, event, helper){
        
        var action = component.get("c.generateCSV");
        
        action.setParams({"parentAgreementId": component.get("v.agreementId") });//component.get("v.recordId")
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {              
                console.log('response==',response.getReturnValue());
                component.set("v.schedules", response.getReturnValue());
             
                var data = response.getReturnValue();
                helper.downloadCSV2(component, data);
                console.log('enter downloadCsv');
                
            }else if (state === "INCOMPLETE") {
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
            }
        });
        
        $A.enqueueAction(action);
    },
    
    downloadCSV2 : function(component, objectRecords){
		 var csvRows;  
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        var keys = ['Risk Id','Status', 'Area of Risk Impact', 'Risk Summary','Impact','Implications','Party Raising Risk','Inherent Risk Rating','Impact of Risk','Likelihood of Eventuation','Action Status'];        
        csvRows = 'Risk Id, Status, Area of Risk Impact , Risk Summary, Impact, Implications, Party Raising Risk, Inherent Risk Rating, Impact of Risk, Likelihood of Eventuation, Action Status,' + '\n';
        for(var i=0; i < objectRecords.length; i++){  
            console.log('objectRecords=='+objectRecords[i].agreementCategory);
            console.log('objectRecords=='+objectRecords[i].scheduleRecordType);
            console.log('objectRecords=='+objectRecords[i].status);
           csvRows +=  objectRecords[i].riskId + ',' + objectRecords[i].Status + ',' + objectRecords[i].AreaofRiskImpact + ',' + objectRecords[i].RiskSummary + ',' + objectRecords[i].Impact + ',' + objectRecords[i].Implications + ',' + objectRecords[i].PartyRaisingRisk + ',' + objectRecords[i].InherentRiskRating + ',' + objectRecords[i].ImpactofRisk + ',' + objectRecords[i].LikelihoodofEventuation + ',' + objectRecords[i].ActionStatus + '\n';

        }
        //return csvRows; 
         var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvRows);
        hiddenElement.target = '_self'; 
        hiddenElement.download = 'ExportData.csv';  
        document.body.appendChild(hiddenElement); 
        hiddenElement.click();      
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ "recordId": component.get("v.agreementId") });
        navEvt.fire();
	},
    
    downloadCsv : function(component,event,helper){
        

        console.log('enter inside downloadCsv');
        // get the Records [contact] list from 'ListOfContact' attribute 
        var schedules = component.get("v.schedules");
       console.log('schedules='+schedules);
        // call the helper function which "return" the CSV data as a String  
        console.log('enter convertArrayOfObjectsToCSV'); 
        var csv = helper.convertArrayOfObjectsToCSV(component,schedules); 
       console.log('csv'+csv);
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ "recordId": component.get("v.agreementId") });
        navEvt.fire();
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
	console.log('enter inside convertArrayOfObjectsToCSV');
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
            console.log('return null');
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Agreement Number','Record Type','Status Category','Status','Agreement Category', 'Agreement Subcategory' ];
        console.log('keys'+keys);
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            console.log('objectRecords.length'+objectRecords.length);
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
               
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                
                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                
                console.log('csvStringResult'+csvStringResult);
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    },
    
    splitURLparams: function(component){
        
        var decodedurl = decodeURIComponent(window.location.href);
        
        var splitedUrl = decodedurl.split("?");
        var paramlist = splitedUrl[1].split("&");
        var paramname = component.get("v.paramname");
         console.log('paramname='+paramname);
        var returnvalue;
        var paramnamevalue;
        var i;
        for(i=0; i<paramlist.length;i++){
            paramnamevalue = paramlist[i].split('=');
            if (paramnamevalue[0] === paramname) {
                returnvalue = paramnamevalue[1];
                break;
            }
        }
        
        return(returnvalue);
    }
    
})
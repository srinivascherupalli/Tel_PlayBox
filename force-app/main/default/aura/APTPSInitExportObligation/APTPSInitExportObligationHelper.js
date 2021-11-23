({
    
    getAgreementSchedules:function(component, event, helper){
       
        var action = component.get("c.generateCSV");
        
        action.setParams({"parentAgreementId": component.get("v.agreementId") });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {              
                console.log('response==',response.getReturnValue());
                component.set("v.schedules", response.getReturnValue());
             
                //helper.downloadCsv(component, event, helper);
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
        var keys = ['Obligation ID',	'Clause Name',	'Category', 'Sub-Category', 'Description', 'Next Due Date','Obligation Frequency','Comments','Responsible','Accountable','Consulted','Informed','Created By'];        
        csvRows = 'Obligation ID, Clause Name, Category, Sub-Category, Description, Next Due Date , Obligation Frequency, Comments, Responsible, Accountable, Consulted, Informed, Created By,' + '\n';
        
        for(var i=0; i < objectRecords.length; i++){  
            console.log('objectRecords=='+objectRecords[i].agreementCategory);
            console.log('objectRecords=='+objectRecords[i].scheduleRecordType);
            console.log('objectRecords=='+objectRecords[i].status);
            csvRows +=  objectRecords[i].Obligation_Id + ',' + objectRecords[i].Agreement_Clause + ',' + objectRecords[i].Category + ',' + objectRecords[i].Sub_Category + ',' + objectRecords[i].Description + ',' + objectRecords[i].Due_Date + ',' + objectRecords[i].Obligation_Frequency + ',' + objectRecords[i].Comments + ',' + objectRecords[i].Responsible + ',' + objectRecords[i].Accountable + ',' + objectRecords[i].Consulted + ',' + objectRecords[i].Informed + ',' + objectRecords[i].CreatedBy  + '\n';
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
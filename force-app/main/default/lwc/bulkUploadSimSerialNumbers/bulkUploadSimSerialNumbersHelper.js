import validateMobileNumbers from '@salesforce/apex/BulkUploadSimSerialNumbersCtrl.validateMobileNumbers';
import updateSimNumbers from '@salesforce/apex/BulkUploadSimSerialNumbersCtrl.updateSimNumbers';
export const helper = {
    validateAndUpload(cmp){
        cmp.fileReader = new FileReader();
        cmp.fileReader.onloadend = (() => {
            cmp.fileContents = cmp.fileReader.result;
            var base64Mark = 'base64,';
            var dataStart = cmp.fileContents.indexOf(base64Mark) + base64Mark.length;
            cmp.fileContents = cmp.fileContents.substring(dataStart);
            const fileArr = cmp.fileContents.trim().split("\r\n");
            fileArr.shift(); 
            if( fileArr.length > 500){
            this.fireCustomEvent(cmp,false,'Number of rows in the CSV file has exceeded the maximum limit.','Error',true);
            } else{
            var Emptyfound = fileArr.some(function(x) {
               return x.split(",").some(function(y) {
               return y == "";});
            });
            var EmptyfoundMessge='';
            if(Emptyfound){
            EmptyfoundMessge='Some or all key details (Mobile numbers, SIM Serial Numbers, Basket Id) are missing'; 
            }
              validateMobileNumbers({ uploadedData: fileArr }).then(data => {
                var validNumbers=true;
                let counter = 0;
                for (var outerIndex in data) {
                  for (var key in data[outerIndex]) {
                    var val = data[outerIndex][key];
                    if(key !== 'remove' && val.length >0){
                      validNumbers=false;
                      counter = counter + 1;
                    }
                  }
                }
                if(validNumbers && EmptyfoundMessge===''){
                  var i,j, temporary,uploaded, chunk = 100;
                  for (i = 0,j = fileArr.length; i < j; i += chunk) {
                  temporary = fileArr.slice(i, i + chunk);
                  updateSimNumbers({ uploadedData: temporary }).then(data => {
                    this.fireCustomEvent(cmp,false,'File Uploaded Successfully','Success',false);
                    })
                   }
                  }
                  if(!validNumbers || EmptyfoundMessge != '' ){
                    if(counter >5){
                    this.fireCustomEvent(cmp,false,'Please reverify CSV file and process again.','Error',true);
                    }else
                    {
                      var ErrorMessge='';
                      if(EmptyfoundMessge){
                      ErrorMessge+="1. "+ EmptyfoundMessge+"\n";
                      }
                      if(EmptyfoundMessge!='' & counter >0){
                        ErrorMessge += "2.";
                      }
                      if(counter >0){
                        ErrorMessge += "One or more mobile numbers are not associated to any plans. Please include the mobile numbers that are assigned to the plans under the basket "+(JSON.stringify(data)).replace('{','').replace('}','');
                      }
                    this.fireCustomEvent(cmp,false,ErrorMessge,'Error',true);
                    }
                  }
              });
            
          }
        });
    },
    fireCustomEvent(cmp,spinner,messge,messgetype,appendError){
        var errorMsg="File upload is unsuccessful due to the error(s) below. Please re-upload the pre-formatted CSV file to proceed.\n Error reason(s): \n";
        if(appendError){
          messge=errorMsg+messge;
        }
        const simuploadEvent = new CustomEvent('simbulkupload', {
          detail: {
          spinner: spinner,
          message: messge,
          type : messgetype
        }
      });
        // Fire the custom events
        cmp.dispatchEvent(simuploadEvent);
      }
}
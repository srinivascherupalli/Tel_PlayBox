import { LightningElement,track } from 'lwc';

export default class BulkUploadSimSerialNumbers extends LightningElement {
    acceptedFormats=".csv";
    filesUploaded = [];
    fileName;
    file;
    fileContents;
    fileReader;
    numberList = [];

    handleUploadFinished(event){
      this.fireCustomEvent(true,null,null,false);
        console.log('Inside handleUploadFinished',event.target.files.length);
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.file = this.filesUploaded[0];
            this.fileReader = new FileReader();
            this.fileReader.onloadend = (() => {
              this.fileContents = this.fileReader.result;
              var base64Mark = 'base64,';
              var dataStart = this.fileContents.indexOf(base64Mark) + base64Mark.length;
              this.fileContents = this.fileContents.substring(dataStart);
              
              const fileArr = this.fileContents.trim().split("\r\n");
              fileArr.shift(); 
              
              let arr1 = [];
              var numdata=[];
              var errorMessge='';
              if( fileArr.length > 500){
              this.fireCustomEvent(false,'Number of rows in the CSV file has exceeded the maximum limit.','Error',true);
              } else{
              var Emptyfound = fileArr.some(function(x) {
                
                const csvData = {num:x.split(",")[0],carrier:x.split(",")[1],accountNumber:x.split(",")[2]};
                numdata.push(csvData);
                 return x.split(",").some(function(y) {
                if(x.split(",").indexOf(y)==0)
                arr1.push(y);
                if(x.split(",").indexOf(y)!=1)
                return y == "";});
                 
              });
              
              this.numberList=numdata;
              let resultToReturn = false;
              resultToReturn = arr1.some((element, index) => { return arr1.indexOf(element) !== index });
              console.log('resultToReturn^^'+resultToReturn);
              if(resultToReturn){
                errorMessge+='\n One or more mobile numbers have already been uploaded to the same basket.';
              }
              if(Emptyfound){
                errorMessge+='\n Some or all key details (Mobile number, Incumbent Account Number) are missing.';
              }
              if( resultToReturn || Emptyfound)
              {
                this.fireCustomEvent(false,errorMessge,'Error',true);
              }else
              this.fireCustomEvent(false,'File Uploaded Successfully','Success',false);
            }
          });
          this.fileReader.readAsText(this.file);
        }
    };
    
    fireCustomEvent(spinner,messge,messgetype,appendError){
      var errorMsg="File upload is unsuccessful due to the error(s) below. Please re-upload the pre-formatted CSV file to proceed.\n Error reason(s): \n";
      if(appendError){
        messge=errorMsg+messge;
      }
      var data=[];
      if(messgetype=='Success'){
        data= this.numberList;
      }
      const portinuploadEvent = new CustomEvent('portinupload', {
        detail: {
        spinner: spinner,
        message: messge,
        type : messgetype,
        data: data
      }
    });
      // Fire the custom events
      this.dispatchEvent(portinuploadEvent);
    }
}
/*
* P2OB - 11853 : LWC Component to let user add numbers for PPV
* Created By   : Team Hawaii : Ritika Jaiswal
*/
import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PRM_PPV_InputNumbers extends NavigationMixin(LightningElement) {



    file;
    fileReader;
    content;


@track fileName = 'No File Selected';
@track index = 0;
@api totalNumbers;
@api recordId;
@api VerificationComplete = false;
@api fileUploaded = false;
@api numberList=[]; //List of numbers from file
@api manualList=[]; //List of numbers added manually
@api validationErrorIndex=[];
@api mobileNumberRegex = new RegExp(/^(61|0)(4)\d{8}$/);
@track FileList = [];

//This var is being used to display numbers on the screen

    @track itemList = [
        {
            id: 0,
            Phone : ''
        }
    ];


/*
* Method to add new manually-added number to cumulative list
 */
updateList(event){
var selectedItem = event.currentTarget;
var index1 = selectedItem.dataset.record;

if(selectedItem.value.length == 8){
    console.log('***Telstra:PRM_PPV_InputNumbers:new manual number:',selectedItem.value);
    this.itemList[index1].Phone = selectedItem.value;
    let temp_list = this.itemList.map(a => '614' + a.Phone);
    this.manualList=this.numberList.concat(temp_list);
    console.log('***Telstra:PRM_PPV_InputNumbers:cumulative number-list:',this.manualList);
    this.totalNumbers = this.manualList.length;
    }
}

/*
* Method to add new empty row for adding number manually
 */
addRow(event) {
++this.index;

        var newItem = [{ id: this.index , Phone : ''}];
        this.itemList = this.itemList.concat(newItem);       
    }


/*
* Method to delete new empty row from UI
 */

    removeRow(event) {
        var selectedItem = event.currentTarget;
        var index1 = selectedItem.dataset.record;
        this.itemList.splice(index1, 1);
    }


/*
* Method to handle uploading of numbers from file
 */

    handleUploadFinished(event) {
        this.fileName = event.detail.files[0].name;
        let csvFile = event.detail.files;        
        let newPromise = new Promise((resolve, reject) => {
            var reader = new FileReader();
            reader.onload = function () {
                resolve(reader.result);
            };
            reader.readAsText(csvFile[0]);
        })
            .then(result => {

        //Convert file-Contents to list of mobile-numbers
        this.csvString = result;
        this.numberList = this.csvString.split('\r\n');
        
        //Remove first row which is column-name
        if(isNaN(this.numberList[0]))
            this.numberList.shift(); 
        
        //Clean file to remove white-space characters
        this.removeWhiteSpace();

        //Validate numbers in file
        this.validateFileNumbers();
        
        //Merge the file contents with manually added numbers
        this.addFileToItemList();  

        //Return total list of numbers to calling Flow
        this.totalNumbers = this.manualList.length;
    })
    .catch(error => {
        console.log('***Telstra:PRM_PPV_InputNumbers:Error:',error.message.body);
    });
}

/*
* Method to display toast
*/
showNotification(_title, _message, _variant) {
const evt = new ShowToastEvent({
    title: _title ,
    message: _message ,
    variant: _variant ,
});
this.dispatchEvent(evt);
}

/*
* Method to validate numbers from uploaded file and present invalid numbers
*/
validateFileNumbers(){
this.validationErrorIndex=[];
for(var index=0;index<this.numberList.length;index++){       
    var result = this.mobileNumberRegex.test(this.numberList[index]);
    if(result == false){
        this.validationErrorIndex.push(index+2);
    }
}
if(this.validationErrorIndex.length > 0){
    this.showNotification('Invalid Numbers!','Uploaded file has invalid mobile numbers at these rows: '+this.validationErrorIndex,'error');
    this.VerificationComplete = false;
    this.fileUploaded = true;
}
else if(this.validationErrorIndex.length == 0){
    this.showNotification('Success!','File Uploaded successfully','success');
    this.fileUploaded = true;
    this.VerificationComplete = true;
}
    
}

/*
* Method to clean up the file contents to remove empty spaces if any
*/
removeWhiteSpace(){
for(var i=0;i<this.numberList.length;i++){
    this.numberList[i] = this.numberList[i].replace(/\s/g, '');
    if (this.numberList[i] == "")
        this.numberList.splice(i--, 1);
}
}

/*
* Method to add file-list to manually-added list of numbers
*/

    addFileToItemList(){
            this.manualList=this.manualList.concat(this.numberList);
            this.manualList = this.manualList.filter(function (el) {
                return (el != null && el != '' && el!= undefined);
              });
    }


disconnectedCallback() {
console.log('***Telstra:PRM_PPV_InputNumbers:Returning from LWC:',this.manualList,this.totalNumbers);    
}


}
/*
Story : EDGE-189351
Author: Kalashree Borgaonkar
 */
import { LightningElement , track , api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getServiceType from '@salesforce/apex/TransitionSelectContoller.getServiceType';
//import readCSV from '@salesforce/apex/TransitionSelectContoller.readCSVFile';
import saveFile from '@salesforce/apex/TransitionSelectContoller.saveCSVfile';
//Start of EDGE-198190 and EDGE-198196 by Abhishek From Osaka Team
import profileAndProductCheck from '@salesforce/apex/TransitionSelectContoller.profileAndProductCheck';
import getCIDNDetails from '@salesforce/apex/TransitionSelectContoller.getCIDNDetails';
import transitionDisplay from '@salesforce/label/c.TransitionSelectDisplay';
import transitionNote from '@salesforce/label/c.TransitionHierarchyNote';
import showCIDNHeirarchy from '@salesforce/label/c.showCIDNHeirarchy';
import chownHardStop from '@salesforce/label/c.chownHardStop';
import chownSuccessMsg from '@salesforce/label/c.chownSuccessMsg';
import transitionHierarchyNoteNguc from '@salesforce/label/c.transitionHierarchyNoteNguc';
import Is_Osaka_Dormant_21_09 from '@salesforce/label/c.Is_Osaka_Dormant_21_09';
//import mtm_Legacy_Product_hardstop from '@salesforce/label/c.mtm_Legacy_Product_hardstop';
//import mtm_tipt_sipc_hardstop  from '@salesforce/label/c.mtm_tipt_sipc_hardstop';
//End of EDGE-198190 and EDGE-198196 by Abhishek From Osaka Team
//import ExistingServiceIds from '@salesforce/apex/csvUploaderHelper.ExistingServiceIds';
//import fileValidations from '@salesforce/apex/TransitionSelectContoller.fileValidations';
//import uploadAuthorization from '@salesforce/apex/TransitionSelectContoller.uploadAuthorization';
import uploadAuthorization from '@salesforce/apex/TransitionSelectContoller.uploadAuthorization';
import missingAuthorization from '@salesforce/apex/TransitionSelectContoller.missingAuthorization';
import cidnsInHierarchy from '@salesforce/apex/TransitionSelectContoller.cidnsInHierarchy';
import fetchProductFamily from '@salesforce/apex/TransitionSelectContoller.fetchProductFamily'; //EDGE-218061

export default class TransitionSelect extends LightningElement {
    
    @track serviceName='';
    @track retrievalMethod;
    @track showBulkUpload=false;
    @api accountid;
    @api basketid;
    @track basketname;
    @track isNextDisabled=true;
    @track responseReceived=false;
    //START OF EDGE-189357 by Abhishek from Osaka Team
    @track isModalOpen = false;//flag to handle Modal Window
    @track isHardStop = false;
    @track isWarning = false;
    @track nextFlag = false;//flag to handle validations on click on Next button
    @track message = '';//to display error message on Modal window
    //END OF EDGE-189357 by Abhishek from Osaka Team
    @track powerbiURL;
    @track fileName = '';
    @track UploadFile = 'Upload CSV File';
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    @track data;
    @api recordId;
    @track error;
    @track fileuploadStatus;
    // Start of EDGE-198138 by  Jay from Osaka 
    @track duplicateData = '';
    @track isDupliacte = false;
    @track isUploaded = false;
    //End of EDGE-198138 by  Jay from Osaka
    //START OF EDGE-198190 By Abhishek from Osaka Team
    @track profileProdCheck;
    @track isCidnSelection;
    @track radioSelectedValue;
    @track accountCIDN;
    @track accountName;
    @track isCidnHierarchy = false;
    @track cidnOptions;
    objects = [];
    products = [];
    @track defaultRadioValue = 'defaultCidn';
    selectedCIDNs = [];
    selectedListOfCidn = [];
    returnedMapValues = [];
    fileData;
    @track displayMsg;
    // Start of EDGE-198192 by  Jay from Osaka 
    @track max_length = 4194304;
    newUploadedFiles;
    uploadedContent;
    uploadedFileName;
    uploadedFileContents =[];
    showLoadingSpinner = false;
    LoadingSpinner = false;
    @track fileNames = '';
    @track newFilesUploaded = [];
    @track opportunityId;
    duplicateMsg =' ';
    @track isDuplicateFiles = false;
    @track allFilesUploaded = false;
    @track missingChown ='';
    isMissingChown = false;
    @track isChownModel = false;
    showAuthorization = false;
    @track isValidateDisabled = true;
    cidnListInFile = [];
    @track isSaveDisabled = false;
    @track maxLengthError = false;
    @track contentFilesLength;
    @track isFileSaved = false;
    @track isSavedDisabled = true;
    @track isOsaka2109Dormant ='';
    @track isOsakaDormantFor2109 = false;
    
    //End of EDGE-198192 

    //Start of DIGI-5034
    @track showPlanConfiguration = false;
    @track SelectedPlanConfig; 
	@track isAutomaticMode = false;
    @track sioConfigMode;
    @track isOsakaDormantFor2112 = false;
    @track dormantValue = '';
    //End of DIGI-5034

    customLabel = {
        transitionDisplay,
        transitionNote,
        showCIDNHeirarchy,
        transitionHierarchyNoteNguc,//Added as a part of EDGE-209886 by Abhishek(Osaka)
        chownHardStop, //Added 
        chownSuccessMsg,
        Is_Osaka_Dormant_21_09
        /*Start of DIGI-1754:- Added by Jay(Osaka)
        mtm_tipt_sipc_hardstop,
        mtm_Legacy_Product_hardstop
        End of DIGI-1754*/
    };
    //END OF EDGE-198190 By Abhishek from Osaka Team

    //Start of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)
    @track productFamily;
    @track isMobile;
    @track isNguc;
    @track isIoT;
    //End of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)
    @track selectedProdFamily = [];
    
    @track isSinglefamily;
    @track singleProductFamily;
    //Start of DIGI-1754
    @track isLegacyProductError = false;
    @track selectedListOfproduct =[];
    //End of DIGI-1754
    connectedCallback(){
       
        if(Is_Osaka_Dormant_21_09 =='true'){
            console.log('inside custom label if ');
            this.isOsakaDormantFor2109 = true;
        }
        
        console.log('Osaka dormant ', this.isOsakaDormantFor2109 );
        this.getDetails(this.basketid);
        //Start of EDGE-198190 and EDGE-198196: Added by Abhishek from Osaka Team
        this.profileProductCheck(this.basketid);
        this.getCidnOptions(this.basketid);
        //End of EDGE-198190 and EDGE-198196: Added by Abhishek from Osaka Team
       
        
    }
   
    getDetails(){  
        //this.basketid  ='a3Q2N0000002Sjb';  
        console.log("basketId: ",this.basketid );
        getServiceType({
            basketid: this.basketid  
        })
        .then(result => {
            this.accountid = result.accountId;
            this.basketname = result.basketNumber;
            this.serviceName = result.serviceType;
            this.responseReceived=true;
            this.powerbiURL = result.powerbiURL;
            //Start of EDGE-198190: Added by Abhishek(Osaka) for populating on selection of On-Screen retreival
            this.accountCIDN = result.accountCIDN;
            this.accountName = result.accountName;
            //End of EDGE-198190: Added by Abhishek(Osaka) for populating on selection of On-Screen retreival
            this.opportunityId = result.opportunityId;// Added by Jay EDGE-198192
            //Start of EDGE-209886 by Abhishek(Osaka) 
            this.productFamily = result.productFamily;
            console.log('Product Family Response : '+this.productFamily);
            if(this.productFamily!= '' || this.productFamily != null){
                //Added by Pradeep(Osaka) for EDGE-218061: Fetching the values for Product Family.
                this.getproductFamilyOptions(this.productFamily) 
                if(this.productFamily == 'Product_Family_for_Mobile'){
                    this.isMobile = true;
                }
                else if((this.productFamily == 'Product_Family_for_ngUc')){
                    this.isNguc = true;
                }else if((this.productFamily == 'Product_Family_For_IoT')){
                    this.isIoT = true;
             }   
            }
            this.dormantValue = result.isDormant;
            console.log('dormantValue ', this.dormantValue);
            if(this.dormantValue == 'true'){

                this.isOsakaDormantFor2112 = true;
            }
            console.log('isProdConfigDisable ', this.isOsakaDormantFor2112);
            //End of EDGE-209886 by Abhishek(Osaka) 
            console.log(' rresult', result);
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
    }
    
    get options() {
        return [
            { label: 'Bulk CSV upload', value: 'bulkUpload' },
            { label: 'On-screen retrieval', value: 'onScreen' },
        ];
    }
    
    onRetrievalChange(event){ 
        this.retrievalMethod = this.value = event.detail.value;
        this.isNextDisabled = false;
        
        if(this.retrievalMethod=='bulkUpload'){
            console.log('outside showCIDNHeirarchy');
            this.showBulkUpload=true;
            this.isCidnHierarchy = false; //Added by Abhishek(Osaka) for EDGE-198196 :Hide the radio Buttons on Bulk-Upload
            this.selectedCIDNs = [];
            // Custom lebel driven switch for enabling CIDN hierarchy 
            if(showCIDNHeirarchy == 'true'){
            console.debug('inside showCIDNHeirarchy');
            // EDGE-217614 - Added condition  by Jay:-  to show approval buttons for Sales and Assurance profiles

            //EDGE-209986 :Added product Family condition to restrict Authorization only for Mobile by Abhishek(Osaka)
            if(this.profileProdCheck == true /*&& this.productFamily == 'Mobile'*/){
                this.showAuthorization = true; // Added by Jay for EDGE-198192
                this.isNextDisabled = false;// Added by Jay for EDGE-198192
                this.showValidate = true; // Added by Jay for EDGE-198192
            }
            }
        }
        else{
           
            this.showBulkUpload=false;
            this.showValidate = false; // Added by Jay for EDGE-198192
            this.showAuthorization = false; // Added by Jay for EDGE-198192\
            this.showPlanConfiguration = false;

        }
        console.log("on Retrieval change", this.retrievalMethod );
        if(this.retrievalMethod=='onScreen' && this.profileProdCheck == true){
            this.defaultRadioValue = 'defaultCidn';
            this.isCidnSelection = true;
            //this.showAuthorization = true; // Added By Jay as a part of EDGE-198192
        }
        else{
            this.isCidnSelection = false;
        }
         //Added condition for Migration Scenario to show radio buttons as a part of DIGI-5034
         if(this.serviceName == 'Migration'){
             console.log('Migration Scenario applicable for both');
            this.showPlanConfiguration = true;
            
        }else{
            this.showPlanConfiguration = false;
        }
         //End of DIGI-5034
    }
    handleNext(){  
        
        console.log('handleNext called ');
        //Start of EDGE-198192: Added by Jay(Osaka):- Used to check the missing attachment and call the handleNewNext
        this.handleMissingChown();
        console.log('Missing chown in Next ', this.missingChown);
        //End of EDGE-198192
    }
    //EDGE-194266. Kalashree Borgaonkar. Common method for dispatching event
    //EDGE-198196- Added 'selectedHierarchialCIDN' and 'isHierarchy' in the existing event.
    createNextEvent(){
        if(this.isCidnHierarchy == true){
            console.log('Inside custom event');
            this.getSelectedCIDNSList();
        }
        console.log('sioConfigMode in createNextEvent ', this.sioConfigMode);
        const handleNextEvent = new CustomEvent('handleNext', 
        {
            detail: { isBulkUpload : this.showBulkUpload,
                    selectedHierarchialCIDN : this.selectedListOfCidn,
                    isHierarchy : this.isCidnHierarchy,   
                    productFamily : this.selectedProdFamily,
                    sioConfigMode : this.sioConfigMode}
            
        });
        this.dispatchEvent(handleNextEvent);
    
    }
    //Start of EDGE-198192: Added by Jay(Osaka):-  All existing logic of handleNext is added in handleNewNext (New method)
    handleNewNext(){

        if(this.showBulkUpload == true && (this.data == 'file uploaded successfully.' || this.fileName == '' || this.data.match(/^\d/))){
            console.log('Inside next block');
            this.nextFlag = true; 
            saveFile({ base64Data: JSON.stringify(this.fileContents),basketId:this.basketid, nextFlag:this.nextFlag})
        .then(result => { 
            window.console.log('result ====> '); 
            window.console.log(result);
            if(result !== null && result !== ''){
                console.log('Inside not Null');
                if(result.includes('multiple')){
                    this.isModalOpen = true;
                    this.isDupliacte = false;
                    //hardStop and isWarning are used to handle visiblity of 'OK' and 'Close' button on Modal popup
                    this.isHardStop = false;
                    this.isWarning = true;
                    this.message = result;
                    this.nextFlag = false;
                }
                else{
                    this.isModalOpen = true;
                    this.isWarning = false;
                    this.isHardStop = true;
                    this.message = result; 
                    this.nextFlag = false;                    
                }     
            }
            else{
                console.log('Inside Null');
                this.showBulkUpload = false;
                this.createNextEvent();
            } 
    
        }) 
        .catch(error => {
            window.console.log(error);   
        });
        
        }
        
        else{
            //Added by Jay(Osaka) as part of DIGI-1754
            this.getSelectedProductList();
            console.log('Selected Prod New List ',this.selectedListOfproduct);
            console.log('Selected Prod New List size ',this.selectedListOfproduct.length);
                console.log('inside last next event block');
                /*if(this.selectedListOfproduct.length == 0){
                    this.isLegacyProductError = true;
                //End of DIGI-1754
                }*/
                if(this.selectedListOfproduct.length == 0 && this.profileProdCheck == true && Is_Osaka_Dormant_21_09 =='false'){
                    this.isLegacyProductError = true;
                //End of DIGI-1754
                }
                else{
                    console.log('Inside Next Else');
                    this.isLegacyProductError = false;
                    this.createNextEvent();
                }
            
        }
       } 
//End of EDGE-198192

    closeModal(event){
        this.isModalOpen = false;
        this.isChownModel = false;
    }
    submitDetails(event){
        this.showBulkUpload = false;
                const handleNextEvent = new CustomEvent('handleNext', 
        {
            detail: { isBulkUpload : this.showBulkUpload }
        });
        this.dispatchEvent(handleNextEvent);
        this.isModalOpen = false;
    }
    //END OF EDGE-189357 by Abhishek From Osaka team
    get acceptedFormats() {
        console.log('Inside acceptedFormats');
        return ['.csv'];
    }
    
    handleFilesChange(event) {
        console.log('Inside handleFilesChange');
        if(event.target.files.length > 0) { 
            this.filesUploaded = event.target.files; 
            this.fileName = event.target.files[0].name; 
            this.uploadHelper();
        }
        //this.duplicateServiceIds(); 
    }
    uploadHelper() {

        this.file = this.filesUploaded[0]; 
       if (this.file.size > this.MAX_FILE_SIZE) { 
            window.console.log('File Size is to long'); 
            return ; 
        }
 
        this.showLoadingSpinner = true;
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => { 
            this.fileContents = this.fileReader.result; 
            this.saveToFile(); 
            this.handleMissingUpload();
        });
        this.fileReader.readAsText(this.file); 
    }

    saveToFile() {
        var reg = new RegExp('^[0-9]+$');
        console.log('regular expression ', reg);
        console.log('inside saveToFile');
        console.log(JSON.stringify(this.fileContents));
        saveFile({ base64Data: JSON.stringify(this.fileContents),basketId:this.basketid, nextFlag:this.nextFlag}) 
        .then(result => { 
            window.console.log('result ====> '); 
            window.console.log(result); 
            this.data = result;
            this.fileName = this.fileName + ' - ' + result; 
            this.isTrue = false; 
            this.showLoadingSpinner = true;
			// Start of EDGE-198138 by  Jay from Osaka 
            if(result.match(/^\d/) || result.startsWith('N')){
                console.log('inside model window condition');
				this.isModalOpen = true;
                this.isDupliacte = true;
                this.isHardStop = true;
                this.duplicateData = result;
                console.log('duplicateData' + this.duplicateData);
            // End of EDGE-198138 by  Jay from Osaka
			}else{
                console.log('model widow is not called');
            if(result.includes('successfully')){
                this.fileuploadStatus = true;
                //this.isNextDisabled = false;
            }else{
                console.log('Error Else');
                this.fileName = 'Error: ' + this.fileName ;                 
                this.fileuploadStatus = false;
                
                //this.isNextDisabled = true;
            }

			}
            
        })
 
        .catch(error => {
            window.console.log(error); 
            this.dispatchEvent( 
                new ShowToastEvent({ 
                    title: 'Error while uploading File', 
                    message: error.message, 
                    variant: 'error', 
                }),
 
            );
 
        });
    }

    //Start of EDGE-198190 and EDGE-198196 by Abhishek(Osaka)
    profileProductCheck(){
        console.log('basket Id in profileProductCheck ', this.basketid);
        profileAndProductCheck({
            basketId: this.basketid  
        })
        .then(result => {
            this.profileProdCheck = result;
            console.log('ProfileCheck', result);
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
    }

    
    handleSelectedRadio(event){
        this.radioSelectedValue = event.target.value;
        if(this.radioSelectedValue == 'cidnHierarchy'){
            this.isCidnHierarchy = true;
            this.showAuthorization = true; // Added by Jay for EDGE-198192
            this.isNextDisabled = true; // Added by Jay for EDGE-198192
            this.showValidate = true; // Added by Jay for EDGE-198192
            
            
        }
        else{
            this.selectedCIDNs = [];
            this.isCidnHierarchy = false;
            this.showAuthorization = false; // Added by Jay for EDGE-198192
            this.isNextDisabled = false; // Added by Jay for EDGE-198192
            this.showValidate = false; // Added by Jay for EDGE-198192
        }
        console.log('Selected Value: '+this.radioSelectedValue);
    }
    
    get radioOptions() {
        if(showCIDNHeirarchy == 'true'){
            console.log('Inside Radio If');
        return [
            
            { label: 'Default (Target CIDN)', value: 'defaultCidn'},
            { label: 'CIDN Hierarchy', value: 'cidnHierarchy' }
            
        ];
    }else{
        console.log('Inside default ');
        return [
            { label: 'Default (Target CIDN)', value: 'defaultCidn'},
        ];
    }
    }

    getCidnOptions(){
        console.log("basketId::: ",this.basketid );
        getCIDNDetails({
            basketid: this.basketid
        })
        .then(result=>{
            console.log('Inside Result');
            console.log('CIDN Values', JSON.stringify(result));
            var mapValues = [];
            this.returnedMapValues = result;
            mapValues = result;
                for(let value in mapValues){
                    console.log('Values:::' +value);
                    const option = {
                        label : String(value),
                        value : String(mapValues[value])
                    };
                    this.objects = [...this.objects, option];
                        
                }
        })
        .catch(error => {
            this.error = error;
            console.log('Error Test: '+ JSON.stringify(this.error));
        })
    }
    selectedValueChange(event){
        console.log('Inside selected Value');
        this.selectedCIDNs = event.detail;
        if(this.selectedCIDNs != null && this.selectedCIDNs.length>0 && this.isCidnSelection == true){
            this.displayMsg = true;
            this.isNextDisabled = false;

        }
        else{
            console.log('Inside selected Value else');
            this.displayMsg = false;
            this.isNextDisabled = true;
            this.isMissingChown = false;
        }
        console.log('Selected CIDNS::' +this.selectedCIDNs);
        
    }
    //End of EDGE-198190 and EDGE-198196 by Abhishek(Osaka)
 
    getSelectedCIDNSList(){
        this.selectedListOfCidn = [];
        for(var i = 0; i < this.selectedCIDNs.length; i++){
            let listValue = this.selectedCIDNs[i];
            var cidnValue = this.returnedMapValues[listValue];
            this.selectedListOfCidn.push(cidnValue);
        }
        console.log('List to send::' +this.selectedListOfCidn);
    }
    
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.csv', '.txt'];
    }
    //Start of EDGE-198192: Added by Jay(Osaka):- Ability for users to upload the consent email/CHOWN web form for CIDN hierarchy transition
    handleUploadFinished(event) {
        let files = event.target.files;
        this.isFileSaved = false;
        this.allFilesUploaded = false;
        this.isMissingChown = false;
        if (files.length > 0) {
            let filesName = '';

            for (let i = 0; i < files.length; i++) {
                let file = files[i];

                filesName = filesName + file.name + ',';

                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,';
                    let content = freader.result.indexOf(base64) + base64.length;
                    console.log('base 64 contest ', content);
                    let fileContents = freader.result.substring(content);
                    console.log('fileContents ', fileContents);
                    this.newFilesUploaded.push({
                        Title: file.name,
                        VersionData: fileContents
                    });
                };
                freader.readAsDataURL(file);
            }

            this.fileNames = filesName.slice(0, -1);
        }
        this.contentFilesLength = files.length;
    }

    handleSaveFiles() {
        console.log('handleSaveFiles called ');
        //this.isSaveDisabled = true;
        //Reset the msg for duplicate CIDNs
        this.duplicateMsg = '';
        var newFilesUploadedStringifyLength = '';
        newFilesUploadedStringifyLength = JSON.stringify(this.newFilesUploaded);
        if(this.newFilesUploaded.length > 0){
            if(newFilesUploadedStringifyLength.length < this.max_length){
            this.LoadingSpinner = true;
            this.isMissingChown = false; 
            console.log('this.LoadingSpinner first Occurance  ', this.LoadingSpinner);
        uploadAuthorization({filesToInsert: this.newFilesUploaded, opportunityId: this.opportunityId})
        .then(result => {
            if(result != ''){
                this.maxLengthError = false;
                this.isDuplicateFiles = true;
                this.isChownModel = true;
                this.isWarning = true;
                //this.isHardStop = true;
                this.duplicateMsg  = 'The consent file(s) are already uploaded for' + result + '.';
                this.LoadingSpinner = false;
                this.isSaveDisabled = false;
                this.isFileSaved = true;
            }else{
                this.allFilesUploaded = true;
                this.maxLengthError = false;
                newFilesUploadedStringifyLength = ''; 
                this.LoadingSpinner = false;
                this.isSaveDisabled = false;
                this.isFileSaved = true;
            }
            
        })
        .catch(error => {
            this.LoadingSpinner = false;
            const showError = new ShowToastEvent({
                title: 'Error!!',
                message: 'An Error occur while uploading the file.',
                variant: 'error',
            });
            this.dispatchEvent(showError);
        });
        
    }else{
        this.maxLengthError = true;
        this.allFilesUploaded = false;
        this.isDuplicateFiles = false;
    }
    }
    console.log('newFilesUploadedStringifyLength before ', newFilesUploadedStringifyLength.length);
    newFilesUploadedStringifyLength = ''; 

        console.log('newFilesUploadedStringifyLength after  ', newFilesUploadedStringifyLength.length);
        console.log('this.newFilesUploaded before ', this.newFilesUploaded);
        this.newFilesUploaded = [];
        console.log('this.newFilesUploaded after ', this.newFilesUploaded);
        
    }
    //Part of EDGE-198192: Added by Jay(Osaka):- Used to check the missing chown and call the handleNewNext
    handleMissingChown(){
        //console.log('Product family in handleMissingChown -->>  ', JSON.deserialize(this.selectedListOfproduct) + 'length ' + JSON.deserialize(this.selectedListOfproduct).length);
        this.getSelectedCIDNSList();
        console.log('Selected CIDNs in handleMissingChown ', this.selectedListOfCidn);
        this.handleMissingUpload();
        var selectedNewCidn = [];
        if(this.cidnListInFile != ''){
            selectedNewCidn = this.cidnListInFile;
        }else{
            selectedNewCidn = this.selectedListOfCidn;
        }
            missingAuthorization({selectedCIDNs: selectedNewCidn, opportunityId: this.opportunityId})
            .then(result => {
                    this.missingChown = result;
                    if(this.missingChown != ''){
                        if(this.profileProdCheck == true){
                        this.isMissingChown = true;
                        this.isFileSaved = false;
                        this.allFilesUploaded = false;
                        }else{
                            this.handleNewNext(); 
                        }
                    }else{
                        this.handleNewNext();
                    }
            })
            this.missingChown = '';
            selectedNewCidn = [];
    }
    //Part of EDGE-198192: Added by Jay(Osaka):- Getting the List of CIDN in case of Bulk upload
    handleMissingUpload(){
            cidnsInHierarchy({base64Data : JSON.stringify(this.fileContents), basketId : this.basketid})
            .then(result =>{
                this.cidnListInFile = result;
            })
    }

    // End of EDGE-198192

    

//Start of EDGE-218061 by Pradeep(Osaka)
getproductFamilyOptions(){
    console.log("productFamily::: ",this.productFamily );
    fetchProductFamily({
        productFamily: this.productFamily
    })
    .then(result=>{
        console.log('Inside Result');
        console.log('productFamily Values', JSON.stringify(result));
        var productFamilyoptions= [];
        productFamilyoptions = result;
        console.log('productFamilyoptions Values', productFamilyoptions);
        console.log('productFamilyoptions size', productFamilyoptions.length);
        if(productFamilyoptions.length==1){
            this.isSinglefamily=true;
            this.singleProductFamily = productFamilyoptions[0];
            //Added by Abhishek(Osaka) to send Product Family for Mobile.
            this.selectedProdFamily = productFamilyoptions;
        }
        else if(productFamilyoptions.length > 1){
            //Added by Abhishek(Osaka) to send Product Family for Mobile(resetting the list).
            this.selectedProdFamily = [];
            this.isSinglefamily=false;
            for(let value in productFamilyoptions){
                console.log('Values:::' +value);
                const option = {
                    label : String(productFamilyoptions[value]),
                    value : String(productFamilyoptions[value])
                };
                this.products = [...this.products, option];          
            }
        }
    })
    .catch(error => {
        this.error = error;
        console.log('Error Test: '+ JSON.stringify(this.error));
    })
} 
  //END of EDGE-218061 by Pradeep(Osaka)

  //Start of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)
  prodFamilyValueChange(event){
    console.log('Inside selected Product Family');
    this.selectedProdFamily = event.detail;

    if(this.selectedProdFamily != null && this.selectedProdFamily.length>0 && this.selectedProdFamily.includes('TIPT-SIPC')){
        console.log('inside tipt-sipc');
        this.defaultRadioValue = 'cidnHierarchy';
        this.isCidnHierarchy = true;
        this.showAuthorization = true; 
        this.isNextDisabled = false; 
        this.showValidate = true;
         
    }
    //Added this to fix DIGI-1755 Abhishek(Osaka)
    //After selecting product family more than 1(without TIPT-SIPC), if user selects CIDN Hierarchy radio button and
    //wishes to remove one product family while CIDN Hierarchy still being selected,
    //CIDN Hierarchy radio button would continue to be selected.
    else if(this.selectedProdFamily.length>0 && !this.selectedProdFamily.includes('TIPT-SIPC')
        && this.radioSelectedValue == 'cidnHierarchy'){
        console.log('Inside Non-tipt-sipc block');
        this.isCidnHierarchy = true;
        this.showAuthorization = true; 
        this.isNextDisabled = false; 
        this.showValidate = true; 
    }
    
    else {
        console.log('Inside tipt-sipc else');
        this.defaultRadioValue = 'defaultCidn';
        this.isCidnHierarchy = false;
        this.showAuthorization = false; 
        this.isNextDisabled = false; 
        this.showValidate = false; 
        
        
    }

    console.log('Selected Prod Family: '+this.selectedProdFamily);
    console.log('Selected Radio: '+this.defaultRadioValue +'/'+this.radioSelectedValue);
    this.getSelectedProductList();
  }
//End of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)

 /*************************************************************************************************
     Name : TransitionSelectContoller
	 Description :<Enhancement> Transition Select UX validation & enhancements(Fetching all selected Product)
	Author: Jay (Osaka) 
	Story: (DIGI-1754)
    ***************************************************************************************************/

getSelectedProductList(){
    console.log('getSelectedProductList called');
    this.isLegacyProductError = false;
    this.selectedListOfproduct = [];
    console.log('selected Prod family length in getSelectedProductList ', this.selectedProdFamily.length);
    for(var i = 0; i < this.selectedProdFamily.length; i++){
        let prodFamilyValue = this.selectedProdFamily[i];
        console.log('prodFamilyValue in getSelectedProductList -->> ', prodFamilyValue);
        this.selectedListOfproduct.push(prodFamilyValue);

    }
    console.log('List of prod family to send::' +this.selectedListOfproduct);
    console.log('this.selectedListOfproduct length', this.selectedListOfproduct.length);
}

/*************************************************************************************************
     Name : TransitionSelectContoller
	 Description :<TED-127> UX enhancement to enable mode of product configuration
	Author: Jay (Osaka) 
	Story: (DIGI-5034)
    ***************************************************************************************************/
get planConfigurationOptions() {
	if(this.serviceName == 'Migration'){
        console.log('PlanConfigOption');
        console.log('showPlanConfiguration ', this.showPlanConfiguration);
		this.showPlanConfiguration = true;
        console.log('showPlanConfiguration latest ', this.showPlanConfiguration);
        return [
            
            { label: 'Automatically retrieve all the existing SIOs to the product basket', value: 'automaticRetrieval'},
            { label: 'Add SIOs manually to the product basket', value: 'manualRetrieval' }
            
        ];
	}
    console.log('showPlanConfiguration ', this.showPlanConfiguration);

}

handleSelectedPlanConfiguration(event){
    this.SelectedPlanConfig = event.target.value;
    if(this.SelectedPlanConfig == 'automaticRetrieval'){
        console.log('Selected auto Value');
        this.sioConfigMode = 'Auto SIO';
    }
    else{
        console.log('Selected manual Value');
        this.sioConfigMode = 'Manual SIO';
    }
    console.log('sioConfigMode latest value ', this.sioConfigMode);
}
//End of DIGI-5034.

}
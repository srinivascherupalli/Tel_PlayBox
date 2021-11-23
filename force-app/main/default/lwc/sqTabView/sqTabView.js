/**
   *  Description of the purpose of the method.
   *  @name SqTabView
   *  @description                       : This LWC is used to display the service Qualifications details in tab view
   *  @return 				 	         : - 
   *  @Jira Story Ref                    : DIGI-333/DIGI-559
   *  @createdBy  				         : Ajith Kumar, Nitin Kumar
**/
import { LightningElement,api, track, wire } from 'lwc';
import getServiceQualificationCheck from '@salesforce/apex/SQTabViewController.getServiceQualificationRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';

const columnsCarriageSolutions = [
    { label: 'Carriage Solution', fieldName: 'Name',type:'text' },
    { label: 'Carriage Solution Status', fieldName: 'carriageSolutionStatus__c', type: 'text' },
    { label: 'Maximum Device Bandwidth', fieldName: 'maximumDeviceBandwidth__c', type: 'text' },
    { label: 'Interface Type', fieldName: 'interfaceType__c', type: 'text' },
    { label: 'Spare Slot Available', fieldName: 'spareSlotIndicator__c', type: 'text' },
    { label: 'Device Build Indicator', fieldName: 'deviceBuildIndicator__c', type: 'text' },
    //DIGI-29002 added new columns under the carriage solution table
    { label: 'Device Type', fieldName: 'Device_Type__c', type: 'text' },
    { label: 'Device Domain', fieldName: 'Device_Domain__c', type: 'text' },
   
];

//DIGI-559 Changed the NT Type api name
const columnsResourceDetails = [
    { label:  'NT ID', fieldName: 'NTD_ID__c', type: 'text'},
    { label: 'NT Power Type', fieldName: 'NTD_Power_Type__c', type: 'text' },
    { label: 'NT Location', fieldName: 'NTD_Location__c', type: 'text' },
    { label: 'NT Type', fieldName: 'NTD_Type__c', type: 'text' }
    
];

const columnsPortDetails = [
    { label: 'UNI Port Type', fieldName: 'Uni_Port_Type__c', type: 'text' },
    { label:  'Port ID', fieldName: 'Port_ID__c', type: 'text'},
    { label: 'Port Status', fieldName: 'Port_Status__c', type: 'text' },
];

export default class ServiceQualificationTabView extends LightningElement {
@api   recordId;
maxESABandwidth;
carriagesol=[];
serviceQualificationProviderRecord=[];
serviceQualificationPortDetailRecords=[];
telstraFibreSQ=[];
nbESFibreSQ=[];
nbnEthernertSQ = [];
formattedDate;
telstraFibrelastModifiedDate;
nbESFibreSQCeaseDate;
nbESFibreSQLastModifiedDate;
nbESFibreSQReadyDate;
nbnEthernertSQLastModifiedDate;
nbnEthernertSQAvailabilityDate;
results;
@track loaded=false;

activeSections=['TELSTRAFIBRE','NBNNEBS','NBNEE'];
columnsCarriageSolutions=columnsCarriageSolutions;
columnsPortDetails = columnsPortDetails;
columnsResourceDetails = columnsResourceDetails;

@wire(getServiceQualificationCheck,{recordId: '$recordId'})
getServiceQualification({error,data}){
    if(error){
        this.loaded=true;
        this.error=error;
        this.dispatchEvent(              
            new ShowToastEvent({
                message: 'Error occured while retrieving the records. Please refresh the page again ',
                variant: 'error'
            })
        )
    }
    else if(data){
        this.loaded=true;
        this.results=data;
        if(this.results.TelstraFibreSQ){
            this.telstraFibreSQ = this.results.TelstraFibreSQ;
            this.telstraFibrelastModifiedDate = this.getDate(this.telstraFibreSQ.LastModifiedDate);
            if(this.results.carriageSolutionsRecord){
                this.carriagesol = this.results.carriageSolutionsRecord;
               if(this.carriagesol[0].maximumESABandwidth__c)      
                   this.maxESABandwidth = this.carriagesol[0].maximumESABandwidth__c;
            }
           
        }
        if(this.results.NBESFibreSQ){
            this.nbESFibreSQ = this.results.NBESFibreSQ;
            this.nbESFibreSQCeaseDate = this.getDate(this.nbESFibreSQ.Cease_Sale_Date__c);
            this.nbESFibreSQLastModifiedDate = this.getDate(this.nbESFibreSQ.LastModifiedDate);
            this.nbESFibreSQReadyDate = this.getDate(this.nbESFibreSQ.Ready_for_Service_Date__c);
            
            if(this.results.serviceQualificationProviderRecord){
                this.serviceQualificationProviderRecord = this.results.serviceQualificationProviderRecord; 
            }
            if(this.results.serviceQualificationPortDetailRecords){
                this.serviceQualificationPortDetailRecords = this.results.serviceQualificationPortDetailRecords;
            }
        }
        if(this.results.NBNEthernertSQ){
            this.nbnEthernertSQ = this.results.NBNEthernertSQ;
            this.nbnEthernertSQLastModifiedDate = this.getDate(this.nbnEthernertSQ.LastModifiedDate);
            this.nbnEthernertSQAvailabilityDate = this.getDate(this.nbnEthernertSQ.NBN_Estimated_Availability_Date__c);
        }        
    }
}

getDate(dateValue){
        if(dateValue){
            var dateFormat=new Date(dateValue);
            let formatter = new Intl.DateTimeFormat(LOCALE, {
                year: "numeric" ,                
                month: "2-digit",                
                day: "2-digit",                
                hour: "2-digit",                
                minute: "2-digit",                
                hour12: "true"                
                }) 
            this.formattedDate = formatter.format(dateFormat);
            return this.formattedDate;
        }
        else return null;        
}
}
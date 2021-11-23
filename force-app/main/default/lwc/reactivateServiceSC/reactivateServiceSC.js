import {LightningElement,track,api,wire} from 'lwc';
import getReactiveServiceMetadata from "@salesforce/apex/ReactivateServiceSC.getReactiveServiceMetadata";
import getReactivateServicesResult from "@salesforce/apex/ReactivateServiceSC.getReactivateServicesResult";
import mapJSONToObjects from '@salesforce/apex/DP_PREInterfaceClass.mapJSONToObjects';

const PAGE_SIZE = 8;

export default class reactivateServiceSC extends LightningElement {
	
	ReactivateServiceMetadata;
	@track gridColumns;
	@track gridData;
	@api category;
	@api alreadyPresentMisdns;
	@api selectedMisdnsList=[];
	@api subscriptionNumber;
	@api offerId;
	@track selectedRows=[];
	@track finalselection=[];
	@track totalCount;
	@track filter; 
    @track filteredData; 
    @track selectedRowsCount = 0; 
    @track NoSearchRecord = false;
	@track data;	
	@track listOfselectedMisdns =[];
	@track disabledSave=true;
	@track allRecords;
	@track selectedRecords=[];
	@track displayMSg='Note:Only services deactivated in the last 28 days will be displayed';
    @track frstBool = true;
    @track lastBool = true;
    @track nextBool = true;
    @track prevBool = true;
    @track offset = 0;
    @track pageSize = PAGE_SIZE;
    @track dataCount = 0;
	@track pagenumber =1;
	@track totalpages;
	@track misdnToBillingAccMap=[];
	

	//method to fetch table data and columns records
	@api getResult(){
		try{
			getReactiveServiceMetadata({
				category:this.category
			}).then(result => {
				if(result!=null && result!=undefined){
					this.ReactivateServiceMetadata = result; // metadata record
					this.gridColumns=JSON.parse(result.columnHeaders__c);//header from metadata
					this.getServicesResult(); //method to fetch data
				}
			});
		}catch (e){
			console.log('Exception in fetchig result-->'+e);
		}
	}
	//method to fetch service data
	@api getServicesResult(){
		try{
		
			getReactivateServicesResult({
				subscriptionNumber:this.subscriptionNumber,
				offerId:this.offerId,
				alreadyPresentMisdns: this.alreadyPresentMisdns,
				searchString: this.searchString,
				reactiveServiceMdt: this.ReactivateServiceMetadata //// INC000095032613
			}).then(ReactivateServicesResult => {
				if(ReactivateServicesResult !=null){
					this.data=ReactivateServicesResult;
					//this.gridData=ReactivateServicesResult;
					//this.allRecords=ReactivateServicesResult;
					let tempData = JSON.parse( JSON.stringify(ReactivateServicesResult) );
					for ( let i = 0; i < tempData.length; i++ ) {
						tempData[ i ]._children = tempData[ i ][ 'addondetails' ];
						delete tempData[ i ].addondetails;
					}
					this.allRecords=tempData;
					this.totalCount=ReactivateServicesResult.length;
					if ( this.allRecords ) {
						this.dataCount = this.allRecords.length;
						this.totalpages =Math.ceil(this.dataCount/this.pageSize);
						if ( this.dataCount > this.pageSize ) {
							this.nextBool = false;
							this.lastBool = false;
						}
						this.fetchData();
					}
					
				}else{
					console.log('No result in service');
				}
			});
		}catch(e){
			console.log('Exception in fetchig result-->'+e);
		}
	}
	
	/*
        Method to navigate to previous set of Account records
    */
    goPrevious() {
        this.offset -= this.pageSize;
		this.pagenumber =this.pagenumber-1;
        this.nextBool = false;
        if( this.offset === 0 ) {
            this.prevBool = true;
            this.frstBool = true;
        } else {
            this.nextBool = false;
            this.lastBool = false;            
        }
        this.fetchData();
    }
    /*
        Method to navigate to next set of Account records
    */
    goNext() {
        this.offset += this.pageSize;
		this.pagenumber=this.pagenumber+1;
        this.prevBool = false;
        if ( ( this.offset + this.pageSize ) >= this.dataCount ) {
            this.nextBool = true;
            this.lastBool = true;
        } else {
            this.prevBool = false;
            this.frstBool = false;
        }      
        this.fetchData();
    }
    /*
        Method to navigate to first set of Account records
    */
    goFirst() {
		this.pagenumber=1;
        this.offset = 0;
        this.nextBool = false;
        this.prevBool = true;
        this.frstBool = true;
        this.lastBool = false;
        this.fetchData();
    }
    /*
        Method to nanigate to last set of Account records
    */
    goLast() {
		this.pagenumber=this.totalpages;
		let lastsecondpage=this.totalpages-1
        this.offset = this.pageSize*lastsecondpage;
        this.nextBool = true;
        this.prevBool = false;
        this.frstBool = false;
        this.lastBool = true;
        this.fetchData();
    }

    /*
        Method to fetch the data from the original list of records.
        slice() is used to get the right set of records based on page size and offset values.
    */
    fetchData() {
		this.finalselection=[];
		this.selectedMisdnsList=this.alreadyPresentMisdns.split(',');
		//this.finalselection=this.selectedMisdnsList;
		this.selectedRowsCount =0;
		for(var num of this.selectedMisdnsList){
			if(num!=''){
				this.finalselection.push(num);
				this.selectedRowsCount++;
			}
		}
		this.gridData = this.allRecords.slice( this.offset, ( this.offset + this.pageSize ) );
    }

	// initialize component
	connectedCallback() {
		console.log('connectedCallback');
		this.getResult();	
	}
	
	// handle row selection
	handleRowSelection(event) {
		this.listOfselectedMisdns= [];
		this.selectedRows=[];
		const treegrid = this.template.querySelector('.reactivateService-treegrid');
        this.selectedRows = treegrid.getSelectedRows();
        this.selectedRowsCount =0;
		this.finalselection=[];
		var misdnmap=[];
		//this.finalselection=selectedMisdnsList;
		if(this.selectedMisdnsList.length>0){
			for(var num of this.selectedMisdnsList){
				this.finalselection.push(num);
				this.selectedRowsCount++;
			}
		}
		for(var servdata of this.selectedRows){
			if(servdata.serviceNumber && servdata.serviceNumber!=null && servdata.serviceNumber!='' && !this.alreadyPresentMisdns.includes(servdata.serviceNumber)){					
				this.finalselection.push(servdata.serviceNumber);
				this.selectedRowsCount++;
				this.listOfselectedMisdns.push(servdata.serviceNumber);
				misdnmap.push({
					key:servdata.serviceNumber,
					value:servdata.billingAcc
				});
				
				
			}
		}
		this.misdnToBillingAccMap=misdnmap;
		console.log('map data-->');
		console.log(this.misdnToBillingAccMap);
		if(this.listOfselectedMisdns.length==0){
			this.disabledSave=true;
		}else{
			this.disabledSave=false;
		}
		
       
	}
	
	//filter data based on search string
	filterData(event) {
        var data = this.data,
            term = event.target.value,
            results = data,
            regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            //added new regex to filter with deviceId as part of EDGE-149079
            results = data.filter(row => regex.test(row.serviceNumber) ||
                regex.test(row.subscriptionName) || regex.test(row.subscriptionNumber));
        } catch (e) {
            // invalid regex, use full list
        }
        this.gridData = results;
		this.totalCount=results.length
        if (this.gridData.length == 0) {
            this.NoSearchRecord = true;
        } else {
            this.NoSearchRecord = false;
        }
    }
	
	//called on save 
	handlesave(event) {
		var selectedMsidns=this.listOfselectedMisdns;
		var misdnMap=this.misdnToBillingAccMap;
		console.log(misdnMap);
		let payload =
		{
			command: 'reactivateMisdns',
			data: misdnMap, //selectedMsidns,
			caller: this.category
		};
		window.parent.postMessage(JSON.stringify(payload), '*') ;
		sessionStorage.setItem("payload", JSON.stringify(payload));
	}
	//close pop up
	handleCancel(event) {
		var cancelEvent=true;
		window.parent.postMessage("close", '*');
		sessionStorage.setItem("close", "close");
	}
	
	handleExpandAll(event) {
		const treegrid = this.template.querySelector('.reactivateService-treegrid');
        treegrid.expandAll();
	}
	
	handleCollapseAll(event) {
		const treegrid = this.template.querySelector('.reactivateService-treegrid');
        treegrid.collapseAll();
	}
}
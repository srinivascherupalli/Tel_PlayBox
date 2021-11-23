//EDGE-150237
import { LightningElement, api,wire ,track} from 'lwc';
import fetchRecords from "@salesforce/apex/ReusableRelatedListControllerNew.fetchRecords";
import { NavigationMixin } from 'lightning/navigation';
export default class ReusableRelatedListNew extends NavigationMixin(LightningElement)  {
    @track activeSections = ["DataTable"];
    @api objectName; 
    @api isViewAll = false;
    @api headerIcon;
    @api parentObjectName;
    @api recordId; 
    @api strTitle;
    @api filterStr;
    @api paramsList;
    @api operator;
    @api fieldsList;
    @api fieldsLabelLst;
    @api hyperlinkField;
    @api relationshipApiName;
    @track titleWithCount;
    @track columns;
    @track countBool = false;
    @track parObjPluName;
    @track parRecName;

    connectedCallback(){
      this.parObjPluName=this.relationshipApiName+'s';
      this.parRecName = 'Parent '+this.relationshipApiName+' Record';
    }
    renderedCallback() {
    }
    
    get vals() {
        return this.recordId + '-' + this.objectName + '-' + this.parentObjectName + '-' + this.filterStr + '-' +  this.paramsList + '-' + this.fieldsList;
    }
             
            @wire(fetchRecords, { listValues: '$vals' }) 
            async accountData( { error, data } ) {

var fieldsApiName= this.fieldsList;
var fieldsLabelName=this.fieldsLabelLst;
var columns =[];
var i=0;
if (fieldsApiName )
{
var fieldsApiList = fieldsApiName.toString().split(",");
var fieldsLabelList = fieldsLabelName.toString().split(",");

for (i = 0; i < fieldsApiList.length; i++) {
    var obj = new Object();
    obj.fieldName = fieldsApiList[i];
    obj.label = fieldsLabelList[i]; 
    if (fieldsApiList[i]==this.hyperlinkField)
    {
        obj.type="url";
        var text='{"label": {"fieldName" :"Id"},"target" : "_blank"}';
        obj.typeAttributes= JSON.parse(text);
    }
    else
    obj.type="text";
    columns.push(obj);
}
}
console.log('columns   ',columns);
this.columns=columns;
                if ( data ) {
                    this.data = await this.parseJsonData(data.listRecords);
                    console.log('Data:  ',data.listRecords);
                    if ( data.recordCount ) {
                        if ( data.recordCount > 3 ) {
        
                            //this.titleWithCount = this.strTitle + ' (3+)';
                            if(this.isViewAll===false){
                              this.countBool = true;
                              this.titleWithCount = this.strTitle + ' (3+)';

                            }
                            else{
                              this.titleWithCount = this.strTitle + ' ('+data.recordCount+')';
                            }                              
                       
                        } else {        
                            this.titleWithCount = this.strTitle + ' (' + data.recordCount + ')';        
                        }
                    }
                    else{
                      this.titleWithCount = this.strTitle + ' (0)';
                      console.log('this.strTitle'+this.strTitle);
                    }
        
                }                
        
            }
            async parseJsonData(jsonData) {
                var parseData = [];
                var outerIndex;
                var iCount = 0;
                var formatter = new Intl.DateTimeFormat('en-us', {
                  day: 'numeric',
                  month: 'numeric',
                  year: 'numeric',
                  hour: 'numeric',
                  minute: 'numeric',
                  hour12: true,
                  timeZone: 'Australia/Sydney'
                });
                for (outerIndex in jsonData) {                  
                  if(iCount===3 && this.isViewAll===false){
                    break;
                  }
                  iCount++;
                  var myObject = {};
                  for (var key in jsonData[outerIndex]) {
                      //console.log('key',key);
                    if (key==this.hyperlinkField) {
					            var val = jsonData[outerIndex]["Id"];
                      await this.navigateToRecordView(val, "view");
                      myObject["Id"] = jsonData[outerIndex][this.hyperlinkField];
                      myObject[key] = this.recordPageUrl;
                    } else if(jsonData[outerIndex][key].includes(".000Z")){
                                var dt = new Date(jsonData[outerIndex][key]);
                                var d = formatter.formatToParts(dt);
                                myObject[key] = ("0" + d[2]['value']).slice(-2)+'/'+("0" + d[0]['value']).slice(-2)+'/'+d[4]['value']
                                +' '+d[6]['value']+':'+d[8]['value']+' '+d[10]['value'];
					          } else {
                      myObject[key] = jsonData[outerIndex][key];
                    }
                  }
                  parseData.push(myObject);
                }
                return parseData;
              }
            
              navigateToRecordView(Id, Action) {
                return this[NavigationMixin.GenerateUrl]({
                  type: "standard__recordPage",
                  attributes: {
                    recordId: Id,
                    actionName: Action
                  }
                }).then(url => {
                  this.recordPageUrl = url;
                });
              }
              handleClick(event) {

                  this[NavigationMixin.Navigate]({
                      type: 'standard__component',
                      attributes: {
                          //Here customLabelExampleAura is name of lightning aura component
                          //This aura component should implement lightning:isUrlAddressable
                          componentName: 'c__CustomRelatedlist_ViewAll'
                        },
                          state: {
                            c__strTitle: this.strTitle,
                            c__objectName:this.objectName,
                            c__headerIcon:this.headerIcon,
                            c__hyperlinkField:this.hyperlinkField,
                            c__parentObjectName:this.parentObjectName,
                            c__relationshipApiName:this.relationshipApiName,
                            c__paramsList:this.paramsList,
                            c__filterStr:this.filterStr,
                            c__fieldsList:this.fieldsList,
                            c__fieldsLabelLst:this.fieldsLabelLst,
                            c__parRecordId:this.recordId                            
                        }
                          
                      //}
                  });
              }
            handleNavigateToCustomPage1(event) {
                event.preventDefault();
                //your custom navigation here
                this[NavigationMixin.Navigate]({
                  type: 'standard__objectPage',
                  attributes: {
                      objectApiName: this.parentObjectName,
                      actionName: 'list'
                  },
                  state: {
                      filterName: 'Recent'
                  },
              });                
            }
            handleNavigateToCustomPage2(event) {
                event.preventDefault();
                //your custom navigation here
                this[NavigationMixin.Navigate]({
                  type: 'standard__recordPage',
                  attributes: {
                      recordId: this.recordId,
                      objectApiName: this.parentObjectName,
                      actionName: 'view'
                  },
              });                
            }              

}
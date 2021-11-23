import { LightningElement, wire, api, track } from "lwc";
import getUserTerritoryData from "@salesforce/apex/UserTerritory2AssociationController.getUserTerritory2Association";
import UserTerritoryRecordCount from "@salesforce/label/c.UserTerritoryRecordCount";
// Datatable Columns
const columns = [
  {
    label: "Name",
    fieldName: "userName",
    type: "text"
  },
  {
    label: "Email",
    fieldName: "userEmail",
    type: "text"
  },
  {
    label: "Territory",
    fieldName: "territory2Name",
    type: "text"
  },
  {
    label: "Role In Territory ",
    fieldName: "roleInTerritory2",
    type: "text"
  },
  {
    label: "Active",
    fieldName: "isActive",
    type: "boolean"
  }
];
export default class UserTerritory2Association extends LightningElement {
  cols = columns;
  /**for pagination */
  @track page = 1; //this will initialize 1st page
  @track startingRecord = 1; //start record position per page
  @track endingRecord = 0; //end record position per page
  @track pageSize = UserTerritoryRecordCount; //record count that will fetch from custom label
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records
  @track items = []; //it contains all the records.
  @track recordCount = 0;
  @track isRecordExist = false;
  @track data = [];
  @api recordId;
  @wire(getUserTerritoryData, { accountId: "$recordId" })
  userTerritoryData({ error, data }) {
    if (data) {
      this.data = data;
      /**for pagination */
      this.items = this.data;
      this.totalRecountCount = data.length; //here it is 23
      this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5

      //initial data to be displayed ----------->
      //slice will take 0th element and ends with 5, but it doesn't include 5th element
      //so 0 to 4th rows will be display in the table
      this.data = this.items.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;

      if (this.data.length == 0) {
        this.recordCount = 0;
        this.isRecordExist = false;
      } else {
        this.isRecordExist = true;
        if (this.totalRecountCount > UserTerritoryRecordCount) {
          this.recordCount = UserTerritoryRecordCount + "+";
        } else {
          this.recordCount = this.totalRecountCount;
        }
      }
    } else if (error) {
      this.isRecordExist = false;
      console.log(error);
    }
  }
  //this method displays records page by page
  displayRecordPerPage(page) {
    /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
    page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
    so, slice(5,10) will give 5th to 9th records.
    */
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }
  //clicking on previous button this method will be called
  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //clicking on next button this method will be called
  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
  }
}
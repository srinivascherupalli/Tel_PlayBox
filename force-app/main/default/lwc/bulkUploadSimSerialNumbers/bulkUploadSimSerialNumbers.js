import { LightningElement, track } from "lwc";
import { helper } from "./bulkUploadSimSerialNumbersHelper.js";

export default class BulkUploadSimSerialNumbers extends LightningElement {
  acceptedFormats = ".csv";
  filesUploaded = [];
  fileName;
  file;
  fileContents;
  fileReader;

  handleUploadFinished(event) {
    helper.fireCustomEvent(this,true, null, null, false);
    if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.fileName = event.target.files[0].name;
      this.file = this.filesUploaded[0];
      helper.validateAndUpload(this);
      this.fileReader.readAsText(this.file);
    }
  }
}
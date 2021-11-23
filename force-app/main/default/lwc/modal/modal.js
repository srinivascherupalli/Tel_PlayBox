import { LightningElement, api } from "lwc";

export default class Modal extends LightningElement {
  @api title = "";
  @api successBtnLabel = "Done";
  @api successBtnBrand = "Neutral";
  @api isLoading = false;
  @api isCancel = false;
  @api isReset = false;
  @api isApplyToggle = false;
  @api applyLabel = "";

  /**
   * Handle cancel action
   */
  handleCancel() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }

  /**
   * Handle save action
   */
  handleSuccess() {
    this.dispatchEvent(new CustomEvent("done"));
  }

  /**
   * Handle reset section action
   */
  handleReset() {
    this.dispatchEvent(new CustomEvent("reset"));
  }

  /**
   * Handle apply toggle
   */
  handleToggleChange(evt) {
    console.log(evt.detail.checked);
    const focusEvent = new CustomEvent("togglechange", {
      detail: {
        toggleValue: evt.detail.checked
      }
    });
    this.dispatchEvent(focusEvent);
  }
}
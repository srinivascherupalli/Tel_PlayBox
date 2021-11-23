import { LightningElement, api, track } from "lwc";

export default class PathTabs extends LightningElement {
  @api activeTab = 0;
  @api tabs = [];
  @track uiTabsModel = [];
  isRendered = false;

  connectedCallback() {
    this._transformTabs();
  }

  /**
   * @desc Iterating through tabs public property. Create the neccessary attributes for UI purpose 
   * such as isActive, isCompleted. Based on these props, add/remove the slds class will be happened
   */
  _transformTabs() {
    const uiTabsModel = this.tabs.map((tab, i) => {
      return {
        idx: i,
        ...tab,
        isActive: (i === this.activeTab),
        isCompleted: false
      }
    });
    this.uiTabsModel = uiTabsModel;
  }

  renderedCallback() {
    if (!this.isRendered) {
      // For first time rendering, slds classes has to be added.
      this._toggleClasses(this.activeTab); 
    }   
    this.isRendered = true; 
  }

  /**
   * @desc Update the user selected tab as active, rest tabs turn to inactive.
   * @param {Event Object} evt - change event object
   */
  handleChangeTab(evt) {
    const tabId = parseInt(evt.currentTarget.dataset.tabId, 10);
    const uiTabsModel = this.uiTabsModel.map((tab, i) => {
      return {
        ...tab,
        isActive: (i === tabId),
      }
    });
    this.uiTabsModel = uiTabsModel;
    this._toggleClasses(tabId);
    this._customEvent(tabId); // Dispatch the change event to Parent component
  }

  _customEvent(tabId) {
    const changeEvent = new CustomEvent("change", {
      detail: tabId,
    });
    this.dispatchEvent(changeEvent);
  }

  _toggleClasses(tabId) {
    const tabLists = this.template.querySelectorAll(".slds-path__item");
    tabLists.forEach((tabList, i) => {
      if (tabId === i) { // Add class
        tabList.classList.add("slds-is-active");
      } else { // Remove class
        tabList.classList.remove("slds-is-active");
      }
    });
  }
}
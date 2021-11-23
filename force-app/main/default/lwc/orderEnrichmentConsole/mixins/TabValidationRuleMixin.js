import operators from "../config/operators";

const TabValidationRuleMixin = (base) =>
  class TabValidationRules extends base {
    /**
     * @desc Iterate through the active tab fields and find the rule field.
     * @param {String} fieldName - name of the field to find
     */
    _findTabRuleField(fieldName) {
      const findField = this.selectedPcMap.cscfga__Attributes__r.records.find(
        (record) => record.Name === fieldName
      );
      return findField;
    }

    /**
     * @desc Iterate through the rules logics
     * @param {Array} logics - rule logic
     * @return {Array} ruleResult - Return the each executed rules result as array.
     */
     _executeTabRuleLogic(logics) {
      let rulesResults = [];
      // Execute Rules
      if (Array.isArray(logics)) {
        logics.forEach((logic) => {
          let extracAttName = "";
          let extracAttValue = "";
          // check attName or attValue has @ expression
          if (
            logic.attName.includes("@", 0) ||
            logic.attValue.includes("@", 0)
          ) {
            // string match utils will return the array or null
            extracAttName = logic.attName.match(/(?<=@).+?(?=@)/g); // Remove the @ from the string
            extracAttValue = logic.attValue.match(/(?<=@).+?(?=@)/g); // Remove the @ from the string
          }
          extracAttName = extracAttName ? extracAttName[0] : "";
          extracAttValue = extracAttValue ? extracAttValue[0] : "";

          // Find the rule field based on the attName.
          const findRuleField = this._findTabRuleField(extracAttName);

          // Find the compare field based on the attValue.
          let findCompareField = {};
          if (logic.attValue && !logic.attValue.match(/(?<=@).+?(?=@)/g)) {   
            // When logic.attValue is assigned a hardcoded value
            findCompareField.cscfga__Value__c = logic.attValue;
          } else {
            // When logic.attValue is assigned @attribute@ value
            findCompareField = this._findTabRuleField(extracAttValue);
          }

          if (!findRuleField) {
            // No field is found, return here, don't execute the rule.
            return;
          }
          // console.log(extracAttName);
          if (!findRuleField.cscfga__Value__c && logic.attValue !== "") {
            // ONLOAD_RULE should not excecute the rule when value is not filled by the user.
            rulesResults.push(false);
            return;
          }
          if (!extracAttValue && !findRuleField.cscfga__Value__c) {
            rulesResults.push(true);
            return;
          }
          if (findCompareField) {
            // Invoke the operators config to execute the operation and push the result
            rulesResults.push(
              operators[logic.operator](
                findRuleField.cscfga__Value__c,
                findCompareField.cscfga__Value__c
              )
            );
          }
          if (logic.attValue === "") {
            // Invoke the operators config to execute the operation and push the result
            rulesResults.push(
              operators[logic.operator](findRuleField.cscfga__Value__c, logic.attValue)
            );
          }
        });
      }
      return rulesResults;
    }

    /**
     * @desc Iterate through the rules logics
     * @param {Array} logics - rule logic
     * @return {Array} ruleResult - Return the each executed rules result as array.
     */
     _executeTabRuleAction(actions) {
      // Execute Rules
      if (Array.isArray(actions.isTrue)) {
        actions.isTrue.forEach((action) => {
          if (action.showInUI === false) {
            this.selectedPcMap.tabList = this.selectedPcMap.tabList.filter(
              (tab) => tab.label !== action.tabName
            );
            this.selectedPcMap.schema = this.selectedPcMap.schema.filter(
              (tab) => tab.Tab_Name__c !== action.tabName
            );
          }          
        });
      }
    }

    _executeTabRules() {
      // Get the Product Specification Id
      const psId =
        this.selectedPcMap.cscfga__Product_Definition__r
          .product_Specification__c;
      // Filter the validation rules based on the Product Specification Id
      this.tabValidationRules = this.basketRecordsDetail[
        this.selectedSolution.solutionKey
      ].validationlist.filter(
        (rule) =>
          rule.Product_Specification_Id__c === psId &&
          rule.Is_Active__c &&
          rule.Target__c === "Tab"
      );

      this.tabValidationRules.forEach((rule) => {
        rule.actions = JSON.parse(rule.Action__c);
        rule.logics = JSON.parse(rule.Logic__c);
        let rulesResults = this._executeTabRuleLogic(rule.logics);

        if (rule.Condition__c === "AND") {
          const hasError = (currentValue) => currentValue === true;
          // console.log(rulesResults.every(hasError));
          if (rulesResults.every(hasError)) {
            this._executeTabRuleAction(rule.actions, true);
          }
        } else {
          // OR condition rule
          if (rulesResults.includes(true)) {
            this._executeTabRuleAction(rule.actions, true);
          }
        }
      });
    }
  };
export default TabValidationRuleMixin;
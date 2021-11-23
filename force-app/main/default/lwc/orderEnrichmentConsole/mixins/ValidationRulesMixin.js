import operators from "../config/operators";

const ValidationRulesMixin = (base) =>
  class ValidationRules extends base {
    /**
     * @desc Iterate through the active tab fields and find the rule field.
     * @param {String} fieldName - name of the field to find
     */
    _findRuleField(fieldName) {
      const findField = this.selectedTabMap.schema[
        this.activeTabId
      ].Attribute_Json__c.attributes.find(
        (attribute) => attribute.name === fieldName
      );
      return findField;
    }

    /**
     * @desc Iterate through the rules logics
     * @param {Array} logics - rule logic
     * @return {Array} ruleResult - Return the each executed rules result as array.
     */
    _executeRuleLogic(logics) {
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
          const findRuleField = this._findRuleField(extracAttName);

          // Find the compare field based on the attValue.
          const findCompareField = this._findRuleField(extracAttValue);

          if (!findRuleField) {
            // No field is found, return here, don't execute the rule.
            return;
          }
          // console.log(extracAttName);
          if (findRuleField.type === "Date") {
            const findRuleFieldDate = new Date(findRuleField.value); // convert string to date
            let compareFieldDate = new Date(); // by default compare value is date
            if (!findRuleField.value && logic.attValue !== "") {
              // ONLOAD_RULE should not excecute the rule when value is not filled by the user.
              rulesResults.push(false);
              return;
            }
            if (!extracAttValue && !findRuleField.value) {
              rulesResults.push(true);
              return;
            }
            if (extracAttValue !== "today" && findCompareField) {
              compareFieldDate = new Date(findCompareField.value);
            }
            // console.log(findRuleFieldDate.toString() === "Invalid Date");
            if (
              findRuleFieldDate.toString() === "Invalid Date" ||
              compareFieldDate.toString() === "Invalid Date"
            ) {
              rulesResults.push(true);
              return;
            }
            // Invoke the operators config to execute the operation and push the result
            rulesResults.push(
              operators[logic.operator](+findRuleFieldDate, +compareFieldDate)
            );
          } else {
            if (!findRuleField.value && logic.attValue !== "") {
              // ONLOAD_RULE should not excecute the rule when value is not filled by the user.
              rulesResults.push(false);
              return;
            }
            if (!extracAttValue && !findRuleField.value) {
              rulesResults.push(true);
              return;
            }
            if (findCompareField) {
              // Invoke the operators config to execute the operation and push the result
              rulesResults.push(
                operators[logic.operator](
                  findRuleField.value,
                  findCompareField.value
                )
              );
            }
            if (logic.attValue === "") {
              // Invoke the operators config to execute the operation and push the result
              rulesResults.push(
                operators[logic.operator](findRuleField.value, logic.attValue)
              );
            }
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
    _executeRuleAction(actions, hasError) {
      // Execute Rules
      if (Array.isArray(actions.isTrue)) {
        actions.isTrue.forEach((action) => {
          let extracAttName = action.attrName;
          let extracAttValue = "";
          // check attName or attValue has @ expression
          if (action.value.includes("@", 0)) {
            // string match utils will return the array or null
            extracAttValue = action.value.match(/(?<=@).+?(?=@)/g); // Remove the @ from the string
          }
          extracAttValue = extracAttValue ? extracAttValue[0] : "";

          // Find the rule field based on the attName.
          const findRuleField = this._findRuleField(extracAttName);

          // Find the compare field based on the attValue.
          const findCompareField = this._findRuleField(extracAttValue);

          if (!findRuleField) {
            // No field is found, return here, don't execute the rule.
            return;
          }
          if (!hasError) {
            // Reverse the action If no error
            findRuleField.errorMessage = "";
            // findRuleField.showInUI = (action.showInUI === findRuleField.showInUI);
            // findRuleField.readOnly = (action.readOnly === findRuleField.readOnly);
            return;
          }
          if (!findRuleField.errorMessage) {
            // Apply the error actions
            findRuleField.errorMessage = action.errorMessage;
            // findRuleField.showInUI = action.showInUI;
            // findRuleField.readOnly = action.readOnly;
          }
          if (!action.errorMessage && extracAttValue && findCompareField) {
            findRuleField.value = findCompareField.value;
          }
        });
      }
    }

    /**
     * @desc Iterate through the validationlist, execute the logic and perform the action
     */
    _executeValidationRule() {
      // Get the Product Specification Id
      const psId =
        this.selectedPcMap.cscfga__Product_Definition__r
          .product_Specification__c;
      // Filter the validation rules based on the Product Specification Id
      this.validationRules = this.basketRecordsDetail[
        this.selectedSolution.solutionKey
      ].validationlist.filter(
        (rule) => rule.Product_Specification_Id__c === psId && rule.Is_Active__c
      );
      this.validationRules.forEach((rule, idx) => {
        rule.actions = JSON.parse(rule.Action__c);
        rule.logics = JSON.parse(rule.Logic__c);
        let rulesResults = this._executeRuleLogic(rule.logics);

        if (rule.Condition__c === "AND") {
          const hasError = (currentValue) => currentValue === true;
          // console.log(rulesResults.every(hasError));
          if (rulesResults.every(hasError)) {
            this._executeRuleAction(rule.actions, true);
          }
        } else {
          // OR condition rule
          if (rulesResults.includes(true)) {
            this._executeRuleAction(rule.actions, true);
          }
        }

        // console.log(`rulesResults ${rulesResults}`);
        const hasError = (currentValue) => currentValue === true;
        // console.log(rulesResults.every(hasError));
        if (!rulesResults.every(hasError)) {
          this._executeRuleAction(rule.actions, false);
        }
      });
    }
  };
export default ValidationRulesMixin;
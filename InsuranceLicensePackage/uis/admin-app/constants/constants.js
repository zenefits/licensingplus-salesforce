export const CHOOSE_FILE = '';
export const RULE_EXP = /[^0-9()(and|or)\s]/gi;
export const DATE_EXP = /^(19[0-9][0-9]|20[0-9][0-9])[-](0[1-9]|[12][0-9]|3[01])[-](0[1-9]|1[012])/g;
export const COMPLIANCE_OPERATORS_EXCLUDE = ['not blank','in','not in'];
export const FIELD_OPERATORS = {
  "STRING_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "in": "in",
    "not in": "not in",
    "not blank": "not blank"
  },
  "ID_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "not blank": "not blank"
  },
  "BOOLEAN_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "not blank": "not blank"
  },
  "DOUBLE_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "less than": "less than",
    "greater than": "greater than",
    "less or equal": "less or equal",
    "greater or equal": "greater or equal",
    "not blank": "not blank"
  },
  "DATETIME_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "less than": "less than",
    "greater than": "greater than",
    "less or equal": "less or equal",
    "greater or equal": "greater or equal",
    "not blank": "not blank"

  },
  "DATE_FIELD": {
    "equals": "equals",
    "not equal to": "not equal to",
    "less than": "less than",
    "greater than": "greater than",
    "less or equal": "less or equal",
    "greater or equal": "greater or equal",
    "not blank": "not blank"
  }
};
export const BLANK_LISCENSE_RULE_SET_RESULT = {
  "stateRule": {
    "license_field__c": "State__c",
    "object__c": "",
    "operator__c": "equals",
    "field__c": "",
    "isactive__c": false
  },
  "residentLicenseRule": {
    "object__c": "",
    "operator__c": "equals",
    "value__c": null
  },
  "ruleSets": [
    {
      "deletedRegularFilterRules": [

      ],
      "deletedLicenseRules": [

      ],
      "isFilterRuleLogicRemoved": false,
      "isLicenseRuleLogicRemoved": false,
      "filterRuleLogic": {
        
      },
      "licenseRuleLogic": {

      },
      "licenseRules": [

      ],
      "regularFilterRules": [

      ]
    }
  ]
}
export const APPROVAL_VIDEO_LINK = 'https://vimeo.com/183026614';
export const COMPLIANCE_VIDEO_LINK = 'https://vimeo.com/183025507';
export const CONFIGURATION_VIDEO_LINK = 'https://vimeo.com/183024977';
export const DB_VIDEO_LINK = 'https://vimeo.com/183026890';
export const EMBED_VIDEO_LINK = 'https://player.vimeo.com/video/182492617';
export const NIPR_VIDEO_LINK = 'https://vimeo.com/183026583';
export const CHOOSE_FILE = 'Choose File';
export const RULE_EXP = /[^0-9()(and|or)\s]/gi;
export const DATE_EXP = /^(19[0-9][0-9]|20[0-9][0-9])[-](0[1-9]|[12][0-9]|3[01])[-](0[1-9]|1[012])/g;
export const COMPLIANCE_OPERATORS_EXCLUDE = ['not blank', 'in', 'not in'];

export const CLASSPREFIX = CLASS_PREFIX + 'ComplianceController';
export const OBJECTPREFIX = NAMESPACE_PREFIX;
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
    [OBJECTPREFIX + "license_field__c"]: OBJECTPREFIX + "State__c",
    [OBJECTPREFIX + "object__c"]: "",
    [OBJECTPREFIX + "operator__c"]: "equals",
    [OBJECTPREFIX + "field__c"]: "",
    [OBJECTPREFIX + "isactive__c"]: false
  },
  "residentLicenseRule": {
    [OBJECTPREFIX + "object__c"]: "",
    [OBJECTPREFIX + "operator__c"]: "equals",
    [OBJECTPREFIX + "value__c"]: null
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

export const BLANK_LICENSE_APROVAL_RULE_SET_RESULT = {
  "stateRule": null,
  "residentLicenseRule": null,
  "ruleSets": [
    {
      "deletedRegularFilterRules": [],
      "deletedLicenseRules": [],
      "isFilterRuleLogicRemoved": false,
      "isLicenseRuleLogicRemoved": false,
      "filterRuleLogic": {},
      "licenseRuleLogic": {
         [OBJECTPREFIX +"object__c"]:  OBJECTPREFIX +"License__c",
         [OBJECTPREFIX +"isactive__c"]: true,
      },
      "licenseRules": [],
      "regularFilterRules": []
    }
  ]
}

export const SKIPLOA = {
  [OBJECTPREFIX + "download_spreadsheet__c"]: true,
  [OBJECTPREFIX + "watch_configuration_video__c"]: true,
  [OBJECTPREFIX + "send_spreadsheet__c"]: true,
  [OBJECTPREFIX + "filled_spreadsheet__c"]: true,
  [OBJECTPREFIX + "configure_loa_skip__c"] : true
}

export const SKIPCOMPLIANCE = {
  [OBJECTPREFIX + 'watch_video__c']: true,
  [OBJECTPREFIX + 'custom_object__c']: true,
  [OBJECTPREFIX + 'watch_compliance_video__c']: true,
  [OBJECTPREFIX + 'activate_compliance_skip__c']: true,
}

export const SKIPNIPR = {
  [OBJECTPREFIX + "nipr_setup__c"]: true,
  [OBJECTPREFIX + "nipr_integration_skip__c"] : true,
  [OBJECTPREFIX + "heroku_application_created__c"] : true,
  [OBJECTPREFIX + "set_approvals__c"] : true,
}
var TestData = {
  "SObjectNames": [
    'account',
    'opportunity',
    'testcustomobject__c',
    'case'
  ],
  "allRuleSetResults": {
    "account": {
      "stateRule": {
        [NAMESPACE_PREFIX + "license_field__c"]: NAMESPACE_PREFIX + "State__c",
        [NAMESPACE_PREFIX + "object__c"]: "account",
        [NAMESPACE_PREFIX + "operator__c"]: "equals",
        [NAMESPACE_PREFIX + "field__c"]: "BillingState",
        [NAMESPACE_PREFIX + "isactive__c"]: true
      },
      "residentLicenseRule": {
        [NAMESPACE_PREFIX + "object__c"]: "account",
        [NAMESPACE_PREFIX + "operator__c"]: "equals",
        [NAMESPACE_PREFIX + "value__c"]: "Resident Rule"
      },
      "ruleSets": [
        {
          "deletedRegularFilterRules": [],
          "deletedLicenseRules": [],
          "isFilterRuleLogicRemoved": false,
          "isLicenseRuleLogicRemoved": false,
          "filterRuleLogic": {
            "id": "a0936000001bI8G",
            "name": "accountRuleLogic2",
            [NAMESPACE_PREFIX + "object__c"]: "account",
            [NAMESPACE_PREFIX + "logic__c"]: "a0836000005XiRT &amp; a0836000005XiRR", //rule from DB
            [NAMESPACE_PREFIX + "filter_rule__c"]: "a0936000001bAHS", //child
            [NAMESPACE_PREFIX + "isactive__c"]: false,
            "recordtypeid": "01236000000mbCw", //License Rule
          },
          "licenseRuleLogic": {
            "id": "a0936000001bAHS",
            "name": "accountRuleLogic1",
            [NAMESPACE_PREFIX + "object__c"]: "account",
            [NAMESPACE_PREFIX + "logic__c"]: "a0836000005XiRTAA0 &amp; a0836000006MZfUAAW", //logic from db
            [NAMESPACE_PREFIX + "filter_rule__c"]: null, //parent
            [NAMESPACE_PREFIX + "isactive__c"]: false
          },
          "licenseRules": [
            {
              "id": "a0836000005XiRTAA0",
              [NAMESPACE_PREFIX + "object__c"]: "account",
              [NAMESPACE_PREFIX + "license_field__c"]: NAMESPACE_PREFIX + "Cost__c",
              [NAMESPACE_PREFIX + "operator__c"]: "equals",
              [NAMESPACE_PREFIX + "field__c"]: "Revenue",
              [NAMESPACE_PREFIX + "isactive__c"]: false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000006MZfUAAW",
              [NAMESPACE_PREFIX + "object__c"]: "account",
              [NAMESPACE_PREFIX + "license_field__c"]: NAMESPACE_PREFIX + "State__c",
              [NAMESPACE_PREFIX + "operator__c"]: "equals",
              [NAMESPACE_PREFIX + "field__c"]: "BillingState",
              [NAMESPACE_PREFIX + "isactive__c"]: false,
              "recordtypeid": "01236000000mZjR",
            }
          ],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRT",
              [NAMESPACE_PREFIX + "object__c"]: "account",
              [NAMESPACE_PREFIX + "field__c"]: "BillingState",
              [NAMESPACE_PREFIX + "operator__c"]: "equals",
              [NAMESPACE_PREFIX + "value__c"]: "Banking",
              [NAMESPACE_PREFIX + "isactive__c"]: false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000005XiRR",
              [NAMESPACE_PREFIX + "object__c"]: "account",
              [NAMESPACE_PREFIX + "field__c"]: "CreatedDate",
              [NAMESPACE_PREFIX + "operator__c"]: "greater than",
              [NAMESPACE_PREFIX + "value__c"]: "2016-06-27 08:08:08",
              [NAMESPACE_PREFIX + "isactive__c"]: false,
              "recordtypeid": "01236000000mZjR",
            },
          ]
        }
      ]
    },
    "opportunity": {
      "stateRule": {
        [NAMESPACE_PREFIX + "license_field__c"]: NAMESPACE_PREFIX + "State__c",
        [NAMESPACE_PREFIX + "object__c"]: "opportunity",
        [NAMESPACE_PREFIX + "operator__c"]: "equals",
        [NAMESPACE_PREFIX + "isactive__c"]: false,
        [NAMESPACE_PREFIX + "field__c"]: "BillingState"
      },
      "residentLicenseRule": null,
      "ruleSets": [
        {
          "deletedRegularFilterRules": [],
          "deletedLicenseRules": [],
          "isFilterRuleLogicRemoved": false,
          "isLicenseRuleLogicRemoved": false,
          "filterRuleLogic": {
            "id": "a0936000001bAHS",
            "name": "accountRuleLogic1",
            [NAMESPACE_PREFIX + "object__c"]: "opportunity",
            [NAMESPACE_PREFIX + "logic__c"]: "a0836000005XiRTAA0", //logic from db
            [NAMESPACE_PREFIX + "filter_rule__c"]: null, //parent
            [NAMESPACE_PREFIX + "isactive__c"]: false
          },
          "licenseRuleLogic": {},
          "licenseRules": [],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRTAA0",
              [NAMESPACE_PREFIX + "object__c"]: "opportunity",
              [NAMESPACE_PREFIX + "field__c"]: "State__c",
              [NAMESPACE_PREFIX + "operator__c"]: "equals",
              [NAMESPACE_PREFIX + "value__c"]: "&lt;script type=&quot;text/javascript&quot;&gt;body.onload = function() {alert(1)};&lt;/script&gt;",
              [NAMESPACE_PREFIX + "isactive__c"]: false,
              "recordtypeid": "01236000000mZjG",
            }
          ]
        }
      ]
    }
  },
  "lines": [
    {
      "Id": "a0836000005Xi2342342",
      "Name": "My Medical &amp; Life",
      [NAMESPACE_PREFIX + "loa_name__c"]: "My Medical &amp; Life",
      [NAMESPACE_PREFIX + "type__c"]: "Medical"
    }
  ],
  "accountsobject": {
    "label": 'Account',
    "fields": {
      "BillingState": "STRING_FIELD",
      "ShippingState": "STRING_FIELD",
      "Revenue": "DOUBLE_FIELD",
      "Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type": "STRING_FIELD"
    }
  },
  "testcustomobject__csobject": {
    "label": 'Test Custom Object',
    "fields": {
      "BillingState": "STRING_FIELD",
      "ShippingState": "STRING_FIELD",
      "Revenue": "DOUBLE_FIELD",
      "Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type": "STRING_FIELD"
    }
  },
  "opportunitysobject": {
    "label": 'Opportunity',
    "fields": {
      "State__c": "STRING_FIELD",
      "BillingState": "STRING_FIELD",
      "Industry": "STRING_FIELD",
      "Cost__c": "DOUBLE_FIELD",
      "Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type__c": "STRING_FIELD",
      "LastModifiedById": "ID_FIELD"
    }
  },
  "casesobject": {
    "label": 'Case',
    "fields": {
      "State__c": "STRING_FIELD",
      "Cost__c": "DOUBLE_FIELD",
      "Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type__c": "STRING_FIELD"
    }
  },
  [NAMESPACE_PREFIX + "license__csobject"]: {
    "label": 'License',
    "fields": {
      [NAMESPACE_PREFIX + "State__c"]: "STRING_FIELD",
      [NAMESPACE_PREFIX + "Cost__c"]: "DOUBLE_FIELD",
      [NAMESPACE_PREFIX + "Is_Active__c"]: "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      [NAMESPACE_PREFIX + "Type__c"]: "STRING_FIELD"
    }
  },
  "checklist": {
    "Id": 'a0736000005GIG1AAO',
    [NAMESPACE_PREFIX + "download_spreadsheet__c"]: true,
    [NAMESPACE_PREFIX + "watch_configuration_video__c"]: true,
    [NAMESPACE_PREFIX + "send_spreadsheet__c"]: true,
    [NAMESPACE_PREFIX + "filled_spreadsheet__c"]: true,
    [NAMESPACE_PREFIX + "watch_video__c"]: true,
    [NAMESPACE_PREFIX + "set_approvals__c"]: true,
    [NAMESPACE_PREFIX + "watch_compliance_video__c"]: true,
    [NAMESPACE_PREFIX + "custom_object__c"]: false,
    [NAMESPACE_PREFIX + 'nipr_setup__c']: true,
    [NAMESPACE_PREFIX + 'nipr_integration__c']: true,
    [NAMESPACE_PREFIX + 'configure_loa_skip__c']: true,
    [NAMESPACE_PREFIX + 'activate_compliance_skip__c']: true,
    [NAMESPACE_PREFIX + 'nipr_integration_skip__c']: true,
    [NAMESPACE_PREFIX + 'heroku_application_created__c']: true
  },
  "niprSyncConfig": {
    "Id": 'a07360000233AAO',
    [NAMESPACE_PREFIX + "NIPR_Integration_User_Name__c"]: 'asdasdad',
    [NAMESPACE_PREFIX + "ForceExpire__c"]: false,
    [NAMESPACE_PREFIX + "ApprovalProcess__c"]: '',
  },
  "licenseRuleSetResult": {
    "stateRule": null,
    "residentLicenseRule": null,
    "ruleSets": [
      {
        "licenseRules": [
          {
            "CreatedDate": 1472035659000,
            "Id": "a025000000cNIuoAAG",
            "RecordTypeId": "012500000009xqXAAQ",
            [NAMESPACE_PREFIX + "Object__c"]: NAMESPACE_PREFIX + "License__c",
            [NAMESPACE_PREFIX + "License_Field__c"]: "LastModifiedDate",
            [NAMESPACE_PREFIX + "Operator__c"]: "equals",
            [NAMESPACE_PREFIX + "Value__c"]: "2016-08-24 04:36:50",
            [NAMESPACE_PREFIX + "isActive__c"]: true,
          },
          {
            "CreatedDate": 1472035659000,
            "Id": "a025000000cNIuoAAG",
            "RecordTypeId": "012500000009xqXAAQ",
             [NAMESPACE_PREFIX +"Object__c"]:  NAMESPACE_PREFIX +"License__c",
             [NAMESPACE_PREFIX +"License_Field__c"]: "LastModifiedDate",
             [NAMESPACE_PREFIX +"Operator__c"]: "equals",
             [NAMESPACE_PREFIX +"Value__c"]: "2016-08-24 04:36:50",
             [NAMESPACE_PREFIX +"isActive__c"]: true,
          },
        ],
        "licenseRuleLogic": {
          "CreatedDate": 1472034403000,
          "Id": "a015000000wpQyHAAU",
           [NAMESPACE_PREFIX +"Logic__c"]: "a025000000cNIuoAAG & a025000000cNIuoAAs",
           [NAMESPACE_PREFIX +"Object__c"]:  NAMESPACE_PREFIX +"License__c",
          "RecordTypeId": "012500000009xqVAAQ",
           [NAMESPACE_PREFIX +"isActive__c"]: true,
        },
        "deletedRegularFilterRules": [],
        "deletedLicenseRules": [],
        "isFilterRuleLogicRemoved": false,
        "isLicenseRuleLogicRemoved": false,
        "filterRuleLogic": null,
        "regularFilterRules": []
      }
    ]
  },
  "licenseApprovalFields": {
    "label": 'License Approval',
    "fields": {
      "BillingState": "STRING_FIELD",
      "ShippingState": "STRING_FIELD",
      [NAMESPACE_PREFIX + "Revenue"]: "DOUBLE_FIELD",
      [NAMESPACE_PREFIX + "Is_Active__c"]: "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type": "STRING_FIELD"
    }
  },
  validationUsers: [
    { ID: 1, Name: "Troy", lastname: "conquer", Username: "troy@gonimbly.com" },
    { ID: 2, Name: "Hopper", lastname: "conquer", Username: "hopper@gonimbly.com" },
    { ID: 3, Name: "Dr.Brenner", lastname: "conquer", Username: "brenner@gonimbly.com" },
    { ID: 4, Name: "Jonathan", lastname: "conquer", Username: "jonathan@gonimbly.com" },
    { ID: 5, Name: "Nancy", lastname: "conquer", Username: "nancy@gonimbly.com" },
    { ID: 6, Name: "Mik", lastname: "conquer", Username: "mik@gonimbly.com" },
    { ID: 7, Name: "Eleven", lastname: "conquer", Username: "eleven@gonimbly.com" },
  ],
  "approvalProcesses": ["Approval Process 1", "Approval Process 2", "Approval Process 3", "Approval Process 4",]
};

module.exports = TestData;
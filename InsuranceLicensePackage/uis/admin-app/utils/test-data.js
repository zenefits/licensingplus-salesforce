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
        "license_field__c": "State__c",
        "object__c": "account",
        "operator__c": "equals",
        "field__c": "BillingState",
        "isActive__c": true
      },
      "residentLicenseRule": {
        "object__c": "account",
        "operator__c": "equals",
        "value__c": "Resident Rule"
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
            "object__c": "account",
            "logic__c": "a0836000005XiRT &amp; a0836000005XiRR", //rule from DB
            "filter_rule__c": "a0936000001bAHS", //child
            "isactive__c": false,
            "recordtypeid": "01236000000mbCw", //License Rule
          },
          "licenseRuleLogic": {
            "id": "a0936000001bAHS",
            "name": "accountRuleLogic1",
            "object__c": "account",
            "logic__c": "a0836000005XiRTAA0 &amp; a0836000006MZfUAAW", //logic from db
            "filter_rule__c": null, //parent
            "isactive__c": false
          },
          "licenseRules": [
            {
              "id": "a0836000005XiRTAA0",
              "object__c": "account",
              "license_field__c": "Cost__c",
              "operator__c": "equals",
              "field__c": "Revenue",
              "isactive__c": false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000006MZfUAAW",
              "object__c": "account",
              "license_field__c": "State__c",
              "operator__c": "equals",
              "field__c": "BillingState",
              "isactive__c": false,
              "recordtypeid": "01236000000mZjR",
            }
          ],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRT",
              "object__c": "account",
              "field__c": "BillingState",
              "operator__c": "equals",
              "value__c": "Banking",
              "isactive__c": false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000005XiRR",
              "object__c": "account",
              "field__c": "CreatedDate",
              "operator__c": "greater than",
              "value__c": "2016-06-27 08:08:08",
              "isactive__c": false,
              "recordtypeid": "01236000000mZjR",
            },
          ]
        }
      ]
    },
    "opportunity": {
      "stateRule": {
        "license_field__c": "State__c",
        "object__c": "opportunity",
        "operator__c": "equals",
        "isactive__c": false,
        "field__c": "BillingState"
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
            "object__c": "opportunity",
            "Logic__c": "a0836000005XiRTAA0", //logic from db
            "filter_rule__c": null, //parent
            "isactive__c": false
          },
          "licenseRuleLogic": {},
          "licenseRules": [],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRTAA0",
              "object__c": "opportunity",
              "field__c": "State__c",
              "operator__c": "equal",
              "value__c": "&lt;script type=&quot;text/javascript&quot;&gt;body.onload = function() {alert(1)};&lt;/script&gt;",
              "isactive__c": false,
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
      "LOA_Name__c": "My Medical &amp; Life",
      "Type__c": "Medical"
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
  "license__csobject": {
    "label": 'License',
    "fields": {
      "State__c": "STRING_FIELD",
      "Cost__c": "DOUBLE_FIELD",
      "Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "Type__c": "STRING_FIELD"
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
  "checklist": {
    Id: 'a0736000005GIG1AAO',
    download_spreadsheet__c: false,
    watch_configuration_video__c: true,
    send_spreadsheet__c: true,
    filled_spreadsheet__c: true,
    watch_video__c: true,
    set_approvals__c: true,
    watch_compliance_video__c: true
  }
}

module.exports = TestData;
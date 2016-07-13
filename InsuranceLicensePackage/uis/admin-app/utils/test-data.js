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
        "licensingplus__license_field__c": "LicensingPlus__State__c",
        "licensingplus__object__c": "account",
        "licensingplus__operator__c": "equals",
        "licensingplus__field__c": "BillingState",
        "licensingplus__isactive__c": true
      },
      "residentLicenseRule": {
        "licensingplus__object__c": "account",
        "licensingplus__operator__c": "equals",
        "licensingplus__value__c": "Resident Rule"
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
            "licensingplus__object__c": "account",
            "licensingplus__logic__c": "a0836000005XiRT &amp; a0836000005XiRR", //rule from DB
            "licensingplus__filter_rule__c": "a0936000001bAHS", //child
            "licensingplus__isactive__c": false,
            "recordtypeid": "01236000000mbCw", //License Rule
          },
          "licenseRuleLogic": {
            "id": "a0936000001bAHS",
            "name": "accountRuleLogic1",
            "licensingplus__object__c": "account",
            "licensingplus__logic__c": "a0836000005XiRTAA0 &amp; a0836000006MZfUAAW", //logic from db
            "licensingplus__filter_rule__c": null, //parent
            "licensingplus__isactive__c": false
          },
          "licenseRules": [
            {
              "id": "a0836000005XiRTAA0",
              "licensingplus__object__c": "account",
              "licensingplus__license_field__c": "Cost__c",
              "licensingplus__operator__c": "equals",
              "licensingplus__field__c": "Revenue",
              "licensingplus__isactive__c": false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000006MZfUAAW",
              "licensingplus__object__c": "account",
              "licensingplus__license_field__c": "LicensingPlus__State__c",
              "licensingplus__operator__c": "equals",
              "licensingplus__field__c": "BillingState",
              "licensingplus__isactive__c": false,
              "recordtypeid": "01236000000mZjR",
            }
          ],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRT",
              "licensingplus__object__c": "account",
              "licensingplus__field__c": "BillingState",
              "licensingplus__operator__c": "equals",
              "licensingplus__value__c": "Banking",
              "licensingplus__isactive__c": false,
              "recordtypeid": "01236000000mZjG",
            },
            {
              "id": "a0836000005XiRR",
              "licensingplus__object__c": "account",
              "licensingplus__field__c": "CreatedDate",
              "licensingplus__operator__c": "greater than",
              "licensingplus__value__c": "2016-06-27 08:08:08",
              "licensingplus__isactive__c": false,
              "recordtypeid": "01236000000mZjR",
            },
          ]
        }
      ]
    },
    "opportunity": {
      "stateRule": {
        "licensingplus__license_field__c": "LicensingPlus__State__c",
        "licensingplus__object__c": "opportunity",
        "licensingplus__operator__c": "equals",
        "licensingplus__isactive__c": false,
        "licensingplus__field__c": "BillingState"
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
            "licensingplus__object__c": "opportunity",
            "licensingplus__logic__c": "a0836000005XiRTAA0", //logic from db
            "licensingplus__filter_rule__c": null, //parent
            "licensingplus__isactive__c": false
          },
          "licenseRuleLogic": {},
          "licenseRules": [],
          "regularFilterRules": [
            {
              "id": "a0836000005XiRTAA0",
              "licensingplus__object__c": "opportunity",
              "licensingplus__field__c": "LicensingPlus__State__c",
              "licensingplus__operator__c": "equal",
              "licensingplus__value__c": "&lt;script type=&quot;text/javascript&quot;&gt;body.onload = function() {alert(1)};&lt;/script&gt;",
              "licensingplus__isactive__c": false,
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
      "licensingplus__loa_name__c": "My Medical &amp; Life",
      "licensingplus__type__c": "Medical"
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
  "licensingplus__license__csobject": {
    "label": 'License',
    "fields": {
      "LicensingPlus__State__c": "STRING_FIELD",
      "LicensingPlus__Cost__c": "DOUBLE_FIELD",
      "LicensingPlus__Is_Active__c": "BOOLEAN_FIELD",
      "CreatedDate": "DATETIME_FIELD",
      "LastModifiedDate": "DATE_FIELD",
      "LicensingPlus__Type__c": "STRING_FIELD"
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
    "Id": 'a0736000005GIG1AAO',
    "licensingplus__download_spreadsheet__c": false,
    "licensingplus__watch_configuration_video__c": true,
    "licensingplus__send_spreadsheet__c": true,
    "licensingplus__filled_spreadsheet__c": true,
    "licensingplus__watch_video__c": true,
    "licensingplus__set_approvals__c": true,
    "licensingplus__watch_compliance_video__c": true
  }
}

module.exports = TestData;
import TestData from './test-data';
import _ from 'lodash';
import {OBJECTPREFIX } from '../constants/constants';

var ComplianceController = {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Sometimes this Controller is MockData, sometimes it is 
  // a real VisualForce Remoting API
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //params:
  // none
  //returns 
  //  success - {licensingplus__checklist__c}, orgwide default checklist record 
  //  failure - "error message"
  getChecklist: function (fn) {
    setTimeout(function () {
      return fn(TestData.checklist)
    }, 300);
  },

  toggleChecklist: function (checklist, fn) {
    setTimeout(function () {
      return fn();
    }, 300);
  },


  //CCOMPLIANCE RULES VIEW
  //params:
  //  none
  //returns
  //  success - {[rules], [ruleLogics]}
  //  failure - "error message"
  getRulesets: function (fn) {
    setTimeout(function () {
      //return all rules in Salesforce
      //some massaging is necessary to render properly in the UI
      //intial thoughts:
      //  groupby object name
      //  createddata is the createddate of the oldest rule's createddate
      //  owner is the owner of the oldest rule
      //  "active" is true if all the rules of an object are active
      return fn();
    }, 300);
  },

  //params:
  //  none
  //returns 
  //  success - [{sobject-meta1},{sobject-meta2}] 
  //  failure - "error message"
  getSobjectNames: function (fn) {
    //return a list of sObject names that can have a trigger written against them
    //and are not currently configured to have rules.
    setTimeout(function () {
      return fn(TestData.SObjectNames);
    }, 300);
  },

  //params:
  // 1 - [rules], array of rule objects to toggle licensingplus__isactive__c
  // 2 - [ruleLogics], array of ruleLogic objects to toggle licensingplus__isactive__c
  //returns 
  //  success - null 
  //  failure - "error message"
  toggleLicenseRuleSet: function (objName, isActive, fn) {
    //takes an array of rules to mark isactive = boolean
    //also mark array of the related ruleLogics isactive = boolean

    console.log('isActive', isActive);
    setTimeout(() => {
      if (!(typeof objName === "string")) {
        return fn({}, { type: 'exception', message: 'ObjectName not defined' });
      }
      if (!(typeof isActive === "boolean")) {
        return fn({}, { type: 'exception', message: 'isActive not defined' });
      }
      return fn({}, { status: 200 });
    }, 300);
  },
  //END COMPLIANCE RULES VIEW
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //params:
  // 1 - "objectName", string object name
  //returns 
  //  success - {objectName: { fieldname: fieldtype } } 
  //  failure - "error message"
  getSobjectWithFields: function (objectName, fn) {

    //sobject name can be "licensingplus__license__c" or "account" or "opportunity"
    //below is the specification we expects
    var sobject = TestData[objectName + 'sobject'] || {};
    setTimeout(function () {
      return fn(sobject, { status: 200 });
    }, 300);
  },

  //params:
  // 1 - [rules], array of rule objects to upsert
  // 2 - [ruleLogics], array of ruleLogic objects to upsert
  //returns 
  //  success - null 
  //  failure - "error message"
  saveLicenseRuleSetResult: function (ruleSetResult, objectName, fn) {
    //takes an array of rules to upsert to db
    //takes array of the related ruleLogics to upsert to db
    //AND any rule or rule logic not in these lists, but related 
    //to the same parent object should be delete from the database.
    setTimeout(function () {
      if (!(ruleSetResult instanceof Object)) {
        return fn({}, { type: 'exception', message: 'rules not defined' });
      }
      if (!(typeof objectName === "string")) {
        return fn({}, { type: 'exception', message: 'ObjectName not defined' });
      }
      if (!(ruleSetResult.stateRule instanceof Object)) {
        return fn({}, { type: 'exception', message: 'State rule not defined' });
      }
      if ((ruleSetResult.stateRule instanceof Object) && ruleSetResult.stateRule[OBJECTPREFIX + 'object__c'] === '') {
        return fn({}, { type: 'exception', message: 'State rule' + OBJECTPREFIX + '\'object__c\' not defined' });
      }
      // return fn({},{type:'exception',message:'Failed on purpose.'});
      return fn({}, { status: 200 });
    }, 300);
  },

  getLicenseRuleSetResult: function (objectName, fn) {
    //sobject name can be "licensingplus__license__c" or "account" or "opportunity"
    //below is the specification we expects
    setTimeout(function () {
      var ruleSetResult = TestData.allRuleSetResults[objectName] || {};
      return fn(ruleSetResult);

    }, 300);
  },

  getAllLicenseRuleSetResults: function (fn) {
    setTimeout(function () {
      return fn(TestData.allRuleSetResults);
    }, 300);
  },

  insertLinesOfAuth: function (linesOfAuth, fn) {
    let sfdcRows = Object.assign([], linesOfAuth)
      .map((row, index) => {
        //add a simple id to each record to simulate salesoforce insert
        row.Id = index;
        return row;
      });

    setTimeout(function () {
      return fn(sfdcRows, { status: 200 });
    }, 300);
  },

  importLicenseData: function (procedures, fn) {
    var successEvent = {
      result: [
        {
          "isSuccess": true,
          "key": "17418240;1139395;Arizona;2/19/2016"
        }
      ],
      status: true
    }
    var errorEvent = {
      result: [
        {
          "errorCode": "NPN_NUMBER_NOT_FOUND",
          "errorMessage": "Not able to match owner with npn number",
          "isSuccess": false,
          "key": "17418240;1139395;Arizona;2/19/2016"
        }
      ],
      status: true
    };
    var error = {
      message: "Unable to convert date '2014-02-12' to Apex type Date.",
      status: false
    }

    setTimeout(function () {
      return fn(successEvent.result, successEvent);
    }, 200)

    // setTimeout(function () {
    //   return fn(errorEvent.result, errorEvent);
    // }, 200)    

    // setTimeout(function () {
    //   return fn(null, error);
    // }, 200)
  },

  deleteLineOfAuth: function (row, fn) {
    setTimeout(function () {
      return fn({ status: 200 });
    }, 300);
  },

  getLinesOfAuth: function (fn) {
    setTimeout(function () {
      return fn(TestData.lines, { status: 200 })
    }, 300);
  },

  getApprovalCriteriaConfig: function (fn) {
    setTimeout(function () {
      return fn({ niprSyncConfig: TestData.niprSyncConfig, licenseRuleSetResult: TestData.licenseRuleSetResult }, { status: 200 });
    }, 300);
  },

  getApprovalProcessNames: function (fn) {
    setTimeout(function () {
      return fn(TestData.approvalProcesses, { status: 200 });
    }, 300);
  },

  saveApprovalCriteriaConfig: function (niprSyncConfig, licenseRuleSetResult,fn) {
    setTimeout(function () {
      return fn({}, { status: 200 });
    }, 300);
  },

  getLicenseApprovalFields: function (fn) {
    setTimeout(function () {
      return fn(TestData.licenseApprovalFields, { status: 200 });
    }, 300);
  },

  getUserNames: function (searchStr, fn) {
    setTimeout(function () {
      var result = TestData.validationUsers.filter(function (user) {
        return user.Username.toLowerCase().indexOf(searchStr.toLowerCase()) !== -1;
      });
      return fn(result, { status: 200 });
      
    }, 300);
  }

  //END OBJECT_NAME RULE & RULE LOGIC EDITOR VIEW
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
};

//must prefix with LicensingPlus to make it deployable to other development environments
window.LicensingPlus = {};
window.LicensingPlus.ComplianceController = ComplianceController;

module.exports = window.LicensingPlus.ComplianceController;
#Data Specification for Compliance Rules App

##What are the data models we expect?

- rules
	- types (record types)
		- Regular Filter Rule
		- License State Rule
		- License Filter Rule
		- License Comparison Rule
		- Resident License Rule

- rule logics
	- record types ()

## Rules Data (expected format via js-remoting)
```
//Regular Filter Rule
{
	"id" : "a0836000005XiRT",
	"object__c" : "account",
	"field__c" : "industry",
	"oeprator__c" : "equals",
	"value__c" : "Banking",
	"isactive__c" : false,
	"recordtypeid" : "01236000000mZjG", //Regular Filter Rule
}
```

```
//License State Rule
{
	"id" : "a0836000006MsMj",
	"object__c" : "account",
	"field__c" : "BillingState1",
	"license_field__c" : "State__c",
	"oeprator__c" : "equals",
	"isactive__c" : false,
	"recordtypeid" : "01236000000md5e", //Regular State Rule
}
```

```
//License Filter Rule
{
	"id" : "a0836000006MskS",
	"name" : "License Effective Date Rule",
	"object__c" : "account",
	"value__c" : "2016-01-01",
	"license_field__c" : "Effective_Date__c",
	"oeprator__c" : "greater than",
	"isactive__c" : false,
	"recordtypeid" : "01236000000md6m", //License Filter Rule
}
```

```
//License Comparison Rule
{
	"id" : "a0836000006MZfe",
	"object__c" : "account",
	"field__c" : "Type",
	"license_field__c" : "Type__c",
	"oeprator__c" : "equals",
	"isactive__c" : false,
	"recordtypeid" : "01236000000mZih", //License Comparison Rule
}
```

```
//Resident License Rule
{
	"id" : "a0836000006MskN",
	"name" : "Account Resident License Rule",
	"object__c" : "account",
	"value__c" : "Resident State",
	"license_field__c" : "RecordType.Name",
	"oeprator__c" : "equals",
	"isactive__c" : false,
	"recordtypeid" : "01236000000md5o", //Resident License Rule
}
```

## Rule Logics Data (expected format via js-remoting)

```
//Filter Rule (parent)
{
	"id" : "a0936000001bAHS",
	"name" : "accountRuleLogic1",
	"object__c" : "account",
	"logic__c" : "a0836000005XiRTAA0 & a0836000006MZfUAAW", //rules of type: "Regular Filter Rule"
	"filter_rule__c" : null, //parent
	"isactive__c" : false,
	"recordtypeid" : "01236000000mbCr", //Filter Rule
}
```

```
//License Rule (child)
{
	"id" : "a0936000001bI8G",
	"name" : "accountRuleLogic2",
	"object__c" : "account",
	"logic__c" : "a0836000006MZfe", //rule of type: "License Comparison Rule"
	"filter_rule__c" : "a0936000001bAHS", //child
	"isactive__c" : false,
	"recordtypeid" : "01236000000mbCw", //License Rule
}
```

## @Remoting Methods for ComplianceController

```
Get all rules @Remoting Apex method (SFDC)
Rule activation @Remoting Apex method (SFDC)
Rule fitler update in Apex, sobject record (SFDC)
Dynamic dropdown for object field values (SFDC)
Apex for dynamic license field values (SFDC)
Save rules Apex @Remoting (SFDC)
Save advanced filtering logic (SFDC)
Save advanced filtering (object.field, operator, string check) (SFDC)
Remove old advanced filters (SFDC)
```

```
var ComplianceController = {
  //Sometimes this Controller is MockData, sometimes it is 
  // a real VisualForce Remoting API
  
  //params:
  // none
  //returns 
  //  success - {checklist__c}, orgwide default checklist record 
  //  failure - "error message"
  getChecklist: function (fn) {
    setTimeout(function(){
      return fn({
        Id: 'a0736000005GIG1AAO',
        download_spreadsheet__c: true,
        watch_configuration_video__c: false,
        send_spreadsheet__c: false,
        filled_spreadsheet__c: false,
        watch_video__c: false,
        set_approvals__c: false,
        watch_compliance_video__c: false
      })
    }, 300);
  },

  toggleChecklist: function (checklist, fn) {
    setTimeout(function(){
      return fn();
    }, 300);
  },

  //CCOMPLIANCE RULES VIEW
  //params:
  //  none
  //returns
  //  success - {[rules], [ruleLogics]}
  //  failure - "error message"
  getLicenseRuleSetResult: function(fn) {
    setTimeout(function(){
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
  getSobjectNames: function(fn) {
    //return a list of sObject names that can have a trigger written against them
    //and are not currently configured to have rules.
    setTimeout(function(){
      
      return fn();
    }, 300);
  },

  //params:
  // 1 - [rules], array of rule objects to toggle isactive__c
  // 2 - [ruleLogics], array of ruleLogic objects to toggle isactive__c
  //returns 
  //  success - null 
  //  failure - "error message"
  toggleRuleset: function(rules, ruleLogics, fn) {
    //takes an array of rules to mark isactive = boolean
    //also mark array of the related ruleLogics isactive = boolean
    setTimeout(function(){
      if(!(rules instanceof Array)) {
        return fn(new Error('rules not defined'));
      }
      if(!(ruleLogics instanceof Array)) {
        return fn(new Error('rule logics not defined'));
      }
      return fn();
    }, 300);
  },
  //END COMPLIANCE RULES VIEW
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //params:
  // 1 - "objectName", string object name
  //returns 
  //  success - {objectName: { fieldname: fieldtype } } 
  //  failure - "error message"
  getSobjectFields: function(objectName, fn) {
    //sobject name can be "license__c" or "account" or "opportunity"
    //below is the specification we expects
    setTimeout(function(){
      var data = {
        "type__c" : "string",
        "status__c" : "string",
        "date_made__c" : "date"
      };
      
      return fn();
    }, 300);
  },

  //params:
  // 1 - [rules], array of rule objects to upsert
  // 2 - [ruleLogics], array of ruleLogic objects to upsert
  //returns 
  //  success - null 
  //  failure - "error message"
  saveRuleset: function(rules, ruleLogics, fn) {
    //takes an array of rules to upsert to db
    //takes array of the related ruleLogics to upsert to db
    //AND any rule or rule logic not in these lists, but related 
    //to the same parent object should be delete from the database.
    setTimeout(function(){
      if(!(rules instanceof Array)) {
        return fn(new Error('rules not defined'));
      }
      if(!(ruleLogics instanceof Array)) {
        return fn(new Error('rule logics not defined'));
      }
      return fn();
    }, 300);
  }

  //END OBJECT_NAME RULE & RULE LOGIC EDITOR VIEW
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
```
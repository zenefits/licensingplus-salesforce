import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';
import Toggle from 'react-toggle'
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';

import * as constants from '../constants/constants';
import Utils from '../utils/utils';
import {
  addAdvancedRule,
  addComplianceRule,
  changeAdvancedRuleLogic,
  changeComplianceRuleLogic,
  clearState,
  deleteAdvancedRule,
  deleteComplianceRule,
  getLicenseFields,
  getLicenseRuleSetResult,
  getSobjectWithFields,
  hideToast,
  saveLicenseRuleSetResult,
  selectAdvancedChange,
  selectComplianceChange,
  selectStateRuleChange,
  toggleChangeResidentRule,
  showAdvancedRule
} from '../actions/object-rule-set-actions';

class ObjectRuleSet extends Component {

  constructor(props) {
    super(props);
    this.state = {
      advancedRulesList: [],
      advancedRuleLogic: {},
      complianceRulesList: [],
      complianceRuleLogic: {},
      deletedRegularFilterRules: [],
      deletedLicenseRules: [],
      errors: false,
      isFilterRuleLogicRemoved: false,
      isLicenseRuleLogicRemoved: false,
      isReadOnly: false,
      residentRule: null,
      residentRuleOn: false,
      stateRule: {},
      showAdvancedRule: 'All',
      showToast: false,
      sobject: {},
      loaded: false,
      licenseSobject: {}
    }

    this.addAdvancedRule = this.addAdvancedRule.bind(this);
    this.addComplianceRule = this.addComplianceRule.bind(this);
    this.changeAdvancedRuleLogic = this.changeAdvancedRuleLogic.bind(this);
    this.changeComplianceRuleLogic = this.changeComplianceRuleLogic.bind(this);
    this.deleteAdvancedRule = this.deleteAdvancedRule.bind(this);
    this.deleteComplianceRule = this.deleteComplianceRule.bind(this);
    this.handleAdvancedChange = this.handleAdvancedChange.bind(this);
    this.handleComplianceChange = this.handleComplianceChange.bind(this);
    this.handleStateRuleChange = this.handleStateRuleChange.bind(this);
    this.renderAdvancedRules = this.renderAdvancedRules.bind(this);
    this.renderComplianceRules = this.renderComplianceRules.bind(this);
    this.saveLicenseRuleSetResult = this.saveLicenseRuleSetResult.bind(this);
    this.toggleChangeResidentRule = this.toggleChangeResidentRule.bind(this);
    this.toggleShowAdvancedRule = this.toggleShowAdvancedRule.bind(this);
    this.validate = this.validate.bind(this);
  }

  componentWillMount() {
    this.props.getSobjectWithFields(this.props.params.sobjectname);
    this.props.getLicenseFields('license__c');
    this.props.getLicenseRuleSetResult(this.props.params.sobjectname);
  }

  componentWillUnmount() {
    this.props.clearState();
  }

  saveLicenseRuleSetResult(event) {
    event.preventDefault();
    var data = {
      advancedRulesList: this.props.advancedRulesList,
      advancedRuleLogic: this.props.advancedRuleLogic,
      complianceRulesList: this.props.complianceRulesList,
      complianceRuleLogic: this.props.complianceRuleLogic,
      deletedRegularFilterRules: this.props.deletedRegularFilterRules,
      deletedLicenseRules: this.props.deletedLicenseRules,
      isFilterRuleLogicRemoved: this.props.isFilterRuleLogicRemoved,
      isLicenseRuleLogicRemoved: this.props.isLicenseRuleLogicRemoved,
      residentRule: this.props.residentRule,
      showAdvancedRule: this.props.showAdvancedRule,
      stateRule: this.props.stateRule
    }

    //only way to copy entire object by value. had issues with Object.assign({},...)
    data = JSON.parse(JSON.stringify(data));
    this.props.saveLicenseRuleSetResult(data);
  }

  validate(value) {
    if (_.trim(value) === '') {
      return false;
    } else {
      return true;
    }
  }

  renderSubmit() {
    if (this.props.errors) {
      return (
        <input className='btn btn-orange' type='button' disabled={true} onClick={this.saveLicenseRuleSetResult.bind(this) } value='Save' />
      );
    } else {
      return (
        <input className='btn btn-orange' type='button' disabled={this.props.isReadOnly} onClick={this.saveLicenseRuleSetResult.bind(this) } value='Save' />
      );
    }
  }

  toggleShowAdvancedRule(event) {
    this.props.toggleShowAdvancedRule(event.target.value);
  }

  hideToast(event) {
    event.preventDefault();
    this.props.hideToast();
  }

  renderToast() {
    if (this.props.showToast) {
      return (
        <div className="alert alert-danger toast" >
          <a onClick={this.props.hideToast.bind(null) }>Dismiss</a>
          <strong className='glyphicon glyphicon-alert'></strong> Something went wrong
        </div>
      );
    }
  }
  changeAdvancedRuleLogic(error, rulesLen, event) {
    var exp = constants.RULE_EXP;
    var logic = event.target.value.replace(exp, '');
    if (Utils.checkSyntax(logic, rulesLen)) {
      this.props.changeAdvancedRuleLogic(event.target.value.replace(exp, ''), false);
    } else {
      this.props.changeAdvancedRuleLogic(event.target.value.replace(exp, ''), true);
    }
  }

  changeComplianceRuleLogic(error, rulesLen, event) {
    var exp = constants.RULE_EXP;
    var logic = event.target.value.replace(exp, '');
    if (Utils.checkSyntax(logic, rulesLen)) {
      this.props.changeComplianceRuleLogic(event.target.value.replace(exp, ''), false);
    } else {
      this.props.changeComplianceRuleLogic(event.target.value.replace(exp, ''), true);
    }
  }

  handleAdvancedChange(index, colIndex, fieldValue, colName, event) {
    var valueType = 'STRING_FIELD';
    var error = this.props.errors;
    var value;

    if (colName === 'field__c') {
      value = event.target.value;
      valueType = this.props.sobject.fields[value];
      error = (_.trim(value) === '') ? true : false;
    } else if (colName === 'operator__c') {
      value = event.target.value;
      valueType = this.props.sobject.fields[fieldValue];
      error = (_.trim(value) === '') ? true : false;
    } else if (colName === 'value__c') {
      valueType = this.props.sobject.fields[fieldValue];
      switch (valueType) {
        case 'BOOLEAN_FIELD':
          error = false;
          value = event.target.value;
          break;
        case 'DATE_FIELD':
          value = Utils.formatSfdcDate(event);
          break;
        case 'DATETIME_FIELD':
          value = Utils.formatSfdcDateTime(event);
          break;
        default:
          value = event.target.value;
          error = (_.trim(value) === '') ? true : false;
      }
    }
    this.props.selectAdvancedChange(value, colName, index, colIndex, error);
  }

  handleComplianceChange(index, colIndex, error, event) {
    if (_.trim(event.target.value) === '') {
      this.props.selectComplianceChange(event.target.value, event.target.name, index, colIndex, true);
    } else {
      this.props.selectComplianceChange(event.target.value, event.target.name, index, colIndex, false);
    }
  }

  handleStateRuleChange(event) {
    this.props.selectStateRuleChange(event.target.value);
  }

  toggleChangeResidentRule(value, event) {
    this.props.toggleChangeResidentRule(value, this.props.params.sobjectname);
  }

  deleteComplianceRule(index) {
    this.props.deleteComplianceRule(index);
  }

  deleteAdvancedRule(index) {
    this.props.deleteAdvancedRule(index);
  }

  addComplianceRule() {
    this.props.addComplianceRule(this.props.params.sobjectname);
  }

  addAdvancedRule() {
    this.props.addAdvancedRule(this.props.params.sobjectname);
  }

  renderAdvancedFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      Object.keys(this.props.sobject.fields).map((key) => {
        return (
          <option key={key} value={key}>{key}</option>
        );
      })
    );
  }

  renderAdvancedFieldsInCompliance(valueType) {
    var fieldType = this.props.licenseSobject.fields[valueType];
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      _.map(this.props.sobject.fields, (value, key) => {
        if (value === fieldType) {
          return (
            <option key={key} value={key}>{_.capitalize(this.props.params.sobjectname) }.{key}</option>
          );
        }
      })
    );
  }

  renderAdvancedOperators(valueType) {
    var options = [<option key={'Operator'} value=''>Operator</option>];
    var operators = constants.FIELD_OPERATORS;
    return options.concat(
      _.map(operators[this.props.sobject.fields[valueType]], (value, key) => {
        return (
          <option key={key} value={key}>{value}</option>
        );
      })
    );
  }

  renderComplianceFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      Object.keys(this.props.licenseSobject.fields).map((key, value) => {
        return (
          <option key={key} value={key}>{key}</option>
        );
      })
    );
  }

  renderComplianceOperators(valueType) {
    var options = [<option key={'Operator'} value=''>Operator</option>];
    var operators = constants.FIELD_OPERATORS;
    var excludeOperators = constants.COMPLIANCE_OPERATORS_EXCLUDE;
    return options.concat(
      _.map(operators[this.props.licenseSobject.fields[valueType]], (value, key) => {
        if (!_.includes(excludeOperators, value)) {
          return (
            <option key={key} value={key}>{value}</option>
          )
        }
      })
    )
  }

  renderStateRuleFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return (
      options.concat(
        _.map(this.props.sobject.fields, (value, key) => {
          if (value === 'STRING_FIELD') {
            return (
              <option key={key} value={key}>{_.capitalize(this.props.params.sobjectname) }.{key}</option>
            )
          }
        })
      )
    )
  }

  renderStateRule() {
    let stateRule = this.props.stateRule;
    if (stateRule && stateRule.license_field__c) {
      var fieldClassname = (stateRule.field__c === '') ? 'form-group has-error' : ' form-group';
      return (
        <tr key={0}>
          <td></td>
          <td>
            <div className='form-group'>
              <select className='form-control' value={stateRule.license_field__c} name='license_field__c' disabled={true}>
                <option value={stateRule.license_field__c}>{stateRule.license_field__c}</option>
              </select>
            </div>
          </td>
          <td>
            <div className='form-group'>
              <select className='form-control' value={stateRule.operator__c} name='operator__c' disabled={true}>
                <option value={stateRule.operator__c}>{stateRule.operator__c}</option>
              </select>
            </div>
          </td>
          <td>
            <div className={fieldClassname}>
              <select className='form-control' disabled={this.props.isReadOnly} value={stateRule.field__c} onChange={this.handleStateRuleChange.bind(null) } name='field__c'>
                {this.renderStateRuleFields() }
              </select>
            </div>
          </td>
          <td></td>
        </tr >
      )
    }
  }

  renderComplianceRulesList() {
    if (this.props.complianceRulesList.length) {
      let licenseInput;
      let fieldInput;
      let operatorInput;
      return this.props.complianceRulesList.map((item, index) => {
        var licClassname = !this.validate(item.license_field__c) ? 'form-group has-error' : ' form-group';
        licenseInput = (
          <div className={licClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item.license_field__c} name='license_field__c' onChange={this.handleComplianceChange.bind(null, index, '0', true) }>
              {this.renderComplianceFields() }
            </select>
          </div>
        );

        var operatorClassname = !this.validate(item.operator__c) ? 'form-group has-error' : ' form-group';
        operatorInput = (
          <div className={operatorClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item.operator__c} name='operator__c' onChange={this.handleComplianceChange.bind(null, index, '1', true) }>
              {this.renderComplianceOperators(item.license_field__c) }
            </select>
          </div>
        );

        var fieldClassname = !this.validate(item.field__c) ? 'form-group has-error' : ' form-group';
        fieldInput = (
          <div className={fieldClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item.field__c} name='field__c' onChange={this.handleComplianceChange.bind(null, index, '2', true) }>
              {this.renderAdvancedFieldsInCompliance(item.license_field__c) }
            </select>
          </div>
        );

        return (
          <tr key={index + 1}>
            <td>{index + 1}</td>
            <td>
              {licenseInput}
            </td>
            <td>
              {operatorInput}
            </td>
            <td>
              {fieldInput}
            </td>
            <td><button className='add-btn' disabled={this.props.isReadOnly} onClick={this.deleteComplianceRule.bind(null, index) } >-</button></td>
          </tr>
        );
      });
    }
  }

  renderAdvancedRulesList() {
    if (this.props.advancedRulesList && this.props.advancedRulesList.length) {
      let valueInput;
      let fieldInput;
      let operatorInput;
      return this.props.advancedRulesList.map((item, index) => {
        var fieldClassname = !this.validate(item.field__c) ? 'form-group has-error' : ' form-group';
        fieldInput = (
          <div className={fieldClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item.field__c} name='field__c' onChange={this.handleAdvancedChange.bind(null, index, '0', this.props.sobject.fields[item.field__c], 'field__c') }>
              {this.renderAdvancedFields() }
            </select>
          </div>
        );
        var fieldType = this.props.sobject.fields[item.field__c];
        var operatorClassname = !this.validate(item.operator__c) ? 'form-group has-error' : ' form-group';
        operatorInput = (
          <div className={operatorClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item.operator__c} name='operator__c' onChange={this.handleAdvancedChange.bind(null, index, '1', item.field__c, 'operator__c') }>
              {this.renderAdvancedOperators(item.field__c) }
            </select>
          </div>
        );
        var valueClassname = (!this.validate(item.value__c) && item.operator__c !== 'not blank') ? 'form-group has-error' : ' form-group';
        if (item.operator__c === 'not blank') {
          valueInput = (
            <div className={valueClassname} >
              <input className='form-control' type='text' disabled={true} value='' name='value__c'/>
            </div>
          );
        }
        else if (fieldType === 'DATE_FIELD' || fieldType === 'DATETIME_FIELD') {
          valueInput = (
            <div className='form-group'>
              <DatePicker className='form-control' disabled={this.props.isReadOnly} selected={moment(item.value__c) } onChange={this.handleAdvancedChange.bind(null, index, '2', item.field__c, 'value__c') } />
            </div>
          );
        }
        else if (fieldType === 'BOOLEAN_FIELD') {
          valueInput = (
            <div className='form-group'>
              <select ref='value__c' className='form-control' disabled={this.props.isReadOnly} value={item.value__c || 'true'} name='value__c' onChange={this.handleAdvancedChange.bind(null, index, '2', item.field__c, 'value__c') }>
                <option value='true' >True</option>
                <option value='false'>False</option>
              </select>
            </div>
          );
        }
        else {
          valueInput = (
            <div className={valueClassname} >
              <input className='form-control' type='text' disabled={this.props.isReadOnly} value={_.unescape(item.value__c) || ''} name='value__c' onChange={this.handleAdvancedChange.bind(null, index, '2', item.field__c, 'value__c') }/>
            </div>
          );
        }

        return (
          <tr key={index}>
            <td>{index + 1}</td>
            <td>
              {fieldInput}
            </td>
            <td>
              {operatorInput}
            </td>
            <td>
              {valueInput}
            </td>
            <td><button className='add-btn' disabled={this.props.isReadOnly} onClick={this.deleteAdvancedRule.bind(null, index) }>-</button></td>
          </tr>
        );
      });
    } else {
      return (
        <tr>
          <td colspan='5'>
            No rules added
          </td>
        </tr>
      )
    }
  }

  renderComplianceRules() {
    let objectName = this.props.params.sobjectname;
    let isValidSyntax = Utils.checkSyntax(this.props.complianceRuleLogic.logic__c, this.props.complianceRulesList.length);
    let logic;
    let length = this.props.complianceRulesList.length;
    if ((isValidSyntax && length) || (isValidSyntax && !length)) {
      logic = (
        <div className='form-group'>
          <input type='text' className='form-control grid-input' disabled={this.props.isReadOnly} value={this.props.complianceRuleLogic.logic__c || ''} onChange={this.changeComplianceRuleLogic.bind(null, false, this.props.complianceRulesList.length) }></input>
        </div>
      );
    }
    else {
      logic = (
        <div className='form-group has-error'>
          <input type='text' className='form-control grid-input form-control-danger' disabled={this.props.isReadOnly} value={this.props.complianceRuleLogic.logic__c || ''} onChange={this.changeComplianceRuleLogic.bind(null, true, this.props.complianceRulesList.length) }></input>
          <small className='text-help'>Invalid logic syntax</small>
        </div>
      );
    }
    return (
      <span className='data-table'>
        <div className='heading-table'>
          <h5>Compliance Pass Criteria</h5>
          <button className='btn btn-orange' disabled={this.props.isReadOnly} onClick={this.addComplianceRule.bind(null) }>Add Criteria +</button>
        </div>
        <table className='table table-hover table-fixed custom-table'>
          <thead>
            <tr>
              <th>Rule Number</th>
              <th>License Field</th>
              <th>Operator</th>
              <th>{_.capitalize(objectName) } Object Field</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this.renderStateRule() }
            {this.renderComplianceRulesList() }
          </tbody>
        </table>
        <h5>Compliance Pass Logic</h5>
        {logic}
        <hr className='divider-grid'/>
      </span>
    );
  }

  renderAdvancedRules() {
    if (this.props.showAdvancedRule === 'Specific') {
      let objectName = this.props.params.sobjectname;
      let isValidSyntax = Utils.checkSyntax(this.props.advancedRuleLogic.logic__c, this.props.advancedRulesList.length);
      let logic;
      let length = this.props.advancedRulesList.length;
      if ((isValidSyntax && length) || (isValidSyntax && !length)) {
        logic = (
          <div className='form-group'>
            <input type='text' className='form-control grid-input' disabled={this.props.isReadOnly} value={this.props.advancedRuleLogic.logic__c || ''} onChange={this.changeAdvancedRuleLogic.bind(null, false, this.props.advancedRulesList.length) }></input>
          </div>
        );
      }
      else {
        logic = (
          <div className='form-group has-error'>
            <input type='text' className='form-control grid-input form-control-danger' disabled={this.props.isReadOnly} value={this.props.advancedRuleLogic.logic__c || ''} onChange={this.changeAdvancedRuleLogic.bind(null, true, this.props.advancedRulesList.length) }></input>
            <small className='text-help'>Invalid logic syntax</small>
          </div>
        );
      }

      return (
        <span className='data-table'>
          <div className='heading-table'>
            <h5>Advanced Rule Filtering</h5>
            <button className='btn btn-orange' disabled={this.props.isReadOnly} onClick={this.addAdvancedRule.bind(null) }>Add Criteria +</button>
          </div>
          <table className='table table-hover table-fixed custom-table'>
            <thead>
              <tr>
                <th>Rule Number</th>
                <th>{_.capitalize(objectName) } Field</th>
                <th>Operator</th>
                <th>Value</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this.renderAdvancedRulesList() }
            </tbody>
          </table>
          <h5>Advanced Rule Logic</h5>
          {logic}
          <hr className='divider-grid'/>
        </span>
      );
    }
  }

  render() {
    let objectLabel = this.props.sobject.label;
    var toggle;
    if (this.props.loaded) {
      toggle = (
        <Toggle
          disabled={this.props.isReadOnly}
          defaultChecked={this.props.residentRuleOn}
          onChange={this.toggleChangeResidentRule.bind(null, !this.props.residentRuleOn) } />
      );
    }

    var links = (
      <div className='salesforce-link-rules'>
        <p>
          <small><span className='glyphicon glyphicon-question-sign'></span> Need more help?<a href='https://www.youtube.com/watch?v=E-0EpztLz0c' target='blank'>Watch our video!</a></small>
        </p>
        <p>
          <a href='/'>Exit to Salesforce</a>
        </p>
      </div>
    )

    var back = (
      <h4>
        <Link to={`/checklist`}>
          &lt; Back to Checklist
        </Link>
      </h4>
    )

    var sideNavigation = (
      <div className="col-sm-3 zenefits-nav">
        {back}
        <h1>Activate your compliance rule.</h1>
        <p>We have already created a few rules that represent standard rules that most team needs.</p>
        <p>After you have setup the app you can add more rules.</p>
        {links}
      </div>
    );

    if (this.props.checklistComplete) {
      sideNavigation = (
        <div className="col-sm-3 zenefits-nav">
          {back}
          <ul className="nav nav-pills nav-stacked">
            <li role="presentation" className="active"><Link to={`/rules`}>Compliance Rules</Link></li>
            <li role="presentation"><Link to={`/lines`}>Lines of Authority</Link></li>
          </ul>
          {links}
        </div>
      );
    }

    return (
      <div className='rules-page license-form'>
        {this.renderToast() }
        <div className='row'>
          {sideNavigation}
          <div className='col-sm-9 inside-container'>
            <h4>{_.capitalize(objectLabel) } Compliance Rule Set </h4>
            <h5 className='heading-table'>Rules Set Filter</h5>
            <div className='heading-table'>
              <h4>Resident Licence Check</h4>
              <small>We ensure agent has active resident liscence</small>
              {toggle}
            </div>
            <span className='filtered-records'>Filtered Records</span>
            <select className='form-control select-filtered-records' disabled={this.props.isReadOnly} value={this.props.showAdvancedRule} onChange={this.toggleShowAdvancedRule.bind(this) }>
              <option value='All'>All Records</option>
              <option value='Specific'>Specific Records</option>
            </select>
            <hr className='divider'/>
            {this.renderAdvancedRules() }
            {this.renderComplianceRules() }
            <div className='submit-box'>
              {this.renderSubmit() }
              <Link to='/rules' className='btn btn-white' role='button'>Cancel</Link>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    advancedRulesList: state.advancedRulesList,
    advancedRuleLogic: state.advancedRuleLogic,
    checklistComplete: state.checklistComplete,
    complianceRulesList: state.complianceRulesList,
    complianceRuleLogic: state.complianceRuleLogic,
    deletedLicenseRules: state.deletedLicenseRules,
    deletedRegularFilterRules: state.deletedRegularFilterRules,
    errors: state.errors,
    isReadOnly: state.isReadOnly,
    isFilterRuleLogicRemoved: state.isFilterRuleLogicRemoved,
    isLicenseRuleLogicRemoved: state.isLicenseRuleLogicRemoved,
    licenseSobject: state.licenseSobject,
    residentRule: state.residentRule,
    residentRuleOn: state.residentRuleOn,
    showAdvancedRule: state.showAdvancedRule,
    sobject: state.sobject,
    loaded: state.loaded,
    stateRule: state.stateRule,
    showToast: state.showToast
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    getLicenseRuleSetResult: (objectName) => {
      dispatch(getLicenseRuleSetResult(objectName));
    },
    getSobjectWithFields: (objectName) => {
      dispatch(getSobjectWithFields(objectName));
    },
    getLicenseFields: (objectName) => {
      dispatch(getLicenseFields(objectName));
    },
    deleteComplianceRule: (index) => {
      dispatch(deleteComplianceRule(index));
    },
    deleteAdvancedRule: (index) => {
      dispatch(deleteAdvancedRule(index));
    },
    addAdvancedRule: (objectName) => {
      dispatch(addAdvancedRule(objectName));
    },
    addComplianceRule: (objectName) => {
      dispatch(addComplianceRule(objectName));
    },
    saveLicenseRuleSetResult: (data, advancedFilter) => {
      dispatch(saveLicenseRuleSetResult(data, advancedFilter));
    },
    selectAdvancedChange: (itemValue, itemName, index, colIndex, error) => {
      dispatch(selectAdvancedChange(itemValue, itemName, index, colIndex, error));
    },
    selectComplianceChange: (itemValue, itemName, index, colIndex, error) => {
      dispatch(selectComplianceChange(itemValue, itemName, index, colIndex, error));
    },
    selectStateRuleChange: (itemValue) => {
      dispatch(selectStateRuleChange(itemValue));
    },
    toggleShowAdvancedRule: (showAdvanced) => {
      dispatch(showAdvancedRule(showAdvanced));
    },
    changeAdvancedRuleLogic: (value, error) => {
      dispatch(changeAdvancedRuleLogic(value, error));
    },
    changeComplianceRuleLogic: (value, error) => {
      dispatch(changeComplianceRuleLogic(value, error));
    },
    clearState: () => {
      dispatch(clearState());
    },
    toggleChangeResidentRule: (value, objectName) => {
      dispatch(toggleChangeResidentRule(value, objectName));
    },
    hideToast: () => {
      dispatch(hideToast());
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ObjectRuleSet);
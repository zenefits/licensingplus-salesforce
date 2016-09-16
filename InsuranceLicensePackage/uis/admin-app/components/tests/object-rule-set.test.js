import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {ObjectRuleSet} from '../object-rule-set';

function setup() {
  const props = {
    advancedRulesList: [],
    advancedRuleLogic: [],
    checklistComplete: {},
    complianceRulesList:[],
    complianceRuleLogic: {},
    deletedLicenseRules: [],
    deletedRegularFilterRules: {},
    errors: {},
    isReadOnly: {},
    isFilterRuleLogicRemoved: {},
    isLicenseRuleLogicRemoved: {},
    licenseSobject: {},
    residentRule: {},
    residentRuleOn: false,
    showAdvancedRule: {},
    sobject: {},
    loaded: {},
    stateRule: {},
    showToast:{},
    params:{},
    
    getSobjectWithFields: () => { return Promise.resolve(); },
    getLicenseFields: () => { return Promise.resolve(); },
    getLicenseRuleSetResult: () => { return Promise.resolve(); },
    hideToast: () => { return Promise.resolve(); },
  };

  return shallow(<ObjectRuleSet  {...props}/>);
}

describe('ObjectRuleSet Component Tests', () => {
  it('renders ObjectRuleSet component', () => {
    const wrapper = setup();
    expect(wrapper.find('h4').last().text()).toEqual(' Compliance Rule Set <Tooltip />');
  });
});
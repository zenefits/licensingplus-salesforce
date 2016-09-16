import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {RuleSets} from '../rule-sets';

function setup() {
  const props = {
    allRuleSetResults:  {},
    allSobjectNames:  [],
    ruleSetResults:  [],
    checklistComplete:  {},
    toggleLicenseRuleSet: () => { return Promise.resolve(); },
    getAllLicenseRuleSetResults: () => { return Promise.resolve(); },
    getSobjectNames: () => { return Promise.resolve(); },
  };

  return shallow(<RuleSets {...props}/>);
}

describe('RuleSets Component Tests', () => {
  it('renders RuleSets component', () => {
    const wrapper = setup();
    expect(wrapper.find('h4').last().text()).toEqual('Compliance Rules');
  });
});
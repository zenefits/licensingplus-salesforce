import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {Welcome} from '../checklist';

function setup() {
  const props = {
    checklist: {},
    toggleChecklist: () => { return Promise.resolve(); }
  };

  return shallow(<Welcome {...props}/>);
}

describe('CheckList Component Tests', () => {
  it('renders checkList component', () => {
    const wrapper = setup();
    expect(wrapper.find('h2').first().text()).toEqual('Getting started checklist');
  });
});
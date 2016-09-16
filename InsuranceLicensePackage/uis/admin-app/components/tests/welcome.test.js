import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {WelcomeScreen} from '../welcome';

function setup() {
  const props = {
    checklist: {},
    toggleChecklist: () => { return Promise.resolve(); }
  };

  return shallow(<WelcomeScreen {...props}/>);
}

describe('Welcome Component Tests', () => {
  it('renders welcome component', () => {
    const wrapper = setup();
    expect(wrapper.find('h1').first().text()).toEqual('Welcome to Licensing +');
  });
});
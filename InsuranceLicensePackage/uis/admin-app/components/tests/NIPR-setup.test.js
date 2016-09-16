import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {NIPRSetupView} from '../NIPR-setup.view';

function setup() {
  const props = {
    showURL: false,
    showURLField: () => { return Promise.resolve(); },
    checkHerokURL: () => { },
    onCreateHerokuClick: () => { },
  };

  return shallow(<NIPRSetupView {...props}/>);
}

describe('NIPRSetupView Tests', () => {
  it('renders NIPRSetupView component', () => {
    const wrapper = setup();
    expect(wrapper.find('h4').first().text()).toContain('NIPR Integration Setup');
  });

  it('should render Create Heroku Application button', () => {
    const wrapper = setup();
    expect(wrapper.find('button').first().text()).toContain('Create Heroku Application');
  });

  it('should not render URL Div', () => {
    const wrapper = setup();
    expect(wrapper.find('h6').length).toEqual(0);
  });

  it('should render URL Div', () => {
    const wrapper = setup();
    wrapper.setProps({
      showURL: true
    });
    expect(wrapper.find('h6').first().text()).toContain('Enter Heroku Credentials');
  });

  it('should show error message ', () => {
    const wrapper = setup();
    wrapper.setProps({
      herokuURLError: true,
      showURL: true,
    });
    expect(wrapper.find('.text-help').length).toEqual(1);
  });

});
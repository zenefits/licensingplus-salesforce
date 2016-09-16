import expect from 'expect';
import React from 'react';
import {render} from 'enzyme';
import {Extend} from '../extend';

function setup() {
  return render(<Extend />);
}

describe('Extend Component Tests', () => {
  it('renders extend component', () => {
    const wrapper = setup();
    expect(wrapper.find('h1').first().text()).toEqual('Recommended next steps');
  });
});
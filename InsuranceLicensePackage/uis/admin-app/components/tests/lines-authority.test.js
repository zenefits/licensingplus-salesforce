import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {LinesAuthority} from '../lines-authority';

function setup() {
  const props = {
    checklistComplete: {},
    previewRows:  [],
    sfdcRows: {},
    showToast:  {},
    fileName: {},
    openCsv: () => { return Promise.resolve(); },
    insertLinesOfAuth: () => { return Promise.resolve(); },
    deleteLineOfAuth: () => { return Promise.resolve(); },
    cancelPreview: () => { return Promise.resolve(); },
    getLinesOfAuth: () => { return Promise.resolve(); },
    hideToast: () => { return Promise.resolve(); },
  };
  return shallow(<LinesAuthority {...props}/>);
}

describe('LinesAuthority Component Tests', () => {
  it('renders LinesAuthority component', () => {
    const wrapper = setup();
    expect(wrapper.find('h4').last().text()).toEqual('Upload your lines of authority spreadsheet');
  });
});
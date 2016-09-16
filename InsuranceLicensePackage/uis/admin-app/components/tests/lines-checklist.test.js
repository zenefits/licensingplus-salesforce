import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {LinesCheckView} from '../lines-checklist.view';

function setup() {
    const props = {
        checklist: {},
        toggleChecklist: () => { return Promise.resolve(); },
        onSkipClick: () => { return Promise.resolve(); }
    };
    return shallow(<LinesCheckView  {...props}/>);
}

describe('LinesChecklist Component Tests', () => {
    it('renders LinesChecklist component', () => {
        const wrapper = setup();
        expect(wrapper.find('h2').first().text()).toEqual('Configure lines of authority');
    });
    it('Skip button should be present', () => {
        const wrapper = setup();
        wrapper.setProps({
            checklist: { "licensingplus__download_spreadsheet__c": true },
        });
        expect(wrapper.find('.skip').length).toEqual(1);
    });
    it('Skip button should not be present', () => {
        const wrapper = setup();
        wrapper.setProps({
            checklist: {
                 "licensingplus__download_spreadsheet__c": true,
                 "licensingplus__watch_configuration_video__c":true,
                 "licensingplus__send_spreadsheet__c":true,
                 "licensingplus__filled_spreadsheet__c":true,
                 },
        });
        expect(wrapper.find('.skip').length).toEqual(0);
    });
});
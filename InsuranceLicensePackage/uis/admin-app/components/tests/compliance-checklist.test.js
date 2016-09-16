import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {ComplianceCheck} from '../compliance-checklist';

function setup() {
    const props = {
        checklist: {},
        toggleChecklist: () => { return Promise.resolve(); }
    };
    return shallow(<ComplianceCheck  {...props}/>);
}

describe('ComplianceChecklist Component Tests', () => {

    it('renders ComplianceChecklist component', () => {
        const wrapper = setup();
        expect(wrapper.find('h2').first().text()).toEqual('Activate compliance rules');
    });

    it('Skip button should be present', () => {
        const wrapper = setup();
        wrapper.setProps({
            checklist: { "licensingplus__download_spreadsheet__c": true },
        });
        expect(wrapper.find('.skip').length).toEqual(1);
    });

    it('Skip button should hidden', () => {
        const wrapper = setup();
        wrapper.setProps({
            checklist: {
                 "licensingplus__watch_video__c": true,
                 "licensingplus__custom_object__c":true,
                 },
        });
        expect(wrapper.find('.skip').length).toEqual(0);
    });
    
});
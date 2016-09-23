import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {NiprCheckView} from '../nipr-checklist.view';

function setup() {
    const props = {
        checklist: {isMaintainanceMode:true},
        toggleChecklist: () => { return Promise.resolve(); },
        onSkipClick: () => { return Promise.resolve(); }

    };
    return shallow(<NiprCheckView  {...props}/>);
}

describe('NIPRChecklist Component Tests', () => {

    it('renders NIPRChecklist component', () => {
        const wrapper = setup();
        expect(wrapper.find('h2').first().text()).toEqual('Integrate NIPR');
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
                "licensingplus__nipr_setup__c": true,
            },
        });
        expect(wrapper.find('.skip').length).toEqual(0);
    });
});
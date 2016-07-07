import * as types from './action-types';
import { hashHistory } from 'react-router';

export function getChecklist(pathname) {
  return (dispatch) => {
    return ComplianceController.getChecklist((checklist) => {
      
      var checklistComplete = checklist.download_spreadsheet__c
        && checklist.watch_configuration_video__c
        && checklist.send_spreadsheet__c
        && checklist.filled_spreadsheet__c
        && checklist.watch_video__c
        && checklist.set_approvals__c
        && checklist.watch_compliance_video__c;

      dispatch({
        type: types.CHECKLIST_RECEIVED,
        checklist: checklist,
        checklistComplete: checklistComplete
      });

      if(pathname === '/'){
        //do redirecting from app view.
        if(checklistComplete) {
          hashHistory.push('/rules');
        }
        else {
          hashHistory.push('/welcome');
        }
      }
    })
  }
}
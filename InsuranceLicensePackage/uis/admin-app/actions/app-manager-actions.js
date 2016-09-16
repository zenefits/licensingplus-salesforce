import * as types from './action-types';
import { hashHistory } from 'react-router';
import { OBJECTPREFIX, CLASSPREFIX } from '../constants/constants';
import Utils from '../utils/utils';

export function getChecklist(pathname) {
  return (dispatch) => {
    return eval(CLASSPREFIX).getChecklist((checklist) => {
      var newchecklist = Utils.lowKey(checklist);
      var checklistComplete = newchecklist[OBJECTPREFIX + 'completed_setup__c'];
      dispatch({
        type: types.CHECKLIST_RECEIVED,
        checklist: checklist,
        checklistComplete: checklistComplete
      });

      var isMaintainanceMode = newchecklist[OBJECTPREFIX + 'completed_setup__c'];

      if (isMaintainanceMode) {
        dispatch({
          type: types.IS_MAINTAINANCE_MODE,
        });
      }

      if (pathname === '/') {
        //do redirecting from app view.
        if (checklistComplete) {
          hashHistory.push('/rules');
        }
        else {
          hashHistory.push('/welcome');
        }
      }
    })
  }
}
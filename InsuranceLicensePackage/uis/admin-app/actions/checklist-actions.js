import * as types from './action-types';
import { OBJECTPREFIX,CLASSPREFIX} from '../constants/constants';

export function toggleChecklist(checklist) {
  return function (dispatch) {
    return eval(CLASSPREFIX).toggleChecklist(checklist, function () {
      dispatch({
        type: types.TOGGLE_CHECKLIST,
        checklist: checklist
      })
    })
  }
}
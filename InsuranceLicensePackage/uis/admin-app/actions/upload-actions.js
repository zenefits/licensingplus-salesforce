import * as types from './action-types';
import { OBJECTPREFIX, CLASSPREFIX } from '../constants/constants';
import _ from 'lodash';

export function readXml(xmlReceived, fileName) {
  return {
    type: types.XML_RECEIVED,
    xmlReceived: xmlReceived,
    fileName: fileName
  };
}

export function importLicenseData(procedures, callback) {
  return function (dispatch) {
    return eval(CLASSPREFIX).importLicenseData(procedures, (result, event) => {
      if (event.status) {
        var errors = [];
        _.each(result, function (item, index) {
          if (item.isSuccess === false) {
            errors.push(item);
          }
        });
        if (errors.length > 0) {
          dispatch(onUploadError(errors));
        }
      }
      else {
        dispatch(onUploadError([{
          errorCode: 1,
          errorMessage: event.message,
          isSuccess: false,
        }]));
      }
      callback();
    });
  };
}

export function showProgressBar(showProgress) {
  return {
    type: types.SHOW_PROGRESS,
    showProgress: showProgress
  };
}

export function onUploadError(errors) {
  return {
    type: types.PRODUCERS_UPLOAD_INSERTED,
    errorMessages: errors,
    insertedProcedures: []
  };
}

export function uploadSuccess() {
  return {
    type: types.UPLOAD_SUCCESS
  };
}

export function uploadError() {
  return {
    type: types.UPLOAD_ERROR
  };
}

export function updateProgressValue(progressValue, showProgress) {
  return {
    type: types.UPDATE_PROGRESS,
    progressValue: progressValue,
    showProgress: showProgress
  };
}

export function uploadStarted() {
  return {
    type: types.UPLOAD_STARTED
  };
}

export function hideToast() {
  return {
    type: types.HIDE_TOAST
  };
}

export function updateMaintenanceMode() {
  return {
   type: types.IS_MAINTAINANCE_MODE,
  };
}

export function showInvalidDbToast() {
  return {
    type: types.SHOW_INVALID_DB_TOAST
  };
}

export function hideInvalidDbToast() {
  return {
    type: types.HIDE_INVALID_DB_TOAST
  };
}
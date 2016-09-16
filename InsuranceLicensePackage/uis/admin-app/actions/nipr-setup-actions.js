import * as types from './action-types';


export function onSetNiprShowUrl(results) {
    return {
        type: types.SET_NIPR_URL,
        results: results
    };
}

export function setNiprShowUrl() {
  return function (dispatch) {
     dispatch(onSetNiprShowUrl());
  };
}
export function onChangeHerokuURL(value) {
    return {
        type: types.HEROKU_URL_CHANGE,
        value: value
    };
}

export function checkHerokURL(url) {
    return function (dispatch) {
        fetch(url + "/ping",{ method: "GET"})
            .then(function (res) {
                if (res.status === 200) {
                    return true;
                }
                else {
                    throw new Error('Bad response status: ' + res.status);
                }
            })
            .then(function (json) {
                 dispatch({
                    type: types.SET_URL_ERROR,
                    value: false
                });
            })
            .catch(function (err) {
                console.log(err)
                dispatch({
                    type: types.SET_URL_ERROR,
                    value: true
                });
            });
    };
}
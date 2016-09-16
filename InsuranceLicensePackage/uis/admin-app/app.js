import React from 'react';
import ReactDOM from 'react-dom';
import { createStore, compose, applyMiddleware } from 'redux';
import { Provider } from 'react-redux';
import { Router, Route, hashHistory } from 'react-router';
import thunk from 'redux-thunk';

import AppManager from './components/app-manager';
import Checklist from './components/checklist';
import LinesAuthority from './components/lines-authority';
import RuleSets from './components/rule-sets';
import ObjectRuleSet from './components/object-rule-set';
import WelcomeScreen from './components/welcome';
import Extend from './components/extend';
import LicenseDB from './components/license-db';
import rootReducer from './reducers';
import NIPRSetupContainer from './components/NIPR-setup.container';
import RuleContainer from './components/approval-rule.container';
import ComplianceCheck from './components/compliance-checklist';
import './styles.scss';
import Complete from './components/complete';
import LinesCheckContainer from './components/lines-checklist.container';
import NIPRCheckContainer from './components/nipr-checklist.container';
import CheckListComplete from './components/checklist-complete';

function configureStore(initialState) {
  return createStore(rootReducer, initialState, applyMiddleware(thunk))
}

const NoMatch = React.createClass({render(){return (<h1>No Match</h1>)}})

const store = configureStore()

var routes = (
  <Provider store={store}>
    <Router history={hashHistory}>
      <Route path='/' component={AppManager} >
        <Route path='/checklist' component={Checklist} />
        <Route path='/lines' component={LinesAuthority} />
        <Route path='/rules' component={RuleSets} />
        <Route path='/rules/:sobjectname' component={ObjectRuleSet} />
        <Route path='/welcome' component={WelcomeScreen} />
        <Route path='/extend' component={Extend} />
        <Route path='/db' component={LicenseDB} />
        <Route path='/nipr' component={NIPRSetupContainer} />
        <Route path='/approval' component={RuleContainer} />
        <Route path='/compliancechecklist' component={ComplianceCheck} />
        <Route path='/complete' component={Complete} />
        <Route path='/lineschecklist' component={LinesCheckContainer} />
        <Route path='/niprchecklist' component={NIPRCheckContainer} />
        <Route path='/checklistcomplete' component={CheckListComplete} />
        <Route path='*' component={NoMatch}/>
      </Route>
    </Router>
  </Provider>
);

ReactDOM.render(routes, document.getElementById('root'))
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
import rootReducer from './reducers';
import './styles.scss';

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
        <Route path="*" component={NoMatch}/>
      </Route>
    </Router>
  </Provider>
);

ReactDOM.render(routes, document.getElementById('root'))
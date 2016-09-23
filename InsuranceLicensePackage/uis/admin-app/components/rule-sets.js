import React, { Component, PropTypes } from 'react';
import { Link, hashHistory } from 'react-router';
import { connect } from 'react-redux';
import Toggle from 'react-toggle'
import { toggleLicenseRuleSet, getAllLicenseRuleSetResults, getSobjectNames } from '../actions/rule-sets-actions';
import { DropdownButton, MenuItem } from 'react-bootstrap';
import Sidebar from './sidebar.container';
import _ from 'lodash';

export class RuleSets extends Component {
  constructor(props) {
    super(props);
    this.addNewRuleSet = this.addNewRuleSet.bind(this);
    this.toggleLicenseRuleSet = this.toggleLicenseRuleSet.bind(this);
  }

  componentWillMount() {
    this.props.getAllLicenseRuleSetResults();
    this.props.getSobjectNames();
  }

  toggleLicenseRuleSet(name, index, isactive) {
    this.props.toggleLicenseRuleSet(name, index, isactive)
  }

  addNewRuleSet(key, event) {
    event.preventDefault()
    hashHistory.push('/rules/' + key);
  }

  renderRuleSetRows() {
    return this.props.ruleSetResults.map((ruleSetResult, index) => {
      var name = ruleSetResult.name;
      var isactive = ruleSetResult.isactive;
      return (
        <tr key={name}>
          <td>
            <Link to={'/rules/' + name}>{_.capitalize(name) } Rule Set</Link>
          </td>
          <td>
            <Toggle
              defaultChecked={isactive}
              onChange={this.toggleLicenseRuleSet.bind(null, name, index, !isactive) } />
          </td>
        </tr>
      );
    });
  }

  renderAddRuleSet() {
    var menuItems;
    if (this.props.allSobjectNames) {
      menuItems = this.props.allSobjectNames
        .filter((name) => {
          var existingRuleSetKeys = _.keys(this.props.allRuleSetResults).map((key) => { return _.lowerCase(key) });
          return !_.includes(existingRuleSetKeys, _.lowerCase(name));
        })
        .sort()
        .map((name) => {
          return <MenuItem key={name} eventKey={name}>{_.capitalize(name) }</MenuItem>
        })
    }
    return (
      <div className='pull-left'>
        <DropdownButton bsStyle={'warning'} title={'Add Rule Set'} key={'addRuleSet'} id={'addRuleSet'} onSelect={this.addNewRuleSet.bind(null) } >
          {menuItems}
        </DropdownButton>
      </div>
    )
  }

  render() {
    return (
      <div className='rules license-form'>
        <div>
          <Sidebar activePage='rules' checklistComplete={this.props.checklistComplete}/>
          <div className='col-sm-9 inside-container'>
            <div>
               <h4 className="sub-heading">Compliance Rules</h4>
            </div>
            <table className='table table-hover table-fixed custom-table rule-set'>
              <thead>
                <tr>
                  <th>Compliance Object</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {this.renderRuleSetRows() }
              </tbody>
            </table>
            <div>
              {this.renderAddRuleSet() }
            </div>
            <br/><br/><br/>      
        
            <Link to={`/niprchecklist`} className={this.props.isMaintainanceMode ? 'btn donebtn-visibility' : 'btn btn-warning btn-right next-button'}>
              Next
            </Link>
          </div>
        </div>
      </div>);
  }
}

const mapStateToProps = (state) => {
  return {
    allRuleSetResults: state.allRuleSetResults,
    allSobjectNames: state.allSobjectNames,
    ruleSetResults: state.ruleSetResults,
    checklistComplete: state.checklistComplete,
    isMaintainanceMode: state.isMaintainanceMode
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    toggleLicenseRuleSet: (name, index, isactive) => {
      dispatch(toggleLicenseRuleSet(name, index, isactive));
    },
    getAllLicenseRuleSetResults: () => {
      dispatch(getAllLicenseRuleSetResults());
    },
    getSobjectNames: () => {
      dispatch(getSobjectNames());
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(RuleSets);
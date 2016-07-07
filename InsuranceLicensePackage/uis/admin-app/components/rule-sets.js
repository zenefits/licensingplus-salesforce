import React, { Component, PropTypes } from 'react';
import { Link, hashHistory } from 'react-router';
import { connect } from 'react-redux';
import Toggle from 'react-toggle'
import { toggleLicenseRuleSet, getAllLicenseRuleSetResults, getSobjectNames } from '../actions/rule-sets-actions';
import { DropdownButton, MenuItem } from 'react-bootstrap';
import { VIDEO_LINK } from '../constants/constants';

class RuleSets extends Component {
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
            <Link to={'/rules/'+name}>{_.capitalize(name)} Rule Set</Link>
          </td>
          <td>
            <Toggle
              defaultChecked={isactive}
              onChange={this.toggleLicenseRuleSet.bind(null, name, index, !isactive)} />
          </td>
        </tr>
      );
    });
  }

  renderAddRuleSet() {
    var menuItems;
    if(this.props.allSobjectNames){
      menuItems = this.props.allSobjectNames
        .filter((name) => {
          var existingRuleSetKeys = _.keys(this.props.allRuleSetResults).map((key)=>{return _.lowerCase(key)});
          return !_.includes(existingRuleSetKeys, _.lowerCase(name));
        })
        .sort()
        .map((name) => {
          return <MenuItem key={name} eventKey={name}>{_.capitalize(name)}</MenuItem>
        })
    }
    return (
      <div className='pull-right'>
        <DropdownButton bsStyle={'warning'} title={'Add Rule Set'} key={'addRuleSet'} id={'addRuleSet'} onSelect={this.addNewRuleSet.bind(null)} >
          {menuItems}
        </DropdownButton>
      </div>
    )
  }

  render() {
    var links = (
      <div className='salesforce-link-rules'>
        <p>
          <small><span className='glyphicon glyphicon-question-sign'></span> Need more help?<a className='link' href={VIDEO_LINK} target='_blank'>Watch our video!</a></small>
        </p>
        <p>
          <a className='link' href='/'>Return to Salesforce</a>
        </p>
      </div>
    )
    
    var back = (
      <h4>
        <Link to={`/checklist`}>
          &lt; Back to Checklist
        </Link>
      </h4>
    )

    var sideNavigation = (
      <div className="col-sm-3 zenefits-nav">
        {back}
        <h1>Activate compliance rules</h1>
        <p>We have already created a few rules that represent standard rules that most teams need. After you have set up the app, you can add more rules.</p>
        {links}
      </div>
    )

    if (this.props.checklistComplete) {
      sideNavigation = (
        <div className="col-sm-3 zenefits-nav">
          {back}
          <ul className="nav nav-pills nav-stacked">
            <li role="presentation" className="active"><Link to={`/rules`}>Compliance Rules</Link></li>
            <li role="presentation"><Link to={`/lines`}>Lines of Authority</Link></li>
          </ul>
          {links}
        </div>
      )
    }

    return (
      <div className='rules license-form'>
        <div className='row'>
          {sideNavigation}
          <div className='col-sm-9 inside-container'>
            <div>
              {this.renderAddRuleSet()}
              <h4>Compliance Rules</h4>
            </div>
            <table className='table table-hover table-fixed custom-table'>
              <thead>
                <tr>
                  <th>Compliance Object</th>
                  <th>Is Active</th>
                </tr>
              </thead>
              <tbody>
                {this.renderRuleSetRows()}
              </tbody>
            </table>
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
    checklistComplete: state.checklistComplete
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
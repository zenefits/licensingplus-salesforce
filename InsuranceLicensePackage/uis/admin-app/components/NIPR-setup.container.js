import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK } from '../constants/constants';
import {setNiprShowUrl, checkHerokURL, onChangeHerokuURL} from '../actions/nipr-setup-actions';
import NIPRSetupView from './NIPR-setup.view';
import { Router, Route, hashHistory } from 'react-router';
import {OBJECTPREFIX } from '../constants/constants';

class NIPRSetupContainer extends Component {
    constructor(props) {
        super(props);
        this.showURLField = this.showURLField.bind(this);
        this.onCreateHerokuClick = this.onCreateHerokuClick.bind(this);
        this.onNextButtonclick = this.onNextButtonclick.bind(this);
        this.onRetryHerokuClick = this.onRetryHerokuClick.bind(this);
        this.toggleChecklist = this.toggleChecklist.bind(this);
    }

    showURLField() {
        this.props.setNiprShowUrl();
    }

    onCreateHerokuClick() {
        this.props.setNiprShowUrl();
        this.toggleChecklist(OBJECTPREFIX + 'heroku_application_created__c');
        window.open('https://heroku.com/deploy?template=https://github.com/zenefits/licensingplus-heroku-java');
    }

    onNextButtonclick(e) {
        //TODO Navigate to '/approval' 
    }

    onRetryHerokuClick(e) {
        window.open('https://heroku.com/deploy?template=https://github.com/zenefits/licensingplus-heroku-java');
    }

    toggleChecklist(key) {
        var checklist = Object.assign({}, this.props.checklist);
        checklist[key] = true;
        this.props.toggleChecklist(checklist);
    }

    render() {
        return (
            <NIPRSetupView
                showURL = {this.props.niprShowUrl}
                showURLField = {this.showURLField}
                onCreateHerokuClick = {this.onCreateHerokuClick}
                onNextButtonclick = {this.onNextButtonclick}
                onRetryHerokuClick = {this.onRetryHerokuClick}
                checkHerokURL={this.props.checkHerokURL}
                herokuURLError={this.props.herokuURLError}
                herokuURL={this.props.herokuURL}
                onChangeHerokuURL={this.props.onChangeHerokuURL}
                isHerokuCreated={this.props.checklist[OBJECTPREFIX + 'heroku_application_created__c']}
                herokuURLSuccess={this.props.herokuURLSuccess}
                isMaintainanceMode={this.props.isMaintainanceMode}
                />
        )
    }
}


const mapStateToProps = (state) => {
    return {
        niprShowUrl: state.niprShowUrl,
        herokuURLError: state.herokuURLError,
        herokuURL: state.herokuURL,
        checklist: state.checklist,
        herokuURLSuccess:state.herokuURLSuccess,
        isMaintainanceMode: state.isMaintainanceMode
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        setNiprShowUrl: () => {
            dispatch(setNiprShowUrl());
        },
        checkHerokURL: (url) => {
            dispatch(checkHerokURL(url));
        },
        onChangeHerokuURL: (event) => {
            dispatch(onChangeHerokuURL(event.target.value));
        },
        toggleChecklist: (checklist) => {
            dispatch(toggleChecklist(checklist));
        }
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(NIPRSetupContainer)
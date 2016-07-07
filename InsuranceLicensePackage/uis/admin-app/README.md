#Zenfits, Compliance + Tech Doc

A summary of all components and workflow of the code behind *Compliance +*.

##Saving to Salesforce

If you are in debug mode you can run `npm run save-resource` which will save (locally) over the *staticresource* in the Salesforce source. Next, save or compile this file (**license_admin_js.resource**) to Salesforce.

To build for production - run `npm run save-resource-prod` which will save (locally) over the *staticresource* in the Salesforce source. Next, save or compile this file (**license_admin_js.resource**) to Salesforce.


##Architecture

####Components

All the view, controllers, and routing for the app. If you'd like to change any content of the application (verbiage / labels / etc..), this is the place to make changes. Currently, we have :

```
- app-manager.js // encapsulates the all components
  - checklist.js // maps directly to the /checklist route
  - lines-authority.js // maps directly to the /lines route
  - rule-sets.js // maps directly to the /rules route
  - object-rule-set.js // maps directly to the /rules/:object_name route
  - welcome-screen.js // maps directly to the /welcom route
  - extend.js // maps directly to the /extend route
```


####Utils. 

Standard utils for simulating the app running locally. Any general functions (like parsing / transforming) reused in different places in the app. **local-utils.js** - This file simulates the JS Remoting namespace in the `window`. It is excluded when building the app and deploying to Salesforce, and is essential for offline (no saving to Salesforce all the time) development. This is a key paradigm of the app it makes development way easier.


#####Actions.

Any action creator which will trigger updates to the js data store. These actions are fired and fed into the reducers to transform the local state of the application. Please refer to [redux-introduction](http://redux.js.org/docs/introduction/index.html) for more information on actions / reducers.


#####Reducers.

Single file which takes dispatched events/actions and returns the new copy of the store / state. For more information on [reducers](http://redux.js.org/docs/basics/Reducers.html). Basically, all transformations (loading of rulesets, previewing lines, activation of rule sets, etc..) to the state are done through **admin-reducer.js**, and transferred to re-render the particular component. State is mapped to the Props of a component at the bottom of each component file, via `export default connect(...)(ComponentName)`.


#####npm.

Holds al scripts for installing/building/running the application. Anything you'd like to add to the build / process should be added as a `scripts` in the **package.json**


#####Assets.

This is for fonts and images. All of these are packed into the **bundle.js** file.


#####Important Libraries

- [Bootstrap](http://getbootstrap.com/)
- [React Redux](https://github.com/reactjs/react-redux)
- [React Router](https://github.com/reactjs/react-router)
- [React](https://facebook.github.io/react/)
- [Redux](http://redux.js.org/)
- [Webpack](http://webpack.github.io/docs/)

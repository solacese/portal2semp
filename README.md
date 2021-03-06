# Demo: Using the Event Portal API and SEMP API to automate creating broker artefacts to receive events.

## What does this demonstrate?

Imagine we've created our events of interest in Event Portal. Now we're thinking about writing to code to receive those events.  How to create what's needed on the broker?

This demo uses the Event Portal API to read your application domain, extract the applications within it and the events those applications subscribe to.  You can then provision queues on the broker, which the demo creates by calling SEMP.  The app then takes the Events, recovers the topics on which they're published, and creates subscriptions on the queues.  In this way the portal user is abstracted from the topics and only deals in the events.

![Portal2SEMP diagramme](collateral/demo-diag.png)

## Running a demo

Instructions:
1. Start a broker locally.  A secure SEMP call to PS+ cloud is NYI due to https (easy fix)
2. Grab your Event Portal [API token](https://docs.solace.com/Solace-Cloud/ght_api_tokens.htm#Create )
3. Install node.js
4. Clone this repo
5. cd to where you've cloned it.  Do `npm install`.
6. Start the demo web server: `npm run dev`
7. Start your browser in web security disabled mode.  For chrome, thats `{chrome path} --disable-web-security --user-data-dir={some path}`
8. Go to `localhost:5000` in the browser address bar.
9. Create an application domain, applications, and events. In your applications, create Client Delivery Endpoints and have your CDEs subscribe to events.
10. Follow the instructions to query the application domain.

## Who is this demo for?

This demo should be run by SEs only: don't give this code to customers, unless under supervision.  It has a limited lifespan as all of this should appear, and be better, in the Event Portal.  

## What is it for?

1. Reassure customers we're thinking about this;
2. Show them that it's possible;
3. Get them to wait for Portal to catch up.

## Authors
Magali Boulet and Tom Fairbairn

## Libraries used

1. [Svelte](https://svelte.dev/).  A reactive javascript framework that manipulates the DOM directly.  Can be a little rough around the edges but boy the core is good.
2. Svelte routes.  A quick and dirty choice.  All nav links are dynamic which is annoying because you can't navigate to them directly.

## To dos
* Proper API paginated response handling.  Currently I just give up and say "I've only got the first page"
* Work out how to interact with the Svelte "stores" correctly.  store.update([...store, new value]) works really nicely but most cases aren't like that.
* Event Portal currently doesn't support CORS, so a vanilla browser will barf.
* Separate Queue creation and RDP creation errors
* Deal with secure connections
* Get API token programmatically

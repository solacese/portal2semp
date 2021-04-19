<script>
  // Svelte routes workaround
  export let location;

  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { Link } from "svelte-routing";

  import List from '../components/List.svelte';
  import Pagination from '../components/Pagination.svelte';
  import ApiLog from "../components/APILog.svelte";

  import { storeAppInfo, storeAD, storeApp } from '../stores.js';
  import { config } from '../config.js';
  import { checkPagination} from '../pagination.js';

  let selectedDomains = [];
  let appInfo = [];
  let applicationData;
  let selectedApps = [];
  let eventDetails = [];
  let eventIdList = [];
  let eventData;
  let gotApps = false;
  let pagination = false;
  let logString = "";
  let apiLogComponent;

  const unsubscribeAD = storeAD.subscribe(value => {
    selectedDomains = value;
  });

  const unsubscribeApp = storeApp.subscribe(value => {
    selectedApps = value;
  });
  
  const unsubscribeAppInfo = storeAppInfo.subscribe(value => {
    appInfo = value;
  });

  const test = () => {
    console.log("TESTING");
    selectedDomains = [ {
      description: "a description",
      name: "TF-sample-EP-to-runtime",
      id: "1a2mpvr5zuwb"
    } ];
    dataGot();
  }

  const dataGot = async() => {
    storeAppInfo.update(data => []);
    gotApps = await getData();
  }

  const getData = async() => {
    eventIdList = [];
    await getApps();
    storeAppInfo.update( x => x );
  }

  const getApps = async() => {
    applicationData = await Promise.all(
      selectedDomains.map(
        domain => apiLogComponent.apiGet(
          "GET",
          "Get applications in domain id " + domain.id,
	  config.portalUrl + 'applications?applicationDomainId=' + domain.id,
	  { headers: { Authorization: config.token } }
	).then( (x) => x.json() )
         .then( (data) =>  {pagination = checkPagination(data);
                            return data; } )
	 .then( async(y) => await processApp(y) )
	 .then( async(z) => await getEvents() )
      )
    )
  }
  
  const processApp = (data) => {
    data.data.forEach ( app => {
      if (app.endpoints.length > 0) { 
	app.endpoints.forEach ( endpoint => {
	  if (endpoint.endpointType === "solaceQueueEndpoint") {
            let newApp = { 
              description: app.description,
	      id: app.id,
	      name: app.name,
              qName: endpoint.name,
              qProvisioned: false,
              subsCreated: [],
              qError: "",
              consumedEventDetails: [],
	      consumedEventIds: endpoint.consumedEventIds,
	      subscriptions: endpoint.topicSubscriptions,
              endpoint: "Queue",
	      rdp: {
	        name: app.name,
	        postRequestTarget: "/some/url",
	        host: "localhost"
	        }
            };
	    // Get Event details
	    endpoint.consumedEventIds.forEach( eventId => {
	      // Only add eventId if we haven't already
	      if ( eventIdList.indexOf(eventId) === -1 ) {
	        eventIdList.push(eventId);
              }
	    } );
	    appInfo.push(newApp);
	  } else {
	    console.log("Uknown endpoint type: ", endpoint.endpointType);
	  }
	});
      }
    });
  }

  const addApp = (app, context) => {
     if (selectedApps.filter(data => (data.name === app.name)).length === 0) {
      storeApp.update(selectedApps => [...selectedApps, app]);
    }
    console.log(selectedApps);
  }

  const removeApp = (showApp, context) => {
    storeApp.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name));
  }

  const getEvents = async() => {
    eventData = await Promise.all(
      eventIdList.map(
        eventId => apiLogComponent.apiGet(
          "GET",
          "Get Event details for id: " + eventId,
          config.portalUrl + 'events/' + eventId,
          { headers: { Authorization: config.token } }
        ).then( (x) => x.json() )
         .then( async(y) => await processEvent(eventId, y) )
      )
    ).then( async() => await deCacheEvents() );
  }

   const processEvent = async(eventId, event) => {
     eventDetails.push( {
       description: event.data.description,
       name: event.data.name,
       topic: event.data.topicName,
       id: eventId
     } );
  }

  const deCacheEvents = async() => {
    // We've got the event details, now go through the apps and fill them out with the event details
    appInfo.forEach( app => {
      app.consumedEventIds.forEach( consumedEventId => {
        if ( app.consumedEventDetails.filter( event => ( event.id === consumedEventId )).length === 0 ) {
	  let consumedEventObj = eventDetails.filter( element => (element.id === consumedEventId) );
	  app.consumedEventDetails.push(consumedEventObj[0]);
	}
      } );
    } );
  }

  onMount( async() => { dataGot(); } );

</script>


<div style="width:100%">
<p>Stage 2: Select your Applications</p>

Each Application Domain in Event Portal can contain multiple Applications.  In the list below are all those Applications we've indentified as needing events persisted for them for later consumption.<p>

<p>Simply select those applications you'd like to deploy and continue to Stage 3.</p>
<hr>

</div>

<div style="float:left; width:100%">

<div style="float:left">
{#if selectedDomains.length > 0 }
    {#if selectedDomains.length === 1}
      <h2>Selected Domain</h2>
    {:else}
      <h2>Selected Domains</h2>
    {/if}
    {#each selectedDomains as showDomain}
      <li class="selected">{showDomain.name}</li>
    {/each}

{:else}
  <p><strong>You haven't selected any Application Domains!</strong></p>

<p>Please go back to the <Link to="getAD">previous step</Link> and pick at least one</p>
{/if}

</div>

<div style="float:left">
<Pagination paginated = {pagination}
            title = "Available Applications"
>
</Pagination>

<List promise = {gotApps}
      list = {appInfo}
      clickFunc = {addApp}
      title = "Available Applications"
      displayTitle = {true}
>
</List>

<List promise = {gotApps}
      list = {selectedApps}
      clickFunc = {removeApp}
      displayDescription = {false}
      title = "Selected Applications"
>
</List>
</div>
</div>

<ApiLog title="Event Portal API"
        logString = {logString}
        bind:this={apiLogComponent}>
</ApiLog>

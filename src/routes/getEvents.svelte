<script>
  // Svelte routes workaround
  export let location;

  import { onMount } from 'svelte';
  import { storeApp, storePossEvents } from "../stores.js";
  import { Link } from "svelte-routing";
  import { fade } from 'svelte/transition';
  import { config } from '../config.js';
  import List from '../components/List.svelte';

  let selectedApps = [];
  let eventIdList = [];
  let eventIdCache = [];
  let eventData;
  let selectedEvents = [];

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribePossEvents = storePossEvents.subscribe(value => {
    eventIdCache = value;
  } );
   
  const getEvents = async() => {
    eventIdList = [];
    addEventsToGet();
    eventData = await Promise.all(
      eventIdList.map(
        eventId => fetch(
          config.portalUrl + 'events/' + eventId,
	  { headers: { Authorization: config.token } }
        ).then( (x) => x.json() )
         .then( async(y) => await processEvent(eventId, y) )
      )
    ).then( async() => await deCacheEvents() );
  }

  const processEvent = async(eventId, event) => {
    if ( eventIdCache.filter( element => (element.id === eventId)).length === 0){
      storePossEvents.update( eventIdCache => [...eventIdCache, {
        description: event.data.description,
        name: event.data.name,
        topic: event.data.topicName,
	id: eventId
      } ] );
    }
  }

  const deCacheEvents = async() => {
    // Takes the event cache and fills out the application storage with the
    //  detailed Event information
    selectedApps.forEach( app => {
      app.consumedEventIds.forEach( consumedEventId => {
	// Check we haven't already done this
	if ( app.consumedEventDetails.filter( 
	       event => (event.id === consumedEventId ) 
	   ).length === 0 ) {
          let consumedEventObj = eventIdCache.filter( element => (element.id === consumedEventId) );
	  app.consumedEventDetails.push(consumedEventObj[0]);
	}
      } );
    } );
    storeApp.update( x => x = selectedApps);
  }

  const addEventsToGet = () => {
    selectedApps.forEach( app => {
      app.consumedEventIds.forEach( eventId => {
        // Only add eventId if we haven't already
        if ( eventIdList.filter( existingId => (existingId === eventId.id)).length === 0) {
          eventIdList.push(eventId);
	}
      } );
    } );
  }

  const addSelectedEvent = (event, app) => {
    if (app.selectedEvents.filter(data => (data.id === event.id)).length === 0) {
      //storeApp.update( selectedApps.selectedEvents => [...selectedApps.selectedEvents, event] )
      // ^Parse error?
      let newEvents = app.selectedEvents.concat(event);
      app.selectedEvents = newEvents;
      // ToDo: how to do this properly
      storeApp.update( x => x = selectedApps);
    }
  }

  const removeSelectedEvent = (event, app) => {
    app.selectedEvents = app.selectedEvents.filter( data => data.id != event.id);
    // ToDo: how to do this properly
    storeApp.update( x => x = selectedApps);
  }

  onMount( async() => await getEvents() );
</script>

<p>State 3: Select your events</p>
<p>Now we know which consumers you are interested in, you can select which events you want to persist.<p>
<hr>

{#if selectedApps.length > 0}

  <div style="float:left">
    <table >
    <tr>
    {#if selectedApps.length === 1}
      <th>Selected Application</th>
    {:else}
      <th>Selected Applications</th>
    {/if}
    <th>Available Events</th>
    <th>Selected Events</th>
    </tr>
    {#each selectedApps as showApp}
      <tr><td>
      <li 
        class="selected"
	> {showApp.name}
      </li>
      </td>
      <td>
      <List promise = {eventData}
        list = {showApp.consumedEventDetails}
        clickFunc = {addSelectedEvent}
        title = "Available Events"
        displayTitle = {false}
        context = {showApp}
         >
      </List>
      </td>
      <td>
      <List promise = {eventData}
        list = {showApp.selectedEvents}
        clickFunc = {removeSelectedEvent}
        displayDescription = {false}
        title = "Selected Events"
        displayTitle = {false}
        context = {showApp}
         >
      </List>
      </td>
      </tr>
    {/each}
    </table>
  </div>



{:else}
  <p><strong>You don't appear to have selected any applications!</strong></p>
  <p>Please go back to the <Link to="getApps">previous step</Link> and pick at least one.<p>
{/if}

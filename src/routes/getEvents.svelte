<script>
  import { onMount } from 'svelte';
  import { storeApp, storePossEvents, storeEvents } from "../stores.js";
  import { Link } from "svelte-routing";
  import { fade } from 'svelte/transition';
  import { config } from '../config.js';
  import List from '../components/List.svelte';

  let selectedApps = [];
  let eventIdList = [];
  let eventIdCache = [];
  let eventData;
  let testList = [];
  let hovering = false;
  let description = "";
  let selectedEvents = [];

  const test = async() => {
    console.log("TESTING");
    eventIdList = [];
    eventIdCache = [];
    selectedApps = [ {
      consumedEventIds: ["1a2mpvr5zuyj", "1a2mpvr6fmp5"], 
      description: "a description",
      name: "A consumer",
      id: "1a2mpvr5zuxp",
      persistent: true
    } ];
    await getEvents();
  }

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribePossEvents = storePossEvents.subscribe(value => {
    eventIdCache = value;
  } );
   
  const unsubscribeEvents = storeEvents.subscribe(value => {
    selectedEvents = value;
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
    )
  }

  const processEvent = async(eventId, event) => {
    if ( eventIdCache.filter( element => (element.id === eventId)).length === 0){
      eventIdCache.push( {
        description: event.data.description,
        name: event.data.name,
        topic: event.data.topicName,
	id: eventId
      } );
    }
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

  const addSelectedEvent = (event) => {
    if (selectedEvents.filter(data => (data.id === event.id)).length === 0) {
      storeEvents.update( selectedEvents => [...selectedEvents, event] )
    }
  }

  const displayEventDescription = (event) => {
    hovering = true;
    description = event.description;
  }

  const removeEventDescription = () => {
    hovering = false;
  }
  
  const removeSelectedEvent = (event) => {
    storeEvents.update( selectedEvents => selectedEvents.filter( 
      data => data.id != event.id
    ));
  }

  onMount( async() => getEvents() );
</script>

<style>
li.select {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #e6ffe6;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
li.select:hover {
  color: #607D8B;
  background-color: #99ff99;
  left: .1em;
}
li.app {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #ffe6e6;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
</style>

<p>State 3: Select your events</p>
<p>Now we know which consumers you are interested in, you can select which events you want to persist.<p>
<hr>

<button on:click="{test}">TEST</button>

{#if selectedApps.length > 0}

  <div style="float:left">
    {#if selectedApps.length === 1}
      <h2>Selected Application</h2>
    {:else}
      <h2>Selected Applications</h2>
    {/if}
    {#each selectedApps as showApp}
      <li 
        class="app"
	> {showApp.name}
      </li>
    {/each}
  </div>



{:else}
  <p><strong>You don't appear to have selected any applications!</strong></p>
  <p>Please go back to the <Link to="getApps">previous step</Link> and pick at least one.<p>
{/if}


<div style="float:left">
<List promise = {eventData}
      list = {eventIdCache}
      clickFunc = {addSelectedEvent}
      displayFunc = {displayEventDescription}
      removeFunc = {removeEventDescription}
      hovering = {hovering}
      description = {description}
      side = "left"
      displayDescription = {true}
>
</List>

<List promise = {eventData}
      list = {selectedEvents}
      clickFunc = {removeSelectedEvent}
      displayFunc = {displayEventDescription}
      removeFunc = {removeEventDescription}
      hovering = {hovering}
      description = {description}
      side = "right"
      displayDescription = {false}
>
</List>

</div>


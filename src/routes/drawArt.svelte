<script>
  // Svelte routes workaround
  export let location;

  import { onMount } from 'svelte';

  import { Link } from 'svelte-routing';
  import { storeApp, storeEvents } from "../stores.js";

  let selectedEvents = [];
  let selectedApps = [];

  let qNames = "";
  let areEvents = false;

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribeEvents = storeEvents.subscribe(value => {
    selectedEvents = value;
  } );

  const getEventById = (eventId) => {
    let eventObj = selectedEvents.filter(event => event.id === eventId);
    return eventObj[0].name;
  }

  const checkSelectedEvents = () => {
    let foundEvents = false;
    selectedApps.forEach( app => {
      app.selectedEvents.forEach( event => {
        foundEvents = true;
      } );
    } );
    return foundEvents;
  }

  const test = () => {
    storeApp.update(selectedApps => [ 
      {
        description: "a description",
	id: "1a2mpvr5zuxp",
	name: "Consumer-1",
	persistent: true,
	tagIds: ["1a2mpvr6h0pf", "1a2mpvr6rsl1"],
	consumedEventIds: ["1a2mpvr5zuyj", "1a2mpvr6fmp5"],
	qName: "Q_Consumer-1",
	subsCreated: []
      },
      {
        consumedEventIds: ["1a2mpvr5zuyj"],
        description: "<p>Another consumer</p>",
        id: "1a2mpvr6fg29",
        name: "Consumer-2",
        persistent: true,
        tagIds: ["1a2mpvr6h0pf"],
	qName: "Q_Consumer-2",
	subsCreated: []
      }
    ] );
    storeEvents.update(selectedEvents => [
      {
        description: "<p><br></p>",
        id: "1a2mpvr6fmp5",
        name: "Another Event",
        topic: "some/topic/space/tbd/yet/another"
      },
      {
        description: "<p>Just a sample event</p>",
        id: "1a2mpvr5zuyj",
        name: "Test event",
        topic: "some/topic/space/tbd/test/event/{event number}"
      }
    ] );
  }

  onMount ( () => areEvents = checkSelectedEvents() );

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
li.event {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #ffe6e6;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
.border {
  margin: 5px;
}
</style>
<button on:click="{test}">Test</button>

{#if selectedApps.length > 0 && areEvents}

   <div class="border" style="float:left">
    <table border="1">
    <tr><th>
    {#if selectedApps.length === 1 }
      Selected Application
    {:else}
      Selected Applications
    {/if}
    </th><th>Selected Events</th>
    </tr>
    {#each selectedApps as showApp}
      <tr>
      <td>
      <li
        class="event"
        > {showApp.name}
      </li>
      </td>

      <td>
      {#each showApp.selectedEvents as event}
        <li
	  class="event"
	  > {event.name}
	</li>
      {/each}
      </td>
      </tr>
    {/each}
  </div>

  <div class="border" style="float:left">
    <h1>Broker Schematic</h1>
    <p>The artefacts that will be created on the broker</p>

    {#each selectedApps as showApp}

      <div style="border-style: solid">
      <p style="float:centre">Subscription list:</p>
      {#each showApp.selectedEvents as event}
        <li>{event.name}</li>
      {/each}
      </div>

      <img src = ./images/queue.png>

      <div style="width:100%">
        <label for={showApp.name}>{showApp.name} queue name:</label>
        <input style="float:centre" bind:value={showApp.qName} name={showApp.name}>
      </div>

    {/each}
  </div>
{:else}
 <p><strong>You don't appear to have selected any events!</strong></p>
  <p>Please go back to the <Link to="getEvents">previous step</Link> and pick at least one.<p>

{/if}


<script>
  import { Link } from 'svelte-routing';
  import { storeApp, storeEvents } from "../stores.js";

  let selectedEvents = [];
  let selectedApps = [];

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribeEvents = storeEvents.subscribe(value => {
    selectedEvents = value;
  } );
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
</style>

{#if selectedEvents.length > 0 && selectedApps.length > 0}

   <div style="float:left">
    {#if selectedApps.length === 1}
      <h2>Selected Application</h2>
    {:else}
      <h2>Selected Applications</h2>
    {/if}
    {#each selectedApps as showApp}
      <li
        class="event"
        > {showApp.name}
      </li>
    {/each}
  </div>

  <div style="float:left">
    {#if selectedEvents.length === 1}
      <h2>Selected Event</h2>
    {:else}
      <h2>Selected Events</h2>
    {/if}
    {#each selectedEvents as event}
      <li
        class="event"
      > {event.name}
      </li>
    {/each}
  </div>
{:else}
 <p><strong>You don't appear to have selected any events!</strong></p>
  <p>Please go back to the <Link to="getEvents">previous step</Link> and pick at least one.<p>

{/if}


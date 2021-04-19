<script>
  // Svelte routes workaround
  export let location;

  import { onMount } from 'svelte';

  import { Link } from 'svelte-routing';
  import { storeApp } from "../stores.js";

  let selectedApps = [];
  let clientTypes = ['Queue', 'RDP'];

  let qNames = "";
  let areEvents = false;

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const checkAreEvents = () => {
    selectedApps.forEach ( app => {
      if ( app.consumedEventIds.length > 0) {
        areEvents = true;
      }
    } );
  }

  onMount( () => checkAreEvents() );

</script>

{#if selectedApps.length > 0 && areEvents}

   <div style="float:left">
    <table>
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
        class="selected"
        > {showApp.name}
      </li>
      </td>

      <td>
      {#each showApp.consumedEventDetails as event}
        <li
	  class="selected"
	  > {event.name}
	</li>
      {/each}
      </td>
      </tr>
    {/each}
  </div>

  <div style="float:left">
    <h1>Broker Schematic</h1>
    <p>The artefacts that will be created on the broker.  Select whether you would like a queue or a REST Delivery Point (RDP)</p>

    {#each selectedApps as showApp}
      {#if showApp.consumedEventDetails.length > 0} 

        <table>
        <tr>
        <td>
        <div style="border-style: solid; float: left">
        <p style="float:centre">Subscription list:</p>
        {#each showApp.consumedEventDetails as event}
          <li>{event.name}</li>
        {/each}
        </div>
        </td>

        <td>
        <div style="width:100%">
          <div style="float:left">
          {#each clientTypes as type} 
            <input type=radio bind:group={showApp.endpoint} value={type}>{type}
	  {/each}
	  </div>

	  {#if showApp.endpoint === "Queue"}
	    <div>
              <label style="position:relative; left:180px; top:55px" for={showApp.name}>{showApp.name} queue name:</label>
              <input style="position:relative; left:182px; top:75px" bind:value={showApp.qName} name={showApp.name}>
            <img style="z-index: -1; float:left" alt="your queue" src = ./images/queue.png>
	    </div>

	  {:else if showApp.endpoint === "RDP"}
	    <div>
	      <label style="position:relative; left: 180px;">{showApp.name}</label>
	      <label style="position:relative; left: 0px; top:40px">Queue Name</label>
	      <input style="position:relative; left: -505px; top:53px;" size= "6" bind:value={showApp.qName}>
	      <img style="z-index: -1; float:left" alt="your RDP" src = ./images/RDP.png>
	      <label style="position:relative; left: -400px; top:-60px">RDP Name:</label>
	      <input style="position:relative; left: 280px; top:-240px;" size= "10" bind:value={showApp.rdp.name}>
	      <label style="position:relative; left: 215px; top:-140px">URL target</label>
	      <input style="position:relative; left: 215px; top:-140px;" size= "10" bind:value={showApp.rdp.postRequestTarget}>
	      <label style="position:relative; left: 325px; top:-197px">Host</label>
	      <input style="position:relative; left: 325px; top:-197px;" size= "10" bind:value={showApp.rdp.host}>
	    </div>

	  {:else}
	    <h2>Unknown endpoint type</h2>
	  {/if}

        </div>
        </td></tr></table>
        {/if}

    {/each}
  </div>
{:else}
 <p><strong>You don't appear to have selected any events!</strong></p>
  <p>Please go back to the <Link to="getEvents">previous step</Link> and pick at least one.<p>

{/if}


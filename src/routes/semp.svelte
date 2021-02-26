<script>
  import { Link } from 'svelte-routing';
  import { fade } from 'svelte/transition';

  import { storeApp, storeEvents } from "../stores.js";
  import { config } from '../config.js';

  let selectedEvents = [];
  let selectedApps = [];

  let postSemp;
  let provisionAttempted = false;

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribeEvents = storeEvents.subscribe(value => {
    selectedEvents = value;
  } );
   
 const provision = async () => {
   // To Do: catch promise fail and update results
   postSemp = await Promise.all( selectedApps.map( async(app) => {
     await createQueue(app);
   } ) );
   provisionAttempted = true;
 }

  const makeSempHeader = (request) => {
    return {
      method: 'post',
      headers: {
        "Authorization": "Basic " + btoa(config.brokerUsername + ":" + config.brokerPassword),
        "Content-Type": "application/json",
        "Content-Length": request.length
      },
      body: JSON.stringify(request)
    }
  }

  const createQueue = async(app) => {
    // Create the queue first
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/queues";
    let body = makeSempHeader({
      msgVpnName: config.brokerVpn,
      queueName: app.qName 
    } );
    postSemp = await fetch(
      url,
      body
    );
    if (postSemp.ok) {
      app.qProvisioned = true;
      app.qError = "";
    } else {
      app.qProvisioned = false;
      let json = await postSemp.json();
      app.qError = json.meta.error.description;
    }

    let allSubscribed = await Promise.all( app.selectedEvents.map ( async(event) => {
      let subscribed = await subscribeQueue(app, event)
    } ) );

    // trigger update
    // ToDo:  should be done per SEMP call
    storeApp.update(selectedApps => selectedApps);
  }

  const subscribeQueue = async(app, event) => {
    let qsubPost;
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/queues/" + app.qName + "/subscriptions";
    console.log("Get eventId", event.id, app);
    console.log("got events", event);
    let topic = event.topic.replace(/(\{.*\})/g, "*");
    let body = makeSempHeader( {
      msgVpnName: config.brokerVpn,
      queueName: app.qName,
      subscriptionTopic: topic
    } );
    qsubPost = await fetch(
      url,
      body
    );
    app.subsCreated = [];
    if (qsubPost.ok) {
      app.subsCreated.push( { id: event.id, created: true, reason: "ok"} );
    } else {
     let json = await qsubPost.json();

      app.subsCreated.push( { id: event.id, created: false, reason: json.meta.error.description } );
      app.qProvisioned = false;
    }
  }

  const getErrors = (app) => {
    let error = "<p>Error(s):</p> <hr>";
    if (app.qProvisioned === false) {
      error = error + "<p>Queue creation error: " + app.qError + "</p>";
    } else {
      error = error + "Queue created OK</p>";
    }
    error = error + "<p>Queue subscriptions:</p>";
    app.subsCreated.forEach(subDesc => {
      // ToDo: use event name rather than ID
      error = error + "<p>EventId: " + subDesc.id + ":";
      if (subDesc.created === false) {
        error = error + subDesc.reason
      } else {
        error = error + "OK";
      }
      error = error + "</p>";
    } );
    return error;
  }

</script>

<style>
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

/* Tooltip text */

.provisioned .tooltip {
  position: relative;
  display: inline-block;
}
.provisioned .tooltiptext {
  visibility: hidden;
  width: 600px;
  background-color: #e6fff7;
  color: #666666;
  text-align: left;
  padding: 5px 0;
  border-radius: 6px;

  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
  left: 95%;
}
/* Show the tooltip text when you mouse over the tooltip container */
.provisioned:hover .tooltiptext {
  visibility: visible;
}


</style>

<div style="width:100%">
<h1>Create broker artefacts</h1>
<p>Now we've collected the details of the applications that will consume and the events we need, we'll now send instructions to your broker to create the artefacts needed to do this.</p>

<p>Fill out the form below with your broker details, then press "create" and the artefacts will be created on the broker for you.<p>
<hr>
</div>

{#if selectedApps.length > 0}

<div style="width:100%">
<table>
<tr>
<td><label for="url">Event Broker admin URL:</label>
<td> <input bind:value={config.brokerUrl} name="url">
<td>
<td><label for="vpn">Event Broker Message VPN:</label>
<td><input bind:value={config.brokerVpn} name="vpn">
</tr>
<tr>
<td><label for="username">Event Broker Admin username:</label>
<td><input bind:value={config.brokerUsername} name="username">
<td>
<td><label for="password">Event Broker Admin password:</label>
<td><input bind:value={config.brokerPassword} name="password">
</tr>
<tr>
<td></td>
<td><button on:click="{provision}">Provision</button></td>
<td></td>
</tr>
</table>
</div>

{#await postSemp}
<p> GETTING DATA</p>
{:then}
   <div class="border" style="float:left">
    <table border = "1">
    <tr><th>
    {#if selectedApps.length === 1}
      Selected Application
    {:else}
      Selected Applications
    {/if}
    </th><th>Selected Events</th>
    </tr>
    {#each selectedApps as showApp}
      <tr><td>
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
      </td></tr>
    {/each}
  </div>

  <div class="border" style="float:left">
    {#if selectedApps.length === 1}
      <h2>Queue</h2>
    {:else}
      <h2>Queues</h2>
    {/if}
    {#each selectedApps as showApp}
      <li
        class="event"
        > {showApp.qName}
      </li>
    {/each}
  </div>

  <div style="float:left">
      <h2>Provisioned?</h2>
    {#each selectedApps as showApp}
      {#if provisionAttempted === false}
        <p> ... </p>
      {:else if showApp.qProvisioned === true}
        <li
	  class="provisioned"
          > <img style="max-height:25px" src= ./images/yes.png>
        </li>
      {:else}
        <li 
	  class="provisioned"
          > <img style="height:25px" src= ./images/no.png>
	  <div class="tooltip">
	  <p class="tooltiptext" transition:fade>{@html getErrors(showApp)}</p>
	  </div>
        </li>
      {/if}
    {/each}
  </div>
{/await}


{:else}
  <div>
  <p>You don't appear to have selected applications and events.  Please go back to the <Link to="drawArt">previous step</Link> and pick at least one.</p>
  </div>
{/if}

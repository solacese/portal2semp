<script>
  // Svelte routes workaround
  export let location;

  import { Link } from 'svelte-routing';
  import { fade } from 'svelte/transition';

  import ApiLog from "../components/APILog.svelte";

  import { storeApp } from "../stores.js";
  import { config } from '../config.js';

  let selectedEvents = [];
  let selectedApps = [];
  let postSemp;
  let provisionAttempted = false;
  let logString = "";
  let apiLogComponent;

  const unsubscribeAppInfo = storeApp.subscribe(value => {
    selectedApps = value;
  });

 const provision = async () => {
   // To Do: catch promise fail and update results
   postSemp = await Promise.all( selectedApps.map( async(app) => {
     await createQueue(app).catch( (err) => {
       app.qError = err;
       } );
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
    // To Do: check queue is created before creating RDP
    // Create the queue first
    app.qProvisioned = false;
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/queues";
    let body = makeSempHeader({
      msgVpnName: config.brokerVpn,
      queueName: app.qName,
      egressEnabled: true,
      ingressEnabled: true,
      permission: "consume"
    } );
    postSemp = await apiLogComponent.apiGet(
      "POST",
      "Create queue " + app.qName,
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
 
    let allSubscribed = await Promise.all( app.subscriptions.map ( async(topic) => {
      let subscribed = await subscribeQueue(app, topic)
    } ) );

    if (app.endpoint === "RDP" && app.qProvisioned === true) {
      console.log("RDP");
      let createdRDP = await createRDP(app);
      let createdRestConsumer = await createRestConsumer(app);
      let createdQBinding = await createQBinding(app);
    }

    // trigger update
    // ToDo:  should be done per SEMP call
    storeApp.update(selectedApps => selectedApps);
  }

  const createRDP = async(app) => {
    console.log("RDP semp");
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/restDeliveryPoints";
    let body = makeSempHeader({
      msgVpnName: config.brokerVpn,
      enabled: true,
      restDeliveryPointName: app.rdp.name,
     } );
     postSemp = await apiLogComponent.apiGet(
       "POST",
        "Create RDP " + app.rdp.name,
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
  }

  const createRestConsumer = async(app) => {
    console.log("RDP  rest consumer semp");
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/restDeliveryPoints/" + app.rdp.name + "/restConsumers";
    let body = makeSempHeader({
      msgVpnName: config.brokerVpn,
      enabled: true,
      remoteHost: app.rdp.host,
      restConsumerName: app.rdp.name,
      restDeliveryPointName: app.rdp.name
     } );
     postSemp = await apiLogComponent.apiGet(
       "POST",
        "Create RDP " + app.rdp.name,
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
  }

  const createQBinding = async(app) => {
    console.log("RDP  queue binding semp");
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/restDeliveryPoints/" + app.rdp.name + "/queueBindings";
    let body = makeSempHeader({
      msgVpnName: config.brokerVpn,
      postRequestTarget: app.rdp.postRequestTarget,
      queueBindingName: app.qName,
      restDeliveryPointName: app.rdp.name
     } );
     postSemp = await apiLogComponent.apiGet(
       "POST",
        "Create RDP " + app.rdp.name,
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
  }

  const subscribeQueue = async(app, topic) => {
    let qsubPost;
    let url = config.brokerUrl + "/SEMP/v2/config/msgVpns/" + config.brokerVpn
      + "/queues/" + app.qName + "/subscriptions";
    let body = makeSempHeader( {
      msgVpnName: config.brokerVpn,
      queueName: app.qName,
      subscriptionTopic: topic
    } );
    qsubPost = await apiLogComponent.apiGet(
      "POST",
      "Create subscription on queue " + app.qName,
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
   <div class="border" style="float:left; width:100%">
    <table >
    <tr><th>
    {#if selectedApps.length === 1}
      Selected Application
    {:else}
      Selected Applications
    {/if}
    </th><th>Selected Events</th>
    {#if selectedApps.length === 1}
      <h2>Queue</h2>
    {:else}
      <th>Queues<th>
    {/if}
    <th>Provisioned?<th>
    </tr>
    {#each selectedApps as showApp}
      <tr><td>
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
      
      <td>
        <li
          class="selected"
          > {showApp.qName}
        </li>
      </td>

      <td>
      {#if provisionAttempted === false}
        <p> ... </p>
      {:else if showApp.qProvisioned === true}
        <li
	  class="tooltip"
          > <img style="max-height:25px" src= ./images/yes.png alt="Succeded">
        </li>
      {:else}
        <li 
	  class="tooltip"
          > <img style="height:25px" src= ./images/no.png alt="failed">
	  <div class="tooltip">
	  <p class="tooltiptext" transition:fade>{@html getErrors(showApp)}</p>
	  </div>
        </li>
      {/if}
      </td>
      </tr>
    {/each}
  </div>
{:catch error}
  <div>
  <p> Error when contacting broker: {error.message}</p>
  </div>
{/await}

<ApiLog title="SEMP v2 API"
        logString={logString}
        bind:this={apiLogComponent}>
</ApiLog>


{:else}
  <div>
  <p>You don't appear to have selected applications and events.  Please go back to the <Link to="drawArt">previous step</Link> and pick at least one.</p>
  </div>
{/if}

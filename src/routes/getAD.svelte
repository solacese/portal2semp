<script>
  import { fade } from 'svelte/transition';
  import { storeAD } from '../stores.js';
  import { storePossAD } from '../stores.js';
  import { config } from '../config.js';
  import List from '../components/List.svelte';

  let allAppDomains;
  let namedDomainData;
  let selectedApps = [];
  let appDomains = [];
  let gotDomains = false;
  let displayConfig = true;
  let contractButtonLabel = ">";
  let gotAD = "block";
  let hovering = false;
  let description = "";

  const unsubscribeSelectedAD = storeAD.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribeAllAD = storePossAD.subscribe(value => {
    appDomains = value;
  });
  

  const displayAdDescrition = ( appDomain) => {
    hovering = true;
    description = appDomain.description; 
  }

  const removeAdDescription = () => {
    hovering = false;
  }

  const processApplicationDomains = (data) => {
    data.data.forEach(appObj => {
      storePossAD.update(appDomains => [...appDomains, { name: appObj.name, 
        id: appObj.id, 
        description: appObj.description}]);
    });
    gotDomains = true;
    displayConfig = !displayConfig;
    return data;
  }

  const processNamedAppDomain = (data) => {
    if (data.data.length !== 1) {
      // TO DO: error processing, should only get 1 named domain back
      return;
    }
    storePossAD.update(appDomains => [ {
      name: data.data[0].name, 
      id: data.data[0].id, 
      description: data.data[0].description} ] );
  }

  const addSelectedAppDomain = (appDomain) => {
    if (selectedApps.filter(data => (data.name === appDomain.name)).length === 0) { 
      storeAD.update(selectedApps => [...selectedApps, appDomain]);
    }
  }

  const hideConfig = () => {
    if (displayConfig === true) { 
      displayConfig = false;
      contractButtonLabel = "^";
      return; 
    }
    displayConfig = true;
    contractButtonLabel = ">";
  }

  const getNamedDomains = () => {
    selectedApps.length = 0;
    let url = config.portalUrl + config.applicationDomainSuffix + "?name=" + config.applicationDomainName;
    namedDomainData = fetch(
      url,
      {
        headers: {
	  Authorization: config.token
	}
      }
    ).then((x) => x.json())
     .then((y) => processNamedAppDomain(y));
  }

  const getDomains = () => {
    appDomains.length = 0;
    let url = config.portalUrl + config.applicationDomainSuffix;
    allAppDomains = fetch(
        url,
        {
          headers: {
            Authorization: config.token
          } 
        }
    ).then((x) => x.json())
     .then((y) => processApplicationDomains(y));
  };
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
</style>

<div id="getAD" style="width:100%;display:{gotAD}">
<div style="width:100%">
<p>Stage 1: Select your Application Domain.</p>Instructions:
<ol>
<li>Check the Event Portal URL is correct and enter your access token
<li>If you have a name for the Application Domain of interest, enter them and click "Get Named Domain"
<li>Otherwise, click "Get Application Domains".  You'll be presented with a list of Application Domains.  Click on those you're interested in and they'll be added to the list on the right.  If you change your mind, just click on an item in the selected list and it will be deselected.
<li>Then just click the next state of the process on the Navigation bar: 2. Applications.
</ol>
</div>
<hr>

{#if displayConfig}
<div style="width:100%" transition:fade>
<table>
<tr>
<td><label for="url">Event Portal URL:</label>
<td> <input bind:value={config.portalUrl} name="url">
<td>
<td><label for="appDomId">Application Domain Name:</label>
<td><input bind:value={config.applicationDomainName} name="appDomId">
</tr>
<tr>
<td><label for="token">Access token:</label>
<td><input bind:value={config.token} name="token">
<td align=center width=10%>OR
</tr>
<tr>
<td> <button on:click="{getDomains}">
  Get All Application Domains
</button>
<td>
<td>
<td> <button on:click="{getNamedDomains}">Get Named Application Domain</button>
<td> {config.applicationDomainName} </td>
</table>
</div>
{/if}

{#if gotDomains === true}
<button on:click="{hideConfig}">
{contractButtonLabel}
</button>
<hr>
{/if}

<List promise = {allAppDomains} 
      list = {appDomains} 
      addFunc = {addSelectedAppDomain}
      displayFunc = {displayAdDescrition}
      removeFunc = {removeAdDescription} 
      hovering = {hovering}
      description = {description}
> 
</List>


{#await allAppDomains}
Getting data
{:then data}
<!-- promise was fulfilled -->

{#if selectedApps.length > 0}
  <div style="float:right">
      {#each selectedApps as showApp}
        <li 
          class="select"
	  transition:fade 
	  on:click = { () => { storeAD.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name));
	    hovering = false; } }
	  on:mouseover = { () => { displayAdDescrition(showApp) } }
	  on:mouseout  = { () => { removeAdDescription() } }
	>
	  {showApp.name}
	</li>
      {/each}
  </div>
{/if}
{:catch error}
<!-- optionally show something while promise was rejected -->
<p>Error: ${error.message}</p>
{/await}
</div>

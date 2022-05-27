<script>
  // Svelte routes workaround
  export const location=0;

  import { fade } from 'svelte/transition';

  import List from '../components/List.svelte';
  import Pagination from "../components/Pagination.svelte";
  import ApiLog from "../components/APILog.svelte";
  
  import { storeAD } from '../stores.js';
  import { storePossAD } from '../stores.js';
  import { config } from '../config.js';
  import { checkPagination } from '../pagination.js';

  let allAppDomains;
  let namedDomainData;
  let selectedApps = [];
  let appDomains = [];
  let gotDomains = false;
  let displayConfig = true;
  let contractButtonLabel = ">";
  let gotAD = "block";
  let pagination = false;
  let logString = "";
  let apiLogComponent;

  const unsubscribeSelectedAD = storeAD.subscribe(value => {
    selectedApps = value;
  });

  const unsubscribeAllAD = storePossAD.subscribe(value => {
    appDomains = value;
  });

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
    return data;
  }

  const addSelectedAppDomain = (appDomain, context) => {
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
    namedDomainData = apiLogComponent.apiGet(
      "GET",
      "Get named domain " + config.applicationDomainName,
      url,
      {
        headers: {
	  Authorization: config.token
	}
      }
    ).then( (x) => x.json() )
     .then( (y) => processNamedAppDomain(y) )
     .then( (data) =>  { pagination = checkPagination(data);
                         return data; } );
  }

  const getDomains = () => {
    appDomains.length = 0;
    let url = config.portalUrl + config.applicationDomainSuffix;
    allAppDomains = apiLogComponent.apiGet(
        "GET",
        "Get all application domains",
        url,
        {
          headers: {
            Authorization: config.token
          } 
        }
    ).then( (x) => x.json() )
     .then( (y) => processApplicationDomains(y) )
     .then( (data) => { pagination = checkPagination(data);
                        return data; } );
  };

  const removeApp = (showApp, context) => {
    storeAD.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name));
  }
</script>


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
</div>

{#if displayConfig}
<div style="width:100%" transition:fade>
<table>
<tr>
<td> <label for="url">Event Portal URL:</label>
<td> <input bind:value={config.portalUrl} name="url">
<td> <label for="appDomId">Application Domain Name:</label>
<td> <input bind:value={config.applicationDomainName} name="appDomId">
</tr>
<tr>
<td> <label for="token">Access token:</label>
<td> <input bind:value={config.token} name="token">
</tr>
<tr>
<td> <button on:click="{getDomains}">
  Get All Application Domains
</button>
<td align="center">OR
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

<div style="float:left; width:100%">
<Pagination paginated = {pagination}
            title = "Application Domains"
>
</Pagination>

<List promise = {allAppDomains} 
      list = {appDomains} 
      clickFunc = {addSelectedAppDomain}
      title = "Available domains"
> 
</List>

<List promise = {allAppDomains}
      list = {selectedApps}
      clickFunc = {removeApp}
      displayDescription = {false}
      title = "Selected domains"
>
</List>

</div>
<ApiLog title="Event Portal API"
        logString={logString}
	bind:this={apiLogComponent}>
</ApiLog>


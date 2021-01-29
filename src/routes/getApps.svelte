<script>
  import { fade } from 'svelte/transition';
  import { Link } from "svelte-routing";
  import { storeAppInfo, storeAD, storeApp } from '../stores.js';
  //TO DO: put this config in a store
  let config = {
    portalUrl: "https://solace.cloud/api/v1/eventPortal",
    token: "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1hYXNfcHJvZF8yMDIwMDMyNiIsInR5cCI6IkpXVCJ9.eyJvcmciOiJzZWFsbCIsIm9yZ1R5cGUiOiJFTlRFUlBSSVNFIiwic3ViIjoiNjd0cjh0a3VidCIsInBlcm1pc3Npb25zIjoiQUFBQUFJQUVBQUFBV3pnQUFBQUFBQUFBQUFBQUFBQUFBQUN3UUFNPSIsImFwaVRva2VuSWQiOiIxYTJudnNmMDZ3NWQiLCJpc3MiOiJTb2xhY2UgQ29ycG9yYXRpb24iLCJpYXQiOjE2MDgxMzkwNDd9.I9tX7C3vPgpjVo0rvra2-7J9eeSeYaDMA592BaQDmYU7V0vn9Zzij5hV-WgooTN49I6IhlZRCuXoIgLtN5fJQqs6dmf1luHh0piHeAsGGfQ-yuqB6m-hdTDe9hSXfrJW9QQZUZWbjPF4PBIJ5pmcAgsMEgW7OkzdMN2yW8M8R3WtY0HZENTQTvyuoZ1yOTAdDTGwgVt73eik2Eg34D8Q42Q_f0fJJUicIPdTuGZjyD5PK9-g8U32BQda13w-PtaiU7BAuZWA-Jds18huroATej_skkEP9yMlmg-F_WnETWBCaRUG28SkfUwdGt-TIYL5gZpUBmTZegKH1iMkVogVEA"
  }

  let selectedDomains = [];
  let appInfo = [];
  let applicationData;
  let description;
  let hovering = false;
  let selectedApps = [];
  let tagData;

  const unsubscribeAD = storeAD.subscribe(value => {
    selectedDomains = value;
  });

  const unsubscribeApp = storeApp.subscribe(value => {
    selectedApps = value;
  });
  
  const unsubscribeAppInfo = storeAppInfo.subscribe(value => {
    appInfo = value;
  });

  const getApps = () => {
selectedDomains.forEach(domain => {
      let url = config.portalUrl + '/applications?applicationDomainId=' + domain.id;
      applicationData = fetch(
        url,
	{
	  headers: {
	    Authorization: config.token
	  }
	}
     ).then( (x) => x.json() )
      .then( (y) => processApplications(y) );
    });
  }

  const processApplications = (data) => {
    data.data.forEach(appObj => {
      if ( appObj.consumedEventIds.length > 0 ) {
        storeAppInfo.update( data =>  [...appInfo, { name: appObj.name, 
          id: appObj.id,
	  description: appObj.description,
	  consumedEventIds: appObj.consumedEventIds
        } ] );
      }
    });
  }

  const displayAppDescrition = ( app ) => {
    hovering = true;
    description = app.description;
  }

  const removeAppDescription = () => {
    hovering = false;
  }

  const addApp = (app) => {
     console.log("App: ", app);
     if (selectedApps.filter(data => (data.name === app.name)).length === 0) {
      storeApp.update(selectedApps => [...selectedApps, app]);
      // Get tags
      let url = config.portalUrl + '/applications/' + app.id + '/tags';
      console.log("Url: ", url);
      tagData = fetch(
        url,
	{
	  headers: {
	    Authorization: config.token
	  }
	}
      ).then( (x) => x.json(x) )
       .then( (y) => processTags(y) );
    }
  }

  const processTags = (data) => {
    data.data.forEach( tag => {
      console.log("tag: ", tag);
    });
  }


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
li.domain {
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

<div style="width:100%">
<p>Stage 2: Select your Applications</p>

Each Application Domain in Event Portal can contain multiple Applications.  In the list below are all those Applications we've indentified as needing events persisted for them for later consumption.<p>

<p>Simply select those applications you'd like to deploy and continue to Stage 3.</p>
<hr>

{#if selectedDomains.length > 0 }
  <div style="float:left">
    <button on:click="{getApps}">Get Applications</button>
    {#if selectedDomains.length === 1}
      <h2>Selected Domain</h2>
    {:else}
      <h2>Selected Domains</h2>
    {/if}
    {#each selectedDomains as showDomain}
      <li class="domain">{showDomain.name}</li>
    {/each}
  </div>

{:else}
  <p><strong>You haven't selected any Application Domains!</strong></p>

<p>Please go back to the <Link to="getAD">previous step</Link> and pick at least one</p>
{/if}

{#await applicationData}
Getting Data
{:then}

<div style="float:left">
<h2>Consumers</h2>
{#each appInfo as app}
  <li 
    class="select"
    on:mouseover = { () => { displayAppDescrition(app) } }
    on:mouseout  = { () => { removeAppDescription() } }
    on:click     = { () => { addApp(app) } }
  >
    {app.name}
  </li>
{/each}
</div>

<div style="float:left">
{#if hovering}
<p transition:fade>Description: {@html description}</p>
{/if}
</div>

{#if selectedApps.length > 0}
  <div style="float:right">
      {#each selectedApps as showApp}
        <li
          class="select"
          transition:fade
          on:click = { () => { storeApp.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name));
            hovering = false; } }
          on:mouseover = { () => { displayAppDescrition(showApp) } }
          on:mouseout  = { () => { removeAppDescription() } }
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

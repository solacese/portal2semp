<script>
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { Link } from "svelte-routing";
  import { storeAppInfo, storeAD, storeApp } from '../stores.js';
  import { config } from '../config.js';
  import List from '../components/List.svelte';

  let selectedDomains = [];
  let appInfo = [];
  let applicationData;
  let selectedApps = [];
  let tagData;
  let tagDetailData;
  let tagIdCache = [];
  let gotApps = false;

  const unsubscribeAD = storeAD.subscribe(value => {
    selectedDomains = value;
  });

  const unsubscribeApp = storeApp.subscribe(value => {
    selectedApps = value;
  });
  
  const unsubscribeAppInfo = storeAppInfo.subscribe(value => {
    appInfo = value;
  });

  const test = () => {
    console.log("TESTING");
    selectedDomains = [ {
      description: "a description",
      name: "TF-sample-EP-to-runtime",
      id: "1a2mpvr5zuwb"
    } ];
    dataGot();
  }

  const dataGot = async() => {
    storeAppInfo.update(data => []);
    gotApps = await getData();
  }

  const getData = async() => {
    await getApps();
    appInfo.forEach( app => {
      app.tagIds.forEach ( tagId => {
        let cacheLine = tagIdCache.filter(x => (x.id === tagId));
	if (cacheLine[0].persistent === true) {
	  app.persistent = true;
	}
      });
    } );
    // Now we know which applications are persistent, so let's prune those
    // that aren't
    let newAppInfo = appInfo.filter(x => (x.persistent === true));
    storeAppInfo.update( x => appInfo.filter(x => (x.persistent === true) ) );
  }

  const getApps = async() => {
    applicationData = await Promise.all(
      selectedDomains.map(
        domain => fetch(
	  config.portalUrl + 'applications?applicationDomainId=' + domain.id,
	  { headers: { Authorization: config.token } }
	).then( (x) => x.json() )
	 .then( async(y) => await gotApp(y) )
	 .then( async() => await getTags() )
	 .then( async() => await getTagDetails() )
      )
    )
  }
  
  const getTags = async() => {
    tagData = await Promise.all( appInfo.map(
      app => fetch(
        config.portalUrl + 'applications/' + app.id + '/tags',
	{ headers: { Authorization: config.token } }
      ).then( (x) => x.json() )
       .then( (y) => addTag(app, y) )
    ) );
  }

  const addTag = (app, data) => {
    app.tagIds = data.data;
    data.data.forEach( tag => {
      if ( tagIdCache.filter(element => (element.id === tag)).length === 0) {
        tagIdCache.push( {id: tag, persistent: false} );
      } 
    });
  }

  const gotApp = (data) => {
    data.data.forEach ( app => {
      if (app.consumedEventIds.length > 0) {
        let newApp = { consumedEventIds: app.consumedEventIds,
          description: app.description,
	  id: app.id,
	  name: app.name,
	  tagIds: "",
	  persistent: false,
          qName: "Q_" + app.name,
          qProvisioned: false,
          subsCreated: [],
          qError: "",
          selectedEvents: [],
          consumedEventDetails: []
        };
	appInfo.push(newApp);
      }
    });
  }

  const addApp = (app, context) => {
     if (selectedApps.filter(data => (data.name === app.name)).length === 0) {
      storeApp.update(selectedApps => [...selectedApps, app]);
    }
  }

  const getTagDetails = async() => {
    // Go through tag cache and get all the tag details.
    //  Then fill out application info with these details.
    tagDetailData = await Promise.all( tagIdCache.map( 
      tagId => fetch(
        config.portalUrl + 'tags/' + tagId.id,
	{ headers: {Authorization: config.token} }
      ).then( (x) => x.json(x) )
       .then( (y) => processTagDetails(y, tagId)  )
    ));
  }

  const processTagDetails = (data, tagCacheLine) => {
    if (data.data.name === "PERSISTENT") {
      tagCacheLine.persistent = true;
    }
  }

  const removeApp = (showApp, context) => {
    storeApp.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name));
  }

  onMount( async() => { dataGot(); } );

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

</div>

<div style="float:left; width:100%">
<button on:click="{test}">Test</button>

<div style="float:left">
{#if selectedDomains.length > 0 }
    {#if selectedDomains.length === 1}
      <h2>Selected Domain</h2>
    {:else}
      <h2>Selected Domains</h2>
    {/if}
    {#each selectedDomains as showDomain}
      <li class="domain">{showDomain.name}</li>
    {/each}

{:else}
  <p><strong>You haven't selected any Application Domains!</strong></p>

<p>Please go back to the <Link to="getAD">previous step</Link> and pick at least one</p>
{/if}

</div>

<div style="float:left">
<List promise = {gotApps}
      list = {appInfo}
      clickFunc = {addApp}
      title = "Available Applications"
      displayTitle = {true}
>
</List>

<List promise = {gotApps}
      list = {selectedApps}
      clickFunc = {removeApp}
      displayDescription = {false}
      title = "Selected Applications"
>
</List>
</div>
      

</div>

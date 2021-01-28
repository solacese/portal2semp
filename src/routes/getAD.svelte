<script>
  import { fade } from 'svelte/transition';
  import { storeAD } from '../stores.js';

  let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1hYXNfcHJvZF8yMDIwMDMyNiIsInR5cCI6IkpXVCJ9.eyJvcmciOiJzZWFsbCIsIm9yZ1R5cGUiOiJFTlRFUlBSSVNFIiwic3ViIjoiNjd0cjh0a3VidCIsInBlcm1pc3Npb25zIjoiQUFBQUFJQUVBQUFBV3pnQUFBQUFBQUFBQUFBQUFBQUFBQUN3UUFNPSIsImFwaVRva2VuSWQiOiIxYTJudnNmMDZ3NWQiLCJpc3MiOiJTb2xhY2UgQ29ycG9yYXRpb24iLCJpYXQiOjE2MDgxMzkwNDd9.I9tX7C3vPgpjVo0rvra2-7J9eeSeYaDMA592BaQDmYU7V0vn9Zzij5hV-WgooTN49I6IhlZRCuXoIgLtN5fJQqs6dmf1luHh0piHeAsGGfQ-yuqB6m-hdTDe9hSXfrJW9QQZUZWbjPF4PBIJ5pmcAgsMEgW7OkzdMN2yW8M8R3WtY0HZENTQTvyuoZ1yOTAdDTGwgVt73eik2Eg34D8Q42Q_f0fJJUicIPdTuGZjyD5PK9-g8U32BQda13w-PtaiU7BAuZWA-Jds18huroATej_skkEP9yMlmg-F_WnETWBCaRUG28SkfUwdGt-TIYL5gZpUBmTZegKH1iMkVogVEA";
  let portalUrl = "https://solace.cloud/api/v1/eventPortal/";
  let applicationDomainSuffix = "applicationDomains";
  let applicationDomainName = "TF-sample-EP-to-runtime";
  let allAppDomains;
  let selectedApps = [];
  let appDomains = [];
  let gotDomains = false;
  let displayConfig = true;
  let contractButtonLabel = ">";
  let gotAD = "block";

  const unsubscribe = storeAD.subscribe(value => {
    selectedApps = value;
  });

  const processApplicationDomains = (data) => {
    data.data.forEach(appObj => {
      appDomains = [...appDomains, { name: appObj.name, id: appObj.id}];
    });
    gotDomains = true;
    displayConfig = !displayConfig;
    return data;
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
    storeAD.set([]);
    let url = portalUrl + applicationDomainSuffix + "?name=" + applicationDomainName;
    console.log("Url: ", url);
    gotAD = "none";
  }

  const getDomains = () => {
    appDomains.length = 0;
    let url = portalUrl + applicationDomainSuffix;
    allAppDomains = fetch(
        url,
        {
          headers: {
            Authorization: token
          } 
        }
    ).then((x) => x.json())
     .then((y) => processApplicationDomains(y));
  };
</script>

<style>
div {
  margin: 0 0 2em 0;
  list-style-type: none;
  padding: 0;
  width: 15em;
}
li.plain {
  background-color: #ffffff;
}
li {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #e6ffe6;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
li:hover {
  color: #607D8B;
  background-color: #99ff99;
  left: .1em;
}
li.selected {
  background-color: #CFD8DC;
  color: white;
}
li.selected:hover {
  background-color: #BBD8DC;
  color: white;
}
label {
  text-align: right;
  clear: both;
  float: left;
  margin-right: 15px;
}
input {
  float: right;
}
</style>

<div id="getAD" style="width:100%;display:{gotAD}">
<div style="width:100%">
<p>Stage 1: Select your Application Domain.</p>Instructions:
<ol>
<li class="plain">Check the Event Portal URL is correct and enter your access token
<li class="plain">If you have a name for the Application Domain of interest, enter them and click "Get Named Domain"
<li class="plain">Otherwise, click "Get Application Domains".  You'll be presented with a list of Application Domains.  Click on those you're interested in and they'll be added to the list on the right.  If you change your mind, just click on an item in the selected list and it will be deselected.
</ol>
</div>
<hr>

{#if displayConfig}
<div style="width:100%" transition:fade>
<table>
<tr>
<td><label for="url">Event Portal URL:</label>
<td> <input bind:value={portalUrl} name="url">
<td>
<td><label for="appDomId">Application Domain Name:</label>
<td><input bind:value={applicationDomainName} name="appDomId">
</tr>
<tr>
<td><label for="token">Access token:</label>
<td><input bind:value={token} name="token">
<td align=center width=10%>OR
</tr>
<tr>
<td> <button on:click="{getDomains}">
  Get All Application Domains
</button>
<td>
<td>
<td> <button on:click="{getNamedDomains}">Get Named Application Domain</button>
<td> {applicationDomainName} </td>
</table>
</div>
{/if}

{#if gotDomains === true}
<button on:click="{hideConfig}">
{contractButtonLabel}
</button>
<hr>
{/if}

{#await allAppDomains}
Getting data
{:then data}
<!-- promise was fulfilled -->
<div style="float:left">
{#each appDomains as app}
  <li on:click={() => addSelectedAppDomain(app)}>{app.name}</li>
{/each}
</div>

{#if selectedApps.length > 0}
  <div style="float:right">
      {#each selectedApps as showApp}
        <li transition:fade on:click={() => { storeAD.update(selectedApps => selectedApps.filter(data => data.name!=showApp.name)) } }>{showApp.name}</li>
      {/each}
  </div>
{/if}
{:catch error}
<!-- optionally show something while promise was rejected -->
<p>Error: ${error.message}</p>
{/await}
</div>

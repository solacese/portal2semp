<script>
  import { Link } from "svelte-routing";
  import { storeAD } from '../stores.js';
  //TO DO: put this config in a store
  let config = {
    portalUrl: "https://solace.cloud/api/v1/eventPortal/applications",
    token: "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1hYXNfcHJvZF8yMDIwMDMyNiIsInR5cCI6IkpXVCJ9.eyJvcmciOiJzZWFsbCIsIm9yZ1R5cGUiOiJFTlRFUlBSSVNFIiwic3ViIjoiNjd0cjh0a3VidCIsInBlcm1pc3Npb25zIjoiQUFBQUFJQUVBQUFBV3pnQUFBQUFBQUFBQUFBQUFBQUFBQUN3UUFNPSIsImFwaVRva2VuSWQiOiIxYTJudnNmMDZ3NWQiLCJpc3MiOiJTb2xhY2UgQ29ycG9yYXRpb24iLCJpYXQiOjE2MDgxMzkwNDd9.I9tX7C3vPgpjVo0rvra2-7J9eeSeYaDMA592BaQDmYU7V0vn9Zzij5hV-WgooTN49I6IhlZRCuXoIgLtN5fJQqs6dmf1luHh0piHeAsGGfQ-yuqB6m-hdTDe9hSXfrJW9QQZUZWbjPF4PBIJ5pmcAgsMEgW7OkzdMN2yW8M8R3WtY0HZENTQTvyuoZ1yOTAdDTGwgVt73eik2Eg34D8Q42Q_f0fJJUicIPdTuGZjyD5PK9-g8U32BQda13w-PtaiU7BAuZWA-Jds18huroATej_skkEP9yMlmg-F_WnETWBCaRUG28SkfUwdGt-TIYL5gZpUBmTZegKH1iMkVogVEA"
  }

  let selectedDomains = [];
  let appInfo = [];
  let applicationData;

  const unsubscribe = storeAD.subscribe(value => {
    selectedDomains = value;
  });

  const getApps = () => {
    selectedDomains.forEach(domain => {
      let url = config.portalUrl + '?applicationDomainId=' + domain.id;
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
      appInfo = [...appInfo, { name: appObj.name, 
        id: appObj.id,
	description: appObj.description,
	consumedEventIds: appObj.consumedEventIds
      }];
    });
  }
</script>

<p>Stage 2: Select you Applications</p>

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
      <li>{showDomain.name}</li>
    {/each}
  </div>

{:else}
  <p><strong>You haven't selected any Application Domains!</strong></p>

<p>Please go back to the <Link to="getAD">previous step</Link> and pick at least one</p>
{/if}

{#await applicationData}
Getting Data
{:then}

{#each appInfo as app}
  <li>{app.name}</li>
{/each}

{:catch error}
<!-- optionally show something while promise was rejected -->
<p>Error: ${error.message}</p>
{/await}

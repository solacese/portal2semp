<script>
  import 'getAD.css';
  let name = 'world';
  let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1hYXNfcHJvZF8yMDIwMDMyNiIsInR5cCI6IkpXVCJ9.eyJvcmciOiJzZWFsbCIsIm9yZ1R5cGUiOiJFTlRFUlBSSVNFIiwic3ViIjoiNjd0cjh0a3VidCIsInBlcm1pc3Npb25zIjoiQUFBQUFJQUVBQUFBV3pnQUFBQUFBQUFBQUFBQUFBQUFBQUN3UUFNPSIsImFwaVRva2VuSWQiOiIxYTJudnNmMDZ3NWQiLCJpc3MiOiJTb2xhY2UgQ29ycG9yYXRpb24iLCJpYXQiOjE2MDgxMzkwNDd9.I9tX7C3vPgpjVo0rvra2-7J9eeSeYaDMA592BaQDmYU7V0vn9Zzij5hV-WgooTN49I6IhlZRCuXoIgLtN5fJQqs6dmf1luHh0piHeAsGGfQ-yuqB6m-hdTDe9hSXfrJW9QQZUZWbjPF4PBIJ5pmcAgsMEgW7OkzdMN2yW8M8R3WtY0HZENTQTvyuoZ1yOTAdDTGwgVt73eik2Eg34D8Q42Q_f0fJJUicIPdTuGZjyD5PK9-g8U32BQda13w-PtaiU7BAuZWA-Jds18huroATej_skkEP9yMlmg-F_WnETWBCaRUG28SkfUwdGt-TIYL5gZpUBmTZegKH1iMkVogVEA";
  let portalUrl = "https://solace.cloud/api/v1/eventPortal/";
  let applicationDomainSuffix = "applicationDomains";
  let promise;
  let selectedApps = [];
  let appDomains = [];
  function processApplicationDomains(data) {
    data.data.forEach(appObj => {
      let obj = { [appObj.name]: appObj.id};
      appDomains = [...appDomains, { name: appObj.name, id: appObj.id}];
    });
    console.log(appDomains);
    return data;
  }
  const handleClick = () => {
    appDomains.length = 0;
    let url = portalUrl + applicationDomainSuffix;
    console.log("Url: ", url);
    promise = fetch(
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
li {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #EEE;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
li:hover {
  color: #607D8B;
  background-color: #DDD;
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
badge {
  display: inline-block;
  font-size: small;
  color: white;
  padding: 0.8em 0.7em 0 0.7em;
  background-color:#405061;
  line-height: 1em;
  position: relative;
  left: -1px;
  top: -4px;
  height: 1.8em;
  margin-right: .8em;
  border-radius: 4px 0 0 4px;
}
</style>


<div>
<label for="url">Event Portal URL:</label>
<input bind:value={portalUrl}>

<button on:click="{handleClick}">
  Click to Load Data
</button>
</div>

{#await promise}
<!-- optionally show something while promise is pending -->
Getting data
{:then data}
<!-- promise was fulfilled -->
<div style="float:left">
{#each appDomains as app}
<label>
  <input type=checkbox bind:group={selectedApps} value={app.name}> {app.name}
</label>
{/each}
</div>

{#if selectedApps.length > 0}
  <div style="float:right">
    <li>
      {#each selectedApps as showApp}
        <li>{showApp}</li>
      {/each}
    </li>
  </div>
{/if}
{:catch error}
<!-- optionally show something while promise was rejected -->
<p>Error: ${error.message}</p>
{/await}
